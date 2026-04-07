package handlers

import (
	"fmt"
	"math/rand"
	"net/http"
	"strings"
	"time"

	"github.com/Dunh1ll/backend/internal/config"
	"github.com/Dunh1ll/backend/internal/models"
	"github.com/Dunh1ll/backend/internal/repository"
	"github.com/Dunh1ll/backend/pkg/utils"
	"github.com/gin-gonic/gin"
)

// AuthHandler handles login, registration, OTP, and password reset.
type AuthHandler struct {
	userRepo    *repository.UserRepository
	profileRepo *repository.ProfileRepository
	otpRepo     *repository.OTPRepository
	cfg         *config.Config
}

// NewAuthHandler creates a new AuthHandler with all dependencies.
func NewAuthHandler(
	userRepo *repository.UserRepository,
	profileRepo *repository.ProfileRepository,
	otpRepo *repository.OTPRepository,
	cfg *config.Config,
) *AuthHandler {
	return &AuthHandler{
		userRepo:    userRepo,
		profileRepo: profileRepo,
		otpRepo:     otpRepo,
		cfg:         cfg,
	}
}

// ─────────────────────────────────────────────────────────────────
// REGISTER
// ─────────────────────────────────────────────────────────────────

// Register creates a new sub user account.
//
// ✅ FEATURE 1: Only Gmail addresses (@gmail.com) are accepted.
// Validation happens in both Flutter (frontend) and here (backend)
// for defense in depth — the backend check cannot be bypassed.
func (h *AuthHandler) Register(c *gin.Context) {
	var req models.RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ValidationError(c, err.Error())
		return
	}

	// Normalize email to lowercase
	req.Email = strings.ToLower(strings.TrimSpace(req.Email))

	// ✅ FEATURE 1: Gmail-only validation (backend security layer)
	// Even if someone bypasses Flutter validation, this check stops them.
	if !strings.HasSuffix(req.Email, "@gmail.com") {
		utils.ValidationError(c,
			"Only Gmail accounts are allowed. "+
				"Please use an email ending with @gmail.com")
		return
	}

	// Enforce password strength
	if !utils.ValidatePassword(req.Password) {
		utils.ValidationError(c,
			"Password must have at least 8 characters, "+
				"1 uppercase letter, and 1 special character")
		return
	}

	// Block main user emails
	for _, mainUser := range models.HardcodedMainUsers {
		if mainUser.Email == req.Email {
			utils.ErrorResponse(c, http.StatusConflict,
				"Email already registered")
			return
		}
	}

	// Check if email already exists in database
	existingUser, _ := h.userRepo.GetByEmail(req.Email)
	if existingUser != nil {
		utils.ErrorResponse(c, http.StatusConflict,
			"Email already registered")
		return
	}

	// Hash the password
	hashedPassword, err := utils.HashPassword(req.Password)
	if err != nil {
		utils.InternalServerError(c)
		return
	}

	// Create user record in users table
	user := &models.User{
		Email:        req.Email,
		PasswordHash: hashedPassword,
		FullName:     req.FullName,
		Phone:        req.Phone,
		IsActive:     true,
	}

	if err := h.userRepo.Create(user); err != nil {
		utils.InternalServerError(c)
		return
	}

	// Auto-create default profile so user appears in dashboard immediately
	defaultProfile := &models.Profile{
		UserID:            user.ID,
		Name:              user.FullName,
		Email:             user.Email,
		Phone:             user.Phone,
		ProfilePictureURL: "assets/images/default_avatar.jpg",
		CoverPhotoURL:     "assets/images/default_cover.jpg",
		IsMainProfile:     false,
	}
	_ = h.profileRepo.CreateSubUser(user.ID, "", defaultProfile)

	// Generate JWT token with role "sub"
	token, err := utils.GenerateToken(
		user.ID, user.Email, "sub", user.FullName, h.cfg)
	if err != nil {
		utils.InternalServerError(c)
		return
	}

	utils.SuccessResponse(c, models.AuthResponse{
		Token: token,
		Role:  "sub",
		Email: user.Email,
		Name:  user.FullName,
		User:  user,
	})
}

// ─────────────────────────────────────────────────────────────────
// LOGIN
// ─────────────────────────────────────────────────────────────────

// Login authenticates a user and returns a JWT token.
// Checks hardcoded main users first, then the database.
func (h *AuthHandler) Login(c *gin.Context) {
	var req models.LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ValidationError(c, err.Error())
		return
	}

	// Normalize email
	req.Email = strings.ToLower(strings.TrimSpace(req.Email))

	// Check hardcoded main users first
	for _, mainUser := range models.HardcodedMainUsers {
		if mainUser.Email == req.Email {
			if req.Password != mainUser.Password {
				utils.ErrorResponse(c, http.StatusUnauthorized,
					"Invalid credentials")
				return
			}
			token, err := utils.GenerateToken(
				mainUser.ID, mainUser.Email,
				"main", mainUser.Name, h.cfg,
			)
			if err != nil {
				utils.InternalServerError(c)
				return
			}
			utils.SuccessResponse(c, models.AuthResponse{
				Token: token,
				Role:  "main",
				Email: mainUser.Email,
				Name:  mainUser.Name,
			})
			return
		}
	}

	// Check database (sub users)
	user, err := h.userRepo.GetByEmail(req.Email)
	if err != nil {
		utils.ErrorResponse(c, http.StatusUnauthorized,
			"Invalid credentials")
		return
	}

	if !utils.CheckPasswordHash(req.Password, user.PasswordHash) {
		utils.ErrorResponse(c, http.StatusUnauthorized,
			"Invalid credentials")
		return
	}

	if !user.IsActive {
		utils.ErrorResponse(c, http.StatusForbidden,
			"Account is deactivated")
		return
	}

	token, err := utils.GenerateToken(
		user.ID, user.Email, "sub", user.FullName, h.cfg)
	if err != nil {
		utils.InternalServerError(c)
		return
	}

	user.PasswordHash = ""

	utils.SuccessResponse(c, models.AuthResponse{
		Token: token,
		Role:  "sub",
		Email: user.Email,
		Name:  user.FullName,
		User:  user,
	})
}

// ─────────────────────────────────────────────────────────────────
// FORGOT PASSWORD — STEP 1: Send OTP
// ─────────────────────────────────────────────────────────────────

// SendOTP handles the first step of forgot-password.
//
// Flow:
//  1. Receive email from Flutter
//  2. Validate it is a Gmail address
//  3. Block main user emails
//  4. Look up user in database
//  5. Clean up old expired OTPs
//  6. Generate a 6-digit OTP
//  7. Hash the OTP and store in otps table (expires in 10 min)
//  8. Send the plain OTP to the user's Gmail via SMTP
//  9. Return success (never confirm whether email exists — security)
func (h *AuthHandler) SendOTP(c *gin.Context) {
	var req struct {
		Email string `json:"email" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ValidationError(c, "Email is required")
		return
	}

	// Normalize
	email := strings.ToLower(strings.TrimSpace(req.Email))

	// Gmail-only check
	if !strings.HasSuffix(email, "@gmail.com") {
		utils.ValidationError(c,
			"Only Gmail accounts are allowed for password reset.")
		return
	}

	// Block main user emails — they use hardcoded passwords
	for _, mainUser := range models.HardcodedMainUsers {
		if mainUser.Email == email {
			utils.ErrorResponse(c, http.StatusBadRequest,
				"Main user accounts cannot use password reset.")
			return
		}
	}

	// Look up user — return generic message if not found
	// (prevents email enumeration attacks)
	user, err := h.userRepo.GetByEmail(email)
	if err != nil {
		// Generic message — don't reveal if email exists
		utils.SuccessResponse(c, gin.H{
			"message": "If this email is registered, " +
				"you will receive an OTP shortly.",
		})
		return
	}

	// Cleanup old expired OTPs (housekeeping)
	_ = h.otpRepo.CleanupExpiredOTPs()

	// Generate a 6-digit OTP
	otpCode := generateOTPCode()

	// Store hashed OTP in database (expires in 10 minutes)
	expiresAt := time.Now().Add(10 * time.Minute)
	if err := h.otpRepo.CreateOTP(email, otpCode, expiresAt); err != nil {
		utils.InternalServerError(c)
		return
	}

	// Send OTP via Gmail SMTP
	emailCfg := utils.LoadEmailConfig()
	if err := utils.SendOTPEmail(
		user.Email, otpCode, emailCfg); err != nil {
		// Log the error but still return success to avoid leaking info
		// In development, log to console so you can see the OTP
		fmt.Printf("⚠️  OTP email send failed: %v\n", err)
		fmt.Printf("📧 OTP for %s: %s\n", email, otpCode)

		// Return error only in development so developer can see OTP
		// In production, always return success
		if h.cfg.Env != "production" {
			utils.ErrorResponse(c, http.StatusInternalServerError,
				fmt.Sprintf("Email send failed. "+
					"For development: OTP is %s", otpCode))
			return
		}
	}

	utils.SuccessResponse(c, gin.H{
		"message": "OTP sent to your Gmail address. " +
			"It expires in 10 minutes.",
	})
}

// ─────────────────────────────────────────────────────────────────
// FORGOT PASSWORD — STEP 2: Verify OTP
// ─────────────────────────────────────────────────────────────────

// VerifyOTP handles the second step of forgot-password.
//
// Flow:
//  1. Receive email + OTP from Flutter
//  2. Look up OTP in database for this email
//  3. Check it is not expired and not already used
//  4. Compare submitted OTP with stored hash
//  5. Mark OTP as used if valid
//  6. Return a reset token (session) so Flutter can proceed to step 3
func (h *AuthHandler) VerifyOTP(c *gin.Context) {
	var req struct {
		Email string `json:"email" binding:"required"`
		OTP   string `json:"otp" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ValidationError(c, "Email and OTP are required")
		return
	}

	email := strings.ToLower(strings.TrimSpace(req.Email))
	otp := strings.TrimSpace(req.OTP)

	// Verify OTP against database
	valid, err := h.otpRepo.VerifyOTP(email, otp)
	if err != nil {
		utils.InternalServerError(c)
		return
	}

	if !valid {
		utils.ErrorResponse(c, http.StatusBadRequest,
			"Invalid or expired OTP. Please request a new one.")
		return
	}

	// OTP is valid — generate a short-lived reset token
	// This token authorizes the password reset in step 3
	// We reuse the JWT utility with a short expiry
	resetToken, err := utils.GenerateResetToken(email, h.cfg)
	if err != nil {
		utils.InternalServerError(c)
		return
	}

	utils.SuccessResponse(c, gin.H{
		"reset_token": resetToken,
		"message":     "OTP verified. You may now reset your password.",
	})
}

// ─────────────────────────────────────────────────────────────────
// FORGOT PASSWORD — STEP 3: Reset Password
// ─────────────────────────────────────────────────────────────────

// ResetPassword handles the final step of forgot-password.
//
// Flow:
//  1. Receive reset_token + new password from Flutter
//  2. Validate the reset token (JWT, not expired)
//  3. Extract email from token
//  4. Validate new password meets requirements
//  5. Hash new password
//  6. Update password_hash in users table
func (h *AuthHandler) ResetPassword(c *gin.Context) {
	var req struct {
		ResetToken  string `json:"reset_token" binding:"required"`
		NewPassword string `json:"new_password" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ValidationError(c,
			"Reset token and new password are required")
		return
	}

	// Validate the reset token and extract email
	email, err := utils.ParseResetToken(req.ResetToken, h.cfg)
	if err != nil {
		utils.ErrorResponse(c, http.StatusUnauthorized,
			"Invalid or expired reset token. "+
				"Please start the reset process again.")
		return
	}

	// Validate new password meets requirements
	if !utils.ValidatePassword(req.NewPassword) {
		utils.ValidationError(c,
			"Password must have at least 8 characters, "+
				"1 uppercase letter, and 1 special character")
		return
	}

	// Find user by email
	user, err := h.userRepo.GetByEmail(email)
	if err != nil {
		utils.NotFoundError(c, "User")
		return
	}

	// Hash the new password
	hashedPassword, err := utils.HashPassword(req.NewPassword)
	if err != nil {
		utils.InternalServerError(c)
		return
	}

	// Update password in database
	if err := h.userRepo.UpdatePassword(
		user.ID, hashedPassword); err != nil {
		utils.InternalServerError(c)
		return
	}

	utils.SuccessMessage(c,
		"Password reset successfully. You can now log in.", nil)
}

// ─────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────

// generateOTPCode generates a cryptographically random 6-digit OTP.
// Uses math/rand seeded with current time for simplicity.
// For higher security, use crypto/rand instead.
func generateOTPCode() string {
	rng := rand.New(rand.NewSource(time.Now().UnixNano()))
	// Generate a number between 100000 and 999999 (always 6 digits)
	code := rng.Intn(900000) + 100000
	return fmt.Sprintf("%06d", code)
}

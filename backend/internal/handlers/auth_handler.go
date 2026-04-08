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

// NewAuthHandler creates a new AuthHandler.
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
// REGISTER — Step 1: Send OTP to Gmail before creating account
// ─────────────────────────────────────────────────────────────────

// RegisterSendOTP is the first step of the new registration flow.
//
// FLOW:
//  1. Receive name + email + password + phone
//  2. Validate Gmail-only email
//  3. Check email not already registered
//  4. Validate password strength
//  5. Store the pending registration data temporarily in OTP table
//     (we re-validate everything in step 2 so nothing is committed yet)
//  6. Generate OTP, store hashed in otps table
//  7. Send OTP to Gmail
//
// NOTE: No user is created yet. Creation happens in RegisterVerifyOTP.
func (h *AuthHandler) RegisterSendOTP(c *gin.Context) {
	var req models.RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ValidationError(c, err.Error())
		return
	}

	// Normalize email
	req.Email = strings.ToLower(strings.TrimSpace(req.Email))

	// Gmail-only enforcement
	if !strings.HasSuffix(req.Email, "@gmail.com") {
		utils.ValidationError(c,
			"Only Gmail accounts are allowed. "+
				"Please use an email ending with @gmail.com")
		return
	}

	// Validate password strength upfront
	if !utils.ValidatePassword(req.Password) {
		utils.ValidationError(c,
			"Password must have at least 8 characters, "+
				"1 uppercase letter, and 1 special character")
		return
	}

	// Block main user emails
	for _, mu := range models.HardcodedMainUsers {
		if mu.Email == req.Email {
			utils.ErrorResponse(c, http.StatusConflict,
				"Email already registered")
			return
		}
	}

	// Check if already registered in database
	existing, _ := h.userRepo.GetByEmail(req.Email)
	if existing != nil {
		utils.ErrorResponse(c, http.StatusConflict,
			"Email already registered. "+
				"Please use a different Gmail address.")
		return
	}

	// Cleanup old OTPs for this email
	_ = h.otpRepo.CleanupExpiredOTPs()

	// Generate 6-digit OTP
	otpCode := generateOTPCode()

	// Store hashed OTP (10 min expiry)
	expiresAt := time.Now().Add(10 * time.Minute)
	if err := h.otpRepo.CreateOTP(
		req.Email, otpCode, expiresAt); err != nil {
		utils.InternalServerError(c)
		return
	}

	// Send OTP via Gmail SMTP
	emailCfg := utils.LoadEmailConfig()
	if err := utils.SendOTPEmail(
		req.Email, otpCode, emailCfg, "register"); err != nil {
		// In development: log and return OTP so developer can test
		fmt.Printf("⚠️  OTP email send failed: %v\n", err)
		fmt.Printf("📧 Registration OTP for %s: %s\n",
			req.Email, otpCode)

		if h.cfg.Env != "production" {
			utils.ErrorResponse(c, http.StatusInternalServerError,
				fmt.Sprintf("Email send failed. "+
					"Development OTP: %s", otpCode))
			return
		}
	}

	utils.SuccessResponse(c, gin.H{
		"message": "OTP sent to your Gmail. " +
			"Enter it to complete registration.",
		"email": req.Email,
	})
}

// RegisterVerifyOTP is the second and final step of registration.
//
// FLOW:
//  1. Receive name + email + password + phone + OTP
//  2. Verify OTP against database (checks expiry + used flag)
//  3. Re-validate Gmail, password strength, email uniqueness
//  4. Create user account (users table)
//  5. Auto-create default profile (profiles table)
//  6. Generate JWT token
//  7. Return token + user info (user is logged in immediately)
func (h *AuthHandler) RegisterVerifyOTP(c *gin.Context) {
	var req struct {
		FullName string `json:"full_name" binding:"required"`
		Email    string `json:"email"     binding:"required"`
		Password string `json:"password"  binding:"required"`
		Phone    string `json:"phone"`
		OTP      string `json:"otp"       binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ValidationError(c, err.Error())
		return
	}

	// Normalize
	req.Email = strings.ToLower(strings.TrimSpace(req.Email))
	req.OTP = strings.TrimSpace(req.OTP)

	// Gmail-only (second layer of defense)
	if !strings.HasSuffix(req.Email, "@gmail.com") {
		utils.ValidationError(c,
			"Only Gmail accounts are allowed.")
		return
	}

	// Verify OTP — this also marks it as used on success
	valid, err := h.otpRepo.VerifyOTP(req.Email, req.OTP)
	if err != nil {
		utils.InternalServerError(c)
		return
	}
	if !valid {
		utils.ErrorResponse(c, http.StatusBadRequest,
			"Invalid or expired OTP. "+
				"Please request a new code.")
		return
	}

	// Re-check email not taken (race condition guard)
	existing, _ := h.userRepo.GetByEmail(req.Email)
	if existing != nil {
		utils.ErrorResponse(c, http.StatusConflict,
			"Email already registered.")
		return
	}

	// Re-validate password
	if !utils.ValidatePassword(req.Password) {
		utils.ValidationError(c,
			"Password must have at least 8 characters, "+
				"1 uppercase letter, and 1 special character")
		return
	}

	// Hash password
	hashedPassword, err := utils.HashPassword(req.Password)
	if err != nil {
		utils.InternalServerError(c)
		return
	}

	// Create user record
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

	// Auto-create default profile
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

	// Generate JWT
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

func (h *AuthHandler) Login(c *gin.Context) {
	var req models.LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ValidationError(c, err.Error())
		return
	}
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
				"main", mainUser.Name, h.cfg)
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
// FORGOT PASSWORD — Step 1: Send OTP
// ─────────────────────────────────────────────────────────────────

func (h *AuthHandler) SendOTP(c *gin.Context) {
	var req struct {
		Email string `json:"email" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ValidationError(c, "Email is required")
		return
	}

	email := strings.ToLower(strings.TrimSpace(req.Email))

	if !strings.HasSuffix(email, "@gmail.com") {
		utils.ValidationError(c,
			"Only Gmail accounts can use password reset.")
		return
	}

	// Block main users
	for _, mu := range models.HardcodedMainUsers {
		if mu.Email == email {
			utils.ErrorResponse(c, http.StatusBadRequest,
				"Main user accounts cannot use password reset.")
			return
		}
	}

	// Generic response if not found (prevent enumeration)
	user, err := h.userRepo.GetByEmail(email)
	if err != nil {
		utils.SuccessResponse(c, gin.H{
			"message": "If this email is registered, " +
				"you will receive an OTP shortly.",
		})
		return
	}

	_ = h.otpRepo.CleanupExpiredOTPs()

	otpCode := generateOTPCode()
	expiresAt := time.Now().Add(10 * time.Minute)
	if err := h.otpRepo.CreateOTP(email, otpCode, expiresAt); err != nil {
		utils.InternalServerError(c)
		return
	}

	emailCfg := utils.LoadEmailConfig()
	if err := utils.SendOTPEmail(
		user.Email, otpCode, emailCfg, "reset"); err != nil {
		fmt.Printf("⚠️  OTP email send failed: %v\n", err)
		fmt.Printf("📧 Reset OTP for %s: %s\n", email, otpCode)

		if h.cfg.Env != "production" {
			utils.ErrorResponse(c, http.StatusInternalServerError,
				fmt.Sprintf("Email send failed. "+
					"Development OTP: %s", otpCode))
			return
		}
	}

	utils.SuccessResponse(c, gin.H{
		"message": "OTP sent to your Gmail address. " +
			"It expires in 10 minutes.",
	})
}

// ─────────────────────────────────────────────────────────────────
// FORGOT PASSWORD — Step 2: Verify OTP
// ─────────────────────────────────────────────────────────────────

func (h *AuthHandler) VerifyOTP(c *gin.Context) {
	var req struct {
		Email string `json:"email" binding:"required"`
		OTP   string `json:"otp"   binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ValidationError(c, "Email and OTP are required")
		return
	}

	email := strings.ToLower(strings.TrimSpace(req.Email))
	otp := strings.TrimSpace(req.OTP)

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
// FORGOT PASSWORD — Step 3: Reset Password
// ─────────────────────────────────────────────────────────────────

func (h *AuthHandler) ResetPassword(c *gin.Context) {
	var req struct {
		ResetToken  string `json:"reset_token"  binding:"required"`
		NewPassword string `json:"new_password" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ValidationError(c,
			"Reset token and new password are required")
		return
	}

	email, err := utils.ParseResetToken(req.ResetToken, h.cfg)
	if err != nil {
		utils.ErrorResponse(c, http.StatusUnauthorized,
			"Invalid or expired reset token. "+
				"Please start the reset process again.")
		return
	}

	if !utils.ValidatePassword(req.NewPassword) {
		utils.ValidationError(c,
			"Password must have at least 8 characters, "+
				"1 uppercase letter, and 1 special character")
		return
	}

	user, err := h.userRepo.GetByEmail(email)
	if err != nil {
		utils.NotFoundError(c, "User")
		return
	}

	hashedPassword, err := utils.HashPassword(req.NewPassword)
	if err != nil {
		utils.InternalServerError(c)
		return
	}

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

func generateOTPCode() string {
	rng := rand.New(rand.NewSource(time.Now().UnixNano()))
	code := rng.Intn(900000) + 100000
	return fmt.Sprintf("%06d", code)
}

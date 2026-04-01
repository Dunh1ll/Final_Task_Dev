package handlers

import (
	"net/http"

	"github.com/Dunh1ll/backend/internal/config"
	"github.com/Dunh1ll/backend/internal/models"
	"github.com/Dunh1ll/backend/internal/repository"
	"github.com/Dunh1ll/backend/pkg/utils"
	"github.com/gin-gonic/gin"
)

// AuthHandler handles login and registration endpoints.
type AuthHandler struct {
	userRepo    *repository.UserRepository
	profileRepo *repository.ProfileRepository
	cfg         *config.Config
}

// NewAuthHandler creates a new AuthHandler with its dependencies.
func NewAuthHandler(
	userRepo *repository.UserRepository,
	profileRepo *repository.ProfileRepository,
	cfg *config.Config,
) *AuthHandler {
	return &AuthHandler{
		userRepo:    userRepo,
		profileRepo: profileRepo,
		cfg:         cfg,
	}
}

// Register creates a new sub user account.
//
// Flow:
//  1. Validate request body
//  2. Check password meets requirements
//  3. Block registration with a main user email
//  4. Check email is not already in use
//  5. Hash the password
//  6. Create user record in database
//  7. Auto-create a default profile (so user appears in sub dashboard immediately)
//  8. Generate JWT token with role "sub"
//  9. Return token + user info
func (h *AuthHandler) Register(c *gin.Context) {
	var req models.RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ValidationError(c, err.Error())
		return
	}

	// Enforce password strength requirements
	if !utils.ValidatePassword(req.Password) {
		utils.ValidationError(c,
			"Password must have at least 8 characters, 1 uppercase letter, and 1 special character")
		return
	}

	// Prevent registering with a main user email address
	// This would cause confusion because main users don't use DB auth
	for _, mainUser := range models.HardcodedMainUsers {
		if mainUser.Email == req.Email {
			utils.ErrorResponse(c, http.StatusConflict, "Email already registered")
			return
		}
	}

	// Check the email is not already registered as a sub user
	existingUser, _ := h.userRepo.GetByEmail(req.Email)
	if existingUser != nil {
		utils.ErrorResponse(c, http.StatusConflict, "Email already registered")
		return
	}

	// Hash the password before storing — never store plain text
	hashedPassword, err := utils.HashPassword(req.Password)
	if err != nil {
		utils.InternalServerError(c)
		return
	}

	// Create the user record in the users table
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

	// Auto-create a default profile for the new user.
	// This ensures they appear in the sub dashboard immediately
	// after registration without needing to manually create a profile.
	defaultProfile := &models.Profile{
		UserID:            user.ID,
		Name:              user.FullName,
		Email:             user.Email,
		Phone:             user.Phone,
		ProfilePictureURL: "assets/images/default_avatar.jpg",
		CoverPhotoURL:     "assets/images/default_cover.jpg",
		IsMainProfile:     false,
	}
	// Silently ignore errors — registration should still succeed
	_ = h.profileRepo.CreateSubUser(user.ID, "", defaultProfile)

	// Generate JWT token with role "sub"
	token, err := utils.GenerateToken(user.ID, user.Email, "sub", user.FullName, h.cfg)
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

// Login authenticates a user and returns a JWT token.
//
// Flow:
//  1. Validate request body
//  2. Check hardcoded main users first (by email match)
//  3. If main user: compare plain text password directly
//  4. If not main user: look up in database and verify hashed password
//  5. Return token with correct role ("main" or "sub")
//
// The role embedded in the token controls all permissions in the Flutter app.
func (h *AuthHandler) Login(c *gin.Context) {
	var req models.LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ValidationError(c, err.Error())
		return
	}

	// ── Step 1: Check hardcoded main users ────────────────────────
	// Main users are not in the database — their credentials are
	// defined in HardcodedMainUsers in models.go.
	for _, mainUser := range models.HardcodedMainUsers {
		if mainUser.Email == req.Email {
			// Compare plain text password (main users don't use bcrypt)
			if req.Password != mainUser.Password {
				utils.ErrorResponse(c, http.StatusUnauthorized, "Invalid credentials")
				return
			}

			// Generate token with role "main"
			token, err := utils.GenerateToken(
				mainUser.ID,
				mainUser.Email,
				"main",
				mainUser.Name,
				h.cfg,
			)
			if err != nil {
				utils.InternalServerError(c)
				return
			}

			// Return without User field — main users have no DB record
			utils.SuccessResponse(c, models.AuthResponse{
				Token: token,
				Role:  "main",
				Email: mainUser.Email,
				Name:  mainUser.Name,
			})
			return
		}
	}

	// ── Step 2: Check database (sub users) ────────────────────────
	user, err := h.userRepo.GetByEmail(req.Email)
	if err != nil {
		// Don't reveal whether email exists — use generic message
		utils.ErrorResponse(c, http.StatusUnauthorized, "Invalid credentials")
		return
	}

	// Verify the password against the stored hash
	if !utils.CheckPasswordHash(req.Password, user.PasswordHash) {
		utils.ErrorResponse(c, http.StatusUnauthorized, "Invalid credentials")
		return
	}

	// Check the account is not deactivated
	if !user.IsActive {
		utils.ErrorResponse(c, http.StatusForbidden, "Account is deactivated")
		return
	}

	// Generate token with role "sub"
	token, err := utils.GenerateToken(user.ID, user.Email, "sub", user.FullName, h.cfg)
	if err != nil {
		utils.InternalServerError(c)
		return
	}

	// Remove hash before sending user object to client
	user.PasswordHash = ""

	utils.SuccessResponse(c, models.AuthResponse{
		Token: token,
		Role:  "sub",
		Email: user.Email,
		Name:  user.FullName,
		User:  user,
	})
}

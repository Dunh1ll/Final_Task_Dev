package handlers

import (
	"net/http"
	"time"

	"github.com/Dunh1ll/backend/internal/middleware"
	"github.com/Dunh1ll/backend/internal/models"
	"github.com/Dunh1ll/backend/internal/repository"
	"github.com/Dunh1ll/backend/pkg/utils"
	"github.com/gin-gonic/gin"
)

// ProfileHandler handles all profile-related HTTP requests.
type ProfileHandler struct {
	profileRepo *repository.ProfileRepository
	userRepo    *repository.UserRepository
}

// NewProfileHandler creates a new ProfileHandler.
// userRepo is needed because DeleteSubUser also deletes the user account.
func NewProfileHandler(
	profileRepo *repository.ProfileRepository,
	userRepo *repository.UserRepository,
) *ProfileHandler {
	return &ProfileHandler{
		profileRepo: profileRepo,
		userRepo:    userRepo,
	}
}

// GetMainProfiles returns the 3 hardcoded main profiles from the database.
// These are the profiles shown on the main carousel in Flutter.
// All authenticated users can call this endpoint.
func (h *ProfileHandler) GetMainProfiles(c *gin.Context) {
	profiles, err := h.profileRepo.GetMainProfiles()
	if err != nil {
		utils.InternalServerError(c)
		return
	}
	utils.SuccessResponse(c, profiles)
}

// GetMyProfiles returns only the profiles owned by the logged-in sub user.
// Filters by user_id so each user only sees their own profiles.
func (h *ProfileHandler) GetMyProfiles(c *gin.Context) {
	userID := middleware.GetUserID(c)

	subUsers, err := h.profileRepo.GetSubUsersByUserID(userID)
	if err != nil {
		utils.InternalServerError(c)
		return
	}

	// Return with both keys for Flutter compatibility
	utils.SuccessResponse(c, gin.H{
		"sub_users": subUsers,
		"profiles":  subUsers,
	})
}

// GetAllSubUsers returns ALL sub user profiles across all accounts.
// Restricted to main users only — sub users get 401 Unauthorized.
// Used by main users on the sub dashboard to see everyone.
func (h *ProfileHandler) GetAllSubUsers(c *gin.Context) {
	// Permission check — only main users can see all sub users
	if !middleware.IsMainUser(c) {
		utils.UnauthorizedError(c)
		return
	}

	subUsers, err := h.profileRepo.GetAllSubUsers()
	if err != nil {
		utils.InternalServerError(c)
		return
	}

	utils.SuccessResponse(c, gin.H{
		"sub_users": subUsers,
		"profiles":  subUsers,
	})
}

// GetPublicProfiles returns ALL sub user profiles for any authenticated user.
// Unlike GetAllSubUsers, this endpoint works for both main and sub users.
// Sub users can view all profiles but can only edit their own (enforced in UI + UpdateProfile).
func (h *ProfileHandler) GetPublicProfiles(c *gin.Context) {
	// Any authenticated user can call this — no role check needed
	subUsers, err := h.profileRepo.GetAllSubUsers()
	if err != nil {
		utils.InternalServerError(c)
		return
	}

	utils.SuccessResponse(c, gin.H{
		"sub_users": subUsers,
		"profiles":  subUsers,
	})
}

// GetProfile returns a single profile by its UUID.
// Used when opening the profile detail screen in Flutter.
func (h *ProfileHandler) GetProfile(c *gin.Context) {
	id := c.Param("id")

	profile, err := h.profileRepo.GetByID(id)
	if err != nil {
		utils.NotFoundError(c, "Profile")
		return
	}

	utils.SuccessResponse(c, profile)
}

// CreateSubUser creates a new sub user profile linked to the logged-in user.
//
// The profile_picture_url and cover_photo_url fields may contain
// base64 data URIs (e.g. "data:image/jpeg;base64,...") when the user
// uploads a photo. These are stored directly in the database column.
func (h *ProfileHandler) CreateSubUser(c *gin.Context) {
	userID := middleware.GetUserID(c)

	var req models.CreateSubUserRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ValidationError(c, err.Error())
		return
	}

	// Convert FlexibleDate to *time.Time for the Profile struct
	var birthday *time.Time
	if req.Birthday != nil && !req.Birthday.Time.IsZero() {
		t := req.Birthday.Time
		birthday = &t
	}

	profile := &models.Profile{
		UserID:            userID,
		Name:              req.Name,
		Bio:               req.Bio,
		Age:               req.Age,
		Gender:            req.Gender,
		YearLevel:         req.YearLevel,
		Birthday:          birthday,
		Email:             req.Email,
		Phone:             req.Phone,
		Hometown:          req.Hometown,
		ProfilePictureURL: req.ProfilePictureURL,
		CoverPhotoURL:     req.CoverPhotoURL,
		IsMainProfile:     false,
	}

	if err := h.profileRepo.CreateSubUser(userID, "", profile); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to create sub user: " + err.Error(),
		})
		return
	}

	utils.SuccessMessage(c, "Sub-user created successfully", profile)
}

// UpdateProfile updates a profile with role-based permission checks.
//
// Permission rules:
//   - Main user editing their OWN main profile → allowed (uses Update with system userID)
//   - Main user editing ANOTHER main profile → forbidden
//   - Main user editing ANY sub user profile → allowed (uses UpdateByID, no userID check)
//   - Sub user editing their OWN profile → allowed (uses Update with own userID)
//   - Sub user editing SOMEONE ELSE'S profile → forbidden
func (h *ProfileHandler) UpdateProfile(c *gin.Context) {
	userID := middleware.GetUserID(c)
	role := middleware.GetRole(c)
	email := middleware.GetEmail(c)
	id := c.Param("id")

	var req models.UpdateProfileRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ValidationError(c, err.Error())
		return
	}

	// Fetch the profile to check its type and ownership
	profile, err := h.profileRepo.GetByID(id)
	if err != nil {
		utils.NotFoundError(c, "Profile")
		return
	}

	// Convert FlexibleDate birthday to *time.Time for the repository
	// This is needed because UpdateProfileRequest uses FlexibleDate
	// but the repository expects a standard time.Time pointer
	var birthdayTime *time.Time
	if req.Birthday != nil && !req.Birthday.Time.IsZero() {
		t := req.Birthday.Time
		birthdayTime = &t
	}

	// Build a clean UpdateProfileRequest with converted birthday
	cleanReq := &models.UpdateProfileRequest{
		Name:               req.Name,
		Bio:                req.Bio,
		Age:                req.Age,
		Gender:             req.Gender,
		YearLevel:          req.YearLevel,
		Hometown:           req.Hometown,
		RelationshipStatus: req.RelationshipStatus,
		Education:          req.Education,
		Work:               req.Work,
		Interests:          req.Interests,
		ProfilePictureURL:  req.ProfilePictureURL,
		CoverPhotoURL:      req.CoverPhotoURL,
		Email:              req.Email,
		Phone:              req.Phone,
	}

	if role == "main" {
		if profile.IsMainProfile {
			// ── Main user editing a main profile ──────────────────
			// Only allowed if it is their own profile
			isOwn := false
			for _, mu := range models.HardcodedMainUsers {
				if mu.Email == email {
					if models.MainUserProfileMap[mu.ID] == id {
						isOwn = true
					}
					break
				}
			}
			if !isOwn {
				utils.ErrorResponse(c, http.StatusForbidden,
					"You can only edit your own profile")
				return
			}
			// Use system userID (owner of main profiles in DB)
			if err := h.profileRepo.UpdateWithBirthday(
				id, profile.UserID, cleanReq, birthdayTime); err != nil {
				utils.InternalServerError(c)
				return
			}
		} else {
			// ── Main user editing a sub user profile ──────────────
			// UpdateByID skips the user_id check — main users have full access
			if err := h.profileRepo.UpdateByIDWithBirthday(
				id, cleanReq, birthdayTime); err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{
					"error": "Update failed: " + err.Error(),
				})
				return
			}
		}
	} else {
		// ── Sub user editing a profile ─────────────────────────────
		// Sub users can only edit profiles they own
		if profile.UserID != userID {
			utils.ErrorResponse(c, http.StatusForbidden,
				"You can only edit your own profile")
			return
		}
		if err := h.profileRepo.UpdateWithBirthday(
			id, userID, cleanReq, birthdayTime); err != nil {
			utils.InternalServerError(c)
			return
		}
	}

	// Return the updated profile
	updatedProfile, err := h.profileRepo.GetByID(id)
	if err != nil {
		utils.SuccessMessage(c, "Profile updated successfully", nil)
		return
	}

	utils.SuccessMessage(c, "Profile updated successfully", updatedProfile)
}

// DeleteSubUser permanently deletes a sub user profile AND their user account.
// Restricted to main users only.
// After deletion the user can re-register with the same email.
func (h *ProfileHandler) DeleteSubUser(c *gin.Context) {
	role := middleware.GetRole(c)
	id := c.Param("id")

	// Only main users can delete profiles
	if role != "main" {
		utils.ErrorResponse(c, http.StatusForbidden,
			"Only main users can delete profiles")
		return
	}

	// Fetch profile to get the associated user ID
	profile, err := h.profileRepo.GetByID(id)
	if err != nil {
		utils.NotFoundError(c, "Profile")
		return
	}

	// Prevent deleting main profiles
	if profile.IsMainProfile {
		utils.ErrorResponse(c, http.StatusForbidden,
			"Cannot delete main profiles")
		return
	}

	// Delete the profile record from profiles table
	if err := h.profileRepo.DeleteByID(id); err != nil {
		utils.InternalServerError(c)
		return
	}

	// Also delete the user account so they can re-register later
	// This is non-critical — profile is already deleted so we don't fail if this errors
	if profile.UserID != "" {
		_ = h.userRepo.DeleteByID(profile.UserID)
	}

	utils.SuccessMessage(c, "Profile and account deleted successfully", nil)
}

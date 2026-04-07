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
func (h *ProfileHandler) GetMainProfiles(c *gin.Context) {
	profiles, err := h.profileRepo.GetMainProfiles()
	if err != nil {
		utils.InternalServerError(c)
		return
	}
	utils.SuccessResponse(c, profiles)
}

// GetMyProfiles returns only the profiles owned by the logged-in sub user.
func (h *ProfileHandler) GetMyProfiles(c *gin.Context) {
	userID := middleware.GetUserID(c)
	subUsers, err := h.profileRepo.GetSubUsersByUserID(userID)
	if err != nil {
		utils.InternalServerError(c)
		return
	}
	utils.SuccessResponse(c, gin.H{
		"sub_users": subUsers,
		"profiles":  subUsers,
	})
}

// GetAllSubUsers returns ALL sub user profiles — main users only.
func (h *ProfileHandler) GetAllSubUsers(c *gin.Context) {
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
func (h *ProfileHandler) GetPublicProfiles(c *gin.Context) {
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

// GetProfile returns a single profile by UUID.
func (h *ProfileHandler) GetProfile(c *gin.Context) {
	id := c.Param("id")
	profile, err := h.profileRepo.GetByID(id)
	if err != nil {
		utils.NotFoundError(c, "Profile")
		return
	}
	utils.SuccessResponse(c, profile)
}

// CreateSubUser creates a new sub user profile.
//
// FIX: When a main user creates a sub user, GetUserID returns "main-user-001"
// which is NOT a valid PostgreSQL UUID. This caused the error:
//
//	"pq: invalid input syntax for type uuid: main-user-001"
//
// Solution: When the logged-in user is a main user, look up the system user's
// real UUID from the database to use as the owner, OR create the profile with
// a generated UUID from the system user. We use the system user for this purpose.
func (h *ProfileHandler) CreateSubUser(c *gin.Context) {
	userID := middleware.GetUserID(c)
	role := middleware.GetRole(c)

	var req models.CreateSubUserRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ValidationError(c, err.Error())
		return
	}

	// ✅ FIX: Main users have hardcoded IDs like "main-user-001" which are
	// NOT valid PostgreSQL UUIDs. When a main user adds a sub user profile,
	// we need to use the system user's real UUID as the owner instead.
	actualUserID := userID
	if role == "main" {
		// Look up the system user's real UUID from the database
		// The system user (system@localhost) is the owner of all main profiles
		// and is used as a placeholder for admin-created profiles
		systemUser, err := h.userRepo.GetByEmail("system@localhost")
		if err != nil {
			// If system user not found, try to get any valid user UUID
			// or return a descriptive error
			c.JSON(http.StatusInternalServerError, gin.H{
				"error": "System user not found. Please ensure the database is initialized.",
			})
			return
		}
		actualUserID = systemUser.ID
	}

	// Convert FlexibleDate birthday to *time.Time
	var birthday *time.Time
	if req.Birthday != nil && !req.Birthday.Time.IsZero() {
		t := req.Birthday.Time
		birthday = &t
	}

	profile := &models.Profile{
		UserID:            actualUserID, // ✅ Uses real UUID, not "main-user-001"
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

	if err := h.profileRepo.CreateSubUser(actualUserID, "", profile); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to create sub user: " + err.Error(),
		})
		return
	}

	utils.SuccessMessage(c, "Sub-user created successfully", profile)
}

// UpdateProfile updates a profile with role-based permission checks.
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

	profile, err := h.profileRepo.GetByID(id)
	if err != nil {
		utils.NotFoundError(c, "Profile")
		return
	}

	// Convert FlexibleDate to *time.Time
	var birthdayTime *time.Time
	if req.Birthday != nil && !req.Birthday.Time.IsZero() {
		t := req.Birthday.Time
		birthdayTime = &t
	}

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
			if err := h.profileRepo.UpdateWithBirthday(
				id, profile.UserID, cleanReq, birthdayTime); err != nil {
				utils.InternalServerError(c)
				return
			}
		} else {
			if err := h.profileRepo.UpdateByIDWithBirthday(
				id, cleanReq, birthdayTime); err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{
					"error": "Update failed: " + err.Error(),
				})
				return
			}
		}
	} else {
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

	updatedProfile, err := h.profileRepo.GetByID(id)
	if err != nil {
		utils.SuccessMessage(c, "Profile updated successfully", nil)
		return
	}
	utils.SuccessMessage(c, "Profile updated successfully", updatedProfile)
}

// DeleteSubUser deletes a sub user profile and their account.
func (h *ProfileHandler) DeleteSubUser(c *gin.Context) {
	role := middleware.GetRole(c)
	id := c.Param("id")

	if role != "main" {
		utils.ErrorResponse(c, http.StatusForbidden,
			"Only main users can delete profiles")
		return
	}

	profile, err := h.profileRepo.GetByID(id)
	if err != nil {
		utils.NotFoundError(c, "Profile")
		return
	}

	if profile.IsMainProfile {
		utils.ErrorResponse(c, http.StatusForbidden,
			"Cannot delete main profiles")
		return
	}

	if err := h.profileRepo.DeleteByID(id); err != nil {
		utils.InternalServerError(c)
		return
	}

	if profile.UserID != "" {
		_ = h.userRepo.DeleteByID(profile.UserID)
	}

	utils.SuccessMessage(c, "Profile and account deleted successfully", nil)
}

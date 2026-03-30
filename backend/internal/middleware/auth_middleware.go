package middleware

import (
	"net/http"
	"strings"

	"github.com/Dunh1ll/backend/internal/config"
	"github.com/Dunh1ll/backend/pkg/utils"
	"github.com/gin-gonic/gin"
)

// AuthMiddleware validates the JWT Bearer token on every protected request.
// It extracts the token from the Authorization header, validates it,
// and stores the claims (userID, email, role, name) in the Gin context
// so handlers can access them via the helper functions below.
func AuthMiddleware(cfg *config.Config) gin.HandlerFunc {
	return func(c *gin.Context) {
		// Check that the Authorization header exists
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, gin.H{
				"error": "Authorization header required",
			})
			c.Abort()
			return
		}

		// Header must be in format: "Bearer <token>"
		parts := strings.SplitN(authHeader, " ", 2)
		if len(parts) != 2 || strings.ToLower(parts[0]) != "bearer" {
			c.JSON(http.StatusUnauthorized, gin.H{
				"error": "Invalid authorization header format",
			})
			c.Abort()
			return
		}

		// Parse and validate the JWT token
		tokenString := parts[1]
		claims, err := utils.ParseToken(tokenString, cfg)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{
				"error": "Invalid or expired token",
			})
			c.Abort()
			return
		}

		// Store all claims in the Gin context for use in handlers
		c.Set("userID", claims.UserID)
		c.Set("email", claims.Email)
		c.Set("role", claims.Role) // "main" or "sub"
		c.Set("name", claims.Name)

		c.Next()
	}
}

// GetUserID retrieves the logged-in user's ID from the Gin context.
// For sub users this is their database UUID.
// For main users this is their hardcoded ID (e.g. "main-user-001").
func GetUserID(c *gin.Context) string {
	userID, exists := c.Get("userID")
	if !exists {
		return ""
	}
	return userID.(string)
}

// GetRole retrieves the logged-in user's role from the Gin context.
// Returns "main" or "sub".
func GetRole(c *gin.Context) string {
	role, exists := c.Get("role")
	if !exists {
		return ""
	}
	return role.(string)
}

// GetEmail retrieves the logged-in user's email from the Gin context.
func GetEmail(c *gin.Context) string {
	email, exists := c.Get("email")
	if !exists {
		return ""
	}
	return email.(string)
}

// GetName retrieves the logged-in user's display name from the Gin context.
func GetName(c *gin.Context) string {
	name, exists := c.Get("name")
	if !exists {
		return ""
	}
	return name.(string)
}

// IsMainUser returns true if the logged-in user has the "main" role.
// Used for permission checks in profile handlers.
func IsMainUser(c *gin.Context) bool {
	return GetRole(c) == "main"
}

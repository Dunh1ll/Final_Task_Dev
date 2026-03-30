package utils

import (
	"fmt"
	"time"

	"github.com/Dunh1ll/backend/internal/config"
	"github.com/golang-jwt/jwt/v5"
)

// Claims holds the data embedded inside the JWT token.
// Every API request includes this token so the backend knows
// who is making the request and what role they have.
type Claims struct {
	UserID string `json:"user_id"` // DB UUID for sub users, hardcoded ID for main users
	Email  string `json:"email"`   // Logged-in user's email address
	Role   string `json:"role"`    // "main" or "sub" — controls all permissions
	Name   string `json:"name"`    // Display name shown in the UI
	jwt.RegisteredClaims
}

// GenerateToken creates a signed JWT token containing user identity and role.
// Called after successful login or registration.
// The token is sent with every subsequent API request in the Authorization header.
func GenerateToken(userID, email, role, name string, cfg *config.Config) (string, error) {
	claims := Claims{
		UserID: userID,
		Email:  email,
		Role:   role,
		Name:   name,
		RegisteredClaims: jwt.RegisteredClaims{
			// Token expires after the configured number of hours
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(
				time.Duration(cfg.JWTExpiryHours) * time.Hour,
			)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			NotBefore: jwt.NewNumericDate(time.Now()),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(cfg.JWTSecret))
}

// ParseToken validates a JWT token string and returns its claims.
// Called by AuthMiddleware on every protected API request.
// Returns an error if the token is invalid, expired, or tampered with.
func ParseToken(tokenString string, cfg *config.Config) (*Claims, error) {
	token, err := jwt.ParseWithClaims(
		tokenString,
		&Claims{},
		func(token *jwt.Token) (interface{}, error) {
			// Ensure the signing method is HMAC (not RSA or others)
			if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
			}
			return []byte(cfg.JWTSecret), nil
		},
	)

	if err != nil {
		return nil, err
	}

	if claims, ok := token.Claims.(*Claims); ok && token.Valid {
		return claims, nil
	}

	return nil, fmt.Errorf("invalid token")
}

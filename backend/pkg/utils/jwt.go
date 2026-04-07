package utils

import (
	"fmt"
	"time"

	"github.com/Dunh1ll/backend/internal/config"
	"github.com/golang-jwt/jwt/v5"
)

// Claims holds the data embedded inside a JWT token.
type Claims struct {
	UserID string `json:"user_id"`
	Email  string `json:"email"`
	Role   string `json:"role"`
	Name   string `json:"name"`
	jwt.RegisteredClaims
}

// ResetClaims holds data for a password-reset JWT token.
// Separate from regular auth claims to prevent misuse.
type ResetClaims struct {
	Email     string `json:"email"`
	TokenType string `json:"token_type"` // always "reset"
	jwt.RegisteredClaims
}

// GenerateToken creates a signed JWT for auth (login/register).
func GenerateToken(
	userID, email, role, name string,
	cfg *config.Config,
) (string, error) {
	claims := Claims{
		UserID: userID,
		Email:  email,
		Role:   role,
		Name:   name,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(
				time.Now().Add(
					time.Duration(cfg.JWTExpiryHours) * time.Hour)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			NotBefore: jwt.NewNumericDate(time.Now()),
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(cfg.JWTSecret))
}

// ParseToken validates and parses an auth JWT token.
func ParseToken(
	tokenString string,
	cfg *config.Config,
) (*Claims, error) {
	token, err := jwt.ParseWithClaims(
		tokenString,
		&Claims{},
		func(token *jwt.Token) (interface{}, error) {
			if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, fmt.Errorf(
					"unexpected signing method: %v",
					token.Header["alg"])
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

// GenerateResetToken creates a short-lived JWT for password reset.
// Expires in 15 minutes — enough time to complete the reset.
// Uses a different token_type field to distinguish from auth tokens.
func GenerateResetToken(email string, cfg *config.Config) (string, error) {
	claims := ResetClaims{
		Email:     email,
		TokenType: "reset",
		RegisteredClaims: jwt.RegisteredClaims{
			// Reset tokens expire in 15 minutes
			ExpiresAt: jwt.NewNumericDate(
				time.Now().Add(15 * time.Minute)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			NotBefore: jwt.NewNumericDate(time.Now()),
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(cfg.JWTSecret))
}

// ParseResetToken validates a password-reset JWT and returns the email.
// Returns error if expired, invalid signature, or wrong token type.
func ParseResetToken(
	tokenString string,
	cfg *config.Config,
) (string, error) {
	token, err := jwt.ParseWithClaims(
		tokenString,
		&ResetClaims{},
		func(token *jwt.Token) (interface{}, error) {
			if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, fmt.Errorf("unexpected signing method")
			}
			return []byte(cfg.JWTSecret), nil
		},
	)
	if err != nil {
		return "", err
	}
	claims, ok := token.Claims.(*ResetClaims)
	if !ok || !token.Valid {
		return "", fmt.Errorf("invalid reset token")
	}
	// Ensure this is a reset token, not a regular auth token
	if claims.TokenType != "reset" {
		return "", fmt.Errorf("invalid token type")
	}
	return claims.Email, nil
}

package utils

import (
	"regexp"

	"golang.org/x/crypto/bcrypt"
)

// HashPassword hashes a plain text password using bcrypt.
// The hashed version is stored in the database — never the plain text.
// bcrypt automatically handles salting for security.
func HashPassword(password string) (string, error) {
	bytes, err := bcrypt.GenerateFromPassword([]byte(password), 14)
	return string(bytes), err
}

// CheckPasswordHash compares a plain text password against a bcrypt hash.
// Returns true if they match, false otherwise.
// Used during login to verify the submitted password.
func CheckPasswordHash(password, hash string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
	return err == nil
}

// ValidatePassword checks that a password meets security requirements:
//   - At least 8 characters long
//   - Contains at least one uppercase letter
//   - Contains at least one special character
//
// Returns true if all requirements are met.
func ValidatePassword(password string) bool {
	if len(password) < 8 {
		return false
	}

	// Check for at least one uppercase letter (A-Z)
	hasUpper := regexp.MustCompile(`[A-Z]`).MatchString(password)
	if !hasUpper {
		return false
	}

	// Check for at least one special character
	hasSpecial := regexp.MustCompile(`[!@#$%^&*(),.?":{}|<>]`).MatchString(password)
	return hasSpecial
}

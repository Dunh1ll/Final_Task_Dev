package repository

import (
	"database/sql"
	"time"

	"github.com/Dunh1ll/backend/pkg/utils"
)

// OTPRepository handles all database operations for the otps table.
type OTPRepository struct {
	db *sql.DB
}

// NewOTPRepository creates a new OTPRepository.
func NewOTPRepository(db *sql.DB) *OTPRepository {
	return &OTPRepository{db: db}
}

// CreateOTP stores a hashed OTP for the given email.
//
// The OTP code is hashed with bcrypt before storage so that
// even if the database is compromised, the plain OTP is not exposed.
// Any existing unused OTPs for this email are deleted first
// to prevent abuse (only one active OTP per email at a time).
//
// Parameters:
//   - email: the user's Gmail address
//   - plainCode: the 6-digit OTP code (e.g. "483921")
//   - expiresAt: when this OTP becomes invalid
func (r *OTPRepository) CreateOTP(
	email string,
	plainCode string,
	expiresAt time.Time,
) error {
	// Delete any existing unused OTPs for this email first
	// This prevents multiple valid OTPs from existing simultaneously
	_, err := r.db.Exec(`
		DELETE FROM otps
		WHERE email = $1 AND used = false
	`, email)
	if err != nil {
		return err
	}

	// Hash the OTP code before storing
	codeHash, err := utils.HashPassword(plainCode)
	if err != nil {
		return err
	}

	// Insert the new OTP record
	_, err = r.db.Exec(`
		INSERT INTO otps (email, code_hash, expires_at, used)
		VALUES ($1, $2, $3, false)
	`, email, codeHash, expiresAt)

	return err
}

// VerifyOTP checks if the given plain-text OTP matches the stored hash
// for the given email, and that it has not expired or been used.
//
// Returns:
//   - true, nil: OTP is valid — caller should mark it as used
//   - false, nil: OTP is invalid (wrong code, expired, or already used)
//   - false, err: database error
func (r *OTPRepository) VerifyOTP(
	email string,
	plainCode string,
) (bool, error) {
	// Find the most recent valid OTP for this email
	var id string
	var codeHash string
	var expiresAt time.Time
	var used bool

	err := r.db.QueryRow(`
		SELECT id, code_hash, expires_at, used
		FROM otps
		WHERE email = $1
		ORDER BY created_at DESC
		LIMIT 1
	`, email).Scan(&id, &codeHash, &expiresAt, &used)

	if err == sql.ErrNoRows {
		// No OTP found for this email
		return false, nil
	}
	if err != nil {
		return false, err
	}

	// Check if already used
	if used {
		return false, nil
	}

	// Check if expired
	if time.Now().After(expiresAt) {
		return false, nil
	}

	// Check if the plain code matches the stored hash
	if !utils.CheckPasswordHash(plainCode, codeHash) {
		return false, nil
	}

	// Mark OTP as used so it cannot be reused
	_, err = r.db.Exec(`
		UPDATE otps SET used = true WHERE id = $1
	`, id)
	if err != nil {
		return false, err
	}

	return true, nil
}

// CleanupExpiredOTPs deletes all expired OTP records from the database.
// This should be called periodically to keep the table small.
// In production, run this on a cron job. For now it runs on each request.
func (r *OTPRepository) CleanupExpiredOTPs() error {
	_, err := r.db.Exec(`
		DELETE FROM otps
		WHERE expires_at < NOW()
		OR used = true
	`)
	return err
}

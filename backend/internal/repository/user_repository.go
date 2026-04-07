package repository

import (
	"database/sql"

	"github.com/Dunh1ll/backend/internal/models"
)

// UserRepository handles all database queries for the users table.
type UserRepository struct {
	db *sql.DB
}

// NewUserRepository creates a new UserRepository.
func NewUserRepository(db *sql.DB) *UserRepository {
	return &UserRepository{db: db}
}

// Create inserts a new user record into the users table.
func (r *UserRepository) Create(user *models.User) error {
	query := `
		INSERT INTO users
		    (email, password_hash, full_name, phone, is_active)
		VALUES ($1, $2, $3, $4, $5)
		RETURNING id, created_at, updated_at
	`
	return r.db.QueryRow(
		query,
		user.Email,
		user.PasswordHash,
		user.FullName,
		user.Phone,
		user.IsActive,
	).Scan(&user.ID, &user.CreatedAt, &user.UpdatedAt)
}

// GetByEmail finds a user by their email address.
func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	query := `
		SELECT id, email, password_hash, full_name,
		       phone, is_active, created_at, updated_at
		FROM users
		WHERE email = $1
	`
	user := &models.User{}
	err := r.db.QueryRow(query, email).Scan(
		&user.ID,
		&user.Email,
		&user.PasswordHash,
		&user.FullName,
		&user.Phone,
		&user.IsActive,
		&user.CreatedAt,
		&user.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}
	return user, nil
}

// GetByID finds a user by their UUID.
func (r *UserRepository) GetByID(id string) (*models.User, error) {
	query := `
		SELECT id, email, password_hash, full_name,
		       phone, is_active, created_at, updated_at
		FROM users
		WHERE id = $1
	`
	user := &models.User{}
	err := r.db.QueryRow(query, id).Scan(
		&user.ID,
		&user.Email,
		&user.PasswordHash,
		&user.FullName,
		&user.Phone,
		&user.IsActive,
		&user.CreatedAt,
		&user.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}
	return user, nil
}

// UpdatePassword updates password_hash for a user by ID.
// Called by ResetPassword after OTP verification succeeds.
func (r *UserRepository) UpdatePassword(
	userID string,
	hashedPassword string,
) error {
	query := `
		UPDATE users
		SET password_hash = $2,
		    updated_at    = NOW()
		WHERE id = $1
	`
	result, err := r.db.Exec(query, userID, hashedPassword)
	if err != nil {
		return err
	}
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return err
	}
	if rowsAffected == 0 {
		return sql.ErrNoRows
	}
	return nil
}

// DeleteByID permanently removes a user account.
func (r *UserRepository) DeleteByID(id string) error {
	_, err := r.db.Exec("DELETE FROM users WHERE id = $1", id)
	return err
}

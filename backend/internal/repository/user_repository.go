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
// The ID, created_at, and updated_at are set by PostgreSQL.
func (r *UserRepository) Create(user *models.User) error {
	query := `
		INSERT INTO users (email, password_hash, full_name, phone, is_active)
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
// Used during login to look up the sub user account.
// Returns sql.ErrNoRows wrapped as an error if not found.
func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	query := `
		SELECT id, email, password_hash, full_name, phone, is_active, created_at, updated_at
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
		SELECT id, email, password_hash, full_name, phone, is_active, created_at, updated_at
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

// DeleteByID permanently removes a user account from the database.
// Called when a main user deletes a sub user profile.
// After deletion the email is freed up for re-registration.
func (r *UserRepository) DeleteByID(id string) error {
	_, err := r.db.Exec("DELETE FROM users WHERE id = $1", id)
	return err
}

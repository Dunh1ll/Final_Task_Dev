package repository

import (
	"database/sql"
	"errors"
	"time"

	"github.com/Dunh1ll/backend/internal/models"
	"github.com/lib/pq"
)

// ProfileRepository handles all database queries for the profiles table.
type ProfileRepository struct {
	db *sql.DB
}

// NewProfileRepository creates a new ProfileRepository.
func NewProfileRepository(db *sql.DB) *ProfileRepository {
	return &ProfileRepository{db: db}
}

// CreateMainProfile inserts a main profile into the database.
// Only called during InitializeMainProfiles on first startup.
func (r *ProfileRepository) CreateMainProfile(
	userID string,
	profile *models.Profile,
) error {
	query := `
		INSERT INTO profiles (
			user_id, name, email, phone, profile_picture_url, cover_photo_url,
			bio, age, gender, year_level, birthday, hometown, relationship_status,
			education, work, interests, is_main_profile
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, true)
		RETURNING id, created_at, updated_at
	`
	return r.db.QueryRow(
		query,
		userID,
		profile.Name,
		profile.Email,
		profile.Phone,
		profile.ProfilePictureURL,
		profile.CoverPhotoURL,
		profile.Bio,
		profile.Age,
		profile.Gender,
		profile.YearLevel,
		profile.Birthday, // *time.Time — nil becomes NULL in PostgreSQL
		profile.Hometown,
		profile.RelationshipStatus,
		profile.Education,
		profile.Work,
		pq.Array(profile.Interests), // Convert Go slice to PostgreSQL array
	).Scan(&profile.ID, &profile.CreatedAt, &profile.UpdatedAt)
}

// CreateSubUser inserts a new sub user profile into the database.
// Called from the CreateSubUser handler and the auto-profile-on-register flow.
func (r *ProfileRepository) CreateSubUser(
	userID string,
	mainProfileID string, // Not currently used — kept for future parent-child features
	profile *models.Profile,
) error {
	query := `
		INSERT INTO profiles (
			user_id, name, email, phone, bio, age, gender, year_level, birthday,
			hometown, relationship_status, education, work, interests,
			profile_picture_url, cover_photo_url, is_main_profile
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, false)
		RETURNING id, created_at, updated_at
	`
	// Use default images if none provided
	profilePic := profile.ProfilePictureURL
	if profilePic == "" {
		profilePic = "assets/images/default_avatar.jpg"
	}
	coverPhoto := profile.CoverPhotoURL
	if coverPhoto == "" {
		coverPhoto = "assets/images/default_cover.jpg"
	}

	return r.db.QueryRow(
		query,
		userID,
		profile.Name,
		profile.Email,
		profile.Phone,
		profile.Bio,
		profile.Age,
		profile.Gender,
		profile.YearLevel,
		profile.Birthday,
		profile.Hometown,
		profile.RelationshipStatus,
		profile.Education,
		profile.Work,
		pq.Array(profile.Interests),
		profilePic,
		coverPhoto,
	).Scan(&profile.ID, &profile.CreatedAt, &profile.UpdatedAt)
}

// GetMainProfiles fetches the 3 main profiles from the database.
// Ordered by creation time so the original seeding order is preserved.
func (r *ProfileRepository) GetMainProfiles() ([]models.Profile, error) {
	query := `
		SELECT id, name, email, phone, profile_picture_url, cover_photo_url,
			bio, age, gender, year_level, birthday, hometown, relationship_status,
			education, work, interests, is_main_profile, created_at, updated_at
		FROM profiles
		WHERE is_main_profile = true
		ORDER BY created_at ASC
		LIMIT 3
	`
	rows, err := r.db.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var profiles []models.Profile
	for rows.Next() {
		var p models.Profile
		var interests []string
		var birthday sql.NullTime // Handles NULL birthday values

		err := rows.Scan(
			&p.ID, &p.Name, &p.Email, &p.Phone,
			&p.ProfilePictureURL, &p.CoverPhotoURL,
			&p.Bio, &p.Age, &p.Gender, &p.YearLevel,
			&birthday,
			&p.Hometown, &p.RelationshipStatus,
			&p.Education, &p.Work,
			pq.Array(&interests),
			&p.IsMainProfile, &p.CreatedAt, &p.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		if birthday.Valid {
			p.Birthday = &birthday.Time
		}
		p.Interests = interests
		profiles = append(profiles, p)
	}
	return profiles, rows.Err()
}

// GetSubUsersByUserID fetches all profiles belonging to a specific user.
// Used when a sub user wants to see only their own profiles.
func (r *ProfileRepository) GetSubUsersByUserID(
	userID string,
) ([]models.Profile, error) {
	query := `
		SELECT id, user_id, name, email, phone, bio, age, gender, year_level, birthday,
			hometown, relationship_status, education, work,
			profile_picture_url, cover_photo_url, interests, is_main_profile,
			main_profile_id, created_at, updated_at
		FROM profiles
		WHERE user_id = $1 AND is_main_profile = false
		ORDER BY created_at DESC
	`
	return r.scanProfileRows(r.db.Query(query, userID))
}

// GetAllSubUsers fetches ALL sub user profiles across all accounts.
// Used by main users to see everyone, and by the public endpoint.
func (r *ProfileRepository) GetAllSubUsers() ([]models.Profile, error) {
	query := `
		SELECT id, user_id, name, email, phone, bio, age, gender, year_level, birthday,
			hometown, relationship_status, education, work,
			profile_picture_url, cover_photo_url, interests, is_main_profile,
			main_profile_id, created_at, updated_at
		FROM profiles
		WHERE is_main_profile = false
		ORDER BY created_at DESC
	`
	return r.scanProfileRows(r.db.Query(query))
}

// scanProfileRows is a helper that scans rows from any profile query
// that returns the full sub user column set.
// Centralizes the scanning logic to avoid repetition.
func (r *ProfileRepository) scanProfileRows(
	rows *sql.Rows,
	err error,
) ([]models.Profile, error) {
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var profiles []models.Profile
	for rows.Next() {
		var p models.Profile
		var interests []string
		var mainProfileID sql.NullString
		var birthday sql.NullTime
		// sql.Null types handle NULL values from PostgreSQL safely
		var email, phone, bio, hometown, relStatus,
			education, work sql.NullString
		var age sql.NullInt32

		err := rows.Scan(
			&p.ID, &p.UserID, &p.Name,
			&email, &phone, &bio,
			&age, &p.Gender, &p.YearLevel,
			&birthday,
			&hometown, &relStatus, &education, &work,
			&p.ProfilePictureURL, &p.CoverPhotoURL,
			pq.Array(&interests),
			&p.IsMainProfile,
			&mainProfileID,
			&p.CreatedAt, &p.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}

		// Map nullable DB values to Go struct fields
		if email.Valid {
			p.Email = email.String
		}
		if phone.Valid {
			p.Phone = phone.String
		}
		if bio.Valid {
			p.Bio = bio.String
		}
		if age.Valid {
			p.Age = int(age.Int32)
		}
		if birthday.Valid {
			p.Birthday = &birthday.Time
		}
		if hometown.Valid {
			p.Hometown = hometown.String
		}
		if relStatus.Valid {
			p.RelationshipStatus = relStatus.String
		}
		if education.Valid {
			p.Education = education.String
		}
		if work.Valid {
			p.Work = work.String
		}
		if mainProfileID.Valid {
			p.MainProfileID = &mainProfileID.String
		}
		p.Interests = interests
		profiles = append(profiles, p)
	}
	return profiles, rows.Err()
}

// GetByID fetches a single profile by its UUID.
// Used by ProfileDetailScreen and permission checks in handlers.
func (r *ProfileRepository) GetByID(id string) (*models.Profile, error) {
	query := `
		SELECT id, user_id, name, email, phone, profile_picture_url, cover_photo_url,
			bio, age, gender, year_level, birthday, hometown, relationship_status,
			education, work, interests, is_main_profile, main_profile_id,
			created_at, updated_at
		FROM profiles WHERE id = $1
	`
	p := &models.Profile{}
	var interests []string
	var email, phone, bio, hometown, relStatus,
		education, work sql.NullString
	var age sql.NullInt32
	var birthday sql.NullTime
	var mainProfileID sql.NullString

	err := r.db.QueryRow(query, id).Scan(
		&p.ID, &p.UserID, &p.Name,
		&email, &phone,
		&p.ProfilePictureURL, &p.CoverPhotoURL,
		&bio, &age, &p.Gender, &p.YearLevel,
		&birthday,
		&hometown, &relStatus, &education, &work,
		pq.Array(&interests),
		&p.IsMainProfile, &mainProfileID,
		&p.CreatedAt, &p.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, errors.New("profile not found")
	}
	if err != nil {
		return nil, err
	}

	if email.Valid {
		p.Email = email.String
	}
	if phone.Valid {
		p.Phone = phone.String
	}
	if bio.Valid {
		p.Bio = bio.String
	}
	if age.Valid {
		p.Age = int(age.Int32)
	}
	if birthday.Valid {
		p.Birthday = &birthday.Time
	}
	if hometown.Valid {
		p.Hometown = hometown.String
	}
	if relStatus.Valid {
		p.RelationshipStatus = relStatus.String
	}
	if education.Valid {
		p.Education = education.String
	}
	if work.Valid {
		p.Work = work.String
	}
	if mainProfileID.Valid {
		p.MainProfileID = &mainProfileID.String
	}
	p.Interests = interests

	return p, nil
}

// Delete removes a profile by ID AND user ID.
// The user_id check ensures sub users can only delete their own profiles.
func (r *ProfileRepository) Delete(id string, userID string) error {
	query := `
		DELETE FROM profiles
		WHERE id = $1 AND user_id = $2 AND is_main_profile = false
	`
	result, err := r.db.Exec(query, id, userID)
	if err != nil {
		return err
	}
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return err
	}
	if rowsAffected == 0 {
		return errors.New("profile not found or cannot be deleted")
	}
	return nil
}

// DeleteByID removes a profile by ID only — used by main users.
// No user_id check because main users can delete any sub user profile.
func (r *ProfileRepository) DeleteByID(id string) error {
	query := `DELETE FROM profiles WHERE id = $1 AND is_main_profile = false`
	result, err := r.db.Exec(query, id)
	if err != nil {
		return err
	}
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return err
	}
	if rowsAffected == 0 {
		return errors.New("profile not found or cannot be deleted")
	}
	return nil
}

// UpdateWithBirthday updates a profile using both profile ID and user ID.
// The birthday is passed separately as *time.Time (already converted from FlexibleDate).
// COALESCE keeps existing values when the new value is empty/zero.
// Used by: sub users editing own profile, main users editing own main profile.
func (r *ProfileRepository) UpdateWithBirthday(
	id string,
	userID string,
	updates *models.UpdateProfileRequest,
	birthday *time.Time,
) error {
	query := `
		UPDATE profiles SET
			name               = COALESCE(NULLIF($3, ''), name),
			bio                = COALESCE(NULLIF($4, ''), bio),
			age                = COALESCE(NULLIF($5, 0), age),
			gender             = COALESCE(NULLIF($6, ''), gender),
			year_level         = COALESCE(NULLIF($7, ''), year_level),
			birthday           = COALESCE($8, birthday),
			hometown           = COALESCE(NULLIF($9, ''), hometown),
			relationship_status = COALESCE(NULLIF($10, ''), relationship_status),
			education          = COALESCE(NULLIF($11, ''), education),
			work               = COALESCE(NULLIF($12, ''), work),
			interests          = COALESCE($13, interests),
			profile_picture_url = COALESCE(NULLIF($14, ''), profile_picture_url),
			cover_photo_url    = COALESCE(NULLIF($15, ''), cover_photo_url),
			email              = COALESCE(NULLIF($16, ''), email),
			phone              = COALESCE(NULLIF($17, ''), phone),
			updated_at         = NOW()
		WHERE id = $1 AND user_id = $2
	`
	_, err := r.db.Exec(
		query, id, userID,
		updates.Name,
		updates.Bio,
		updates.Age,
		updates.Gender,
		updates.YearLevel,
		birthday, // Already converted *time.Time — nil becomes NULL
		updates.Hometown,
		updates.RelationshipStatus,
		updates.Education,
		updates.Work,
		pq.Array(updates.Interests),
		updates.ProfilePictureURL,
		updates.CoverPhotoURL,
		updates.Email,
		updates.Phone,
	)
	return err
}

// UpdateByIDWithBirthday updates a profile by ID only — used by main users.
// No user_id check — main users can edit ANY sub user profile.
// The birthday is passed separately as *time.Time.
func (r *ProfileRepository) UpdateByIDWithBirthday(
	id string,
	updates *models.UpdateProfileRequest,
	birthday *time.Time,
) error {
	query := `
		UPDATE profiles SET
			name               = COALESCE(NULLIF($2, ''), name),
			bio                = COALESCE(NULLIF($3, ''), bio),
			age                = COALESCE(NULLIF($4, 0), age),
			gender             = COALESCE(NULLIF($5, ''), gender),
			year_level         = COALESCE(NULLIF($6, ''), year_level),
			birthday           = COALESCE($7, birthday),
			hometown           = COALESCE(NULLIF($8, ''), hometown),
			relationship_status = COALESCE(NULLIF($9, ''), relationship_status),
			education          = COALESCE(NULLIF($10, ''), education),
			work               = COALESCE(NULLIF($11, ''), work),
			interests          = COALESCE($12, interests),
			profile_picture_url = COALESCE(NULLIF($13, ''), profile_picture_url),
			cover_photo_url    = COALESCE(NULLIF($14, ''), cover_photo_url),
			email              = COALESCE(NULLIF($15, ''), email),
			phone              = COALESCE(NULLIF($16, ''), phone),
			updated_at         = NOW()
		WHERE id = $1 AND is_main_profile = false
	`
	result, err := r.db.Exec(
		query, id,
		updates.Name,
		updates.Bio,
		updates.Age,
		updates.Gender,
		updates.YearLevel,
		birthday,
		updates.Hometown,
		updates.RelationshipStatus,
		updates.Education,
		updates.Work,
		pq.Array(updates.Interests),
		updates.ProfilePictureURL,
		updates.CoverPhotoURL,
		updates.Email,
		updates.Phone,
	)
	if err != nil {
		return err
	}
	rows, _ := result.RowsAffected()
	if rows == 0 {
		return errors.New("profile not found or update failed")
	}
	return nil
}

// InitializeMainProfiles seeds the 3 hardcoded main profiles on first startup.
// Creates a system user to own the main profiles.
// Idempotent — skips if main profiles already exist.
func (r *ProfileRepository) InitializeMainProfiles() error {
	// Check if already initialized
	var count int
	err := r.db.QueryRow(
		"SELECT COUNT(*) FROM profiles WHERE is_main_profile = true",
	).Scan(&count)
	if err != nil {
		return err
	}
	if count > 0 {
		return nil // Already seeded — nothing to do
	}

	// Create a system user to own the main profiles
	// ON CONFLICT handles the case where system user already exists
	var systemUserID string
	err = r.db.QueryRow(`
		INSERT INTO users (email, password_hash, full_name, is_active)
		VALUES ('system@localhost', 'system', 'System', false)
		ON CONFLICT (email) DO UPDATE SET email = 'system@localhost'
		RETURNING id
	`).Scan(&systemUserID)
	if err != nil {
		return err
	}

	// Insert each of the 3 main profiles
	for _, profile := range models.MainProfiles {
		profile.UserID = systemUserID
		if err := r.CreateMainProfile(systemUserID, &profile); err != nil {
			return err
		}
	}
	return nil
}

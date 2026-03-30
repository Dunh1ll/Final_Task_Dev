package database

import (
	"database/sql"
	"fmt"
	"log"

	"github.com/Dunh1ll/backend/internal/config"
	_ "github.com/lib/pq"
)

type DB struct {
	*sql.DB
}

func New(cfg *config.Config) (*DB, error) {
	dsn := fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		cfg.DBHost, cfg.DBPort, cfg.DBUser, cfg.DBPassword, cfg.DBName, cfg.DBSSLMode,
	)

	db, err := sql.Open("postgres", dsn)
	if err != nil {
		return nil, fmt.Errorf("failed to open database: %w", err)
	}

	if err := db.Ping(); err != nil {
		return nil, fmt.Errorf("failed to ping database: %w", err)
	}

	log.Println("Connected to PostgreSQL")
	return &DB{db}, nil
}

func (db *DB) Close() error {
	return db.DB.Close()
}

package main

import (
	"log"
	"os"

	"github.com/Dunh1ll/backend/internal/config"
	"github.com/Dunh1ll/backend/internal/database"
	"github.com/Dunh1ll/backend/internal/handlers"
	"github.com/Dunh1ll/backend/internal/middleware"
	"github.com/Dunh1ll/backend/internal/repository"
	"github.com/gin-gonic/gin"
)

func main() {
	// Load configuration from .env file
	// Contains: DB credentials, JWT secret, server port, environment
	cfg := config.Load()

	// Connect to PostgreSQL — creates a connection pool
	db, err := database.New(cfg)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer db.Close()

	// Run SQL migrations — creates tables if they don't exist
	if err := runMigrations(db); err != nil {
		log.Printf("Migration warning: %v", err)
	}

	// Create repositories — each handles DB queries for one table
	userRepo := repository.NewUserRepository(db.DB)
	profileRepo := repository.NewProfileRepository(db.DB)

	// Seed the 3 hardcoded main profiles on first startup
	// Skipped automatically if they already exist (idempotent)
	if err := profileRepo.InitializeMainProfiles(); err != nil {
		log.Printf("Failed to initialize main profiles: %v", err)
	}

	// Create handlers — they receive HTTP requests and call repositories
	authHandler := handlers.NewAuthHandler(userRepo, profileRepo, cfg)
	// NOTE: profileHandler now requires userRepo for DeleteSubUser
	// (deleting a sub user also deletes their user account)
	profileHandler := handlers.NewProfileHandler(profileRepo, userRepo)

	// Set Gin mode based on environment
	if cfg.Env == "production" {
		gin.SetMode(gin.ReleaseMode)
	}

	r := gin.Default()
	r.SetTrustedProxies(nil) // Suppress proxy trust warning

	// CORS middleware — allows Flutter Web (localhost) to call this API
	// Without CORS, the browser blocks all cross-origin requests
	r.Use(func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Methods",
			"GET, POST, PUT, DELETE, OPTIONS")
		c.Writer.Header().Set("Access-Control-Allow-Headers",
			"Origin, Content-Type, Accept, Authorization")

		// Handle browser preflight OPTIONS requests
		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}
		c.Next()
	})

	// ── Public routes — no token required ────────────────────────
	r.POST("/api/auth/register", authHandler.Register)
	r.POST("/api/auth/login", authHandler.Login)

	// ── Protected routes — Bearer token required ─────────────────
	api := r.Group("/api")
	api.Use(middleware.AuthMiddleware(cfg))
	{
		// Get profiles owned by the logged-in sub user
		api.GET("/profiles", profileHandler.GetMyProfiles)

		// Get the 3 hardcoded main profiles
		api.GET("/profiles/main", profileHandler.GetMainProfiles)

		// ✅ CRITICAL: /profiles/all and /profiles/public MUST be registered
		// BEFORE /profiles/:id — otherwise Gin treats "all" and "public"
		// as the :id parameter and routes them to GetProfile instead
		api.GET("/profiles/all", profileHandler.GetAllSubUsers)       // Main users only
		api.GET("/profiles/public", profileHandler.GetPublicProfiles) // All auth users

		// Get a single profile by UUID
		api.GET("/profiles/:id", profileHandler.GetProfile)

		// Create a new sub user profile
		api.POST("/profiles/sub", profileHandler.CreateSubUser)

		// Update an existing profile
		api.PUT("/profiles/:id", profileHandler.UpdateProfile)

		// Delete a profile (main users only)
		api.DELETE("/profiles/:id", profileHandler.DeleteSubUser)
	}

	// Health check endpoint — Flutter calls this on startup
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok"})
	})

	// Start the HTTP server
	addr := cfg.ServerHost + ":" + cfg.ServerPort
	log.Printf("Server starting on %s", addr)
	if err := r.Run(addr); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}

// runMigrations reads and executes the SQL migration file.
// This creates the users and profiles tables in PostgreSQL if they don't exist.
func runMigrations(db *database.DB) error {
	log.Println("Running database migrations...")

	migrationSQL, err := os.ReadFile("migrations/001_initial_schema.sql")
	if err != nil {
		return err
	}

	_, err = db.Exec(string(migrationSQL))
	if err != nil {
		return err
	}

	log.Println("Migrations completed successfully")
	return nil
}

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
	cfg := config.Load()

	db, err := database.New(cfg)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer db.Close()

	if err := runMigrations(db); err != nil {
		log.Printf("Migration warning: %v", err)
	}

	userRepo := repository.NewUserRepository(db.DB)
	profileRepo := repository.NewProfileRepository(db.DB)
	otpRepo := repository.NewOTPRepository(db.DB)

	if err := profileRepo.InitializeMainProfiles(); err != nil {
		log.Printf("Failed to initialize main profiles: %v", err)
	}

	authHandler := handlers.NewAuthHandler(
		userRepo, profileRepo, otpRepo, cfg)
	profileHandler := handlers.NewProfileHandler(
		profileRepo, userRepo)

	if cfg.Env == "production" {
		gin.SetMode(gin.ReleaseMode)
	}

	r := gin.Default()
	r.SetTrustedProxies(nil)

	// CORS
	r.Use(func(c *gin.Context) {
		c.Writer.Header().Set(
			"Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set(
			"Access-Control-Allow-Methods",
			"GET, POST, PUT, DELETE, OPTIONS")
		c.Writer.Header().Set(
			"Access-Control-Allow-Headers",
			"Origin, Content-Type, Accept, Authorization")
		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}
		c.Next()
	})

	// ── Public auth routes ─────────────────────────────────────

	// ✅ NEW: Registration now requires OTP verification
	// Step 1: Validate data + send OTP to Gmail
	r.POST("/api/auth/register/send-otp",
		authHandler.RegisterSendOTP)
	// Step 2: Verify OTP + create account
	r.POST("/api/auth/register/verify-otp",
		authHandler.RegisterVerifyOTP)

	// Login (unchanged)
	r.POST("/api/auth/login", authHandler.Login)

	// Forgot password — 3 steps
	r.POST("/api/auth/forgot-password/send-otp",
		authHandler.SendOTP)
	r.POST("/api/auth/forgot-password/verify-otp",
		authHandler.VerifyOTP)
	r.POST("/api/auth/forgot-password/reset",
		authHandler.ResetPassword)

	// ── Protected routes ───────────────────────────────────────
	api := r.Group("/api")
	api.Use(middleware.AuthMiddleware(cfg))
	{
		api.GET("/profiles", profileHandler.GetMyProfiles)
		api.GET("/profiles/main",
			profileHandler.GetMainProfiles)
		api.GET("/profiles/all",
			profileHandler.GetAllSubUsers)
		api.GET("/profiles/public",
			profileHandler.GetPublicProfiles)
		api.GET("/profiles/:id",
			profileHandler.GetProfile)
		api.POST("/profiles/sub",
			profileHandler.CreateSubUser)
		api.PUT("/profiles/:id",
			profileHandler.UpdateProfile)
		api.DELETE("/profiles/:id",
			profileHandler.DeleteSubUser)
	}

	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok"})
	})

	addr := cfg.ServerHost + ":" + cfg.ServerPort
	log.Printf("Server starting on %s", addr)
	if err := r.Run(addr); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}

func runMigrations(db *database.DB) error {
	log.Println("Running database migrations...")
	migrations := []string{
		"migrations/001_initial_schema.sql",
		"migrations/002_otp_table.sql",
	}
	for _, path := range migrations {
		sql, err := os.ReadFile(path)
		if err != nil {
			log.Printf("Migration %s not found: %v", path, err)
			continue
		}
		if _, err := db.Exec(string(sql)); err != nil {
			log.Printf("Migration %s warning: %v", path, err)
		} else {
			log.Printf("✅ Migration %s applied", path)
		}
	}
	log.Println("Migrations completed")
	return nil
}

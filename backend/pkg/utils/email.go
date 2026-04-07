package utils

import (
	"fmt"
	"net/smtp"
	"os"
	"strconv"
)

// EmailConfig holds SMTP connection settings.
// Values are read from environment variables set in .env
type EmailConfig struct {
	Host     string // e.g. smtp.gmail.com
	Port     int    // e.g. 587
	Username string // your Gmail address
	Password string // Gmail App Password (NOT your regular password)
}

// LoadEmailConfig reads SMTP settings from environment variables.
// Required .env variables:
//
//	SMTP_HOST=smtp.gmail.com
//	SMTP_PORT=587
//	SMTP_USER=yourapp@gmail.com
//	SMTP_PASS=xxxx xxxx xxxx xxxx   (Gmail App Password)
func LoadEmailConfig() EmailConfig {
	port, _ := strconv.Atoi(os.Getenv("SMTP_PORT"))
	if port == 0 {
		port = 587 // Default Gmail SMTP port
	}
	return EmailConfig{
		Host:     os.Getenv("SMTP_HOST"),
		Port:     port,
		Username: os.Getenv("SMTP_USER"),
		Password: os.Getenv("SMTP_PASS"),
	}
}

// SendOTPEmail sends a 6-digit OTP to the given Gmail address.
//
// HOW TO SET UP GMAIL SMTP:
//  1. Go to your Google Account → Security
//  2. Enable 2-Step Verification (required for App Passwords)
//  3. Go to Security → App Passwords
//  4. Select app: Mail, Select device: Other → type "ProfileApp"
//  5. Google gives you a 16-character password like "xxxx xxxx xxxx xxxx"
//  6. Put that in your .env as SMTP_PASS (spaces are fine)
//
// IMPORTANT: Use an App Password NOT your regular Gmail password.
// Regular passwords are blocked by Google for SMTP.
func SendOTPEmail(toEmail string, otpCode string, cfg EmailConfig) error {
	// Validate config is set
	if cfg.Host == "" || cfg.Username == "" || cfg.Password == "" {
		return fmt.Errorf("SMTP configuration is incomplete. " +
			"Please set SMTP_HOST, SMTP_USER, SMTP_PASS in .env")
	}

	// Gmail SMTP authentication
	auth := smtp.PlainAuth(
		"",
		cfg.Username,
		cfg.Password,
		cfg.Host,
	)

	// Build email content
	from := cfg.Username
	to := []string{toEmail}
	subject := "Your Profile App Password Reset OTP"
	body := buildOTPEmailBody(otpCode)

	// Full RFC 822 email format
	message := []byte(fmt.Sprintf(
		"From: Profile App <%s>\r\n"+
			"To: %s\r\n"+
			"Subject: %s\r\n"+
			"MIME-Version: 1.0\r\n"+
			"Content-Type: text/html; charset=UTF-8\r\n"+
			"\r\n"+
			"%s",
		from, toEmail, subject, body,
	))

	// Send via Gmail SMTP TLS port 587
	addr := fmt.Sprintf("%s:%d", cfg.Host, cfg.Port)
	err := smtp.SendMail(addr, auth, from, to, message)
	if err != nil {
		return fmt.Errorf("failed to send OTP email: %w", err)
	}

	return nil
}

// buildOTPEmailBody returns an HTML email body with the OTP code.
func buildOTPEmailBody(otpCode string) string {
	return fmt.Sprintf(`
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Password Reset OTP</title>
</head>
<body style="font-family: Arial, sans-serif; background-color: #0f0f1a; 
            color: #ffffff; padding: 40px; text-align: center;">
<div style="max-width: 480px; margin: 0 auto; 
            background: rgba(255,255,255,0.05);
            border: 1px solid rgba(34,197,94,0.3);
            border-radius: 16px; padding: 40px;">
    
    <h1 style="color: #86efac; font-size: 24px; margin-bottom: 8px;">
    Password Reset
    </h1>
    <p style="color: rgba(255,255,255,0.6); font-size: 14px;">
    Profile Carousel App
    </p>

    <hr style="border: none; border-top: 1px solid rgba(255,255,255,0.1); 
            margin: 24px 0;" />

    <p style="color: rgba(255,255,255,0.8); font-size: 15px;">
    Your One-Time Password (OTP) is:
    </p>

    <div style="background: rgba(34,197,94,0.1);
                border: 2px solid rgba(34,197,94,0.4);
                border-radius: 12px; padding: 24px; margin: 20px 0;">
    <span style="font-size: 42px; font-weight: 900; 
                letter-spacing: 12px; color: #ffffff;
                font-family: monospace;">
        %s
    </span>
    </div>

    <p style="color: rgba(255,255,255,0.5); font-size: 13px;">
    This OTP is valid for <strong style="color: #86efac;">10 minutes</strong>.
    <br>Do not share this code with anyone.
    </p>

    <hr style="border: none; border-top: 1px solid rgba(255,255,255,0.1); 
            margin: 24px 0;" />

    <p style="color: rgba(255,255,255,0.3); font-size: 11px;">
    If you did not request a password reset, ignore this email.
    </p>
</div>
</body>
</html>
`, otpCode)
}

package utils

import (
	"encoding/base64"
	"fmt"
	"net/smtp"
	"os"
	"path/filepath"
	"strconv"
)

// EmailConfig holds SMTP connection settings.
type EmailConfig struct {
	Host     string
	Port     int
	Username string
	Password string
}

// LoadEmailConfig reads SMTP settings from environment variables.
func LoadEmailConfig() EmailConfig {
	port, _ := strconv.Atoi(os.Getenv("SMTP_PORT"))
	if port == 0 {
		port = 587
	}
	return EmailConfig{
		Host:     os.Getenv("SMTP_HOST"),
		Port:     port,
		Username: os.Getenv("SMTP_USER"),
		Password: os.Getenv("SMTP_PASS"),
	}
}

// logoBase64 reads the logo from disk and returns it as a base64 string.
// The logo is embedded inline in the email so it shows without a public URL.
//
// WHERE TO PUT THE LOGO IMAGE:
//
//	Place your logo file at this path in your Go backend project:
//	backend/assets/email_logo.png
//
//	Supported formats: PNG, JPG, JPEG, GIF, WebP
//	Recommended size: 200x60 pixels or similar wide/short ratio
//	File name must be exactly: email_logo.png
//
// If the file is not found, the email sends without a logo (no crash).
func logoBase64() (string, string) {
	// Try multiple possible paths since working directory can vary
	possiblePaths := []string{
		"assets/email_logo.png",
		"../assets/email_logo.png",
		"../../assets/email_logo.png",
		filepath.Join("assets", "email_logo.png"),
	}

	for _, path := range possiblePaths {
		data, err := os.ReadFile(path)
		if err == nil {
			encoded := base64.StdEncoding.EncodeToString(data)
			// Detect mime type from extension
			ext := filepath.Ext(path)
			mime := "image/png"
			switch ext {
			case ".jpg", ".jpeg":
				mime = "image/jpeg"
			case ".gif":
				mime = "image/gif"
			case ".webp":
				mime = "image/webp"
			}
			return encoded, mime
		}
	}

	// Return empty if logo not found — email still sends fine
	return "", ""
}

// SendOTPEmail sends a 6-digit OTP to the given Gmail address.
// The email includes the app logo embedded as base64 inline image.
//
// SMTP SETUP:
//  1. Google Account → Security → 2-Step Verification (enable)
//  2. Google Account → Security → App Passwords
//  3. Create password: Mail + Other → name "ProfileApp"
//  4. Add to .env: SMTP_PASS=xxxx xxxx xxxx xxxx
func SendOTPEmail(
	toEmail string,
	otpCode string,
	cfg EmailConfig,
	purpose string, // "reset" or "register"
) error {
	if cfg.Host == "" || cfg.Username == "" || cfg.Password == "" {
		return fmt.Errorf("SMTP configuration incomplete. " +
			"Set SMTP_HOST, SMTP_USER, SMTP_PASS in .env")
	}

	auth := smtp.PlainAuth("", cfg.Username, cfg.Password, cfg.Host)

	from := cfg.Username
	to := []string{toEmail}

	// Determine email content based on purpose
	subject := "Your Profile App Verification Code"
	heading := "Email Verification"
	subtext := "You requested to create an account on Profile Carousel."
	if purpose == "reset" {
		subject = "Your Profile App Password Reset Code"
		heading = "Password Reset"
		subtext = "You requested to reset your password on Profile Carousel."
	}

	body := buildOTPEmailBody(otpCode, heading, subtext)

	message := []byte(fmt.Sprintf(
		"From: Profile Carousel <%s>\r\n"+
			"To: %s\r\n"+
			"Subject: %s\r\n"+
			"MIME-Version: 1.0\r\n"+
			"Content-Type: text/html; charset=UTF-8\r\n"+
			"\r\n"+
			"%s",
		from, toEmail, subject, body,
	))

	addr := fmt.Sprintf("%s:%d", cfg.Host, cfg.Port)
	return smtp.SendMail(addr, auth, from, to, message)
}

// buildOTPEmailBody returns a modern green-themed HTML email with inline logo.
func buildOTPEmailBody(otpCode, heading, subtext string) string {
	// Embed logo as base64 inline image
	logoData, logoMime := logoBase64()
	logoHTML := ""
	if logoData != "" {
		logoHTML = fmt.Sprintf(`
		<div style="text-align: center; margin-bottom: 28px;">
		    <img
		    src="data:%s;base64,%s"
		    alt="Profile Carousel Logo"
		    style="height: 56px; width: auto; object-fit: contain;"
		    />
		</div>`, logoMime, logoData)
	} else {
		// Fallback text logo if image not found
		logoHTML = `
		<div style="text-align: center; margin-bottom: 28px;">
		    <div style="
		    display: inline-block;
		    background: linear-gradient(135deg, #16a34a, #22c55e);
		    color: #ffffff;
		    font-size: 18px;
		    font-weight: 800;
		    letter-spacing: 2px;
		    padding: 10px 24px;
		    border-radius: 10px;
		    ">PROFILE CAROUSEL</div>
		</div>`
	}

	return fmt.Sprintf(`<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>OTP Verification</title>
</head>
<body style="
margin: 0;
padding: 0;
background-color: #050510;
font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI',
            Roboto, Helvetica, Arial, sans-serif;
">
<!-- Outer wrapper -->
<table width="100%%" cellpadding="0" cellspacing="0" border="0"
        style="background-color: #050510; padding: 48px 16px;">
    <tr>
    <td align="center">
        <!-- Card -->
        <table width="520" cellpadding="0" cellspacing="0" border="0"
            style="
                background: linear-gradient(160deg, #0d1f14 0%%, #0a0a1a 60%%);
                border-radius: 20px;
                border: 1px solid rgba(34,197,94,0.25);
                box-shadow: 0 0 60px rgba(34,197,94,0.08),
                            0 24px 80px rgba(0,0,0,0.6);
                overflow: hidden;
            ">

        <!-- Green top accent bar -->
        <tr>
            <td style="
            background: linear-gradient(90deg, #16a34a, #22c55e, #4ade80, #22c55e, #16a34a);
            height: 4px;
            font-size: 0;
            line-height: 0;
            ">&nbsp;</td>
        </tr>

        <!-- Card body -->
        <tr>
            <td style="padding: 44px 48px 40px;">

            <!-- Logo section -->
            %s

            <!-- Divider -->
            <div style="
                height: 1px;
                background: linear-gradient(90deg,
                transparent, rgba(34,197,94,0.3), transparent);
                margin-bottom: 32px;
            "></div>

            <!-- Heading -->
            <h1 style="
                margin: 0 0 10px 0;
                font-size: 26px;
                font-weight: 800;
                color: #ffffff;
                text-align: center;
                letter-spacing: -0.5px;
            ">%s</h1>

            <!-- Subtext -->
            <p style="
                margin: 0 0 32px 0;
                font-size: 14px;
                color: rgba(255,255,255,0.5);
                text-align: center;
                line-height: 1.6;
            ">%s</p>

            <!-- OTP label -->
            <p style="
                margin: 0 0 12px 0;
                font-size: 12px;
                font-weight: 700;
                color: #86efac;
                text-align: center;
                letter-spacing: 3px;
                text-transform: uppercase;
            ">Your Verification Code</p>

            <!-- OTP box -->
            <div style="
                background: linear-gradient(135deg,
                rgba(34,197,94,0.08), rgba(74,222,128,0.04));
                border: 2px solid rgba(34,197,94,0.35);
                border-radius: 16px;
                padding: 28px 20px;
                text-align: center;
                margin-bottom: 28px;
                position: relative;
            ">
                <!-- Subtle corner dots for modern feel -->
                <div style="
                font-size: 48px;
                font-weight: 900;
                letter-spacing: 18px;
                color: #ffffff;
                font-family: 'Courier New', Courier, monospace;
                text-shadow: 0 0 30px rgba(34,197,94,0.4);
                padding-left: 18px;
                ">%s</div>
            </div>

            <!-- Expiry notice -->
            <table width="100%%" cellpadding="0" cellspacing="0" border="0"
                    style="margin-bottom: 28px;">
                <tr>
                <td align="center">
                    <div style="
                    display: inline-block;
                    background: rgba(234,179,8,0.08);
                    border: 1px solid rgba(234,179,8,0.25);
                    border-radius: 8px;
                    padding: 10px 18px;
                    ">
                    <span style="
                        font-size: 13px;
                        color: rgba(234,179,8,0.9);
                        font-weight: 500;
                    ">&#9203; This code expires in <strong>10 minutes</strong></span>
                    </div>
                </td>
                </tr>
            </table>

            <!-- Security tips -->
            <div style="
                background: rgba(255,255,255,0.03);
                border: 1px solid rgba(255,255,255,0.07);
                border-radius: 10px;
                padding: 16px 20px;
                margin-bottom: 32px;
            ">
                <p style="
                margin: 0 0 8px 0;
                font-size: 12px;
                font-weight: 700;
                color: rgba(255,255,255,0.5);
                letter-spacing: 1px;
                text-transform: uppercase;
                ">Security Reminder</p>
                <p style="
                margin: 0;
                font-size: 13px;
                color: rgba(255,255,255,0.35);
                line-height: 1.6;
                ">Never share this code with anyone.
                Profile Carousel staff will never ask for your OTP.
                If you did not request this, please ignore this email.</p>
            </div>

            <!-- Divider -->
            <div style="
                height: 1px;
                background: linear-gradient(90deg,
                transparent, rgba(255,255,255,0.08), transparent);
                margin-bottom: 24px;
            "></div>

            <!-- Footer -->
            <p style="
                margin: 0;
                font-size: 12px;
                color: rgba(255,255,255,0.2);
                text-align: center;
                line-height: 1.8;
            ">
                &copy; 2026 Profile Carousel &middot; Built with Flutter &amp; Go<br>
                <span style="color: rgba(34,197,94,0.4);">
                This is an automated message, please do not reply.
                </span>
            </p>

            </td>
        </tr>

        <!-- Green bottom accent bar -->
        <tr>
            <td style="
            background: linear-gradient(90deg, #16a34a, #22c55e, #4ade80, #22c55e, #16a34a);
            height: 4px;
            font-size: 0;
            line-height: 0;
            ">&nbsp;</td>
        </tr>

        </table>
        <!-- End card -->

    </td>
    </tr>
</table>
</body>
</html>`,
		logoHTML, heading, subtext, otpCode)
}

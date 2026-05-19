package utils

import (
	"fmt"
	"net/smtp"
	"os"
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

// SendOTPEmail sends a styled OTP email with a One Piece theme.
//
// FIX 1: Removed base64 inline logo — Gmail strips/blocks large data URIs
//
//	and the encoded image was pushing the email over Gmail's 102KB
//	clip limit, hiding the OTP and all body content.
//
// FIX 2: Replaced inline logo with a styled text badge (no external image
//
//	needed, always renders correctly in all email clients).
//
// FIX 3: Trimmed overall HTML size to stay well under 102KB.
// FIX 4: Rethemed from green to One Piece (gold / crimson / parchment).
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

	subject := "Your PiraTern Profile Verification Code"
	heading := "Email Verification"
	subtext := "You requested to create an account on PiraTern Profiles."
	if purpose == "reset" {
		subject = "Your PiraTern Profile Password Reset Code"
		heading = "Password Reset"
		subtext = "You requested to reset your password on PiraTern Profiles."
	}

	body := buildOTPEmailBody(otpCode, heading, subtext)

	message := []byte(fmt.Sprintf(
		"From: PiraTern Profiles <%s>\r\n"+
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

// buildOTPEmailBody returns a One Piece themed HTML email.
// Kept intentionally compact to stay under Gmail's 102KB clip threshold.
//
// ONE PIECE PALETTE:
//   - Background:  #0D0800  (dark sea at night)
//   - Card:        #1A0A00  (dark wood)
//   - Gold accent: #D4A017  (treasure gold)
//   - Bright gold: #FFD700  (Straw Hat gold)
//   - Crimson:     #8B1A1A  (Marine flag red)
//   - Parchment:   #F5DEB3  (wanted poster paper)
//   - Aged gold:   #8B6914  (poster border)
func buildOTPEmailBody(otpCode, heading, subtext string) string {
	return fmt.Sprintf(`<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>%s</title>
</head>
<body style="margin:0;padding:0;background:#0D0800;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Arial,sans-serif;">

<table width="100%%" cellpadding="0" cellspacing="0" border="0" style="background:#0D0800;padding:40px 16px;">
<tr><td align="center">

<!-- Card -->
<table width="520" cellpadding="0" cellspacing="0" border="0" style="background:#1A0A00;border-radius:16px;border:1px solid #8B6914;box-shadow:0 0 40px rgba(212,160,23,0.15),0 20px 60px rgba(0,0,0,0.7);overflow:hidden;">

    <!-- Gold top bar -->
    <tr>
    <td style="background:linear-gradient(90deg,#8B1A1A,#D4A017,#FFD700,#D4A017,#8B1A1A);height:4px;font-size:0;line-height:0;">&nbsp;</td>
    </tr>

    <!-- Body -->
    <tr><td style="padding:40px 44px 36px;">

    <!-- Text logo badge -->
    <div style="text-align:center;margin-bottom:28px;">
        <div style="display:inline-block;background:linear-gradient(135deg,#8B1A1A,#1A0A00);border:2px solid #D4A017;border-radius:10px;padding:10px 28px;">
        <span style="font-size:11px;font-weight:900;letter-spacing:4px;color:#FFD700;text-transform:uppercase;">&#9875; PIRATERN PROFILES</span>
        </div>
    </div>

    <!-- Gold divider -->
    <div style="height:1px;background:linear-gradient(90deg,transparent,#D4A017,transparent);margin-bottom:28px;"></div>

    <!-- Heading -->
    <h1 style="margin:0 0 10px 0;font-size:24px;font-weight:800;color:#F5DEB3;text-align:center;letter-spacing:-0.5px;">%s</h1>

    <!-- Subtext -->
    <p style="margin:0 0 28px 0;font-size:13px;color:rgba(245,222,179,0.5);text-align:center;line-height:1.6;">%s</p>

    <!-- OTP label -->
    <p style="margin:0 0 10px 0;font-size:11px;font-weight:700;color:#D4A017;text-align:center;letter-spacing:3px;text-transform:uppercase;">&#9876; Your Verification Code</p>

    <!-- OTP box -->
    <div style="background:linear-gradient(135deg,rgba(212,160,23,0.08),rgba(139,26,26,0.06));border:2px solid rgba(212,160,23,0.4);border-radius:14px;padding:26px 20px;text-align:center;margin-bottom:24px;">
        <span style="font-size:46px;font-weight:900;letter-spacing:16px;color:#FFD700;font-family:'Courier New',monospace;text-shadow:0 0 24px rgba(255,215,0,0.35);padding-left:16px;">%s</span>
    </div>

    <!-- Expiry -->
    <table width="100%%" cellpadding="0" cellspacing="0" border="0" style="margin-bottom:24px;">
        <tr><td align="center">
        <div style="display:inline-block;background:rgba(139,26,26,0.15);border:1px solid rgba(139,26,26,0.4);border-radius:8px;padding:9px 18px;">
            <span style="font-size:12px;color:#F5DEB3;font-weight:600;">&#9203; This code expires in <strong style="color:#FFD700;">10 minutes</strong></span>
        </div>
        </td></tr>
    </table>

    <!-- Security box -->
    <div style="background:rgba(245,222,179,0.03);border:1px solid rgba(245,222,179,0.08);border-radius:10px;padding:14px 18px;margin-bottom:28px;">
        <p style="margin:0 0 6px 0;font-size:11px;font-weight:700;color:rgba(245,222,179,0.4);letter-spacing:1px;text-transform:uppercase;">Security Reminder</p>
        <p style="margin:0;font-size:12px;color:rgba(245,222,179,0.3);line-height:1.6;">Never share this code with anyone. PiraTern Profiles staff will never ask for your OTP. If you did not request this, please ignore this email.</p>
    </div>

    <!-- Thin divider -->
    <div style="height:1px;background:linear-gradient(90deg,transparent,rgba(212,160,23,0.2),transparent);margin-bottom:20px;"></div>

    <!-- Footer -->
    <p style="margin:0;font-size:11px;color:rgba(245,222,179,0.2);text-align:center;line-height:1.8;">
        &copy; 2026 PiraTern Profiles &middot; Built with Flutter &amp; Go<br>
        <span style="color:rgba(212,160,23,0.35);">This is an automated message, please do not reply.</span>
    </p>

    </td></tr>

    <!-- Gold bottom bar -->
    <tr>
    <td style="background:linear-gradient(90deg,#8B1A1A,#D4A017,#FFD700,#D4A017,#8B1A1A);height:4px;font-size:0;line-height:0;">&nbsp;</td>
    </tr>

</table>
<!-- End card -->

</td></tr>
</table>
</body>
</html>`,
		heading, heading, subtext, otpCode)
}

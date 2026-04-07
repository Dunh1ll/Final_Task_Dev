-- OTP table for forgot-password verification
-- Each row stores one OTP attempt for one email address
-- OTPs expire after 10 minutes and can only be used once

CREATE TABLE IF NOT EXISTS otps (
    id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    email      TEXT        NOT NULL,
    code_hash  TEXT        NOT NULL,       -- bcrypt hash of the 6-digit OTP
    expires_at TIMESTAMPTZ NOT NULL,       -- 10 minutes from creation
    used       BOOLEAN     NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index on email so lookup by email is fast
CREATE INDEX IF NOT EXISTS idx_otps_email ON otps (email);

-- Index on expires_at for cleanup queries
CREATE INDEX IF NOT EXISTS idx_otps_expires ON otps (expires_at);
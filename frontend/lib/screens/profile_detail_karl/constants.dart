import 'package:flutter/material.dart';

class KC {
  // ── Base Background Layers ─────────────────────────────────────
  static const bg       = Color(0xFF0A192F); // deep navy
  static const bgLight  = Color(0xFF112240); // slightly lighter navy
  static const bgCard   = Color(0xFF1D2D50); // card surface
  static const navy     = Color(0xFF0A192F);

  // ── Text ───────────────────────────────────────────────────────
  static const textPrimary   = Color(0xFFCCD6F6); // light slate
  static const textSecondary = Color(0xFF8892B0); // slate
  static const textMuted     = Color(0xFF4A5568); // dark slate

  // ── Accent ─────────────────────────────────────────────────────
  static const mint     = Color(0xFF64FFDA); // primary accent
  static const mintDim  = Color(0xFF64FFDA); // same, used with opacity

  // ── Borders ────────────────────────────────────────────────────
  static const border   = Color(0xFF233554); // subtle border

  // ── Legacy aliases (keep so shared widgets still compile) ──────
  static const text    = textPrimary;
  static const muted   = textSecondary;
  static const hint    = textMuted;
  static const amber   = mint;      // map old amber → mint
  static const blue    = Color(0xFF57CBFF);
  static const purple  = Color(0xFFBD93F9);
  static const green   = mint;
  static const rose    = Color(0xFFFF6B9D);
  static const card    = bgCard;
  static const surface = bgLight;
}

enum KTab { home, about, experience, projects, contact }
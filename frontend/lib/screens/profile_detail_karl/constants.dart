import 'package:flutter/material.dart';

class KC {
  // ── Core Palette ────────────────────────────────────────────────
  static const bg = Color(0xFFF5ECD7);           
  static const bgLight = Color(0xFFEFE5CE);      
  static const bgCard = Color(0xFFF7F0E0);       
  static const border = Color(0xFFD4A5A5);       
  static const borderStr = Color(0xFF8B3A4A);    

  // ── Text ────────────────────────────────────────────────
  static const textPrimary = Color(0xFF3D0A15);   
  static const textSecondary = Color(0xFF5C1020); 
  static const textMuted = Color(0xFF7A2538);     
  static const textDim = Color(0xFF9B4055);       

  // ── Accent ─────────────────────────────────────────────────────
  static const white = Color(0xFF3D0A15);          
  static const accent = Color(0xFF3D0A15);         

  // ── Legacy aliases ─────────────────────────────────────────────
  static const navy = bg;
  static const mint = white;
  static const amber = white;
  static const text = textPrimary;
  static const muted = textSecondary;
  static const hint = textMuted;
  static const card = bgCard;
  static const surface = bgLight;

  // ── Typography ─────────────────────────────────────────────────
  static const fontDisplay = 'SpaceGrotesk';
  static const fontMono = 'IBMPlexMono';

  // ── BOLD TEXT STYLES (using IBMPlexMono Bold/Medium) ───────────
  
  // For headings and important text
  static const TextStyle monoBold = TextStyle(
    fontFamily: fontMono,
    fontWeight: FontWeight.w700,
    fontSize: 14,
    letterSpacing: 0.3,
    color: textPrimary,
  );
  
  // For body text and descriptions
  static const TextStyle monoMedium = TextStyle(
    fontFamily: fontMono,
    fontWeight: FontWeight.w500,
    fontSize: 13,
    letterSpacing: 0.2,
    color: textSecondary,
  );
  
  // For labels and metadata (still readable)
  static const TextStyle monoLabel = TextStyle(
    fontFamily: fontMono,
    fontWeight: FontWeight.w600,  // Bold but small
    fontSize: 9,
    letterSpacing: 2,
    color: textDim,
  );
  
  // For chips and tags
  static const TextStyle monoChip = TextStyle(
    fontFamily: fontMono,
    fontWeight: FontWeight.w600,
    fontSize: 10,
    letterSpacing: 2,
    color: textMuted,
  );
}

enum KTab { home, about, experience, projects, contact }
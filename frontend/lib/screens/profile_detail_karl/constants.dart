import 'package:flutter/material.dart';

class KC {
  // ── Core Palette ───────────────────────────────────────────────
  static const bg        = Color(0xFF080808); // near-black
  static const bgLight   = Color(0xFF111111); // subtle lift
  static const bgCard    = Color(0xFF181818); // card surface
  static const border    = Color(0xFF242424); // subtle divider
  static const borderStr = Color(0xFFEDEDED); // strong border

  // ── Text ───────────────────────────────────────────────────────
  static const textPrimary   = Color(0xFFEDEDED); // near-white
  static const textSecondary = Color(0xFFCCCCCC); // readable grey
  static const textMuted     = Color(0xFFAAAAAA); // readable
  static const textDim       = Color(0xFF777777); // soft

  // ── Accent — monochrome only ───────────────────────────────────
  static const white   = Color(0xFFEDEDED);
  static const accent  = Color(0xFFEDEDED); // same as white

  // ── Legacy aliases ─────────────────────────────────────────────
  static const navy    = bg;
  static const mint    = white;
  static const amber   = white;
  static const text    = textPrimary;
  static const muted   = textSecondary;
  static const hint    = textMuted;
  static const card    = bgCard;
  static const surface = bgLight;

  // ── Typography ─────────────────────────────────────────────────
  // Display font: SpaceGrotesk-Black (weight 900)
  // Body/mono font: IBMPlexMono
  static const fontDisplay = 'SpaceGrotesk';
  static const fontMono    = 'IBMPlexMono';
}

enum KTab { home, about, experience, projects, contact }
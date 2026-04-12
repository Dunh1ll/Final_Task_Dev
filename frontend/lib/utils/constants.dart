import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────
// ONE PIECE THEME — Asset Paths
// ─────────────────────────────────────────────────────────────────
class AssetPaths {
  static const String logo = 'assets/images/logo.png';

  // Two home background videos: light = home1, dark = home2
  static const String homeVideoLight = 'assets/videos/home1.mp4';
  static const String homeVideoDark = 'assets/videos/home2.mp4';

  static const String loginBackgroundVideo = 'assets/videos/livebackground.mp4';
  static const String dashboardBackgroundVideo =
      'assets/videos/dashboard_bg.mp4';
  static const String subDashboardBackgroundVideo =
      'assets/videos/subdashboard.mp4';
  static const String defaultAvatar = 'assets/images/default_avatar.jpg';
  static const String defaultCover = 'assets/images/default_cover.jpg';
}

// ─────────────────────────────────────────────────────────────────
// ONE PIECE THEME — Colors
// ─────────────────────────────────────────────────────────────────
class AppColors {
  // Primary accent — gold like Berry (฿) and treasure
  static const Color primaryBlue = Color(0xFFD4A017);
  static const Color primaryGold = Color(0xFFD4A017);

  // Deep crimson — Marine flag
  static const Color darkGreen = Color(0xFF8B1A1A);
  static const Color crimson = Color(0xFF8B1A1A);

  // Bright gold — Straw Hat, treasure chests
  static const Color lightGreen = Color(0xFFFFD700);
  static const Color brightGold = Color(0xFFFFD700);

  // Parchment — wanted poster paper background
  static const Color parchment = Color(0xFFF5DEB3);
  static const Color dirtyWhite = Color(0xFFF5DEB3);

  // Aged gold — poster borders, frames
  static const Color agedGold = Color(0xFF8B6914);

  // Dark background — sea at night
  static const Color darkBackground = Color(0xFF1A0A00);
  static const Color darkGray = Color(0xFF1A0A00);

  // Card surface — dark wood panels
  static const Color cardSurface = Color(0xFF2C1A00);

  // Navy blue — Marine uniform
  static const Color navyBlue = Color(0xFF1C3A5C);

  // Text on dark — faded parchment
  static const Color lightGray = Color(0xFFC8A96E);

  // Glow — gold shimmer
  static const Color greenGlow = Color(0xFFD4A017);

  // ✅ Alias kept for compatibility with existing widgets
  // that still reference AppColors.primaryBlue
  // (points to gold — intentional One Piece override)
}

// ─────────────────────────────────────────────────────────────────
// APP DURATIONS — Animation timing constants
//
// ✅ FIXED: Re-added AppDurations which was removed in the
// One Piece theme rewrite, causing compile errors in widgets
// that reference AppDurations.cardHover etc.
// ─────────────────────────────────────────────────────────────────
class AppDurations {
  /// Card hover scale animation duration
  static const Duration cardHover = Duration(milliseconds: 200);

  /// Screen/page transition animation duration
  static const Duration pageTransition = Duration(milliseconds: 300);

  /// Subtle pulse animation for interactive elements
  static const Duration pulse = Duration(milliseconds: 1500);
}

// ─────────────────────────────────────────────────────────────────
// CARD EFFECTS — Profile card visual constants
//
// ✅ FIXED: Re-added CardEffects which was removed in the
// One Piece theme rewrite, causing compile errors in widgets
// that reference CardEffects.hoverScale etc.
// ─────────────────────────────────────────────────────────────────
class CardEffects {
  /// Scale factor applied when mouse hovers over a card
  static const double hoverScale = 1.02;

  /// Scale factor for the centered/active card in carousel
  static const double centerScale = 1.05;

  /// Scale factor for side cards (slightly smaller for depth)
  static const double defaultScale = 0.9;

  /// Strong shadow shown on hover — gold tinted (One Piece)
  static List<BoxShadow> hoverShadow = [
    BoxShadow(
      color: const Color(0xFFD4A017).withOpacity(0.35),
      blurRadius: 20,
      spreadRadius: 2,
      offset: const Offset(0, 10),
    ),
  ];

  /// Default subtle shadow for non-hovered cards
  static List<BoxShadow> defaultShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 10,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];
}

// ─────────────────────────────────────────────────────────────────
// MAIN USER CONFIG — unchanged
// ─────────────────────────────────────────────────────────────────
class MainUserConfig {
  static const List<String> emails = [
    'pallen@main.com',
    'karl@main.com',
    'aldhy@main.com',
  ];

  static const Map<String, String> emailToProfileId = {
    'pallen@main.com': 'profile_1',
    'karl@main.com': 'profile_2',
    'aldhy@main.com': 'profile_3',
  };

  static bool isMainEmail(String email) => emails.contains(email);

  static String? getProfileId(String email) => emailToProfileId[email];
}

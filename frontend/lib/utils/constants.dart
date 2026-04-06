import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────
// ASSET PATHS
// Centralized file paths for all images and videos used in the app.
// Update filenames here instead of hunting through every screen.
// ─────────────────────────────────────────────────────────────────
class AssetPaths {
  /// App logo shown on login, register, and home screens
  static const String logo = 'assets/images/logo.png';

  /// Video background for login and register screens
  static const String loginBackgroundVideo = 'assets/videos/livebackground.mp4';

  /// Video background for the main dashboard carousel screen
  static const String dashboardBackgroundVideo =
      'assets/videos/dashboard_bg.mp4';

  /// Video background for the sub user dashboard screen
  static const String subDashboardBackgroundVideo =
      'assets/videos/subdashboard.mp4';

  /// Default profile picture — shown when no photo has been uploaded
  /// Used as fallback in ImageHelper.buildProvider()
  static const String defaultAvatar = 'assets/images/default_avatar.jpg';

  /// Default cover photo — shown when no cover has been uploaded
  static const String defaultCover = 'assets/images/default_cover.jpg';
}

// ─────────────────────────────────────────────────────────────────
// COLORS — Green Theme
//
// All color accents use green shades for a modern aesthetic feel.
// These are used consistently across all screens and widgets.
// ─────────────────────────────────────────────────────────────────
class AppColors {
  /// Off-white card background — used for profile cards
  static const Color dirtyWhite = Color(0xFFF0F2F5);

  /// Primary green — main buttons, active states, highlights
  /// ✅ Changed from blue to green for consistent green theme
  static const Color primaryBlue = Color(0xFF22C55E); // green-500

  /// Dark gray — primary text on light backgrounds
  static const Color darkGray = Color(0xFF1A1A2E);

  /// Light gray — secondary text, captions, placeholders
  static const Color lightGray = Color(0xFF6B7280);

  /// Dark green — hover glow, role badges, accent borders
  static const Color darkGreen = Color(0xFF16A34A); // green-600

  /// Light green — used for text labels on dark backgrounds
  static const Color lightGreen = Color(0xFF86EFAC); // green-300

  /// Deep dark background — used for cards and panels
  static const Color darkBackground = Color(0xFF0F172A);

  /// Card surface color — slightly lighter than background
  static const Color cardSurface = Color(0xFF1E293B);

  /// Green glow color — used for shadow effects on hover
  static const Color greenGlow = Color(0xFF4ADE80); // green-400
}

// ─────────────────────────────────────────────────────────────────
// DURATIONS — Animation timing constants
// Keeping these centralized ensures consistent animation speeds
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
// Controls scaling and shadows at different interaction states
// ─────────────────────────────────────────────────────────────────
class CardEffects {
  /// Scale factor applied when mouse hovers over a card
  static const double hoverScale = 1.02;

  /// Scale factor for the centered/active card in the carousel
  static const double centerScale = 1.05;

  /// Scale factor for side cards (slightly smaller for depth)
  static const double defaultScale = 0.9;

  /// Strong shadow shown on hover — green tinted
  static List<BoxShadow> hoverShadow = [
    BoxShadow(
      color: AppColors.primaryBlue.withOpacity(0.3),
      blurRadius: 20,
      spreadRadius: 2,
      offset: const Offset(0, 10),
    ),
  ];

  /// Default subtle shadow for non-hovered cards
  static List<BoxShadow> defaultShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 10,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];
}

// ─────────────────────────────────────────────────────────────────
// MAIN USER CONFIG
//
// Maps main user emails to their Flutter profile model IDs.
// Must match HardcodedMainUsers in Go backend models.go.
// ─────────────────────────────────────────────────────────────────
class MainUserConfig {
  /// All hardcoded main user email addresses
  static const List<String> emails = [
    'pallen@main.com',
    'karl@main.com',
    'aldhy@main.com',
  ];

  /// Maps email → Flutter profile ID (profile_1/2/3)
  /// profile_1 = PallenPrinceDunhill
  /// profile_2 = AlbanielKarlAngelo
  /// profile_3 = FajardoAldhy
  static const Map<String, String> emailToProfileId = {
    'pallen@main.com': 'profile_1',
    'karl@main.com': 'profile_2',
    'aldhy@main.com': 'profile_3',
  };

  /// Returns true if the email belongs to a hardcoded main user
  static bool isMainEmail(String email) => emails.contains(email);

  /// Returns the Flutter profile ID for a main user email
  /// Returns null if email is not a main user
  static String? getProfileId(String email) => emailToProfileId[email];
}

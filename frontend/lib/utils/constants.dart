import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────
// ASSET PATHS
//
// All file paths for images and videos used in the app.
// Centralizing them here means you only need to update one place
// if a file is renamed or moved.
// ─────────────────────────────────────────────────────────────────

class AssetPaths {
  /// App logo shown on login and register screens
  static const String logo = 'assets/images/logo.png';

  /// Video background for login and register screens
  static const String loginBackgroundVideo = 'assets/videos/livebackground.mp4';

  /// Video background for the main dashboard screen
  static const String dashboardBackgroundVideo =
      'assets/videos/dashboard_bg.mp4';

  /// Video background for the sub user dashboard screen
  static const String subDashboardBackgroundVideo =
      'assets/videos/subdashboard.mp4';

  /// Default circular avatar shown when no profile photo is set
  static const String defaultAvatar = 'assets/images/default_avatar.png';

  /// Default cover photo shown when no cover image is uploaded
  static const String defaultCover = 'assets/images/default_cover.png';
}

// ─────────────────────────────────────────────────────────────────
// COLORS
//
// App-wide color palette. Change a color here and it updates
// everywhere it is referenced throughout the UI.
// ─────────────────────────────────────────────────────────────────

class AppColors {
  /// Off-white card background color
  static const Color dirtyWhite = Color(0xFFF0F2F5);

  /// Primary blue — buttons, active indicators, links
  static const Color primaryBlue = Color(0xFF1877F2);

  /// Dark gray — primary text on light backgrounds
  static const Color darkGray = Color(0xFF333333);

  /// Light gray — secondary text, captions, placeholders
  static const Color lightGray = Color(0xFF999999);

  /// Dark green — hover glow on cards, "Sub" role badge color
  static const Color darkGreen = Color(0xFF1B5E20);
}

// ─────────────────────────────────────────────────────────────────
// DURATIONS
//
// Consistent animation timings used throughout the app.
// Keeping these in one place ensures all animations feel the same.
// ─────────────────────────────────────────────────────────────────

class AppDurations {
  /// Card hover scale animation duration
  static const Duration cardHover = Duration(milliseconds: 200);

  /// Screen/page transition animation duration
  static const Duration pageTransition = Duration(milliseconds: 300);
}

// ─────────────────────────────────────────────────────────────────
// CARD EFFECTS
//
// Visual constants that control how ProfileCards look at different
// states: center (focused), side (unfocused), and hovered.
// ─────────────────────────────────────────────────────────────────

class CardEffects {
  /// Scale factor applied on hover (slight zoom in)
  static const double hoverScale = 1.02;

  /// Scale factor for the currently centered/active card
  static const double centerScale = 1.05;

  /// Scale factor for cards on the sides of the carousel
  static const double defaultScale = 0.9;

  /// Strong shadow shown when the user hovers over a card
  static List<BoxShadow> hoverShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
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
// Configuration for the 3 hardcoded main users.
// These credentials match HardcodedMainUsers in Go backend models.go.
//
// Important notes:
// - Main users are NOT stored in the users database table
// - They log in using hardcoded credentials checked in auth_handler.go
// - Their profiles (Pallen, Karl, Aldhy) ARE stored in DB as main profiles
// - The emailToProfileId map links their email to their Flutter model ID
// ─────────────────────────────────────────────────────────────────

class MainUserConfig {
  /// All main user email addresses — used to identify main users
  static const List<String> emails = [
    'pallen@main.com',
    'karl@main.com',
    'aldhy@main.com',
  ];

  /// Maps each main user email to their Flutter profile model ID.
  ///
  /// These IDs correspond to the hardcoded Dart model files:
  ///   profile_1 = PallenPrinceDunhill  (pallen_prince_dunhill.dart)
  ///   profile_2 = AlbanielKarlAngelo   (albaniel_karl_angelo.dart)
  ///   profile_3 = FajardoAldhy         (fajardo_aldhy.dart)
  ///
  /// Also used to determine which edit button to show on the main dashboard.
  static const Map<String, String> emailToProfileId = {
    'pallen@main.com': 'profile_1',
    'karl@main.com': 'profile_2',
    'aldhy@main.com': 'profile_3',
  };

  /// Returns true if [email] belongs to a hardcoded main user
  static bool isMainEmail(String email) => emails.contains(email);

  /// Returns the Flutter profile ID for the given main user email.
  /// Returns null if the email is not a main user email.
  /// Example: 'pallen@main.com' returns 'profile_1'
  static String? getProfileId(String email) => emailToProfileId[email];
}

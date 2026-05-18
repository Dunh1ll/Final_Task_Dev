import 'package:flutter/material.dart';

// ── Theme Notifier ─────────────────────────────────────────────────
class KTheme extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  void toggle() {
    _isDark = !_isDark;
    notifyListeners();
  }

  static KTheme of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_KThemeInherited>()!
        .notifier!;
  }

  static KColors colors(BuildContext context) {
    final isDark = context
        .dependOnInheritedWidgetOfExactType<_KThemeInherited>()!
        .notifier!
        .isDark;
    return isDark ? KColors.dark() : KColors.light();
  }
}

// ── Inherited Widget ───────────────────────────────────────────────
class _KThemeInherited extends InheritedNotifier<KTheme> {
  const _KThemeInherited({
    required KTheme notifier,
    required super.child,
  }) : super(notifier: notifier);
}

// ── Theme Provider Widget ──────────────────────────────────────────
class KThemeProvider extends StatefulWidget {
  final Widget child;
  const KThemeProvider({required this.child, super.key});

  @override
  State<KThemeProvider> createState() => _KThemeProviderState();
}

class _KThemeProviderState extends State<KThemeProvider> {
  final _notifier = KTheme();

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _KThemeInherited(
      notifier: _notifier,
      child: widget.child,
    );
  }
}

// ── Color Palette ──────────────────────────────────────────────────
class KColors {
  final Color bg;
  final Color bgLight;
  final Color bgCard;
  final Color border;
  final Color borderStr;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textDim;
  final Color white;
  final Color accent;

  const KColors({
    required this.bg,
    required this.bgLight,
    required this.bgCard,
    required this.border,
    required this.borderStr,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textDim,
    required this.white,
    required this.accent,
  });

  factory KColors.light() => const KColors(
    bg:            Color(0xFFF5ECD7),
    bgLight:       Color(0xFFEFE5CE),
    bgCard:        Color(0xFFF7F0E0),
    border:        Color(0xFFD4A5A5),
    borderStr:     Color(0xFF8B3A4A),
    textPrimary:   Color(0xFF3D0A15),
    textSecondary: Color(0xFF5C1020),
    textMuted:     Color(0xFF7A2538),
    textDim:       Color(0xFF9B4055),
    white:         Color(0xFF3D0A15),
    accent:        Color(0xFF3D0A15),
  );

factory KColors.dark() => const KColors(
   bg:      Color(0xFF2E1A1F),
bgLight: Color(0xFF3A2228),
bgCard:  Color(0xFF422830),
    border:        Color(0xFF5E1E2B),
    borderStr:     Color(0xFFD4A5A5),
    textPrimary:   Color(0xFFF5ECD7),
    textSecondary: Color(0xFFF0E7D8),
    textMuted:     Color(0xFFC8B8A0),
    textDim:       Color(0xFFA08878),
    white:         Color(0xFFD8C7B3),
    accent:        Color(0xFFF5ECD7),
  );

  // ── Legacy static aliases (light only — for const contexts) ──────
  static const Color bgStatic            = Color(0xFFF5ECD7);
  static const Color bgLightStatic       = Color(0xFFEFE5CE);
  static const Color bgCardStatic        = Color(0xFFF7F0E0);
  static const Color borderStatic        = Color(0xFFD4A5A5);
  static const Color borderStrStatic     = Color(0xFF8B3A4A);
  static const Color textPrimaryStatic   = Color(0xFF3D0A15);
  static const Color textSecondaryStatic = Color(0xFF5C1020);
  static const Color textMutedStatic     = Color(0xFF7A2538);
  static const Color textDimStatic       = Color(0xFF9B4055);
}

// ── KC — keep this for now, we'll migrate file by file ────────────
class KC {
  static const bg            = Color(0xFFF5ECD7);
  static const bgLight       = Color(0xFFEFE5CE);
  static const bgCard        = Color(0xFFF7F0E0);
  static const border        = Color(0xFFD4A5A5);
  static const borderStr     = Color(0xFF8B3A4A);
  static const textPrimary   = Color(0xFF3D0A15);
  static const textSecondary = Color(0xFF5C1020);
  static const textMuted     = Color(0xFF7A2538);
  static const textDim       = Color(0xFF9B4055);
  static const white         = Color(0xFF3D0A15);
  static const accent        = Color(0xFF3D0A15);
  static const navy          = bg;
  static const mint          = white;
  static const amber         = white;
  static const text          = textPrimary;
  static const muted         = textSecondary;
  static const hint          = textMuted;
  static const card          = bgCard;
  static const surface       = bgLight;

  static const fontDisplay = 'SpaceGrotesk';
  static const fontMono    = 'IBMPlexMono';

  static const TextStyle monoBold = TextStyle(
    fontFamily: fontMono,
    fontWeight: FontWeight.w700,
    fontSize: 14,
    letterSpacing: 0.3,
    color: textPrimary,
  );

  static const TextStyle monoMedium = TextStyle(
    fontFamily: fontMono,
    fontWeight: FontWeight.w500,
    fontSize: 13,
    letterSpacing: 0.2,
    color: textSecondary,
  );

  static const TextStyle monoLabel = TextStyle(
    fontFamily: fontMono,
    fontWeight: FontWeight.w600,
    fontSize: 9,
    letterSpacing: 2,
    color: textDim,
  );

  static const TextStyle monoChip = TextStyle(
    fontFamily: fontMono,
    fontWeight: FontWeight.w600,
    fontSize: 10,
    letterSpacing: 2,
    color: textMuted,
  );
}

enum KTab { home, about, experience, projects, contact }
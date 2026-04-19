// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../utils/constants.dart';

// ─────────────────────────────────────────────────────────────────
// PORTFOLIO DESIGN TOKENS — Professional dark-tech palette
//
// Concept: "Engineering Portfolio" — dark IDE aesthetic meets
// modern SaaS dashboard. Clean, structured, trustworthy.
// ─────────────────────────────────────────────────────────────────
const Color _kBg = Color(0xFF060D1A); // near-black navy
const Color _kSurface = Color(0xFF0E1F35); // dark blue surface
const Color _kSurface2 = Color(0xFF172A44); // lighter card
const Color _kBorder = Color(0xFF1E3A5C); // blue-tinted border
const Color _kBorderLit = Color(0xFF2D5A8E); // highlighted border
const Color _kPrimary = Color(0xFF2563EB); // bold blue
const Color _kPrLight = Color(0xFF3B82F6); // lighter blue
const Color _kCyan = Color(0xFF06B6D4); // cyan accent
const Color _kAmber = Color(0xFFF59E0B); // amber highlight
const Color _kGreen = Color(0xFF10B981); // emerald
const Color _kRed = Color(0xFFEF4444); // for accents
const Color _kText = Color(0xFFEEF2FF); // near-white
const Color _kTextSub = Color(0xFF93A8C8); // blue-tinted grey
const Color _kTextMuted = Color(0xFF4B6484); // muted text
const Color _kNavBg = Color(0xFF0A1628); // nav background

// ─────────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────────

class _ContactData {
  final IconData icon;
  final String platform;
  final String handle;
  final Color color;
  final String url;

  const _ContactData({
    required this.icon,
    required this.platform,
    required this.handle,
    required this.color,
    required this.url,
  });
}

// Language badge: (displayName, brandColor, abbreviation)
typedef _LangEntry = (String, Color, String);

/// MainProfileCardPallen
///
/// ✅ Portfolio-style card with 4 sections:
///   Home → About → Thesis → Contact
///
/// ✅ Section switching uses fade + slide animation.
///
/// ✅ [onOpenProfile] — called by the "Open Profile" button.
///   Passed from _CarouselCardSlot in dashboard_screen.dart.
///   This replaces the old outer GestureDetector wrapper so
///   inner tab taps don't conflict with profile navigation.
///
/// ────────────────────────────────────────────────────────────────
/// ASSET REQUIRED:
///   assets/images/pallen_bg.jpg
///   → Place any professional/landscape background photo here.
///   → Falls back to a dark gradient if not found.
/// ────────────────────────────────────────────────────────────────
class MainProfileCardPallen extends StatefulWidget {
  final bool isCenter;

  /// Callback to navigate to the full profile detail screen.
  /// Provided by _CarouselCardSlot. If null, button is hidden.
  final VoidCallback? onOpenProfile;

  const MainProfileCardPallen({
    super.key,
    required this.isCenter,
    this.onOpenProfile,
  });

  @override
  State<MainProfileCardPallen> createState() => _MainProfileCardPallenState();
}

class _MainProfileCardPallenState extends State<MainProfileCardPallen>
    with SingleTickerProviderStateMixin {
  int _activeTab = 0;
  static const _tabLabels = ['Home', 'About', 'Thesis', 'Contact'];

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // ── Programming Languages ──────────────────────────────────────
  static const List<_LangEntry> _frontendLangs = [
    ('HTML', Color(0xFFE34F26), 'HTM'),
    ('CSS', Color(0xFF1572B6), 'CSS'),
    ('JavaScript', Color(0xFFB8A000), 'JS'),
    ('Flutter', Color(0xFF27B5F7), 'FLT'),
  ];

  static const List<_LangEntry> _backendLangs = [
    ('Go', Color(0xFF00ACD7), 'GO'),
    ('Java', Color(0xFFED8B00), 'JV'),
    ('Python', Color(0xFF4B8BBE), 'PY'),
    ('C++', Color(0xFF00599C), 'C++'),
    ('C', Color(0xFF6E8FBE), 'C'),
  ];

  static const List<_LangEntry> _dbLangs = [
    ('PostgreSQL', Color(0xFF336791), 'PG'),
    ('MySQL', Color(0xFF4479A1), 'MY'),
  ];

  static const List<_LangEntry> _otherLangs = [
    ('Assembly', Color(0xFF8B6914), 'ASM'),
    ('HDL', Color(0xFF7C3AED), 'HDL'),
  ];

  // ── Engineering Tools ──────────────────────────────────────────
  static const _tools = [
    (
      'KiCad',
      Color(0xFF2A4CB0),
      Icons.developer_board_rounded,
      'PCB Design & Schematic Layout',
    ),
    (
      'AutoCAD',
      Color(0xFFCC1825),
      Icons.architecture_rounded,
      '3D Modeling & Technical Drawing',
    ),
    (
      'Fusion 360',
      Color(0xFFE05A00),
      Icons.view_in_ar_rounded,
      '3D CAD Design & Simulation',
    ),
  ];

  // ── Contact Information ────────────────────────────────────────
  static const _contacts = <_ContactData>[
    _ContactData(
      icon: Icons.people_alt_rounded,
      platform: 'Facebook',
      handle: 'Dunhill Pallen',
      color: Color(0xFF1877F2),
      url: 'https://www.facebook.com/dunhill.pallen',
    ),
    _ContactData(
      icon: Icons.terminal_rounded,
      platform: 'GitHub',
      handle: 'Dunh1ll',
      color: Color(0xFF6E40C9),
      url: 'https://github.com/Dunh1ll',
    ),
    _ContactData(
      icon: Icons.alternate_email_rounded,
      platform: 'Gmail',
      handle: 'cpe.pallen.pd...',
      color: Color(0xFFEA4335),
      url: 'mailto:cpe.pallen.princedunhill@gmail.com',
    ),
    _ContactData(
      icon: Icons.phone_iphone_rounded,
      platform: 'Mobile',
      handle: '0950 464 7074',
      color: Color(0xFF10B981),
      url: 'tel:+639504647074',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 270),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOut,
    ));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _switchTab(int index) {
    if (index == _activeTab) return;
    _animCtrl.reverse().then((_) {
      if (!mounted) return;
      setState(() => _activeTab = index);
      _animCtrl.forward();
    });
  }

  void _launch(String url) => html.window.open(url, '_blank');

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          color: _kBg,
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: _buildActiveSection(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // TOP NAVIGATION BAR
  // ─────────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: _kNavBg,
        border: Border(
          bottom: BorderSide(color: _kBorder, width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            // ── Brand Mark ──────────────────────────────────
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_kPrimary, _kCyan],
                    ),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Center(
                    child: Text(
                      'P',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'PALLEN.DEV',
                  style: TextStyle(
                    color: _kText,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // ── Nav Tabs ─────────────────────────────────────
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                _tabLabels.length,
                (i) {
                  final isActive = i == _activeTab;
                  return GestureDetector(
                    onTap: () => _switchTab(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        color: isActive
                            ? _kPrimary.withOpacity(0.18)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isActive
                              ? _kPrLight.withOpacity(0.55)
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _tabLabels[i],
                        style: TextStyle(
                          color: isActive ? _kPrLight : _kTextMuted,
                          fontSize: 11,
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w400,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const Spacer(),

            // ── Status + Open Profile ────────────────────────
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Green "Available" pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _kGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _kGreen.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: _kGreen,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _kGreen.withOpacity(0.6),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'Available',
                        style: TextStyle(
                          color: _kGreen,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Open Profile button (only if callback given)
                if (widget.onOpenProfile != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: widget.onOpenProfile,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_kPrimary, _kCyan],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _kPrimary.withOpacity(0.35),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.open_in_full_rounded,
                            size: 10,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSection() {
    switch (_activeTab) {
      case 0:
        return _buildHome();
      case 1:
        return _buildAbout();
      case 2:
        return _buildThesis();
      case 3:
        return _buildContact();
      default:
        return _buildHome();
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // HOME SECTION
  //
  // Layout: Background image (with gradient overlay) spanning
  // the full card. Profile photo + name + degree on the left.
  // Quick-stats column on the right.
  // ─────────────────────────────────────────────────────────────────

  Widget _buildHome() {
    return Stack(
      children: [
        // ── Background Photo ───────────────────────────────────
        // Add your hero photo at: assets/images/pallen_bg.jpg
        // Falls back to a gradient if not found.
        Positioned.fill(
          child: Image.asset(
            'assets/images/pallen_bg.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF060D1A),
                    Color(0xFF0E2040),
                    Color(0xFF060D1A),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
        ),

        // ── Gradient Overlay ───────────────────────────────────
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [
                  Color(0xE0060D1A),
                  Color(0xCC060D1A),
                  Color(0xBB060D1A),
                ],
              ),
            ),
          ),
        ),

        // ── Subtle grid lines decoration ───────────────────────
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _GridLinePainter(),
            ),
          ),
        ),

        // ── Content ────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 18, 18),
          child: Row(
            children: [
              // Left: Profile identity
              Expanded(
                flex: 55,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Profile photo with glow
                    Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [_kPrimary, _kCyan],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _kPrimary.withOpacity(0.5),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(3),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/profile1.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: _kPrimary,
                            child: const Center(
                              child: Text(
                                'PD',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Name
                    const Text(
                      'Prince Dunhill',
                      style: TextStyle(
                        color: _kText,
                        fontSize: 21,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.5,
                        height: 1.1,
                      ),
                    ),
                    const Text(
                      'PALLEN',
                      style: TextStyle(
                        color: _kPrLight,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                        height: 1.0,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Degree badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _kAmber.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: _kAmber.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        'BS COMPUTER ENGINEERING',
                        style: TextStyle(
                          color: _kAmber,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Full-Stack Dev  ·  Embedded Systems',
                      style: TextStyle(
                        color: _kTextSub,
                        fontSize: 10,
                        letterSpacing: 0.3,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Tech stack quick pills
                    Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: [
                        _pill('Flutter', const Color(0xFF27B5F7)),
                        _pill('Go', const Color(0xFF00ACD7)),
                        _pill('Python', const Color(0xFF4B8BBE)),
                        _pill('C++', const Color(0xFF00599C)),
                        _pill('ESP32', const Color(0xFF00AD9F)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              // Right: Quick stats
              Expanded(
                flex: 40,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _statTile(
                      icon: Icons.code_rounded,
                      value: '13',
                      label: 'Languages',
                      color: _kPrLight,
                    ),
                    const SizedBox(height: 8),
                    _statTile(
                      icon: Icons.build_rounded,
                      value: '3',
                      label: 'CAD / EDA Tools',
                      color: _kAmber,
                    ),
                    const SizedBox(height: 8),
                    _statTile(
                      icon: Icons.biotech_rounded,
                      value: '1',
                      label: 'Thesis Project',
                      color: _kGreen,
                    ),
                    const SizedBox(height: 8),
                    _statTile(
                      icon: Icons.school_rounded,
                      value: 'BS',
                      label: 'CompE Graduate',
                      color: _kCyan,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // ABOUT SECTION
  //
  // Left column: About Me text + Education + Tools
  // Right column: Programming languages by category
  // ─────────────────────────────────────────────────────────────────

  Widget _buildAbout() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left column ──────────────────────────────────
          Expanded(
            flex: 48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _colHeader('About Me'),
                const SizedBox(height: 8),
                Text(
                  'Computer Engineering graduate with a '
                  'strong foundation in both hardware and '
                  'software development. Skilled in '
                  'full-stack web development, embedded '
                  'systems programming, and PCB design.',
                  style: const TextStyle(
                    color: _kTextSub,
                    fontSize: 10,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 14),
                _colHeader('Education'),
                const SizedBox(height: 8),
                _eduCard(),
                const SizedBox(height: 14),
                _colHeader('Engineering Tools'),
                const SizedBox(height: 8),
                ...List.generate(
                  _tools.length,
                  (i) => Padding(
                    padding:
                        EdgeInsets.only(bottom: i < _tools.length - 1 ? 6 : 0),
                    child: _toolRow(
                      _tools[i].$1,
                      _tools[i].$2,
                      _tools[i].$3,
                      _tools[i].$4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ── Right column: Languages ──────────────────────
          Expanded(
            flex: 52,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _langGroup('Frontend', _frontendLangs),
                const SizedBox(height: 10),
                _langGroup('Backend', _backendLangs),
                const SizedBox(height: 10),
                _langGroup('Database', _dbLangs),
                const SizedBox(height: 10),
                _langGroup('Other', _otherLangs),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // THESIS SECTION
  // ─────────────────────────────────────────────────────────────────

  Widget _buildThesis() {
    const abstract = 'Navira is an innovative assistive technology '
        'device designed to enhance the daily navigation '
        'and independence of visually impaired individuals. '
        'The system integrates an ESP32 microcontroller with '
        'ultrasonic sensors, IR proximity detection, and '
        'a wireless Bluetooth armband to deliver real-time '
        'haptic and audio feedback for obstacle avoidance.';

    const highlights = [
      (
        Icons.sensors_rounded,
        'Smart Obstacle Detection',
        'Ultrasonic + IR multi-sensor fusion for real-time proximity alerts',
        Color(0xFF2563EB),
      ),
      (
        Icons.bluetooth_rounded,
        'Wireless Armband',
        'Bluetooth LE communication for vibration-based distance feedback',
        Color(0xFF7C3AED),
      ),
      (
        Icons.accessibility_new_rounded,
        'Inclusive Design',
        'Engineered for enhanced mobility of the visually impaired',
        Color(0xFF10B981),
      ),
    ];

    const techStack = [
      ('ESP32', Color(0xFF00AD9F)),
      ('C++', Color(0xFF00599C)),
      ('Bluetooth LE', Color(0xFF7C3AED)),
      ('Ultrasonic', Color(0xFF2563EB)),
      ('IR Sensor', Color(0xFFEA4335)),
      ('KiCad', Color(0xFF2A4CB0)),
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title card ────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kPrimary.withOpacity(0.35)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _kPrimary.withOpacity(0.1),
                  _kBg,
                ],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _kAmber.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: _kAmber.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              'UNDERGRADUATE THESIS',
                              style: TextStyle(
                                color: _kAmber,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'NAVIRA',
                        style: TextStyle(
                          color: _kPrLight,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'An ESP32-Based Smart Blind Stick\n'
                        'with Wireless Armband Integration',
                        style: TextStyle(
                          color: _kText,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _kPrimary.withOpacity(0.25),
                        _kCyan.withOpacity(0.25),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _kCyan.withOpacity(0.4),
                    ),
                  ),
                  child: const Icon(
                    Icons.biotech_rounded,
                    color: _kCyan,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Abstract + Tech stack
              Expanded(
                flex: 52,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _colHeader('Abstract'),
                    const SizedBox(height: 7),
                    Text(
                      abstract,
                      style: const TextStyle(
                        color: _kTextSub,
                        fontSize: 10,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _colHeader('Technology Stack'),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children:
                          techStack.map((t) => _pill(t.$1, t.$2)).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Key highlights
              Expanded(
                flex: 48,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _colHeader('Key Features'),
                    const SizedBox(height: 7),
                    ...List.generate(
                      highlights.length,
                      (i) => Padding(
                        padding: EdgeInsets.only(
                            bottom: i < highlights.length - 1 ? 7 : 0),
                        child: _highlightTile(
                          highlights[i].$1,
                          highlights[i].$2,
                          highlights[i].$3,
                          highlights[i].$4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // CONTACT SECTION
  // ─────────────────────────────────────────────────────────────────

  Widget _buildContact() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Header
          Column(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [_kPrLight, _kCyan],
                ).createShader(bounds),
                child: const Text(
                  "Let's Connect",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Available for collaboration and opportunities',
                style: TextStyle(
                  color: _kTextMuted,
                  fontSize: 10.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 2x2 contact grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 3.2,
            ),
            itemCount: _contacts.length,
            itemBuilder: (context, i) => _contactCard(_contacts[i]),
          ),

          const SizedBox(height: 16),

          // Bottom note
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _kBorder, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 12,
                  color: _kTextMuted,
                ),
                const SizedBox(width: 5),
                const Text(
                  'Philippines  ·  Open to Remote & On-site',
                  style: TextStyle(
                    color: _kTextMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // SHARED HELPER WIDGETS
  // ─────────────────────────────────────────────────────────────────

  /// Small colored pill chip (tech tag)
  Widget _pill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.45), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color.withOpacity(0.95),
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Stat tile for Home section right column
  Widget _statTile({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 15),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: _kTextMuted,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Section column header with left accent bar
  Widget _colHeader(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 13,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_kPrLight, _kCyan],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            color: _kText,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  /// Education card for About section
  Widget _eduCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _kPrimary.withOpacity(0.25),
                  _kCyan.withOpacity(0.25),
                ],
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: _kPrLight,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bachelor of Science in',
                  style: TextStyle(
                    color: _kTextMuted,
                    fontSize: 9.5,
                  ),
                ),
                Text(
                  'Computer Engineering',
                  style: TextStyle(
                    color: _kText,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Graduate',
                  style: TextStyle(
                    color: _kGreen,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Tool row for About section skills
  Widget _toolRow(
    String name,
    Color color,
    IconData icon,
    String desc,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 13),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: _kText,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  desc,
                  style: const TextStyle(
                    color: _kTextMuted,
                    fontSize: 8.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Language category group for About section
  Widget _langGroup(
    String category,
    List<_LangEntry> langs,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category.toUpperCase(),
          style: const TextStyle(
            color: _kTextMuted,
            fontSize: 8.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 5),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: langs.map((l) => _langBadge(l.$1, l.$2, l.$3)).toList(),
        ),
      ],
    );
  }

  /// Language badge widget (colored icon + name)
  Widget _langBadge(
    String name,
    Color color,
    String abbr,
  ) {
    final bool lightBg = color.computeLuminance() > 0.45;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withOpacity(0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Center(
              child: Text(
                abbr.trim().length > 2
                    ? abbr.trim().substring(0, 2)
                    : abbr.trim(),
                style: TextStyle(
                  color: lightBg ? Colors.black87 : Colors.white,
                  fontSize: 6.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            name,
            style: TextStyle(
              color: color.withOpacity(0.9),
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Thesis highlight tile
  Widget _highlightTile(
    IconData icon,
    String title,
    String desc,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: _kText,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(
                    color: _kTextMuted,
                    fontSize: 8.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Contact card for Contact section
  Widget _contactCard(_ContactData item) {
    return GestureDetector(
      onTap: () => _launch(item.url),
      child: _HoverContainer(
        defaultDecoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: item.color.withOpacity(0.3), width: 1),
        ),
        hoverDecoration: BoxDecoration(
          color: _kSurface2,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: item.color.withOpacity(0.7), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: item.color.withOpacity(0.18),
              blurRadius: 12,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(item.icon, color: item.color, size: 17),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.platform,
                      style: TextStyle(
                        color: _kTextMuted,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      item.handle,
                      style: const TextStyle(
                        color: _kText,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.open_in_new_rounded,
                size: 11,
                color: item.color.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// HOVER CONTAINER — animates border/shadow on mouse enter/exit
// (web-only via MouseRegion)
// ─────────────────────────────────────────────────────────────────

class _HoverContainer extends StatefulWidget {
  final Widget child;
  final BoxDecoration defaultDecoration;
  final BoxDecoration hoverDecoration;

  const _HoverContainer({
    required this.child,
    required this.defaultDecoration,
    required this.hoverDecoration,
  });

  @override
  State<_HoverContainer> createState() => _HoverContainerState();
}

class _HoverContainerState extends State<_HoverContainer> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration:
            _hovered ? widget.hoverDecoration : widget.defaultDecoration,
        child: widget.child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// GRID LINE PAINTER — subtle decorative grid for Home bg
// ─────────────────────────────────────────────────────────────────

class _GridLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E3A5C).withOpacity(0.25)
      ..strokeWidth = 0.5;

    const spacing = 40.0;

    // Vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Dot at grid intersections
    final dotPaint = Paint()
      ..color = const Color(0xFF2D5A8E).withOpacity(0.4)
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_GridLinePainter oldDelegate) => false;
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../data/developer_data.dart';
import '../utils/constants.dart';

// ─────────────────────────────────────────────────────────────────
// GREEN COLOR PALETTE — consistent with AppColors
// ─────────────────────────────────────────────────────────────────
const Color _kAccent = Color(0xFF22C55E); // green-500 primary
const Color _kAccentLight = Color(0xFF86EFAC); // green-300 light text
const Color _kAccentDark = Color(0xFF16A34A); // green-600 dark shade
const Color _kAccentGlow = Color(0xFF4ADE80); // green-400 glow

// ─────────────────────────────────────────────────────────────────
// HOME SCREEN
//
// Public landing page shown before login.
// Sections (scrollable top to bottom):
//   1. Hero       — video background, tagline, CTA buttons
//   2. Developers — 3 square developer cards (bigger, less whitespace)
//   3. Positions  — 2x2 grid: Frontend+Backend top, Fullstack+Designer bottom
//   4. Contact    — bigger contact cards with Gmail, Facebook, phone
// ─────────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  late VideoPlayerController _videoController;
  bool _videoInitialized = false;
  double _scrollOffset = 0.0;

  late AnimationController _heroTextController;
  late Animation<double> _heroTextFade;
  late Animation<Offset> _heroTextSlide;

  // Nav button hover states
  bool _aboutHover = false;
  bool _loginHover = false;
  bool _signupHover = false;

  @override
  void initState() {
    super.initState();

    // Initialize hero background video
    _videoController =
        VideoPlayerController.asset('assets/videos/homepage_bg.mp4');
    _videoController.initialize().then((_) {
      if (mounted) {
        setState(() => _videoInitialized = true);
        _videoController
          ..setLooping(true)
          ..setVolume(0)
          ..play();
      }
    });

    // Track scroll position for hero fade effect
    _scrollController.addListener(() {
      if (mounted) {
        setState(() => _scrollOffset = _scrollController.offset);
      }
    });

    // Hero text entrance animation — fade + slide up
    _heroTextController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _heroTextFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _heroTextController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    _heroTextSlide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
            .animate(CurvedAnimation(
      parent: _heroTextController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    // Request keyboard focus and start entrance animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _heroTextController.forward();
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _heroTextController.dispose();
    super.dispose();
  }

  /// Handle UP/DOWN arrow keys for smooth scroll navigation
  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final delta =
          event.logicalKey == LogicalKeyboardKey.arrowDown ? 120.0 : -120.0;
      if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
          event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _scrollController.animateTo(
          (_scrollController.offset + delta)
              .clamp(0.0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  /// Show About modal with glassmorphism effect
  void _showAbout() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (_) => const _AboutDialog(),
    );
  }

  /// Hero overlay opacity — increases as user scrolls down
  /// Creates the smooth fade-to-black transition into next section
  double get _heroFadeOpacity {
    const double fadeEnd = 400.0;
    if (_scrollOffset <= 0) return 0.0;
    if (_scrollOffset >= fadeEnd) return 1.0;
    return _scrollOffset / fadeEnd;
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: _handleKeyEvent,
      child: GestureDetector(
        // Re-request focus on tap so arrow keys keep working
        onTap: () => _focusNode.requestFocus(),
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // ── Scrollable page content ─────────────────────────
              SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Section 1: Hero with video
                    _HeroSection(
                      videoController: _videoController,
                      videoInitialized: _videoInitialized,
                      heroFadeOpacity: _heroFadeOpacity,
                      heroTextFade: _heroTextFade,
                      heroTextSlide: _heroTextSlide,
                    ),

                    // Section 2: Meet the Developers
                    // ✅ Square cards, bigger, less whitespace
                    const _DevelopersSection(),

                    // Section 3: Our Expertise / Positions
                    // ✅ 2x2 grid: Frontend+Backend top, Fullstack+Designer bottom
                    const _PositionsSection(),

                    // Section 4: Get in Touch / Contact
                    // ✅ Bigger cards, less whitespace
                    const _ContactSection(),
                  ],
                ),
              ),

              // ── Fixed top navigation bar ────────────────────────
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _TopNavBar(
                  scrollOffset: _scrollOffset,
                  aboutHover: _aboutHover,
                  loginHover: _loginHover,
                  signupHover: _signupHover,
                  onAboutHoverChange: (v) => setState(() => _aboutHover = v),
                  onLoginHoverChange: (v) => setState(() => _loginHover = v),
                  onSignupHoverChange: (v) => setState(() => _signupHover = v),
                  onAbout: _showAbout,
                  onLogin: () => context.go('/login'),
                  onSignup: () => context.go('/register'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// TOP NAVIGATION BAR
// Becomes more opaque as user scrolls down
// All buttons use green theme
// ─────────────────────────────────────────────────────────────────
class _TopNavBar extends StatelessWidget {
  final double scrollOffset;
  final bool aboutHover, loginHover, signupHover;
  final ValueChanged<bool> onAboutHoverChange,
      onLoginHoverChange,
      onSignupHoverChange;
  final VoidCallback onAbout, onLogin, onSignup;

  const _TopNavBar({
    required this.scrollOffset,
    required this.aboutHover,
    required this.loginHover,
    required this.signupHover,
    required this.onAboutHoverChange,
    required this.onLoginHoverChange,
    required this.onSignupHoverChange,
    required this.onAbout,
    required this.onLogin,
    required this.onSignup,
  });

  @override
  Widget build(BuildContext context) {
    // Nav bar fades from transparent to dark as user scrolls
    final double bgOpacity = (scrollOffset / 200).clamp(0.0, 0.95);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(bgOpacity),
            // ✅ Subtle green bottom border on nav bar
            border: Border(
              bottom: BorderSide(
                color: scrollOffset > 50
                    ? _kAccent.withOpacity(0.2)
                    : Colors.transparent,
                width: 1,
              ),
            ),
          ),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            bottom: 8,
            left: 24,
            right: 24,
          ),
          child: Row(
            children: [
              // Logo with green glow on scroll
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: scrollOffset > 100
                      ? [
                          BoxShadow(
                            color: _kAccent.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 2,
                          )
                        ]
                      : [],
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 40,
                  errorBuilder: (_, __, ___) => const Text(
                    'PROFILE APP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // About button
              _NavButton(
                label: 'About',
                hovered: aboutHover,
                onHoverChange: onAboutHoverChange,
                onTap: onAbout,
                filled: false,
              ),
              const SizedBox(width: 8),

              // Login button (outlined green)
              _NavButton(
                label: 'Login',
                hovered: loginHover,
                onHoverChange: onLoginHoverChange,
                onTap: onLogin,
                filled: false,
                showBorder: true,
              ),
              const SizedBox(width: 8),

              // Sign Up button (solid green fill)
              _NavButton(
                label: 'Sign Up',
                hovered: signupHover,
                onHoverChange: onSignupHoverChange,
                onTap: onSignup,
                filled: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reusable navigation button with green hover effects
class _NavButton extends StatelessWidget {
  final String label;
  final bool hovered;
  final ValueChanged<bool> onHoverChange;
  final VoidCallback onTap;
  final bool filled;
  final bool showBorder;

  const _NavButton({
    required this.label,
    required this.hovered,
    required this.onHoverChange,
    required this.onTap,
    required this.filled,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onHoverChange(true),
      onExit: (_) => onHoverChange(false),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: filled
                ? (hovered ? _kAccent : _kAccent.withOpacity(0.85))
                : (hovered ? _kAccent.withOpacity(0.12) : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
            border: showBorder || filled
                ? Border.all(
                    color:
                        filled ? Colors.transparent : _kAccent.withOpacity(0.5),
                  )
                : Border.all(
                    color: hovered
                        ? _kAccent.withOpacity(0.4)
                        : Colors.transparent),
            boxShadow: filled && hovered
                ? [
                    BoxShadow(
                      color: _kAccent.withOpacity(0.45),
                      blurRadius: 20,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: hovered && !filled ? _kAccentLight : Colors.white,
              fontSize: 15,
              fontWeight: filled ? FontWeight.bold : FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// HERO SECTION
// Full screen height, video background, fade to black on scroll
// ─────────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final VideoPlayerController videoController;
  final bool videoInitialized;
  final double heroFadeOpacity;
  final Animation<double> heroTextFade;
  final Animation<Offset> heroTextSlide;

  const _HeroSection({
    required this.videoController,
    required this.videoInitialized,
    required this.heroFadeOpacity,
    required this.heroTextFade,
    required this.heroTextSlide,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight,
      child: Stack(
        children: [
          // Video background
          Positioned.fill(
            child: videoInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: videoController.value.size.width,
                      height: videoController.value.size.height,
                      child: VideoPlayer(videoController),
                    ),
                  )
                : Container(color: const Color(0xFF0A0A0A)),
          ),

          // Gradient overlay for text readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.35),
                    Colors.black.withOpacity(0.55),
                    Colors.black.withOpacity(0.88),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          // Scroll-driven fade to black
          // Transitions smoothly into the developers section
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: heroFadeOpacity,
                child: Container(color: Colors.black),
              ),
            ),
          ),

          // Hero text content + CTA buttons
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeTransition(
                    opacity: heroTextFade,
                    child: SlideTransition(
                      position: heroTextSlide,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ✅ Green eyebrow pill label
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _kAccent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                              border:
                                  Border.all(color: _kAccent.withOpacity(0.5)),
                            ),
                            child: const Text(
                              'PROFILE CAROUSEL',
                              style: TextStyle(
                                color: _kAccentLight,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Main headline
                          const Text(
                            'Discover\nAmazing\nPeople',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 72,
                              fontWeight: FontWeight.w900,
                              height: 1.05,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Subheadline
                          Text(
                            'Connect with profiles, explore stories,\n'
                            'and find your community.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 18,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 48),

                          // CTA buttons
                          Row(
                            children: [
                              _HeroCTAButton(
                                label: 'Get Started',
                                filled: true,
                                onTap: () => context.go('/register'),
                              ),
                              const SizedBox(width: 16),
                              _HeroCTAButton(
                                label: 'Learn More',
                                filled: false,
                                onTap: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Scroll indicator at the bottom
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: heroTextFade,
              child: const Column(
                children: [
                  Text(
                    'SCROLL TO EXPLORE',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  _ScrollArrow(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated bouncing arrow scroll indicator
class _ScrollArrow extends StatefulWidget {
  const _ScrollArrow();

  @override
  State<_ScrollArrow> createState() => _ScrollArrowState();
}

class _ScrollArrowState extends State<_ScrollArrow>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _b;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _b = Tween<double>(begin: 0, end: 10)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _b,
        builder: (_, __) => Transform.translate(
          offset: Offset(0, _b.value),
          child: const Icon(Icons.keyboard_arrow_down,
              color: Colors.white54, size: 28),
        ),
      );
}

/// CTA button in the hero section with green fill or outline
class _HeroCTAButton extends StatefulWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _HeroCTAButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  State<_HeroCTAButton> createState() => _HeroCTAButtonState();
}

class _HeroCTAButtonState extends State<_HeroCTAButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            color: widget.filled
                ? (_hovered ? _kAccent : _kAccent.withOpacity(0.85))
                : (_hovered
                    ? Colors.white.withOpacity(0.12)
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.filled
                  ? Colors.transparent
                  : Colors.white.withOpacity(0.45),
            ),
            boxShadow: widget.filled && _hovered
                ? [
                    BoxShadow(
                      color: _kAccent.withOpacity(0.4),
                      blurRadius: 24,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
          child: Text(
            widget.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// DEVELOPERS SECTION
//
// ✅ CHANGED: Square cards instead of circles
// ✅ CHANGED: Bigger cards to reduce empty whitespace
// ✅ CHANGED: Green accent borders and hover glow
// ─────────────────────────────────────────────────────────────────
class _DevelopersSection extends StatelessWidget {
  const _DevelopersSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      // ✅ Reduced vertical padding to minimize whitespace
      color: const Color(0xFF080808),
      padding: const EdgeInsets.symmetric(vertical: 72, horizontal: 48),
      child: Column(
        children: [
          const _SectionLabel(label: 'THE TEAM'),
          const SizedBox(height: 16),

          // Section title
          const Text(
            'Meet the Developers',
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          Text(
            'The talented individuals who built this platform',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),

          // ✅ Reduced gap before cards
          const SizedBox(height: 48),

          // Developer cards — row on wide screens
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;
            if (isWide) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: DeveloperData.developers
                    .map((dev) => Padding(
                          // ✅ Larger horizontal padding for breathing room
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _DeveloperCard(developer: dev),
                        ))
                    .toList(),
              );
            }
            return Column(
              children: DeveloperData.developers
                  .map((dev) => Padding(
                        padding: const EdgeInsets.only(bottom: 32),
                        child: _DeveloperCard(developer: dev),
                      ))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }
}

/// Developer card with SQUARE photo and green hover effects
/// ✅ CHANGED: Square image (was circle), bigger size, green glow on hover
class _DeveloperCard extends StatefulWidget {
  final DeveloperInfo developer;

  const _DeveloperCard({required this.developer});

  @override
  State<_DeveloperCard> createState() => _DeveloperCardState();
}

class _DeveloperCardState extends State<_DeveloperCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        // Lift card slightly on hover
        transform: Matrix4.identity()..translate(0.0, _hovered ? -8.0 : 0.0),
        child: Column(
          children: [
            // ✅ SQUARE photo container — was circle
            // Bigger size (240x240) fills space better
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                // ✅ Square with rounded corners (not fully circular)
                borderRadius: BorderRadius.circular(16),
                boxShadow: _hovered
                    ? [
                        BoxShadow(
                          // ✅ Green glow on hover
                          color: _kAccent.withOpacity(0.45),
                          blurRadius: 35,
                          spreadRadius: 5,
                        )
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        )
                      ],
                border: Border.all(
                  // ✅ Green border on hover
                  color: _hovered ? _kAccent : Colors.white.withOpacity(0.1),
                  width: _hovered ? 3 : 1,
                ),
                image: DecorationImage(
                  image: AssetImage(widget.developer.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Developer name
            Text(
              widget.developer.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 6),

            // Role label in green
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                // ✅ Green pill behind role label
                color: _kAccent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _kAccent.withOpacity(0.3)),
              ),
              child: Text(
                widget.developer.primaryRole,
                style: const TextStyle(
                  color: _kAccentLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// POSITIONS SECTION
//
// ✅ CHANGED: 2x2 grid layout
//   Top row:    Frontend Developer | Backend Developer
//   Bottom row: Full-Stack Developer | Web Designer
// ✅ CHANGED: Bigger cards to reduce whitespace
// ✅ CHANGED: Green color accents per role
// ─────────────────────────────────────────────────────────────────
class _PositionsSection extends StatelessWidget {
  const _PositionsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF050505),
      // ✅ Reduced vertical padding
      padding: const EdgeInsets.symmetric(vertical: 72, horizontal: 48),
      child: Column(
        children: [
          const _SectionLabel(label: 'ROLES'),
          const SizedBox(height: 16),

          const Text(
            'Our Expertise',
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          Text(
            'Each developer brings unique skills to the team',
            style:
                TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
            textAlign: TextAlign.center,
          ),

          // ✅ Reduced gap before grid
          const SizedBox(height: 48),

          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;

            if (isWide) {
              // ✅ 2x2 GRID LAYOUT for wide screens
              return Column(
                children: [
                  // ── Top row: Frontend + Backend ──────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _RoleCard(
                        role: 'Frontend Developer',
                        developer: DeveloperData.developers[2],
                        // Aldhy
                        icon: Icons.web,
                        color: const Color(0xFF22C55E), // green
                      ),
                      const SizedBox(width: 24),
                      _RoleCard(
                        role: 'Backend Developer',
                        developer: DeveloperData.developers[1],
                        // Karl
                        icon: Icons.storage,
                        color: const Color(0xFF10B981), // emerald
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Bottom row: Full-Stack + Web Designer ─────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _RoleCard(
                        role: 'Full-Stack Developer',
                        developer: DeveloperData.developers[0],
                        // Pallen
                        icon: Icons.layers,
                        color: const Color(0xFF4ADE80), // light green
                      ),
                      const SizedBox(width: 24),
                      _RoleCard(
                        role: 'Web Designer',
                        developer: DeveloperData.developers[0],
                        // Pallen
                        icon: Icons.brush,
                        color: const Color(0xFFA3E635), // lime
                      ),
                    ],
                  ),
                ],
              );
            }

            // Narrow screens — single column
            return Column(
              children: [
                _RoleCard(
                  role: 'Frontend Developer',
                  developer: DeveloperData.developers[2],
                  icon: Icons.web,
                  color: const Color(0xFF22C55E),
                  fullWidth: true,
                ),
                const SizedBox(height: 16),
                _RoleCard(
                  role: 'Backend Developer',
                  developer: DeveloperData.developers[1],
                  icon: Icons.storage,
                  color: const Color(0xFF10B981),
                  fullWidth: true,
                ),
                const SizedBox(height: 16),
                _RoleCard(
                  role: 'Full-Stack Developer',
                  developer: DeveloperData.developers[0],
                  icon: Icons.layers,
                  color: const Color(0xFF4ADE80),
                  fullWidth: true,
                ),
                const SizedBox(height: 16),
                _RoleCard(
                  role: 'Web Designer',
                  developer: DeveloperData.developers[0],
                  icon: Icons.brush,
                  color: const Color(0xFFA3E635),
                  fullWidth: true,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

/// Role card — bigger size, green accents, hover glow
/// ✅ CHANGED: Consistent width for both cards in each row
class _RoleCard extends StatefulWidget {
  final String role;
  final DeveloperInfo developer;
  final IconData icon;
  final Color color;
  final bool fullWidth;

  const _RoleCard({
    required this.role,
    required this.developer,
    required this.icon,
    required this.color,
    this.fullWidth = false,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        // ✅ Bigger card width (was 300, now 380) to fill space better
        width: widget.fullWidth ? double.infinity : 380,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: _hovered
              ? Colors.white.withOpacity(0.07)
              : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered
                ? widget.color.withOpacity(0.6)
                : Colors.white.withOpacity(0.08),
            width: _hovered ? 1.5 : 1,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: widget.color.withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            // ✅ Bigger developer photo (was 64, now 80)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                // Square with rounded corners for consistency
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.color.withOpacity(0.5),
                  width: 2,
                ),
                image: DecorationImage(
                  image: AssetImage(widget.developer.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(width: 20),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Role icon + title
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: widget.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(widget.icon, color: widget.color, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.role,
                          style: TextStyle(
                            color: widget.color,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Developer name
                  Text(
                    widget.developer.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Primary role subtitle
                  Text(
                    widget.developer.primaryRole,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow indicator on hover
            AnimatedOpacity(
              opacity: _hovered ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.arrow_forward_ios,
                color: widget.color,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// CONTACT SECTION
//
// ✅ CHANGED: Bigger cards to reduce whitespace
// ✅ CHANGED: More content visible, larger photos
// ✅ CHANGED: Green accents throughout
// ─────────────────────────────────────────────────────────────────
class _ContactSection extends StatelessWidget {
  const _ContactSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      // ✅ Reduced vertical padding
      padding: const EdgeInsets.symmetric(vertical: 72, horizontal: 48),
      child: Column(
        children: [
          const _SectionLabel(label: 'CONTACT'),
          const SizedBox(height: 16),

          const Text(
            'Get in Touch',
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          Text(
            'Reach out to any of our developers directly',
            style:
                TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
            textAlign: TextAlign.center,
          ),

          // ✅ Reduced gap before cards
          const SizedBox(height: 48),

          // Contact cards
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900;
            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: DeveloperData.developers
                    .map((dev) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: _ContactCard(developer: dev),
                        ))
                    .toList(),
              );
            }
            return Column(
              children: DeveloperData.developers
                  .map((dev) => Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _ContactCard(developer: dev),
                      ))
                  .toList(),
            );
          }),

          const SizedBox(height: 64),

          // Footer
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  _kAccent.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          Text(
            '© 2026 Profile Carousel · Built with Flutter & Go',
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Contact card — bigger, more content visible
/// ✅ CHANGED: Larger photo, more padding, bigger text
class _ContactCard extends StatefulWidget {
  final DeveloperInfo developer;

  const _ContactCard({required this.developer});

  @override
  State<_ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<_ContactCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        // ✅ Bigger card width (was 300, now 360)
        width: 360,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: _hovered
              ? Colors.white.withOpacity(0.07)
              : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hovered
                ? _kAccent.withOpacity(0.5)
                : Colors.white.withOpacity(0.08),
            width: _hovered ? 1.5 : 1,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: _kAccent.withOpacity(0.12),
                    blurRadius: 40,
                    spreadRadius: 4,
                  )
                ]
              : [],
        ),
        child: Column(
          children: [
            // ✅ Bigger square photo (was 80x80 circle, now 120x120 square)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _kAccent.withOpacity(0.4),
                  width: 2,
                ),
                boxShadow: _hovered
                    ? [
                        BoxShadow(
                          color: _kAccent.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                        )
                      ]
                    : [],
                image: DecorationImage(
                  image: AssetImage(widget.developer.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Name
            Text(
              widget.developer.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 6),

            // Role pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: _kAccent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _kAccent.withOpacity(0.3)),
              ),
              child: Text(
                widget.developer.primaryRole,
                style: const TextStyle(
                  color: _kAccentLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Divider with green gradient
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    _kAccent.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Contact info rows — bigger icons and text
            _ContactRow(
              icon: Icons.email_outlined,
              label: widget.developer.gmail,
              color: const Color(0xFFEF4444),
            ),
            const SizedBox(height: 14),
            _ContactRow(
              icon: Icons.facebook,
              label: widget.developer.facebook,
              color: const Color(0xFF22C55E),
            ),
            const SizedBox(height: 14),
            _ContactRow(
              icon: Icons.phone_outlined,
              label: widget.developer.phone,
              color: const Color(0xFF4ADE80),
            ),
          ],
        ),
      ),
    );
  }
}

/// Contact info row with icon and label
class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ✅ Bigger icon container (was 32, now 40)
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              // ✅ Bigger text (was 13, now 14)
              fontSize: 14,
              letterSpacing: 0.2,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ABOUT DIALOG — Glassmorphism modal
// ─────────────────────────────────────────────────────────────────
class _AboutDialog extends StatelessWidget {
  const _AboutDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: 560,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _kAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.info_outline,
                          color: _kAccentLight, size: 24),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'About Profile Carousel',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close,
                          color: Colors.white.withOpacity(0.6)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Profile Carousel is a modern full-stack web application '
                  'that allows users to discover, create, and manage '
                  'user profiles in a beautiful carousel interface.',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 15,
                      height: 1.7),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _TechChip(
                        label: 'Flutter Web', color: const Color(0xFF54C5F8)),
                    _TechChip(label: 'Go', color: const Color(0xFF00ACD7)),
                    _TechChip(
                        label: 'PostgreSQL', color: const Color(0xFF336791)),
                    _TechChip(label: 'REST API', color: _kAccent),
                    _TechChip(
                        label: 'JWT Auth', color: const Color(0xFFF59E0B)),
                  ],
                ),
                const SizedBox(height: 24),
                ...[
                  'Role-based authentication (Main & Sub users)',
                  'Profile creation with photo upload',
                  'Real-time profile management',
                  'Responsive design for all screen sizes',
                ].map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline,
                            color: _kAccent, size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(f,
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TechChip extends StatelessWidget {
  final String label;
  final Color color;

  const _TechChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// SHARED SECTION LABEL — green pill used across all sections
// ─────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: _kAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _kAccent.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _kAccentLight,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 3,
        ),
      ),
    );
  }
}

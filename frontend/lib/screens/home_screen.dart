import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'dart:ui';
import '../data/developer_data.dart';

/// HomeScreen is the public landing page shown before login.
///
/// Structure (top to bottom, scrollable):
///   1. Hero section — video background + tagline + CTA buttons
///   2. Developers section — 3 developer cards with photos and names
///   3. Positions section — role layout (Frontend, Backend, Fullstack, Designer)
///   4. Contact section — Gmail, Facebook, phone for each developer
///
/// Navigation is via scroll wheel, swipe, or UP/DOWN arrow keys.
/// The hero video scrolls away naturally (not fixed).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Scroll controller for the entire page
  final ScrollController _scrollController = ScrollController();

  // Focus node so keyboard arrow keys work immediately
  final FocusNode _focusNode = FocusNode();

  // Video player for the hero background
  late VideoPlayerController _videoController;
  bool _videoInitialized = false;

  // Track scroll position for the fade overlay on the hero section
  double _scrollOffset = 0.0;

  // Animation controllers
  late AnimationController _heroTextController;
  late Animation<double> _heroTextFade;
  late Animation<Offset> _heroTextSlide;

  // Hover state for nav buttons
  bool _aboutHover = false;
  bool _loginHover = false;
  bool _signupHover = false;

  @override
  void initState() {
    super.initState();

    // Initialize video player for hero background
    _videoController = VideoPlayerController.asset(
      'assets/videos/homepage_bg.mp4',
    );
    _videoController.initialize().then((_) {
      setState(() => _videoInitialized = true);
      _videoController.setLooping(true);
      _videoController.setVolume(0);
      _videoController.play();
    });

    // Track scroll to fade out hero video
    _scrollController.addListener(() {
      setState(() => _scrollOffset = _scrollController.offset);
    });

    // Hero text entrance animation
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
    _heroTextSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _heroTextController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    // Request focus for keyboard navigation
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

  /// Smooth scroll by a fixed amount when arrow keys are pressed
  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _scrollController.animateTo(
          _scrollController.offset + 120,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _scrollController.animateTo(
          _scrollController.offset - 120,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  /// Show the About modal dialog
  void _showAbout() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (context) => const _AboutDialog(),
    );
  }

  /// Hero fade overlay opacity based on scroll — increases as user scrolls
  double get _heroFadeOpacity {
    const fadeStart = 0.0;
    const fadeEnd = 400.0;
    if (_scrollOffset <= fadeStart) return 0.0;
    if (_scrollOffset >= fadeEnd) return 1.0;
    return (_scrollOffset - fadeStart) / (fadeEnd - fadeStart);
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: _handleKeyEvent,
      child: GestureDetector(
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
                    // Section 1: Hero with video background
                    _HeroSection(
                      videoController: _videoController,
                      videoInitialized: _videoInitialized,
                      heroFadeOpacity: _heroFadeOpacity,
                      heroTextFade: _heroTextFade,
                      heroTextSlide: _heroTextSlide,
                    ),

                    // Section 2: Developers
                    const _DevelopersSection(),

                    // Section 3: Positions / Roles
                    const _PositionsSection(),

                    // Section 4: Contact
                    const _ContactSection(),
                  ],
                ),
              ),

              // ── Fixed top navigation bar ────────────────────────
              // Overlays the scrollable content at the top
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
// ─────────────────────────────────────────────────────────────────

class _TopNavBar extends StatelessWidget {
  final double scrollOffset;
  final bool aboutHover;
  final bool loginHover;
  final bool signupHover;
  final ValueChanged<bool> onAboutHoverChange;
  final ValueChanged<bool> onLoginHoverChange;
  final ValueChanged<bool> onSignupHoverChange;
  final VoidCallback onAbout;
  final VoidCallback onLogin;
  final VoidCallback onSignup;

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
    // Nav bar becomes more opaque as user scrolls down
    final double bgOpacity = (scrollOffset / 200).clamp(0.0, 0.95);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          color: Colors.black.withOpacity(bgOpacity),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            bottom: 8,
            left: 24,
            right: 24,
          ),
          child: Row(
            children: [
              // Logo
              Image.asset(
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

              const Spacer(),

              // About button
              MouseRegion(
                onEnter: (_) => onAboutHoverChange(true),
                onExit: (_) => onAboutHoverChange(false),
                child: GestureDetector(
                  onTap: onAbout,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: aboutHover
                          ? Colors.white.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: aboutHover
                            ? Colors.white.withOpacity(0.4)
                            : Colors.transparent,
                      ),
                    ),
                    child: const Text(
                      'About',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Login button
              MouseRegion(
                onEnter: (_) => onLoginHoverChange(true),
                onExit: (_) => onLoginHoverChange(false),
                child: GestureDetector(
                  onTap: onLogin,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: loginHover
                          ? Colors.white.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Sign Up button (filled)
              MouseRegion(
                onEnter: (_) => onSignupHoverChange(true),
                onExit: (_) => onSignupHoverChange(false),
                child: GestureDetector(
                  onTap: onSignup,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: signupHover
                          ? const Color(0xFF1877F2)
                          : const Color(0xFF1877F2).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: signupHover
                          ? [
                              BoxShadow(
                                color: const Color(0xFF1877F2).withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 2,
                              )
                            ]
                          : [],
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
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
// HERO SECTION
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
          // ── Video background ──────────────────────────────────
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

          // ── Gradient overlay (always present) ─────────────────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.85),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // ── Scroll-driven fade to black ───────────────────────
          // As user scrolls down, this overlay fades in
          // creating a smooth transition to the next section
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: heroFadeOpacity,
              duration: Duration.zero, // Immediate — driven by scroll
              child: Container(color: Colors.black),
            ),
          ),

          // ── Hero text content ─────────────────────────────────
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Entrance animation for the text
                  FadeTransition(
                    opacity: heroTextFade,
                    child: SlideTransition(
                      position: heroTextSlide,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Eyebrow label
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1877F2).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: const Color(0xFF1877F2).withOpacity(0.6),
                              ),
                            ),
                            child: const Text(
                              'PROFILE CAROUSEL',
                              style: TextStyle(
                                color: Color(0xFF60A5FA),
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
                            'Connect with profiles, explore stories,\nand find your community.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 18,
                              height: 1.6,
                              letterSpacing: 0.3,
                            ),
                          ),

                          const SizedBox(height: 48),

                          // CTA buttons row
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
                                onTap: () {
                                  // Scroll to developers section
                                },
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

          // ── Scroll indicator at bottom ────────────────────────
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

/// Animated bouncing scroll arrow indicator
class _ScrollArrow extends StatefulWidget {
  const _ScrollArrow();

  @override
  State<_ScrollArrow> createState() => _ScrollArrowState();
}

class _ScrollArrowState extends State<_ScrollArrow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white54,
            size: 28,
          ),
        );
      },
    );
  }
}

/// CTA button in the hero section
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
                ? (_hovered
                    ? const Color(0xFF1877F2)
                    : const Color(0xFF1877F2).withOpacity(0.85))
                : (_hovered
                    ? Colors.white.withOpacity(0.15)
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.filled
                  ? Colors.transparent
                  : Colors.white.withOpacity(0.5),
            ),
            boxShadow: widget.filled && _hovered
                ? [
                    BoxShadow(
                      color: const Color(0xFF1877F2).withOpacity(0.4),
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
// ─────────────────────────────────────────────────────────────────

class _DevelopersSection extends StatelessWidget {
  const _DevelopersSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 48),
      child: Column(
        children: [
          // Section label
          _SectionLabel(label: 'THE TEAM'),
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
          const SizedBox(height: 16),

          Text(
            'The talented individuals who built this platform',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 72),

          // Developer cards row
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              if (isWide) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: DeveloperData.developers
                      .map((dev) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: _DeveloperCard(developer: dev),
                          ))
                      .toList(),
                );
              }
              return Column(
                children: DeveloperData.developers
                    .map((dev) => Padding(
                          padding: const EdgeInsets.only(bottom: 40),
                          child: _DeveloperCard(developer: dev),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

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
        transform: Matrix4.identity()..translate(0.0, _hovered ? -12.0 : 0.0),
        child: Column(
          children: [
            // Photo container with glow on hover
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: _hovered
                    ? [
                        BoxShadow(
                          color: const Color(0xFF1877F2).withOpacity(0.5),
                          blurRadius: 40,
                          spreadRadius: 5,
                        )
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        )
                      ],
                border: Border.all(
                  color: _hovered
                      ? const Color(0xFF1877F2)
                      : Colors.white.withOpacity(0.15),
                  width: 3,
                ),
                image: DecorationImage(
                  image: AssetImage(widget.developer.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 20),

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

            // Primary role label
            Text(
              widget.developer.primaryRole,
              style: TextStyle(
                color: const Color(0xFF60A5FA).withOpacity(0.8),
                fontSize: 14,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// POSITIONS SECTION
// ─────────────────────────────────────────────────────────────────

class _PositionsSection extends StatelessWidget {
  const _PositionsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF050505),
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 48),
      child: Column(
        children: [
          _SectionLabel(label: 'ROLES'),
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
          const SizedBox(height: 16),

          Text(
            'Each developer brings unique skills to the team',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 72),

          // Top row: Frontend + Backend
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              return Column(
                children: [
                  // Top row
                  if (isWide)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _RoleCard(
                          role: 'Frontend Developer',
                          developer: DeveloperData.developers[0],
                          icon: Icons.web,
                          color: const Color(0xFF3B82F6),
                        ),
                        const SizedBox(width: 24),
                        _RoleCard(
                          role: 'Backend Developer',
                          developer: DeveloperData.developers[1],
                          icon: Icons.storage,
                          color: const Color(0xFF10B981),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _RoleCard(
                          role: 'Frontend Developer',
                          developer: DeveloperData.developers[0],
                          icon: Icons.web,
                          color: const Color(0xFF3B82F6),
                        ),
                        const SizedBox(height: 24),
                        _RoleCard(
                          role: 'Backend Developer',
                          developer: DeveloperData.developers[1],
                          icon: Icons.storage,
                          color: const Color(0xFF10B981),
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),

                  // Middle: Full-stack
                  _RoleCard(
                    role: 'Full-Stack Developer',
                    developer: DeveloperData.developers[2],
                    icon: Icons.layers,
                    color: const Color(0xFF8B5CF6),
                    wide: isWide,
                  ),

                  const SizedBox(height: 24),

                  // Bottom: Web Designer
                  _RoleCard(
                    role: 'Web Designer',
                    developer: DeveloperData.developers[0],
                    icon: Icons.brush,
                    color: const Color(0xFFF59E0B),
                    wide: isWide,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final String role;
  final DeveloperInfo developer;
  final IconData icon;
  final Color color;
  final bool wide;

  const _RoleCard({
    required this.role,
    required this.developer,
    required this.icon,
    required this.color,
    this.wide = false,
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
        width: widget.wide ? 500 : 300,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: _hovered
              ? Colors.white.withOpacity(0.07)
              : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered
                ? widget.color.withOpacity(0.5)
                : Colors.white.withOpacity(0.08),
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: widget.color.withOpacity(0.15),
                    blurRadius: 30,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            // Developer photo
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
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

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Role icon + title
                  Row(
                    children: [
                      Icon(widget.icon, color: widget.color, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.role,
                          style: TextStyle(
                            color: widget.color,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Developer name
                  Text(
                    widget.developer.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
// ─────────────────────────────────────────────────────────────────

class _ContactSection extends StatelessWidget {
  const _ContactSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 48),
      child: Column(
        children: [
          _SectionLabel(label: 'CONTACT'),
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
          const SizedBox(height: 16),

          Text(
            'Reach out to any of our developers directly',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 72),

          // Contact cards
          LayoutBuilder(
            builder: (context, constraints) {
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
                          padding: const EdgeInsets.only(bottom: 24),
                          child: _ContactCard(developer: dev),
                        ))
                    .toList(),
              );
            },
          ),

          const SizedBox(height: 80),

          // Footer
          Divider(color: Colors.white.withOpacity(0.1)),
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
        width: 300,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: _hovered
              ? Colors.white.withOpacity(0.07)
              : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered
                ? const Color(0xFF1877F2).withOpacity(0.4)
                : Colors.white.withOpacity(0.08),
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: const Color(0xFF1877F2).withOpacity(0.1),
                    blurRadius: 30,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: Column(
          children: [
            // Photo
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF1877F2).withOpacity(0.4),
                  width: 2,
                ),
                image: DecorationImage(
                  image: AssetImage(widget.developer.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Name
            Text(
              widget.developer.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 4),

            Text(
              widget.developer.primaryRole,
              style: TextStyle(
                color: const Color(0xFF60A5FA).withOpacity(0.8),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            Divider(color: Colors.white.withOpacity(0.1)),

            const SizedBox(height: 16),

            // Contact info rows
            _ContactRow(
              icon: Icons.email_outlined,
              label: widget.developer.gmail,
              color: const Color(0xFFEF4444),
            ),
            const SizedBox(height: 12),
            _ContactRow(
              icon: Icons.facebook,
              label: widget.developer.facebook,
              color: const Color(0xFF3B82F6),
            ),
            const SizedBox(height: 12),
            _ContactRow(
              icon: Icons.phone_outlined,
              label: widget.developer.phone,
              color: const Color(0xFF10B981),
            ),
          ],
        ),
      ),
    );
  }
}

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
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
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
// ABOUT DIALOG
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
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1877F2).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        color: Color(0xFF60A5FA),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'About Profile Carousel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Content
                Text(
                  'Profile Carousel is a modern full-stack web application '
                  'that allows users to discover, create, and manage '
                  'user profiles in a beautiful carousel interface.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 15,
                    height: 1.7,
                  ),
                ),

                const SizedBox(height: 20),

                // Tech stack chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _TechChip(
                        label: 'Flutter Web', color: const Color(0xFF54C5F8)),
                    _TechChip(label: 'Go', color: const Color(0xFF00ACD7)),
                    _TechChip(
                        label: 'PostgreSQL', color: const Color(0xFF336791)),
                    _TechChip(
                        label: 'REST API', color: const Color(0xFF10B981)),
                    _TechChip(
                        label: 'JWT Auth', color: const Color(0xFFF59E0B)),
                  ],
                ),

                const SizedBox(height: 24),

                // Feature list
                ...[
                  'Role-based authentication (Main & Sub users)',
                  'Profile creation with photo upload',
                  'Real-time profile management',
                  'Responsive design for all screen sizes',
                ].map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Color(0xFF10B981),
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            feature,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
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
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// SHARED SECTION LABEL
// ─────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1877F2).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFF1877F2).withOpacity(0.3),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF60A5FA),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 3,
        ),
      ),
    );
  }
}

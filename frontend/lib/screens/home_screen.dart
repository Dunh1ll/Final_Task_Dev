import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../data/developer_data.dart';

// ─────────────────────────────────────────────────────────────────
// GREEN COLOR PALETTE — replaces all blue accents
// ─────────────────────────────────────────────────────────────────
const Color _kAccent = Color(0xFF22C55E); // green-500 — primary
const Color _kAccentLight = Color(0xFF86EFAC); // green-300 — light text
const Color _kAccentGlow = Color(0xFF16A34A); // green-600 — glow/shadow

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
  bool _aboutHover = false;
  bool _loginHover = false;
  bool _signupHover = false;

  @override
  void initState() {
    super.initState();
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
    _scrollController.addListener(() {
      if (mounted) setState(() => _scrollOffset = _scrollController.offset);
    });
    _heroTextController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _heroTextFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _heroTextController,
          curve: const Interval(0.0, 0.7, curve: Curves.easeOut)),
    );
    _heroTextSlide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _heroTextController,
                curve: const Interval(0.0, 0.8, curve: Curves.easeOut)));
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

  void _showAbout() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (_) => const _AboutDialog(),
    );
  }

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
        onTap: () => _focusNode.requestFocus(),
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _HeroSection(
                      videoController: _videoController,
                      videoInitialized: _videoInitialized,
                      heroFadeOpacity: _heroFadeOpacity,
                      heroTextFade: _heroTextFade,
                      heroTextSlide: _heroTextSlide,
                    ),
                    const _DevelopersSection(),
                    const _PositionsSection(),
                    const _ContactSection(),
                  ],
                ),
              ),
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
// TOP NAV BAR
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

              // About
              _NavButton(
                label: 'About',
                hovered: aboutHover,
                onHoverChange: onAboutHoverChange,
                onTap: onAbout,
                filled: false,
              ),
              const SizedBox(width: 8),

              // Login
              _NavButton(
                label: 'Login',
                hovered: loginHover,
                onHoverChange: onLoginHoverChange,
                onTap: onLogin,
                filled: false,
                showBorder: true,
              ),
              const SizedBox(width: 8),

              // Sign Up (filled green)
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
            border: (showBorder || filled)
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

          // Gradient overlay
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
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: heroFadeOpacity,
                child: Container(color: Colors.black),
              ),
            ),
          ),

          // Hero text + CTA
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
                          // Eyebrow pill
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

          // Scroll indicator
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

class _HeroCTAButton extends StatefulWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;
  const _HeroCTAButton(
      {required this.label, required this.filled, required this.onTap});
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
          const _SectionLabel(label: 'THE TEAM'),
          const SizedBox(height: 16),
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
            style:
                TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 72),
          LayoutBuilder(builder: (context, constraints) {
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
          }),
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
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: _hovered
                    ? [
                        BoxShadow(
                            color: _kAccent.withOpacity(0.5),
                            blurRadius: 40,
                            spreadRadius: 5)
                      ]
                    : [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 2)
                      ],
                border: Border.all(
                  color: _hovered ? _kAccent : Colors.white.withOpacity(0.15),
                  width: 3,
                ),
                image: DecorationImage(
                  image: AssetImage(widget.developer.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
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
            Text(
              widget.developer.primaryRole,
              style: TextStyle(
                color: _kAccentLight.withOpacity(0.8),
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
// ✅ Updated roles: Pallen=Full-Stack, Aldhy=Front-End
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
          const SizedBox(height: 16),
          Text(
            'Each developer brings unique skills to the team',
            style:
                TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 72),
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;
            return Column(
              children: [
                // Top row: Full-Stack (Pallen) + Backend (Karl)
                if (isWide)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _RoleCard(
                        role: 'Frontend Developer',
                        developer: DeveloperData.developers[2],
                        icon: Icons.layers,
                        color: const Color(0xFF22C55E),
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
                  Column(children: [
                    _RoleCard(
                      role: 'Frontend Developer',
                      developer: DeveloperData.developers[2],
                      icon: Icons.layers,
                      color: const Color(0xFF22C55E),
                    ),
                    const SizedBox(height: 24),
                    _RoleCard(
                      role: 'Backend Developer',
                      developer: DeveloperData.developers[1],
                      icon: Icons.storage,
                      color: const Color(0xFF10B981),
                    ),
                  ]),

                const SizedBox(height: 24),

                // Middle: Front-End (Aldhy)
                _RoleCard(
                  role: 'Full-stack Developer',
                  developer: DeveloperData.developers[0],
                  icon: Icons.web,
                  color: const Color(0xFF4ADE80),
                  wide: isWide,
                ),

                const SizedBox(height: 24),

                // Bottom: Web Designer (Pallen)
                _RoleCard(
                  role: 'Web Designer',
                  developer: DeveloperData.developers[0],
                  icon: Icons.brush,
                  color: const Color(0xFFA3E635),
                  wide: isWide,
                ),
              ],
            );
          }),
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
                      spreadRadius: 2)
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                    Border.all(color: widget.color.withOpacity(0.5), width: 2),
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
          const SizedBox(height: 16),
          Text(
            'Reach out to any of our developers directly',
            style:
                TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 72),
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
                        padding: const EdgeInsets.only(bottom: 24),
                        child: _ContactCard(developer: dev),
                      ))
                  .toList(),
            );
          }),
          const SizedBox(height: 80),
          Divider(color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 32),
          Text(
            '© 2026 KAD · Built with Flutter & Go',
            style:
                TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13),
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
                ? _kAccent.withOpacity(0.4)
                : Colors.white.withOpacity(0.08),
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                      color: _kAccent.withOpacity(0.1),
                      blurRadius: 30,
                      spreadRadius: 2)
                ]
              : [],
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _kAccent.withOpacity(0.4), width: 2),
                image: DecorationImage(
                  image: AssetImage(widget.developer.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.developer.name,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              widget.developer.primaryRole,
              style: TextStyle(
                  color: _kAccentLight.withOpacity(0.8), fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Divider(color: Colors.white.withOpacity(0.1)),
            const SizedBox(height: 16),
            _ContactRow(
              icon: Icons.email_outlined,
              label: widget.developer.gmail,
              color: const Color(0xFFEF4444),
            ),
            const SizedBox(height: 12),
            _ContactRow(
              icon: Icons.facebook,
              label: widget.developer.facebook,
              color: const Color(0xFF22C55E),
            ),
            const SizedBox(height: 12),
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

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _ContactRow(
      {required this.icon, required this.label, required this.color});

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
            style:
                TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
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
                        'About KAD',
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
                  'KAD is a modern full-stack web application '
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

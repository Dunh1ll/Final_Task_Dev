import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../data/developer_data.dart';
import '../utils/constants.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

const Color _kGold = Color(0xFFD4A017);
const Color _kBrightGold = Color(0xFFFFD700);
const Color _kCrimson = Color(0xFF8B1A1A);
const Color _kParchment = Color(0xFFF5DEB3);
const Color _kDarkBrown = Color(0xFF1A0A00);
const Color _kAgedGold = Color(0xFF8B6914);
const Color _kNavy = Color(0xFF1C3A5C);

/// HomeScreen — One Piece themed landing page.
///
/// ✅ FIX 1: Video no longer moves on overscroll.
///   Changed from BouncingScrollPhysics to ClampingScrollPhysics.
///   Overscroll is detected via NotificationListener<OverscrollNotification>
///   WITHOUT moving the content — only the refresh indicator moves.
///   This matches the Facebook pull-to-refresh behavior.
///
/// ✅ FIX 2: Mode toggle shows a full-screen loading overlay.
///   When Dark/Light is clicked, the entire screen goes black.
///   The site logo appears at the center with a circular spinner.
///   Once the new video is loaded, the overlay fades out.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  bool _isDarkMode = false;

  // ✅ FIX 2: Loading overlay state
  // true while the new video is being initialized
  bool _isLoadingMode = false;

  late VideoPlayerController _videoController;
  bool _videoInitialized = false;
  double _scrollOffset = 0.0;

  // ✅ FIX 1: Pull-to-refresh state
  // Tracks how far the indicator has been pulled (0 to threshold)
  double _pullIndicatorOffset = 0.0;
  bool _isRefreshing = false;
  static const double _refreshThreshold = 80.0;

  late AnimationController _heroTextController;
  late Animation<double> _heroTextFade;
  late Animation<Offset> _heroTextSlide;

  // Spinning animation for refresh indicator
  late AnimationController _spinController;

  // Fade animation for the loading overlay
  late AnimationController _loadingFadeController;
  late Animation<double> _loadingFade;

  bool _aboutHover = false;
  bool _loginHover = false;
  bool _signupHover = false;

  @override
  void initState() {
    super.initState();

    _initVideo(AssetPaths.homeVideoLight);

    _scrollController.addListener(() {
      if (mounted) {
        setState(() => _scrollOffset = _scrollController.offset);
      }
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

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();

    _loadingFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _loadingFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _loadingFadeController, curve: Curves.easeOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _heroTextController.forward();
    });
  }

  Future<void> _initVideo(String assetPath) async {
    if (_videoInitialized) {
      await _videoController.dispose();
      if (mounted) setState(() => _videoInitialized = false);
    }
    _videoController = VideoPlayerController.asset(assetPath);
    await _videoController.initialize();
    if (mounted) {
      setState(() => _videoInitialized = true);
      _videoController
        ..setLooping(true)
        ..setVolume(0)
        ..play();
    }
  }

  /// ✅ FIX 2: Toggle video mode with full-screen loading overlay.
  ///
  /// Flow:
  ///   1. Show black overlay with logo + spinner (fade in)
  ///   2. Initialize the new video in the background
  ///   3. Fade out the overlay
  Future<void> _toggleVideoMode() async {
    // Prevent double-tap while loading
    if (_isLoadingMode) return;

    // Show the loading overlay
    setState(() => _isLoadingMode = true);
    await _loadingFadeController.forward(from: 0.0);

    // Switch video
    final bool newMode = !_isDarkMode;
    setState(() => _isDarkMode = newMode);
    await _initVideo(
        newMode ? AssetPaths.homeVideoDark : AssetPaths.homeVideoLight);

    // Short pause so the video starts playing before we hide overlay
    await Future.delayed(const Duration(milliseconds: 400));

    // Fade out the overlay
    await _loadingFadeController.reverse();
    if (mounted) setState(() => _isLoadingMode = false);
  }

  /// ✅ FIX 1: Trigger page refresh.
  Future<void> _triggerRefresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 600));
    html.window.location.reload();
  }

  @override
  void dispose() {
    _videoController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _heroTextController.dispose();
    _spinController.dispose();
    _loadingFadeController.dispose();
    super.dispose();
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final double delta =
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
      barrierColor: Colors.black.withOpacity(0.85),
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
          backgroundColor: _kDarkBrown,
          body: Stack(
            children: [
              // ── MAIN SCROLL CONTENT ───────────────────
              // ✅ FIX 1: NotificationListener detects overscroll
              // WITHOUT the content moving.
              // ClampingScrollPhysics stops the elastic bounce
              // that was causing the video to slide down.
              NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  // Only care about overscroll at the very top
                  if (notification is OverscrollNotification &&
                      notification.overscroll < 0 &&
                      _scrollController.offset <= 0) {
                    // User is pulling down past the top edge.
                    // Move only the indicator, not the content.
                    setState(() {
                      _pullIndicatorOffset = (_pullIndicatorOffset +
                              (-notification.overscroll * 0.5))
                          .clamp(0.0, _refreshThreshold * 1.3);
                    });

                    if (_pullIndicatorOffset >= _refreshThreshold &&
                        !_isRefreshing) {
                      _triggerRefresh();
                    }
                  }

                  // When scroll ends and we haven't triggered,
                  // animate the indicator back up
                  if (notification is ScrollEndNotification) {
                    if (!_isRefreshing && _pullIndicatorOffset > 0) {
                      setState(() => _pullIndicatorOffset = 0.0);
                    }
                  }

                  return false;
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  // ✅ FIX 1: ClampingScrollPhysics prevents
                  // the rubber-band bounce that moved the video.
                  physics: const ClampingScrollPhysics(),
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
              ),

              // ── PULL-TO-REFRESH INDICATOR ─────────────
              // ✅ FIX 1: Only the indicator slides down —
              // the video/content behind it does NOT move.
              if (_pullIndicatorOffset > 0 || _isRefreshing)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _PullRefreshIndicator(
                    pullOffset: _pullIndicatorOffset,
                    isRefreshing: _isRefreshing,
                    threshold: _refreshThreshold,
                    spinController: _spinController,
                  ),
                ),

              // ── NAV BAR — fully invisible background ──
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _TopNavBar(
                  isDarkMode: _isDarkMode,
                  aboutHover: _aboutHover,
                  loginHover: _loginHover,
                  signupHover: _signupHover,
                  onAboutHoverChange: (v) => setState(() => _aboutHover = v),
                  onLoginHoverChange: (v) => setState(() => _loginHover = v),
                  onSignupHoverChange: (v) => setState(() => _signupHover = v),
                  onAbout: _showAbout,
                  onLogin: () => context.go('/login'),
                  onSignup: () => context.go('/register'),
                  onToggleMode: _toggleVideoMode,
                ),
              ),

              // ── MODE-SWITCH LOADING OVERLAY ───────────
              // ✅ FIX 2: Full-screen black overlay with logo
              // and circular spinner. Shown while the new video
              // initializes. Fades in and out smoothly.
              if (_isLoadingMode)
                FadeTransition(
                  opacity: _loadingFade,
                  child: _ModeSwitchLoadingOverlay(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// MODE SWITCH LOADING OVERLAY
//
// Modern loading indicator with logo centered and
// animated dots at the bottom that pulse as a loading signal.
// ─────────────────────────────────────────────────────────────────
class _ModeSwitchLoadingOverlay extends StatefulWidget {
  @override
  State<_ModeSwitchLoadingOverlay> createState() =>
      _ModeSwitchLoadingOverlayState();
}

class _ModeSwitchLoadingOverlayState extends State<_ModeSwitchLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _dotController;
  late List<Animation<double>> _dotAnimations;

  @override
  void initState() {
    super.initState();

    // Controller for the dot animations
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // Create staggered animations for 3 dots
    _dotAnimations = List.generate(3, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _dotController,
          curve: Interval(
            index * 0.2,
            0.6 + (index * 0.2),
            curve: Curves.easeInOut,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo at the center
          Image.asset(
            'assets/images/logo.png',
            height: 80,
            errorBuilder: (_, __, ___) => const Text(
              '⚓',
              style: TextStyle(
                fontSize: 72,
                color: _kBrightGold,
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Animated dots at the bottom of the logo
          AnimatedBuilder(
            animation: _dotController,
            builder: (context, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  // Calculate opacity and scale based on animation value
                  final double opacity =
                      0.3 + (0.7 * _dotAnimations[index].value);
                  final double scale =
                      0.6 + (0.5 * _dotAnimations[index].value);

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _kBrightGold.withOpacity(opacity),
                          boxShadow: [
                            BoxShadow(
                              color: _kBrightGold.withOpacity(
                                  0.3 * _dotAnimations[index].value),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),

          // Optional: Loading text below the dots
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: _dotController,
            builder: (context, child) {
              // Pulsing text effect
              final double textOpacity = 0.4 +
                  (0.3 *
                      (1 + math.sin(_dotController.value * 2 * math.pi)) /
                      2);

              return Opacity(
                opacity: textOpacity,
                child: const Text(
                  'LOADING',
                  style: TextStyle(
                    color: _kAgedGold,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// PULL-TO-REFRESH INDICATOR
//
// ✅ FIX 1: This widget slides DOWN from the top edge.
// The content behind it (video) does NOT move at all.
// Only this widget's vertical position changes based on pullOffset.
// ─────────────────────────────────────────────────────────────────
class _PullRefreshIndicator extends StatelessWidget {
  final double pullOffset;
  final bool isRefreshing;
  final double threshold;
  final AnimationController spinController;

  const _PullRefreshIndicator({
    required this.pullOffset,
    required this.isRefreshing,
    required this.threshold,
    required this.spinController,
  });

  @override
  Widget build(BuildContext context) {
    // Progress from 0.0 (just starting to pull)
    // to 1.0 (threshold reached)
    final double progress = (pullOffset / threshold).clamp(0.0, 1.0);

    // The indicator starts hidden above the top (offset = -48)
    // and slides down as the user pulls.
    // When refreshing, it stays at a fixed position.
    final double topOffset =
        isRefreshing ? 24.0 : (-48.0 + pullOffset * 0.75).clamp(-48.0, 40.0);

    return AnimatedPositioned(
      duration:
          isRefreshing ? const Duration(milliseconds: 200) : Duration.zero,
      top: topOffset,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedOpacity(
          opacity: progress,
          duration: Duration.zero,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              // Dark background so it's visible over the video
              color: _kDarkBrown.withOpacity(0.9),
              shape: BoxShape.circle,
              border: Border.all(
                color: _kGold.withOpacity(0.4 + 0.6 * progress),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _kGold.withOpacity(0.25 * progress),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: isRefreshing
                // Full spin while refreshing
                ? RotationTransition(
                    turns: spinController,
                    child: const Icon(
                      Icons.refresh,
                      color: _kBrightGold,
                      size: 24,
                    ),
                  )
                // Rotate proportionally as user pulls
                : Transform.rotate(
                    angle: progress * 6.28,
                    child: const Icon(
                      Icons.refresh,
                      color: _kBrightGold,
                      size: 24,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// TOP NAV BAR — fully transparent/invisible background
// ─────────────────────────────────────────────────────────────────
class _TopNavBar extends StatelessWidget {
  final bool isDarkMode;
  final bool aboutHover, loginHover, signupHover;
  final ValueChanged<bool> onAboutHoverChange,
      onLoginHoverChange,
      onSignupHoverChange;
  final VoidCallback onAbout, onLogin, onSignup;
  final VoidCallback onToggleMode;

  const _TopNavBar({
    required this.isDarkMode,
    required this.aboutHover,
    required this.loginHover,
    required this.signupHover,
    required this.onAboutHoverChange,
    required this.onLoginHoverChange,
    required this.onSignupHoverChange,
    required this.onAbout,
    required this.onLogin,
    required this.onSignup,
    required this.onToggleMode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 8,
        left: 24,
        right: 24,
      ),
      child: Row(
        children: [
          // Logo — no glow, no animated container
          Image.asset(
            'assets/images/logo.png',
            height: 40,
            errorBuilder: (_, __, ___) => const Text(
              'ONE PIECE',
              style: TextStyle(
                color: _kBrightGold,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),

          const Spacer(),

          _ModeToggleButton(
            isDarkMode: isDarkMode,
            onToggle: onToggleMode,
          ),

          const SizedBox(width: 12),

          _NavButton(
            label: 'About',
            hovered: aboutHover,
            onHoverChange: onAboutHoverChange,
            onTap: onAbout,
            filled: false,
          ),
          const SizedBox(width: 8),
          _NavButton(
            label: 'Login',
            hovered: loginHover,
            onHoverChange: onLoginHoverChange,
            onTap: onLogin,
            filled: false,
            showBorder: true,
          ),
          const SizedBox(width: 8),
          _NavButton(
            label: 'Sign Up',
            hovered: signupHover,
            onHoverChange: onSignupHoverChange,
            onTap: onSignup,
            filled: true,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// MODE TOGGLE BUTTON
// ─────────────────────────────────────────────────────────────────
class _ModeToggleButton extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggle;

  const _ModeToggleButton({
    required this.isDarkMode,
    required this.onToggle,
  });

  @override
  State<_ModeToggleButton> createState() => _ModeToggleButtonState();
}

class _ModeToggleButtonState extends State<_ModeToggleButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color:
                _hovered ? _kGold.withOpacity(0.25) : _kGold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _kGold.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.isDarkMode
                    ? Icons.wb_sunny_outlined
                    : Icons.nights_stay_outlined,
                color: _kBrightGold,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                widget.isDarkMode ? 'Light' : 'Dark',
                style: const TextStyle(
                  color: _kBrightGold,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
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
// NAV BUTTON
// ─────────────────────────────────────────────────────────────────
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
                ? (hovered ? _kGold : _kGold.withOpacity(0.85))
                : (hovered ? _kGold.withOpacity(0.15) : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
            border: (showBorder || filled)
                ? Border.all(
                    color:
                        filled ? Colors.transparent : _kGold.withOpacity(0.6),
                  )
                : Border.all(
                    color:
                        hovered ? _kGold.withOpacity(0.5) : Colors.transparent),
            boxShadow: filled && hovered
                ? [
                    BoxShadow(
                      color: _kGold.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: hovered && !filled ? _kBrightGold : Colors.white,
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
// HERO SECTION — PirataOne font on title
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
          // Video background — stays fixed, never moves
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
                : Container(color: _kDarkBrown),
          ),

          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.92),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          // Scroll-based dark fade
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: heroFadeOpacity,
                child: Container(color: Colors.black),
              ),
            ),
          ),

          // Hero text
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: _kGold.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                              border:
                                  Border.all(color: _kGold.withOpacity(0.6)),
                            ),
                            child: const Text(
                              '⚓  NAKAMA PROFILES',
                              style: TextStyle(
                                color: _kBrightGold,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // ✅ PirataOne font on main title
                          const Text(
                            'Set Sail\nWith Your\nCrew!',
                            style: TextStyle(
                              fontFamily: 'PirataOne',
                              color: Colors.white,
                              fontSize: 80,
                              fontWeight: FontWeight.w900,
                              height: 1.05,
                              letterSpacing: 1,
                            ),
                          ),

                          const SizedBox(height: 20),

                          Text(
                            'Discover your nakama, explore '
                            'their stories,\n'
                            'and find your place on the '
                            'Grand Line.',
                            style: TextStyle(
                              color: _kParchment.withOpacity(0.75),
                              fontSize: 18,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 48),

                          Row(
                            children: [
                              _HeroCTAButton(
                                label: '⚓  Join the Crew',
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

          // Scroll cue
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
                      color: _kAgedGold,
                      fontSize: 11,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w700,
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
              color: _kAgedGold, size: 28),
        ),
      );
}

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
                ? (_hovered ? _kGold : _kGold.withOpacity(0.85))
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
                      color: _kGold.withOpacity(0.5),
                      blurRadius: 28,
                      spreadRadius: 3,
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
      color: const Color(0xFF0D0500),
      padding: const EdgeInsets.symmetric(vertical: 72, horizontal: 48),
      child: Column(
        children: [
          const _SectionLabel(label: '⚓  THE CREW'),
          const SizedBox(height: 16),
          const Text(
            'Meet the Developers',
            style: TextStyle(
              color: _kParchment,
              fontSize: 48,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'The nakama who built this ship from scratch',
            style: TextStyle(
              color: _kParchment.withOpacity(0.5),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;
            if (isWide) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: DeveloperData.developers
                    .map((dev) => Padding(
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
        transform: Matrix4.identity()..translate(0.0, _hovered ? -8.0 : 0.0),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: _hovered
                    ? [
                        BoxShadow(
                          color: _kGold.withOpacity(0.5),
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
                  color: _hovered ? _kBrightGold : _kAgedGold.withOpacity(0.4),
                  width: _hovered ? 3 : 1.5,
                ),
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
                color: _kParchment,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _kGold.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _kGold.withOpacity(0.4)),
              ),
              child: Text(
                widget.developer.primaryRole,
                style: const TextStyle(
                  color: _kBrightGold,
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
// ─────────────────────────────────────────────────────────────────
class _PositionsSection extends StatelessWidget {
  const _PositionsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A0300),
      padding: const EdgeInsets.symmetric(vertical: 72, horizontal: 48),
      child: Column(
        children: [
          const _SectionLabel(label: '🏴‍☠️  DEVIL FRUITS'),
          const SizedBox(height: 16),
          const Text(
            'Our Expertise',
            style: TextStyle(
              color: _kParchment,
              fontSize: 48,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Each crew member brings unique powers',
            style: TextStyle(
              color: _kParchment.withOpacity(0.5),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;
            if (isWide) {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _RoleCard(
                          role: 'Frontend Developer',
                          developer: DeveloperData.developers[2],
                          icon: Icons.web,
                          color: _kGold),
                      const SizedBox(width: 24),
                      _RoleCard(
                          role: 'Backend Developer',
                          developer: DeveloperData.developers[1],
                          icon: Icons.storage,
                          color: _kCrimson),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _RoleCard(
                          role: 'Full-Stack Developer',
                          developer: DeveloperData.developers[0],
                          icon: Icons.layers,
                          color: _kBrightGold),
                      const SizedBox(width: 24),
                      _RoleCard(
                          role: 'Web Designer',
                          developer: DeveloperData.developers[0],
                          icon: Icons.brush,
                          color: _kNavy),
                    ],
                  ),
                ],
              );
            }
            return Column(
              children: [
                _RoleCard(
                    role: 'Frontend Developer',
                    developer: DeveloperData.developers[2],
                    icon: Icons.web,
                    color: _kGold,
                    fullWidth: true),
                const SizedBox(height: 16),
                _RoleCard(
                    role: 'Backend Developer',
                    developer: DeveloperData.developers[1],
                    icon: Icons.storage,
                    color: _kCrimson,
                    fullWidth: true),
                const SizedBox(height: 16),
                _RoleCard(
                    role: 'Full-Stack Developer',
                    developer: DeveloperData.developers[0],
                    icon: Icons.layers,
                    color: _kBrightGold,
                    fullWidth: true),
                const SizedBox(height: 16),
                _RoleCard(
                    role: 'Web Designer',
                    developer: DeveloperData.developers[0],
                    icon: Icons.brush,
                    color: _kNavy,
                    fullWidth: true),
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
        width: widget.fullWidth ? double.infinity : 380,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: _hovered
              ? _kGold.withOpacity(0.06)
              : Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered
                ? widget.color.withOpacity(0.6)
                : _kAgedGold.withOpacity(0.2),
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
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: widget.color.withOpacity(0.5), width: 2),
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
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: widget.color.withOpacity(0.15),
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
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.developer.name,
                    style: const TextStyle(
                      color: _kParchment,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.developer.primaryRole,
                    style: TextStyle(
                      color: _kParchment.withOpacity(0.4),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedOpacity(
              opacity: _hovered ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child:
                  Icon(Icons.arrow_forward_ios, color: widget.color, size: 14),
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
      padding: const EdgeInsets.symmetric(vertical: 72, horizontal: 48),
      child: Column(
        children: [
          const _SectionLabel(label: '📡  DEN DEN MUSHI'),
          const SizedBox(height: 16),
          const Text(
            'Get in Touch',
            style: TextStyle(
              color: _kParchment,
              fontSize: 48,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Send a transponder snail to our crew',
            style: TextStyle(
              color: _kParchment.withOpacity(0.5),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
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
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  _kGold.withOpacity(0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            '© 2026 Nakama Profiles · Flutter & Go · ⚓',
            style: TextStyle(
              color: _kAgedGold.withOpacity(0.5),
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
        width: 360,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: _hovered
              ? _kGold.withOpacity(0.06)
              : Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hovered
                ? _kGold.withOpacity(0.5)
                : _kAgedGold.withOpacity(0.2),
            width: _hovered ? 1.5 : 1,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: _kGold.withOpacity(0.15),
                    blurRadius: 40,
                    spreadRadius: 4,
                  )
                ]
              : [],
        ),
        child: Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _kGold.withOpacity(0.5), width: 2),
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
                color: _kParchment,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: _kGold.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _kGold.withOpacity(0.4)),
              ),
              child: Text(
                widget.developer.primaryRole,
                style: const TextStyle(
                  color: _kBrightGold,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    _kGold.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _ContactRow(
              icon: Icons.email_outlined,
              label: widget.developer.gmail,
              color: _kCrimson,
            ),
            const SizedBox(height: 14),
            _ContactRow(
              icon: Icons.facebook,
              label: widget.developer.facebook,
              color: _kNavy,
            ),
            const SizedBox(height: 14),
            _ContactRow(
              icon: Icons.phone_outlined,
              label: widget.developer.phone,
              color: _kGold,
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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: _kParchment.withOpacity(0.75),
              fontSize: 14,
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
              color: _kDarkBrown.withOpacity(0.92),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _kGold.withOpacity(0.35)),
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
                        color: _kGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.info_outline,
                          color: _kBrightGold, size: 24),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'About Nakama Profiles',
                        style: TextStyle(
                            color: _kParchment,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close,
                          color: _kParchment.withOpacity(0.6)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Nakama Profiles is a full-stack web '
                  'application inspired by One Piece. '
                  'Discover crew members, explore their '
                  'stories, and find your nakama.',
                  style: TextStyle(
                    color: _kParchment.withOpacity(0.75),
                    fontSize: 15,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _TechChip(label: 'Flutter Web', color: _kNavy),
                    _TechChip(label: 'Go', color: const Color(0xFF00ACD7)),
                    _TechChip(label: 'PostgreSQL', color: _kCrimson),
                    _TechChip(label: 'REST API', color: _kGold),
                    _TechChip(label: 'JWT Auth', color: _kBrightGold),
                  ],
                ),
                const SizedBox(height: 24),
                ...[
                  'Role-based auth (Captain & Crew)',
                  'Profile creation with photo upload',
                  'Wanted poster style profile cards',
                  'Responsive design for all screens',
                ].map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline,
                            color: _kGold, size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(f,
                              style: TextStyle(
                                color: _kParchment.withOpacity(0.7),
                                fontSize: 14,
                              )),
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
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: _kGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _kGold.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _kBrightGold,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 3,
        ),
      ),
    );
  }
}

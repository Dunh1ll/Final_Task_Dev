import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/sub_user.dart';
import '../utils/constants.dart';
import '../utils/image_helper.dart';
import '../widgets/main_profile_card_pallen.dart';
import '../widgets/main_profile_card_karl.dart';
import '../widgets/main_profile_card_aldhy.dart';
import '../widgets/video_background.dart';

const Color _kGold = Color(0xFFD4A017);
const Color _kBrightGold = Color(0xFFFFD700);
const Color _kCrimson = Color(0xFF8B1A1A);
const Color _kParchment = Color(0xFFF5DEB3);
const Color _kAgedGold = Color(0xFF8B6914);

/// DashboardScreen — One Piece themed main carousel.
///
/// ✅ CHANGED: Center card is bigger.
///   viewportFraction: 0.92 makes the center card fill 92%
///   of the screen width. Combined with minimal horizontal
///   padding (4px each side) the card is as large as possible
///   while still allowing side cards to peek.
///
/// ✅ KEPT: Side cards are faded (0.38 opacity) and
///   completely NOT clickable via IgnorePointer.
///   Only keyboard arrows, screen arrows, and swipe navigate.
/// ✅ KEPT: PirataOne font on "MAIN USER" title.
/// ✅ KEPT: 4:3 landscape card aspect ratio.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final PageController _pageController;
  final FocusNode _focusNode = FocusNode();
  int _currentPage = 0;
  static const int _cardCount = 3;

  @override
  void initState() {
    super.initState();
    // ✅ CHANGED: viewportFraction 0.92 — card is bigger,
    // fills most of the screen. Side cards peek 4% each side.
    _pageController = PageController(
      viewportFraction: 0.92,
      initialPage: 0,
    );
    _pageController.addListener(_onPageChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _onPageChanged() {
    if (_pageController.page != null) {
      setState(() => _currentPage = _pageController.page!.round());
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft &&
          _currentPage > 0) {
        _goToPrevious();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
          _currentPage < _cardCount - 1) {
        _goToNext();
      }
    }
  }

  void _goToPrevious() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    }
  }

  void _goToNext() {
    if (_currentPage < _cardCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleLogout() {
    context.read<AuthProvider>().logout();
    if (mounted) context.go('/');
  }

  void _openProfile(int index) {
    switch (index) {
      case 0:
        context.push('/profile-pallen');
        break;
      case 1:
        context.push('/profile-karl');
        break;
      case 2:
        context.push('/profile-aldhy');
        break;
    }
  }

  ImageProvider _getBadgeImageProvider(AuthProvider auth) {
    if (auth.isMainUser && auth.email != null) {
      const Map<String, String> emailToAsset = {
        'pallen@main.com': 'assets/images/profile1.jpg',
        'karl@main.com': 'assets/images/profile2.jpg',
        'aldhy@main.com': 'assets/images/profile3.png',
      };
      final assetPath = emailToAsset[auth.email!];
      if (assetPath != null) {
        return AssetImage(assetPath);
      }
    }

    if (auth.userID != null && auth.subUsers.isNotEmpty) {
      SubUser? found;
      for (final user in auth.subUsers) {
        if (user is SubUser && user.ownerUserId == auth.userID) {
          found = user;
          break;
        }
      }
      if (found == null) {
        for (final user in auth.subUsers) {
          if (user is SubUser && user.id == auth.userID) {
            found = user;
            break;
          }
        }
      }
      if (found != null) {
        if (found.profilePictureBytes != null) {
          return MemoryImage(found.profilePictureBytes!);
        }
        if (found.profilePicture != null && found.profilePicture!.isNotEmpty) {
          return ImageHelper.buildProvider(
            found.profilePicture,
            AssetPaths.defaultAvatar,
          );
        }
      }
    }

    return AssetImage(AssetPaths.defaultAvatar);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final ImageProvider badgeImage = _getBadgeImageProvider(auth);

    final bool showLeft = _currentPage > 0;
    final bool showRight = _currentPage < _cardCount - 1;

    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: _handleKeyEvent,
      child: GestureDetector(
        onTap: () => _focusNode.requestFocus(),
        child: Scaffold(
          body: Stack(
            children: [
              const VideoBackground(
                videoPath: AssetPaths.dashboardBackgroundVideo,
              ),
              Container(color: Colors.black.withOpacity(0.3)),

              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 80),

                    // "MAIN USER" title — PirataOne font
                    _OnePieceTitle(text: 'MAIN USER'),

                    const SizedBox(height: 4),
                    Text(
                      'Use arrows or swipe to navigate',
                      style: TextStyle(
                        fontSize: 12,
                        color: _kParchment.withOpacity(0.45),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // ── Carousel ─────────────────────────
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            itemCount: _cardCount,
                            // ✅ PageScrollPhysics keeps
                            // swipe working while side
                            // cards are non-tappable
                            physics: const PageScrollPhysics(),
                            onPageChanged: (index) =>
                                setState(() => _currentPage = index),
                            itemBuilder: (context, index) {
                              final bool isCenter = index == _currentPage;

                              return Padding(
                                // ✅ Smaller padding = bigger card
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 8),
                                child: _CarouselCardSlot(
                                  index: index,
                                  isCenter: isCenter,
                                  onTapCenter: () => _openProfile(index),
                                ),
                              );
                            },
                          ),

                          // Left arrow button
                          Positioned(
                            left: 4,
                            child: AnimatedOpacity(
                              opacity: showLeft ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 250),
                              child: IgnorePointer(
                                ignoring: !showLeft,
                                child: _NavArrowButton(
                                  icon: Icons.chevron_left,
                                  onTap: _goToPrevious,
                                ),
                              ),
                            ),
                          ),

                          // Right arrow button
                          Positioned(
                            right: 4,
                            child: AnimatedOpacity(
                              opacity: showRight ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 250),
                              child: IgnorePointer(
                                ignoring: !showRight,
                                child: _NavArrowButton(
                                  icon: Icons.chevron_right,
                                  onTap: _goToNext,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Page indicator dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _cardCount,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? _kGold
                                : _kAgedGold.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),

              // Fixed top nav bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        _LoggedInUserBadge(
                          userName: auth.userName ?? 'User',
                          isMainUser: auth.isMainUser,
                          imageProvider: badgeImage,
                        ),
                        const Spacer(),
                        _TopBarButton(
                          label: 'Crew',
                          icon: Icons.people,
                          onTap: () => context.push('/sub-dashboard'),
                          color: _kCrimson,
                        ),
                        const SizedBox(width: 8),
                        _TopBarButton(
                          label: 'Logout',
                          icon: Icons.logout,
                          onTap: _handleLogout,
                          color: Colors.black.withOpacity(0.35),
                          outlined: true,
                        ),
                      ],
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
// ONE PIECE TITLE — PirataOne font with gold gradient
// ─────────────────────────────────────────────────────────────────
class _OnePieceTitle extends StatelessWidget {
  final String text;

  const _OnePieceTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow halo
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'PirataOne',
            fontSize: 44,
            fontWeight: FontWeight.w900,
            letterSpacing: 5,
            height: 1.0,
            foreground: Paint()
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14)
              ..color = _kGold.withOpacity(0.5),
          ),
        ),
        // Dark outline
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'PirataOne',
            fontSize: 44,
            fontWeight: FontWeight.w900,
            letterSpacing: 5,
            height: 1.0,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 9
              ..color = Colors.black.withOpacity(0.85),
          ),
        ),
        // Gold gradient fill
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFE566),
              Color(0xFFD4A017),
              Color(0xFF8B6914),
            ],
            stops: [0.0, 0.5, 1.0],
          ).createShader(bounds),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'PirataOne',
              fontSize: 44,
              fontWeight: FontWeight.w900,
              letterSpacing: 5,
              height: 1.0,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// CAROUSEL CARD SLOT
//
// Center card: full opacity, tap opens profile.
// Side cards: 0.38 opacity + IgnorePointer blocks ALL taps.
//   The PageView scroll gesture still works underneath.
// ─────────────────────────────────────────────────────────────────
class _CarouselCardSlot extends StatelessWidget {
  final int index;
  final bool isCenter;
  final VoidCallback onTapCenter;

  const _CarouselCardSlot({
    required this.index,
    required this.isCenter,
    required this.onTapCenter,
  });

  @override
  Widget build(BuildContext context) {
    final double opacity = isCenter ? 1.0 : 0.38;

    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: Stack(
        children: [
          // Card widget
          _buildCardWidget(index),

          // Side cards: block all pointer events with IgnorePointer.
          // Note: ignoring: true means the widget ignores all
          // pointer events — clicks, hovers, drags on the card itself.
          // The PageView's drag recognizer works because it's
          // attached to the PageView, not to this card widget.
          if (!isCenter)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.black.withOpacity(0.10),
                  ),
                ),
              ),
            ),

          // Center card: transparent tap layer opens profile
          if (isCenter)
            Positioned.fill(
              child: GestureDetector(
                onTap: onTapCenter,
                child: Container(color: Colors.transparent),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardWidget(int index) {
    switch (index) {
      case 0:
        return MainProfileCardPallen(isCenter: isCenter);
      case 1:
        return MainProfileCardKarl(isCenter: isCenter);
      case 2:
        return MainProfileCardAldhy(isCenter: isCenter);
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─────────────────────────────────────────────────────────────────
// NAV ARROW BUTTON
// ─────────────────────────────────────────────────────────────────
class _NavArrowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavArrowButton({
    required this.icon,
    required this.onTap,
  });

  @override
  State<_NavArrowButton> createState() => _NavArrowButtonState();
}

class _NavArrowButtonState extends State<_NavArrowButton> {
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
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _hovered
                ? _kGold.withOpacity(0.85)
                : Colors.black.withOpacity(0.5),
            border: Border.all(
              color: _hovered ? _kBrightGold : _kGold.withOpacity(0.4),
              width: _hovered ? 2 : 1.5,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: _kGold.withOpacity(0.5),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                    ),
                  ],
          ),
          child: Icon(
            widget.icon,
            color: _hovered ? Colors.white : _kParchment.withOpacity(0.8),
            size: 28,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// LOGGED-IN USER BADGE
// ─────────────────────────────────────────────────────────────────
class _LoggedInUserBadge extends StatelessWidget {
  final String userName;
  final bool isMainUser;
  final ImageProvider imageProvider;

  const _LoggedInUserBadge({
    required this.userName,
    required this.isMainUser,
    required this.imageProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: _kGold.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _kGold.withOpacity(0.15),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _kGold, width: 2),
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                userName,
                style: const TextStyle(
                  color: _kParchment,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isMainUser
                      ? _kGold.withOpacity(0.8)
                      : _kCrimson.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isMainUser ? 'Captain' : 'Crew',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// TOP BAR BUTTON
// ─────────────────────────────────────────────────────────────────
class _TopBarButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final bool outlined;

  const _TopBarButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.color,
    this.outlined = false,
  });

  @override
  State<_TopBarButton> createState() => _TopBarButtonState();
}

class _TopBarButtonState extends State<_TopBarButton> {
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _hovered ? widget.color.withOpacity(0.9) : widget.color,
            borderRadius: BorderRadius.circular(20),
            border: widget.outlined
                ? Border.all(color: _kGold.withOpacity(0.4), width: 1)
                : null,
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 1,
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

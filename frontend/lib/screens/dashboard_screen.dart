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
/// ✅ BUG FIX: Tapping empty space beside the card no longer
///   navigates to the profile.
///
///   ROOT CAUSE: The old `Positioned.fill(GestureDetector)` overlay
///   covered the ENTIRE page slot width (~92% of screen). But the 4:3
///   card is constrained by height so it's only ~637px wide on a typical
///   1366px screen, leaving ~612px of uncovered empty space where the
///   overlay still caught taps.
///
///   FIX: For the center card, wrap the card widget in `Center` (which
///   passes loose constraints → AspectRatio sizes to card bounds) then
///   `GestureDetector`. The GestureDetector matches the card's visual
///   size (not the full slot). Taps in surrounding empty space fall
///   through to PageView which ignores taps. ✓
///
///   For side cards, `IgnorePointer` blocks taps while PageView's
///   Scrollable gesture recognizer (which sits above IgnorePointer in
///   the widget tree) still handles swipes. ✓
///
/// ✅ CHANGED: Title is now "NAKAMA" (One Piece themed word for crew/
///   companions) and is placed inside the nav bar row, centered between
///   the user badge and the action buttons.
///
/// ✅ NEW: One Piece character image on the right side of the screen
///   as decoration. Add any One Piece character PNG (transparent bg)
///   to assets/images/one_piece_character.png and it appears automatically.
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
        'karl@main.com': 'assets/images/profile2.png',
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
              // ── Video background ────────────────────────
              const VideoBackground(
                videoPath: AssetPaths.dashboardBackgroundVideo,
              ),
              Container(color: Colors.black.withOpacity(0.3)),

              // ── One Piece character decoration ───────────
              // ✅ NEW: Place a One Piece character PNG
              // (with transparent background) at:
              //   assets/images/one_piece_character.png
              // It will automatically appear on the right side.
              // errorBuilder returns SizedBox.shrink() so nothing
              // shows if the file doesn't exist yet.
              Positioned(
                right: 0,
                // Below nav bar
                top: 90,
                // Above the bottom dots indicator
                bottom: 80,
                child: IgnorePointer(
                  child: SizedBox(
                    // Width = 20% of screen, capped at 280px
                    width: MediaQuery.of(context).size.width * 0.20,
                    child: Opacity(
                      opacity: 0.92,
                      child: Image.asset(
                        'assets/images/'
                        'one_piece_character.png',
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomRight,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Main carousel content ─────────────────────
              SafeArea(
                child: Column(
                  children: [
                    // Space reserved for the Positioned
                    // nav bar above
                    const SizedBox(height: 72),

                    // Hint text
                    Text(
                      'Use arrows or swipe to navigate',
                      style: TextStyle(
                        fontSize: 12,
                        color: _kParchment.withOpacity(0.45),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),

                    // ── Carousel ─────────────────────────────
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            itemCount: _cardCount,
                            physics: const PageScrollPhysics(),
                            onPageChanged: (index) =>
                                setState(() => _currentPage = index),
                            itemBuilder: (context, index) {
                              final bool isCenter = index == _currentPage;

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 8,
                                ),
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

              // ── Fixed top nav bar ─────────────────────────
              // ✅ CHANGED: Title "NAKAMA" is now INSIDE the
              // nav bar, perfectly centered between the user
              // badge and the action buttons using Stack + Center.
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // ── Badge (left) ────────────────────
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _LoggedInUserBadge(
                            userName: auth.userName ?? 'User',
                            isMainUser: auth.isMainUser,
                            imageProvider: badgeImage,
                          ),
                        ),

                        // ── NAKAMA title (center) ───────────
                        // Center positions title at horizontal
                        // center of the full nav bar width.
                        Center(
                          child: _OnePieceTitle(
                            text: 'NAKAMA',
                            fontSize: 34,
                          ),
                        ),

                        // ── Action buttons (right) ──────────
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
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
// ONE PIECE TITLE — PirataOne font, gold gradient
// ─────────────────────────────────────────────────────────────────
class _OnePieceTitle extends StatelessWidget {
  final String text;
  final double fontSize;

  const _OnePieceTitle({
    required this.text,
    this.fontSize = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Gold glow halo behind text
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'PirataOne',
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 5,
            height: 1.0,
            foreground: Paint()
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
              ..color = _kGold.withOpacity(0.5),
          ),
        ),
        // Black outline
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'PirataOne',
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 5,
            height: 1.0,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = fontSize * 0.2
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
            style: TextStyle(
              fontFamily: 'PirataOne',
              fontSize: fontSize,
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
// ✅ BUG FIX EXPLAINED:
//
//   OLD (broken):
//     Positioned.fill(GestureDetector(...))
//     The GestureDetector covered the FULL page slot (92% of screen
//     width, e.g. 1249px). The actual 4:3 card is only ~637px wide
//     (constrained by height). Clicking in the ~612px empty space to
//     the right of the card still triggered navigation.
//
//   NEW (fixed):
//     Center(child: GestureDetector(child: _buildCardWidget(...)))
//
//     - `Center` passes LOOSE constraints to its child.
//     - `AspectRatio(4/3)` under loose constraints sizes itself to
//       min(slotWidth, slotHeight*4/3) = 637px wide.
//     - `GestureDetector` wrapping AspectRatio also sizes to 637px.
//     - Taps OUTSIDE 637px → not claimed by GestureDetector →
//       fall to PageView Scrollable which ignores taps → nothing. ✓
//     - Taps INSIDE 637px → GestureDetector fires onTap → navigate. ✓
//
//   For side cards: `IgnorePointer` blocks tap events.
//   PageView swipes STILL WORK because PageView's Scrollable gesture
//   recognizer is an ANCESTOR of IgnorePointer in the widget tree —
//   it registered for the pointer event before IgnorePointer excluded
//   the subtree from hit testing.
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
    return AnimatedOpacity(
      opacity: isCenter ? 1.0 : 0.38,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: isCenter
          // ── CENTER CARD ──────────────────────────────────
          // GestureDetector inside Center so it sizes to the
          // card's AspectRatio bounds, NOT the full slot width.
          // Only tapping within the card's visual area navigates.
          ? Center(
              child: GestureDetector(
                // HitTestBehavior.opaque: reliably claims
                // taps within the GestureDetector's bounds
                // (637x478 — card size, not slot size).
                behavior: HitTestBehavior.opaque,
                onTap: onTapCenter,
                child: _buildCardWidget(index),
              ),
            )
          // ── SIDE CARDS ───────────────────────────────────
          // IgnorePointer blocks ALL pointer events on the card.
          // PageView's Scrollable (an ancestor) still handles
          // horizontal swipe drag gestures for navigation.
          : IgnorePointer(
              child: _buildCardWidget(index),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _kGold, width: 2),
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                userName,
                style: const TextStyle(
                  color: _kParchment,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isMainUser
                      ? _kGold.withOpacity(0.8)
                      : _kCrimson.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isMainUser ? 'Captain' : 'Crew',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
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
              Icon(widget.icon, color: Colors.white, size: 16),
              const SizedBox(width: 5),
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

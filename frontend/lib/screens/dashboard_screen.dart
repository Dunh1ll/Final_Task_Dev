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
// ✅ FIXED: Removed unused 'dart:typed_data' import

/// DashboardScreen — main carousel screen after login.
///
/// ✅ FIXED: Removed unused 'dart:typed_data' import.
/// ✅ FIXED: Removed unused 'availableHeight' variable —
///   the carousel now uses Expanded which fills remaining space
///   automatically, so a manual height calculation is not needed.
/// ✅ FIXED: Badge photo updates immediately after profile edit.
/// ✅ NEW: Left/right arrow navigation buttons.
///   Left arrow hidden on first card, right arrow hidden on last.
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
      viewportFraction: 0.55,
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

  /// Get the correct ImageProvider for the top-left badge.
  ///
  /// Priority:
  ///   1. Main users → static asset from email map (never changes)
  ///   2. Sub users → search auth.subUsers by ownerUserId
  ///      a. Photo bytes found → MemoryImage (updates instantly)
  ///      b. Only URL found → ImageHelper.buildProvider
  ///   3. Fallback → default avatar asset
  ImageProvider _getBadgeImageProvider(AuthProvider auth) {
    // ── Main users: always use static asset ────────────────────
    if (auth.isMainUser && auth.email != null) {
      const Map<String, String> emailToAsset = {
        'pallen@main.com': 'assets/images/profile1.jpg',
        'karl@main.com': 'assets/images/profile2.jpg',
        'aldhy@main.com': 'assets/images/profile3.png',
      };
      final assetPath = emailToAsset[auth.email!];
      if (assetPath != null) return AssetImage(assetPath);
    }

    // ── Sub users: search by ownerUserId then by id ────────────
    if (auth.userID != null && auth.subUsers.isNotEmpty) {
      SubUser? found;

      // Primary: ownerUserId == auth.userID
      for (final user in auth.subUsers) {
        if (user is SubUser && user.ownerUserId == auth.userID) {
          found = user;
          break;
        }
      }

      // Secondary fallback: profile.id == auth.userID
      if (found == null) {
        for (final user in auth.subUsers) {
          if (user is SubUser && user.id == auth.userID) {
            found = user;
            break;
          }
        }
      }

      if (found != null) {
        // Bytes first — shows updated photo instantly after edit
        if (found.profilePictureBytes != null) {
          return MemoryImage(found.profilePictureBytes!);
        }
        // Fall back to URL / asset path
        if (found.profilePicture != null && found.profilePicture!.isNotEmpty) {
          return ImageHelper.buildProvider(
            found.profilePicture,
            AssetPaths.defaultAvatar,
          );
        }
      }
    }

    // ── Default ────────────────────────────────────────────────
    return AssetImage(AssetPaths.defaultAvatar);
  }

  @override
  Widget build(BuildContext context) {
    // watch() ensures full rebuild when auth.subUsers changes
    final auth = context.watch<AuthProvider>();
    final ImageProvider badgeImage = _getBadgeImageProvider(auth);

    // Arrow visibility
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
              // Background video
              const VideoBackground(
                videoPath: AssetPaths.dashboardBackgroundVideo,
              ),
              Container(color: Colors.black.withOpacity(0.3)),

              // Main content — fills all available space
              // ✅ FIXED: Removed 'availableHeight' variable.
              // Column + Expanded fills space correctly without
              // needing to manually calculate heights.
              SafeArea(
                child: Column(
                  children: [
                    // Top bar spacer
                    const SizedBox(height: 80),

                    // Title
                    const Text(
                      'Main User',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap arrows or swipe to navigate',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // Carousel with arrows — fills remaining space
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // PageView carousel
                          PageView.builder(
                            controller: _pageController,
                            itemCount: _cardCount,
                            physics: const BouncingScrollPhysics(),
                            onPageChanged: (index) {
                              setState(() => _currentPage = index);
                            },
                            itemBuilder: (context, index) {
                              final isCenter = index == _currentPage;
                              final scale = isCenter ? 1.0 : 0.88;

                              return GestureDetector(
                                onTap: () => _focusNode.requestFocus(),
                                child: AnimatedScale(
                                  scale: scale,
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOut,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: _buildCard(index, isCenter),
                                  ),
                                ),
                              );
                            },
                          ),

                          // ✅ LEFT ARROW — hidden on first card
                          Positioned(
                            left: 12,
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

                          // ✅ RIGHT ARROW — hidden on last card
                          Positioned(
                            right: 12,
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
                                ? AppColors.primaryBlue
                                : Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),

              // Fixed top navigation bar (overlays content)
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
                        // Badge with dynamic image provider
                        _LoggedInUserBadge(
                          userName: auth.userName ?? 'User',
                          isMainUser: auth.isMainUser,
                          imageProvider: badgeImage,
                        ),

                        const Spacer(),

                        _TopBarButton(
                          label: 'Other Profiles',
                          icon: Icons.people,
                          onTap: () => context.push('/sub-dashboard'),
                          color: AppColors.darkGreen,
                        ),
                        const SizedBox(width: 8),
                        _TopBarButton(
                          label: 'Logout',
                          icon: Icons.logout,
                          onTap: _handleLogout,
                          color: Colors.white.withOpacity(0.15),
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

  Widget _buildCard(int index, bool isCenter) {
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
//
// ✅ NEW: Circular arrow button for carousel navigation.
// Appears/disappears via AnimatedOpacity in the parent.
// Green glow on hover, consistent with the app theme.
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
                ? AppColors.primaryBlue.withOpacity(0.85)
                : Colors.black.withOpacity(0.45),
            border: Border.all(
              color: _hovered
                  ? AppColors.primaryBlue
                  : Colors.white.withOpacity(0.2),
              width: _hovered ? 2 : 1,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.4),
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
            color: _hovered ? Colors.white : Colors.white.withOpacity(0.8),
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
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: isMainUser
              ? AppColors.primaryBlue.withOpacity(0.5)
              : Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isMainUser
                ? AppColors.primaryBlue.withOpacity(0.15)
                : Colors.black.withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Profile picture circle
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isMainUser
                    ? AppColors.primaryBlue
                    : Colors.white.withOpacity(0.4),
                width: 2,
              ),
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
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isMainUser
                      ? AppColors.primaryBlue.withOpacity(0.8)
                      : AppColors.darkGreen.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isMainUser ? 'Main User' : 'Sub User',
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
                ? Border.all(color: Colors.white.withOpacity(0.3), width: 1)
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../utils/constants.dart';
import '../utils/image_helper.dart';
import '../widgets/main_profile_card_pallen.dart';
import '../widgets/main_profile_card_karl.dart';
import '../widgets/main_profile_card_aldhy.dart';
import '../widgets/video_background.dart';

/// DashboardScreen — main landing screen for all users after login.
///
/// ✅ CHANGED: Each main profile card is now its own widget from
/// a separate file (main_profile_card_pallen/karl/aldhy.dart).
/// This allows each card to be independently designed and updated.
///
/// The 9:16 aspect ratio and carousel scale are preserved.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final PageController _pageController;
  final FocusNode _focusNode = FocusNode();
  int _currentPage = 0;

  /// Total number of main profile cards
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
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
          _currentPage < _cardCount - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  void _handleLogout() {
    context.read<AuthProvider>().logout();
    if (mounted) context.go('/');
  }

  /// Map email → profile image for the logged-in user badge
  String? _getLoggedInUserProfilePic(AuthProvider auth) {
    if (!auth.isMainUser || auth.email == null) return null;
    const Map<String, String> emailToImage = {
      'pallen@main.com': 'assets/images/profile1.jpg',
      'karl@main.com': 'assets/images/profile2.png',
      'aldhy@main.com': 'assets/images/profile3.png',
    };
    return emailToImage[auth.email!];
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final String? loggedInProfilePic = _getLoggedInUserProfilePic(auth);

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

              // Carousel + title
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const topBarHeight = 80.0;
                    final availableHeight =
                        constraints.maxHeight - topBarHeight - 20;

                    return Column(
                      children: [
                        SizedBox(height: topBarHeight + 12),

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
                          '← → arrow keys or swipe to navigate',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),

                        // ✅ Each card is now its own separate widget
                        // imported from individual files
                        SizedBox(
                          height: availableHeight * 0.86,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: _cardCount,
                            physics: const BouncingScrollPhysics(),
                            onPageChanged: (index) {
                              setState(() => _currentPage = index);
                            },
                            itemBuilder: (context, index) {
                              final isCenter = index == _currentPage;
                              // Scale: center card full size, sides smaller
                              final scale = isCenter ? 1.0 : 0.88;

                              return GestureDetector(
                                onTap: () {
                                  _focusNode.requestFocus();
                                },
                                child: AnimatedScale(
                                  scale: scale,
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOut,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    // ✅ Each index renders its own card widget
                                    // from a separate dedicated file
                                    child: _buildCard(index, isCenter),
                                  ),
                                ),
                              );
                            },
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
                      ],
                    );
                  },
                ),
              ),

              // Top navigation bar
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
                        // Logged-in user badge with profile picture
                        _LoggedInUserBadge(
                          userName: auth.userName ?? 'User',
                          isMainUser: auth.isMainUser,
                          profileImagePath: loggedInProfilePic,
                        ),

                        const Spacer(),

                        // Other Profiles button
                        _TopBarButton(
                          label: 'Other Profiles',
                          icon: Icons.people,
                          onTap: () => context.push('/sub-dashboard'),
                          color: AppColors.darkGreen,
                        ),

                        const SizedBox(width: 8),

                        // Logout button
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

  /// Build the correct card widget based on carousel index.
  /// Each returns a separate dedicated widget from its own file.
  Widget _buildCard(int index, bool isCenter) {
    switch (index) {
      case 0:
        // Pallen's card — from main_profile_card_pallen.dart
        return MainProfileCardPallen(isCenter: isCenter);
      case 1:
        // Karl's card — from main_profile_card_karl.dart
        return MainProfileCardKarl(isCenter: isCenter);
      case 2:
        // Aldhy's card — from main_profile_card_aldhy.dart
        return MainProfileCardAldhy(isCenter: isCenter);
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─────────────────────────────────────────────────────────────────
// LOGGED-IN USER BADGE
// Shows profile picture + name + role of the logged-in user
// ─────────────────────────────────────────────────────────────────

class _LoggedInUserBadge extends StatelessWidget {
  final String userName;
  final bool isMainUser;
  final String? profileImagePath;

  const _LoggedInUserBadge({
    required this.userName,
    required this.isMainUser,
    this.profileImagePath,
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
          // Profile picture
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
                image: ImageHelper.buildProvider(
                  profileImagePath,
                  AssetPaths.defaultAvatar,
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Name + role
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

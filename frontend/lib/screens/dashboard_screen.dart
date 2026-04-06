import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/pallen_prince_dunhill.dart';
import '../models/albaniel_karl_angelo.dart';
import '../models/fajardo_aldhy.dart';
import '../models/user_base.dart';
import '../utils/constants.dart';
import '../utils/image_helper.dart';
import '../widgets/video_background.dart';

/// DashboardScreen — main landing screen for all users after login.
///
/// Shows the 3 hardcoded main profiles in a 9:16 portrait carousel.
/// Navigation: left/right arrow keys + swipe gestures.
///
/// ✅ CHANGED: Top-left user badge is bigger and shows the actual
/// profile picture of the logged-in user.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final PageController _pageController;

  /// Named FocusNode — required to retain keyboard focus after taps
  final FocusNode _focusNode = FocusNode();

  int _currentPage = 0;

  /// The 3 hardcoded main profiles from local Dart model files
  late List<UserBase> _mainProfiles;

  @override
  void initState() {
    super.initState();

    // viewportFraction < 1.0 shows edges of adjacent cards
    _pageController = PageController(
      viewportFraction: 0.55,
      initialPage: 0,
    );
    _pageController.addListener(_onPageChanged);

    _mainProfiles = [
      PallenPrinceDunhill(),
      AlbanielKarlAngelo(),
      FajardoAldhy(),
    ];

    // Request keyboard focus after build completes
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

  /// Handle left/right arrow key navigation
  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft &&
          _currentPage > 0) {
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
          _currentPage < _mainProfiles.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  /// Logout and redirect to home page
  void _handleLogout() {
    context.read<AuthProvider>().logout();
    if (mounted) context.go('/');
  }

  /// Get the profile picture asset path for the logged-in user.
  ///
  /// For main users: maps their email to the correct profile image.
  ///   pallen@main.com → assets/images/profile1.jpg
  ///   karl@main.com   → assets/images/profile2.jpg
  ///   aldhy@main.com  → assets/images/profile3.png
  ///
  /// For sub users: returns null (will fall back to default avatar)
  String? _getLoggedInUserProfilePic(AuthProvider auth) {
    if (!auth.isMainUser || auth.email == null) return null;

    // Map main user emails to their profile image assets
    const Map<String, String> emailToImage = {
      'pallen@main.com': 'assets/images/profile1.jpg',
      'karl@main.com': 'assets/images/profile2.jpg',
      'aldhy@main.com': 'assets/images/profile3.png',
    };

    return emailToImage[auth.email!];
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Get the profile picture for the logged-in user
    final String? loggedInProfilePic = _getLoggedInUserProfilePic(auth);

    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: _handleKeyEvent,
      child: GestureDetector(
        // Re-request focus when user taps anywhere
        onTap: () => _focusNode.requestFocus(),
        child: Scaffold(
          body: Stack(
            children: [
              // ── Background video ─────────────────────────────────
              const VideoBackground(
                videoPath: AssetPaths.dashboardBackgroundVideo,
              ),
              Container(color: Colors.black.withOpacity(0.3)),

              // ── Carousel + title ─────────────────────────────────
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const topBarHeight = 80.0;
                    final availableHeight =
                        constraints.maxHeight - topBarHeight - 20;

                    return Column(
                      children: [
                        SizedBox(height: topBarHeight + 12),

                        // Title — "Main User" at top-center
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

                        // 9:16 Portrait Carousel
                        SizedBox(
                          height: availableHeight * 0.86,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: _mainProfiles.length,
                            physics: const BouncingScrollPhysics(),
                            onPageChanged: (index) {
                              setState(() => _currentPage = index);
                            },
                            itemBuilder: (context, index) {
                              final profile = _mainProfiles[index];
                              final isCenter = index == _currentPage;
                              final scale = isCenter ? 1.0 : 0.88;

                              return GestureDetector(
                                onTap: () {
                                  _focusNode.requestFocus();
                                  context.push('/profile/${profile.id}');
                                },
                                child: AnimatedScale(
                                  scale: scale,
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOut,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    // No edit button on main profiles
                                    child: _MainProfileCard(
                                      profile: profile,
                                    ),
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
                            _mainProfiles.length,
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

              // ── Fixed top navigation bar ─────────────────────────
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
                        // ── ✅ CHANGED: Bigger user badge with profile pic ──
                        // Shows the actual profile picture of the logged-in user
                        // alongside their name and role badge
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
}

// ─────────────────────────────────────────────────────────────────
// LOGGED-IN USER BADGE
//
// ✅ NEW: Bigger badge shown at top-left of the dashboard.
// Shows the actual profile picture of the logged-in user,
// their display name, and a colored role badge (Main/Sub).
//
// For main users: shows their actual profile photo from assets.
// For sub users: shows the default avatar as fallback.
// ─────────────────────────────────────────────────────────────────
class _LoggedInUserBadge extends StatelessWidget {
  final String userName;
  final bool isMainUser;

  /// Asset path to the logged-in user's profile picture.
  /// For main users this maps to profile1/2/3.jpg.
  /// null for sub users — falls back to default avatar.
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
        // Semi-transparent dark background
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          // Green border for main users, subtle white for sub users
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
          // ✅ Profile picture of the logged-in user
          // Bigger than before (was just an icon, now 44x44 image)
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
              boxShadow: [
                BoxShadow(
                  color: isMainUser
                      ? AppColors.primaryBlue.withOpacity(0.3)
                      : Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
              image: DecorationImage(
                // Use the actual profile picture if available
                // Falls back to default avatar for sub users
                image: ImageHelper.buildProvider(
                  profileImagePath,
                  AssetPaths.defaultAvatar,
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Name + role badge column
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Display name — slightly bigger than before
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

              // Role badge
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
// TOP BAR BUTTON — reusable nav button
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
                ? Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  )
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

// ─────────────────────────────────────────────────────────────────
// MAIN PROFILE CARD — 9:16 Portrait
//
// No edit button — main profiles are hardcoded in Dart files
// and cannot be edited via the UI.
// ─────────────────────────────────────────────────────────────────

class _MainProfileCard extends StatefulWidget {
  final UserBase profile;

  const _MainProfileCard({required this.profile});

  @override
  State<_MainProfileCard> createState() => _MainProfileCardState();
}

class _MainProfileCardState extends State<_MainProfileCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: AspectRatio(
          aspectRatio: 9 / 16,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.dirtyWhite,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _isHovered
                        ? AppColors.darkGreen.withOpacity(0.6)
                        : Colors.black.withOpacity(0.3),
                    blurRadius: _isHovered ? 30 : 20,
                    spreadRadius: _isHovered ? 6 : 3,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: _isHovered
                    ? Border.all(
                        color: AppColors.darkGreen.withOpacity(0.7),
                        width: 2,
                      )
                    : null,
              ),
              child: Stack(
                children: [
                  Column(
                    children: [
                      // Cover photo
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.24,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: ImageHelper.buildProvider(
                                widget.profile.coverPhoto,
                                AssetPaths.defaultCover,
                                bytes: widget.profile.coverPhotoBytes,
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.2),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 50),

                      // Name
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          widget.profile.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGray,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Year level badge
                      if (widget.profile.yearLevel != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.profile.yearLevel!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      const SizedBox(height: 6),

                      // Bio
                      if (widget.profile.bio != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            widget.profile.bio!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.lightGray,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                      const Spacer(),

                      // Info chips
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            if (widget.profile.age != null)
                              _chip('${widget.profile.age} yrs'),
                            if (widget.profile.hometown != null)
                              _chip(widget.profile.hometown!),
                            if (widget.profile.gender != null)
                              _chip(widget.profile.gender!),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Profile picture overlapping cover
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.24 - 44,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                          image: DecorationImage(
                            image: ImageHelper.buildProvider(
                              widget.profile.profilePicture,
                              AssetPaths.defaultAvatar,
                              bytes: widget.profile.profilePictureBytes,
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // No edit button — main profiles are hardcoded
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

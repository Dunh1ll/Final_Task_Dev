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

/// DashboardScreen — the main landing screen for all users after login.
///
/// Shows the 3 hardcoded main profiles in a 9:16 portrait carousel.
/// Navigation: left/right arrow keys + swipe gestures.
/// No vertical scroll on this screen — that is on SubDashboardScreen.
///
/// Design changes from requirements:
///   - Title changed from "Discover People" to "Main User"
///   - Title moved to top-center
///   - Cards use 9:16 aspect ratio (portrait, like a phone screen)
///   - Cards centered with adjacent cards visible on sides
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  /// Controls which card is shown and handles programmatic page changes
  late final PageController _pageController;

  /// Named FocusNode — required to properly capture keyboard events.
  /// Without a named FocusNode, keyboard events are lost after any tap.
  final FocusNode _focusNode = FocusNode();

  /// Index of the currently centered/active card
  int _currentPage = 0;

  /// The 3 hardcoded main profiles — loaded from local Dart model files
  late List<UserBase> _mainProfiles;

  @override
  void initState() {
    super.initState();

    // viewportFraction < 1.0 shows the edges of adjacent cards
    // This creates the "peek" effect showing there are more cards
    _pageController = PageController(
      viewportFraction: 0.55,
      initialPage: 0,
    );
    _pageController.addListener(_onPageChanged);

    // Initialize the 3 hardcoded main profiles
    _mainProfiles = [
      PallenPrinceDunhill(),
      AlbanielKarlAngelo(),
      FajardoAldhy(),
    ];

    // Request keyboard focus immediately after the widget tree is built
    // Without this, arrow keys don't work until the user clicks somewhere
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  /// Update the current page index when the carousel scrolls
  void _onPageChanged() {
    if (_pageController.page != null) {
      setState(() => _currentPage = _pageController.page!.round());
    }
  }

  @override
  void dispose() {
    // Always clean up controllers and focus nodes to prevent memory leaks
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Handle keyboard navigation — left and right arrow keys only.
  ///
  /// FIX: The previous implementation used an anonymous FocusNode
  /// which lost focus when the user clicked on cards or buttons.
  /// Now we use a named FocusNode and re-request focus on tap.
  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft &&
          _currentPage > 0) {
        // Navigate to previous card
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
          _currentPage < _mainProfiles.length - 1) {
        // Navigate to next card
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  void _handleLogout() {
    context.read<AuthProvider>().logout();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    // Watch so UI rebuilds when auth state changes (e.g. after login)
    final auth = context.watch<AuthProvider>();

    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true, // Capture keyboard events from the start
      onKey: _handleKeyEvent,
      child: GestureDetector(
        // ✅ FIX: Re-request keyboard focus whenever user taps anywhere
        // Without this, clicking a card or button steals focus
        // and arrow keys stop working until the user presses Tab
        onTap: () => _focusNode.requestFocus(),
        child: Scaffold(
          body: Stack(
            children: [
              // ── Layer 1: Video background ──────────────────────────
              const VideoBackground(
                videoPath: AssetPaths.dashboardBackgroundVideo,
              ),

              // ── Layer 2: Dark overlay ──────────────────────────────
              // Semi-transparent black improves text readability
              Container(color: Colors.black.withOpacity(0.3)),

              // ── Layer 3: Main content ──────────────────────────────
              // LayoutBuilder gives us exact available height
              // so we can calculate the carousel height precisely
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Reserve space for the top navigation bar
                    const topBarHeight = 72.0;
                    final availableHeight =
                        constraints.maxHeight - topBarHeight - 20;

                    return Column(
                      children: [
                        // Space below the top bar
                        SizedBox(height: topBarHeight + 12),

                        // ── Title — "Main User" at top-center ─────────
                        // Design change: was "Discover People", now "Main User"
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

                        // Navigation hint
                        Text(
                          '← → arrow keys or swipe to navigate',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),

                        // ── 9:16 Portrait Carousel ─────────────────────
                        // The card height drives the layout via AspectRatio
                        SizedBox(
                          height: availableHeight * 0.86,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: _mainProfiles.length,
                            // BouncingScrollPhysics gives swipe gesture support
                            physics: const BouncingScrollPhysics(),
                            onPageChanged: (index) {
                              setState(() => _currentPage = index);
                            },
                            itemBuilder: (context, index) {
                              final profile = _mainProfiles[index];
                              final isCenter = index == _currentPage;

                              // ── Edit button permission ───────────────
                              // Main users: only show edit on their OWN profile
                              // Sub users: never show edit on main profiles
                              bool showEdit = false;
                              if (auth.isMainUser) {
                                // ownProfileId maps email → profile_1/2/3
                                showEdit = auth.ownProfileId == profile.id;
                              }

                              // Center card is full size; side cards are smaller
                              final scale = isCenter ? 1.0 : 0.88;

                              return GestureDetector(
                                onTap: () {
                                  // Re-request focus so arrow keys work after tap
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
                                    child: _MainProfileCard(
                                      profile: profile,
                                      showEdit: showEdit,
                                      onEdit: showEdit
                                          ? () {
                                              _focusNode.requestFocus();
                                              context.push(
                                                  '/profile/${profile.id}');
                                            }
                                          : null,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 8),

                        // ── Page indicator dots ────────────────────────
                        // Active dot is wider (24px) to show current position
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

              // ── Layer 4: Top navigation bar ────────────────────────
              // Fixed at top, overlays everything below
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        // ── Logged-in user info badge ──────────────────
                        // Shows name and role (Main/Sub) with color coding
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.person,
                                  color: Colors.white70, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                auth.userName ?? 'User',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 6),
                              // Blue badge for Main, green for Sub
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: auth.isMainUser
                                      ? AppColors.primaryBlue
                                      : AppColors.darkGreen,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  auth.isMainUser ? 'Main' : 'Sub',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // ── Other Profiles button ──────────────────────
                        // Navigates to sub dashboard
                        ElevatedButton.icon(
                          onPressed: () => context.push('/sub-dashboard'),
                          icon: const Icon(Icons.people,
                              color: Colors.white, size: 18),
                          label: const Text(
                            'Other Profiles',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColors.darkGreen.withOpacity(0.8),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            elevation: 4,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // ── Logout button ──────────────────────────────
                        ElevatedButton.icon(
                          onPressed: _handleLogout,
                          icon: const Icon(Icons.logout,
                              color: Colors.white, size: 18),
                          label: const Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.15),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            elevation: 2,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
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
// MAIN PROFILE CARD — 9:16 Portrait Card
//
// Each card uses AspectRatio(9/16) to maintain portrait proportions
// regardless of screen size. This gives it a "smartphone screen" look
// which works well for profile cards.
//
// Structure from top to bottom:
//   1. Cover photo (top ~45% of card)
//   2. Profile picture (circular, overlapping cover/content boundary)
//   3. Name, year level badge, bio (middle section)
//   4. Info chips — age, hometown, gender (bottom)
// ─────────────────────────────────────────────────────────────────

class _MainProfileCard extends StatefulWidget {
  final UserBase profile;
  final bool showEdit;
  final VoidCallback? onEdit;

  const _MainProfileCard({
    required this.profile,
    required this.showEdit,
    this.onEdit,
  });

  @override
  State<_MainProfileCard> createState() => _MainProfileCardState();
}

class _MainProfileCardState extends State<_MainProfileCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      // Track hover state for shadow/border glow effect
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: AspectRatio(
          // ✅ 9:16 aspect ratio — portrait orientation like a phone
          aspectRatio: 9 / 16,
          child: ClipRRect(
            // Clip content to rounded corners (prevents overflow)
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.dirtyWhite,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    // Green glow on hover, regular shadow otherwise
                    color: _isHovered
                        ? AppColors.darkGreen.withOpacity(0.6)
                        : Colors.black.withOpacity(0.3),
                    blurRadius: _isHovered ? 30 : 20,
                    spreadRadius: _isHovered ? 6 : 3,
                    offset: const Offset(0, 8),
                  ),
                ],
                // Green border appears on hover
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
                      // ── Cover photo ──────────────────────────────────
                      // Takes up the top portion of the card
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.24,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              // ImageHelper handles base64, network, asset
                              image: ImageHelper.buildProvider(
                                widget.profile.coverPhoto,
                                AssetPaths.defaultCover,
                                bytes: widget.profile.coverPhotoBytes,
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            // Gradient fade at bottom for smooth transition
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

                      // ── Gap for profile picture overlap ──────────────
                      const SizedBox(height: 50),

                      // ── Name ─────────────────────────────────────────
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

                      // ── Year level badge ──────────────────────────────
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

                      // ── Bio ───────────────────────────────────────────
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

                      // ── Info chips ────────────────────────────────────
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

                  // ── Profile picture — overlaps cover/content border ──
                  // Positioned to overlap the bottom of the cover photo
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
                            // ImageHelper handles base64, network, asset
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

                  // ── Edit button — top right corner ────────────────────
                  // Only visible when showEdit is true (own main profile)
                  if (widget.showEdit)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: widget.onEdit,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ),
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

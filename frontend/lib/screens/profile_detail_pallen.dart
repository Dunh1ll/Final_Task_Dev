// lib/screens/profile_detail_pallen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../utils/constants.dart';
import '../utils/image_helper.dart';

/// ProfileDetailPallen — Modern, interactive One Piece "Wanted Poster" profile.
/// All profile data unchanged; pure UI/UX enhancement.
class ProfileDetailPallen extends StatefulWidget {
  const ProfileDetailPallen({super.key});

  @override
  State<ProfileDetailPallen> createState() => _ProfileDetailPallenState();
}

class _ProfileDetailPallenState extends State<ProfileDetailPallen>
    with TickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _statsController;
  late final AnimationController _fadeController;

  // Parallax & animation values
  double _coverOffset = 0.0;
  double _profileScale = 1.0;
  double _headerOpacity = 0.0;

  // Animated counters
  final ValueNotifier<int> _projectCount = ValueNotifier(0);
  final ValueNotifier<int> _friendCount = ValueNotifier(0);
  final ValueNotifier<int> _coffeeCount = ValueNotifier(0);

  // ── Pallen's profile data (unchanged) ─────────────────────────
  static const String _name = 'Pallen, Prince Dunhill';
  static const String _bio =
      'Computer Science major | Photography enthusiast | Coffee lover ☕';
  static const String _yearLevel = '4th year';
  static const String _age = '22';
  static const String _gender = 'Male';
  static const String _hometown = 'Brgy. Sta. Rosa, Alaminos, Laguna';
  static const String _relationship = 'Single';
  static const String _education = 'B.S. Computer Engineering';
  static const String _work = 'FDSAP Intern';
  static const String _email = 'pallen@main.com';
  static const String _phone = '+63 950 464 7074';
  static const String _profilePicture = 'assets/images/profile1.jpg';
  static const String _coverPhoto = 'assets/images/default_cover.jpg';
  static const List<String> _interests = [
    'Gaming',
    'Watching',
    'Coding',
    'Cooking',
    'Sleeping',
  ];

  // Decorative One Piece elements
  static const String _bounty = '฿ 1,500,000';
  static const String _crew = 'Straw Hat Devs';
  static const int _targetProjects = 12;
  static const int _targetFriends = 48;
  static const int _targetCoffee = 342;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);

    _statsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Animate counters after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
      _animateCounters();
    });
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    setState(() {
      // Parallax effect: cover moves slower
      _coverOffset = offset * 0.5;
      // Profile picture scales down as you scroll
      _profileScale = math.max(0.6, 1.0 - (offset / 400));
      // Header fade in when scrolled past 100
      _headerOpacity = (offset / 150).clamp(0.0, 1.0);
    });
  }

  void _animateCounters() {
    _statsController.forward(from: 0.0);
    _statsController.addListener(() {
      final progress = _statsController.value;
      _projectCount.value = (_targetProjects * progress).round();
      _friendCount.value = (_targetFriends * progress).round();
      _coffeeCount.value = (_targetCoffee * progress).round();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _statsController.dispose();
    _fadeController.dispose();
    _projectCount.dispose();
    _friendCount.dispose();
    _coffeeCount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // Main scrollable content
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // ── Collapsible App Bar with Parallax ─────────────
                SliverAppBar(
                  expandedHeight: 320,
                  pinned: true,
                  stretch: true,
                  elevation: 0,
                  backgroundColor: AppColors.darkBackground,
                  leading: _buildBackButton(),
                  actions: [
                    _buildShareButton(),
                    const SizedBox(width: 8),
                  ],
                  flexibleSpace: LayoutBuilder(
                    builder: (context, constraints) {
                      final top = constraints.biggest.height;
                      final expandedHeight =
                          MediaQuery.of(context).padding.top + kToolbarHeight;
                      final t =
                          ((top - expandedHeight) / (320 - expandedHeight))
                              .clamp(0.0, 1.0);

                      return FlexibleSpaceBar(
                        centerTitle: false,
                        titlePadding: EdgeInsets.only(
                          left: 72,
                          bottom: 16,
                          right: 16,
                        ),
                        title: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _headerOpacity,
                          child: _buildCollapsedTitle(),
                        ),
                        background: _buildParallaxCover(t),
                      );
                    },
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(70),
                    child: Container(
                      height: 70,
                      color: AppColors.darkBackground,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: 24,
                            bottom: 12,
                            child: _buildAnimatedProfilePicture(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Main Content ──────────────────────────────────
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeController,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Bio & Crew card with glass effect
                          _buildGlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.anchor,
                                      color: AppColors.primaryGold,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'CREW: $_crew',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryGold,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const Spacer(),
                                    // Bounty badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.primaryGold,
                                            AppColors.agedGold,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primaryGold
                                                .withOpacity(0.5),
                                            blurRadius: 12,
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.monetization_on,
                                            size: 16,
                                            color: Colors.black87,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _bounty,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _bio,
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                    color: isDark
                                        ? AppColors.lightGray
                                        : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Interactive stats counters
                          _buildStatsSection(),

                          const SizedBox(height: 24),

                          // Quick info grid with tilt effect
                          _buildInfoGrid(),

                          const SizedBox(height: 24),

                          // Detailed info with expandable sections
                          _buildExpandableDetails(),

                          const SizedBox(height: 24),

                          // Interactive interests with animation
                          _buildAnimatedInterests(),

                          const SizedBox(height: 32),

                          // Wanted poster footer
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  width: 60,
                                  height: 2,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        AppColors.agedGold,
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'WANTED — DEAD OR ALIVE',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 6,
                                    color: AppColors.agedGold.withOpacity(0.7),
                                  ),
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

            // Floating Action Buttons
            Positioned(
              bottom: 24,
              right: 20,
              child: Column(
                children: [
                  _buildFloatingActionButton(
                    icon: Icons.message,
                    label: 'Message',
                    onPressed: () {
                      // Show snackbar as interaction demo
                      _showSnackBar('Opening chat with $_name...');
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildFloatingActionButton(
                    icon: Icons.add_a_photo,
                    label: 'Photo',
                    onPressed: () {
                      _showSnackBar('Camera feature coming soon');
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildFloatingActionButton(
                    icon: Icons.share,
                    label: 'Share',
                    onPressed: () {
                      _showSnackBar('Share this wanted poster');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // Helper Widgets (Modern & Interactive)
  // ───────────────────────────────────────────────────────────────

  Widget _buildBackButton() {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primaryGold.withOpacity(0.3),
          ),
        ),
        child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
      ),
      onPressed: () => context.pop(),
    );
  }

  Widget _buildShareButton() {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primaryGold.withOpacity(0.3),
          ),
        ),
        child: Icon(Icons.share, color: AppColors.primaryGold, size: 20),
      ),
      onPressed: () => _showSnackBar('Share this wanted poster'),
    );
  }

  Widget _buildCollapsedTitle() {
    return Row(
      children: [
        Text(
          _name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primaryGold.withOpacity(0.9),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            _bounty,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParallaxCover(double t) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Parallax cover image
        Transform.translate(
          offset: Offset(0, _coverOffset),
          child: Transform.scale(
            scale: 1.0 + (t * 0.1), // subtle zoom on collapse
            child: Image(
              image: ImageHelper.buildProvider(
                _coverPhoto,
                AssetPaths.defaultCover,
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Gradient overlays
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.transparent,
                AppColors.darkBackground.withOpacity(0.8),
                AppColors.darkBackground,
              ],
              stops: const [0.0, 0.4, 0.8, 1.0],
            ),
          ),
        ),
        // Expandable title when fully expanded
        if (t < 0.5)
          Positioned(
            left: 24,
            bottom: 80,
            child: AnimatedOpacity(
              opacity: 1.0 - (t * 2),
              duration: const Duration(milliseconds: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _name,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildBountyBadge(),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBountyBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryGold.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.agedGold,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withOpacity(0.6),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.monetization_on,
            color: Colors.black87,
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            _bounty,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedProfilePicture() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: _profileScale),
      duration: const Duration(milliseconds: 100),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _showEnlargedProfilePicture(),
          child: AnimatedContainer(
            duration: AppDurations.cardHover,
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryGold,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGold.withOpacity(0.6),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
              image: DecorationImage(
                image: ImageHelper.buildProvider(
                  _profilePicture,
                  AssetPaths.defaultAvatar,
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEnlargedProfilePicture() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Hero(
            tag: 'profile_pic',
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryGold,
                  width: 6,
                ),
                image: DecorationImage(
                  image: ImageHelper.buildProvider(
                    _profilePicture,
                    AssetPaths.defaultAvatar,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryGold.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildStatsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCounter(
          icon: Icons.code,
          label: 'Projects',
          notifier: _projectCount,
          color: AppColors.primaryGold,
        ),
        _buildStatCounter(
          icon: Icons.people,
          label: 'Friends',
          notifier: _friendCount,
          color: AppColors.crimson,
        ),
        _buildStatCounter(
          icon: Icons.local_cafe,
          label: 'Coffee',
          notifier: _coffeeCount,
          color: AppColors.agedGold,
        ),
      ],
    );
  }

  Widget _buildStatCounter({
    required IconData icon,
    required String label,
    required ValueNotifier<int> notifier,
    required Color color,
  }) {
    return ValueListenableBuilder<int>(
      valueListenable: notifier,
      builder: (context, value, child) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: AppDurations.cardHover,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 8),
                Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoGrid() {
    final items = [
      {'icon': Icons.school, 'label': 'Education', 'value': _education},
      {'icon': Icons.work, 'label': 'Work', 'value': _work},
      {'icon': Icons.location_on, 'label': 'Hometown', 'value': _hometown},
      {'icon': Icons.favorite, 'label': 'Status', 'value': _relationship},
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: items.map((item) => _buildTiltCard(item)).toList(),
    );
  }

  Widget _buildTiltCard(Map<String, dynamic> item) {
    // State for tilt effect
    return StatefulBuilder(
      builder: (context, setState) {
        double tiltX = 0.0;
        double tiltY = 0.0;

        return MouseRegion(
          onHover: (event) {
            setState(() {
              // Calculate tilt based on mouse position relative to card center
              final localX = event.localPosition.dx;
              final localY = event.localPosition.dy;
              final centerX = 80.0; // approximate half width
              final centerY = 40.0; // approximate half height
              tiltX = ((localY - centerY) / centerY) * 5;
              tiltY = ((localX - centerX) / centerX) * -5;
            });
          },
          onExit: (_) {
            setState(() {
              tiltX = 0.0;
              tiltY = 0.0;
            });
          },
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(tiltX * math.pi / 180)
              ..rotateY(tiltY * math.pi / 180),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.cardSurface.withOpacity(0.6),
                  AppColors.darkBackground.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.agedGold.withOpacity(0.4),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGold.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 0,
                  offset: Offset(tiltY * 2, tiltX * 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: AppColors.primaryGold,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item['label'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.agedGold.withOpacity(0.8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['value'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandableDetails() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('PERSONAL DETAILS'),
          const SizedBox(height: 16),
          _detailRow('Age', _age),
          _detailRow('Gender', _gender),
          _detailRow('Year Level', _yearLevel),
          _detailRow('Hometown', _hometown),
          _detailRow('Relationship', _relationship),
          const Divider(
            color: AppColors.agedGold,
            height: 24,
            thickness: 0.5,
          ),
          _detailRow('Education', _education),
          _detailRow('Work', _work),
          // Interactive contact rows with copy functionality
          _interactiveDetailRow('Email', _email, onTap: () {
            Clipboard.setData(ClipboardData(text: _email));
            _showSnackBar('Email copied to clipboard');
          }),
          _interactiveDetailRow('Phone', _phone, onTap: () {
            Clipboard.setData(ClipboardData(text: _phone));
            _showSnackBar('Phone number copied');
          }),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.crimson,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: AppColors.crimson.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: AppColors.primaryGold,
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.agedGold.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.4,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _interactiveDetailRow(String label, String value,
      {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.agedGold.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primaryGold.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          value,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.copy,
                        size: 16,
                        color: AppColors.primaryGold.withOpacity(0.6),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedInterests() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('INTERESTS & HOBBIES'),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _interests.map((interest) {
              return _buildInteractiveChip(interest);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveChip(String label) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: AppDurations.cardHover,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              gradient: isHovered
                  ? LinearGradient(
                      colors: [
                        AppColors.primaryGold.withOpacity(0.3),
                        AppColors.agedGold.withOpacity(0.2),
                      ],
                    )
                  : null,
              color: isHovered ? null : AppColors.primaryGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isHovered
                    ? AppColors.primaryGold
                    : AppColors.primaryGold.withOpacity(0.4),
                width: isHovered ? 2 : 1,
              ),
              boxShadow: isHovered
                  ? [
                      BoxShadow(
                        color: AppColors.primaryGold.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isHovered ? Colors.white : AppColors.primaryGold,
                  ),
                ),
                if (isHovered) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    size: 14,
                    color: AppColors.primaryGold,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: AppDurations.cardHover,
        width: 56,
        height: 56,
        child: FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: AppColors.cardSurface.withOpacity(0.9),
          elevation: 8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primaryGold, size: 24),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.darkBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: AppColors.primaryGold),
        ),
      ),
    );
  }
}

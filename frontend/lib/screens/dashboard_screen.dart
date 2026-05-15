import 'dart:async';
import 'dart:html' as html; // ignore: avoid_web_libraries_in_flutter
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
const Color _kGoldBright = Color(0xFFFFE566);

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

  /// Tracks whether the dashboard is the TOPMOST visible screen.
  /// Set to false when the user pushes a sub-route (profile, sub-dashboard).
  /// Set back to true when they return.
  /// The browser-back interceptor ONLY fires when this is true.
  bool _isDashboardActive = true;

  StreamSubscription<html.PopStateEvent>? _popStateSub;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92, initialPage: 0);
    _pageController.addListener(_onPageChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _setupBrowserBackInterceptor();
    });
  }

  /// Sets up the browser back button interceptor.
  /// Called on init and every time we return TO the dashboard.
  ///
  /// HOW IT WORKS:
  /// 1. We push TWO dummy states: [real-entry, dummy-A, dummy-B]
  ///    History stack: [...prev, /dashboard(real), /dashboard(A), /dashboard(B)]
  ///    User is at B.
  /// 2. Mouse back pressed: browser pops B → user is now at A.
  ///    onPopState fires → we show the logout dialog.
  ///    We push B back immediately so the stack is restored.
  /// 3. If user presses No in dialog: stack still has A and B, works again.
  /// 4. If user presses Yes: we call logout + replaceState('/').
  void _setupBrowserBackInterceptor() {
    // Cancel any existing subscription first
    _popStateSub?.cancel();
    _popStateSub = null;

    // Push two dummy entries. The extra one gives us a buffer so
    // rapid double-clicks don't skip past our interception.
    html.window.history
        .pushState({'page': 'dashboard', 'level': 1}, '', '/dashboard');
    html.window.history
        .pushState({'page': 'dashboard', 'level': 2}, '', '/dashboard');

    _popStateSub = html.window.onPopState.listen((event) {
      if (!mounted) return;

      // Not on dashboard — someone navigated elsewhere, ignore.
      if (!_isDashboardActive) {
        // But we still need to re-push our sentinel so returning
        // to dashboard later works correctly. We do that in _navigateTo.
        return;
      }

      // The back button was pressed while on the dashboard.
      // Immediately push the sentinel back so the browser stack is
      // restored before the dialog opens. This prevents the page from
      // actually navigating away.
      html.window.history
          .pushState({'page': 'dashboard', 'level': 2}, '', '/dashboard');

      _showLogoutConfirmDialog();
    });
  }

  @override
  void dispose() {
    _popStateSub?.cancel();
    _popStateSub = null;
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onPageChanged() {
    if (_pageController.page != null) {
      setState(() => _currentPage = _pageController.page!.round());
    }
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft && _currentPage > 0)
        _goToPrevious();
      else if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
          _currentPage < _cardCount - 1) _goToNext();
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

  /// Navigate to a sub-route.
  /// Sets _isDashboardActive = false so back presses on the sub-screen
  /// are ignored by our listener.
  /// When the user returns (.then), re-activates the interceptor.
  void _navigateTo(String route) {
    setState(() => _isDashboardActive = false);
    context.push(route).then((_) {
      if (mounted) {
        setState(() => _isDashboardActive = true);
        // Re-setup the interceptor so the next back press on the
        // dashboard is caught correctly.
        _setupBrowserBackInterceptor();
      }
    });
  }

  void _openProfile(int index) {
    switch (index) {
      case 0:
        _navigateTo('/profile-pallen');
        break;
      case 1:
        _navigateTo('/profile-karl');
        break;
      case 2:
        _navigateTo('/profile-aldhy');
        break;
    }
  }

  void _showLogoutConfirmDialog() {
    if (!mounted) return;
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _LogoutConfirmDialog(),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        _performLogout();
      }
      // User pressed No — interceptor is already restored because we
      // pushed the sentinel back BEFORE showing the dialog.
    });
  }

  void _performLogout() {
    final auth = context.read<AuthProvider>();
    auth.logout();
    html.window.history.replaceState(null, '', '/');
    if (mounted) context.go('/');
  }

  void _handleLogout() => _showLogoutConfirmDialog();

  ImageProvider _getBadgeImageProvider(AuthProvider auth) {
    if (auth.isMainUser && auth.email != null) {
      const Map<String, String> emailToAsset = {
        'pallen@main.com': 'assets/images/profile1.jpg',
        'karl@main.com': 'assets/images/profile2.jpg',
        'aldhy@main.com': 'assets/images/profile3.jpg',
      };
      final assetPath = emailToAsset[auth.email!];
      if (assetPath != null) return AssetImage(assetPath);
    }

    if (auth.currentUserPictureBytes != null) {
      return MemoryImage(auth.currentUserPictureBytes!);
    }

    if (auth.userID != null && auth.subUsers.isNotEmpty) {
      SubUser? found;
      for (final user in auth.subUsers) {
        if (user is SubUser && user.id == auth.userID) {
          found = user;
          break;
        }
      }
      if (found == null) {
        for (final user in auth.subUsers) {
          if (user is SubUser && user.ownerUserId == auth.userID) {
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
              found.profilePicture, AssetPaths.defaultAvatar);
        }
      }
    }

    return AssetImage(AssetPaths.defaultAvatar);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final badgeImage = _getBadgeImageProvider(auth);
    final bool showLeft = _currentPage > 0;
    final bool showRight = _currentPage < _cardCount - 1;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop && _isDashboardActive) _showLogoutConfirmDialog();
      },
      child: RawKeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKey: _handleKeyEvent,
        child: GestureDetector(
          onTap: () => _focusNode.requestFocus(),
          child: Scaffold(
            body: Stack(
              children: [
                const VideoBackground(
                    videoPath: AssetPaths.dashboardBackgroundVideo),
                Container(color: Colors.black.withOpacity(0.3)),
                Positioned(
                  right: 0,
                  top: 90,
                  bottom: 80,
                  child: IgnorePointer(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.20,
                      child: Opacity(
                        opacity: 0.92,
                        child: Image.asset(
                          'assets/images/one_piece_character.png',
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomRight,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 72),
                      Text(
                        'Use arrows or swipe to navigate',
                        style: TextStyle(
                          fontSize: 12,
                          color: _kParchment.withOpacity(0.45),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PageView.builder(
                              controller: _pageController,
                              itemCount: _cardCount,
                              physics: const PageScrollPhysics(),
                              onPageChanged: (i) =>
                                  setState(() => _currentPage = i),
                              itemBuilder: (context, index) {
                                final bool isCenter = index == _currentPage;
                                return Padding(
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
                            Positioned(
                              left: 4,
                              child: AnimatedOpacity(
                                opacity: showLeft ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 250),
                                child: IgnorePointer(
                                  ignoring: !showLeft,
                                  child: _NavArrowButton(
                                      icon: Icons.chevron_left,
                                      onTap: _goToPrevious),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 4,
                              child: AnimatedOpacity(
                                opacity: showRight ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 250),
                                child: IgnorePointer(
                                  ignoring: !showRight,
                                  child: _NavArrowButton(
                                      icon: Icons.chevron_right,
                                      onTap: _goToNext),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
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
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: _LoggedInUserBadge(
                              userName: auth.userName ?? 'User',
                              isMainUser: auth.isMainUser,
                              imageProvider: badgeImage,
                            ),
                          ),
                          Center(
                            child: _OnePieceTitle(text: 'NAKAMA', fontSize: 34),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _TopBarButton(
                                  label: 'Crew',
                                  icon: Icons.people,
                                  onTap: () => _navigateTo('/sub-dashboard'),
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
      ),
    );
  }
}

// ── ONE PIECE TITLE ───────────────────────────────────────────────
class _OnePieceTitle extends StatelessWidget {
  final String text;
  final double fontSize;
  const _OnePieceTitle({required this.text, this.fontSize = 44});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(text,
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
            )),
        Text(text,
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
            )),
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
          child: Text(text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'PirataOne',
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                letterSpacing: 5,
                height: 1.0,
                color: Colors.white,
              )),
        ),
      ],
    );
  }
}

// ── CAROUSEL CARD SLOT ────────────────────────────────────────────
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
          ? Center(child: _buildCard())
          : IgnorePointer(child: _buildCard()),
    );
  }

  Widget _buildCard() {
    switch (index) {
      case 0:
        return MainProfileCardPallen(
            isCenter: isCenter, onOpenProfile: isCenter ? onTapCenter : null);
      case 1:
        return MainProfileCardKarl(
            isCenter: isCenter, onOpenProfile: isCenter ? onTapCenter : null);
      case 2:
        return MainProfileCardAldhy(
            isCenter: isCenter, onOpenProfile: isCenter ? onTapCenter : null);
      default:
        return const SizedBox.shrink();
    }
  }
}

// ── NAV ARROW BUTTON ─────────────────────────────────────────────
class _NavArrowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavArrowButton({required this.icon, required this.onTap});
  @override
  State<_NavArrowButton> createState() => _NavArrowButtonState();
}

class _NavArrowButtonState extends State<_NavArrowButton> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
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
                          spreadRadius: 2)
                    ]
                  : [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.3), blurRadius: 8)
                    ],
            ),
            child: Icon(widget.icon,
                color: _hovered ? Colors.white : _kParchment.withOpacity(0.8),
                size: 28),
          ),
        ),
      );
}

// ── LOGGED-IN USER BADGE ──────────────────────────────────────────
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
        border: Border.all(color: _kGold.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: _kGold.withOpacity(0.15), blurRadius: 12, spreadRadius: 1)
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _kGold, width: 2),
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(userName,
                style: const TextStyle(
                    color: _kParchment,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isMainUser
                    ? _kGold.withOpacity(0.8)
                    : _kCrimson.withOpacity(0.8),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(isMainUser ? 'Captain' : 'Crew',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  )),
            ),
          ],
        ),
      ]),
    );
  }
}

// ── TOP BAR BUTTON ────────────────────────────────────────────────
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
  Widget build(BuildContext context) => MouseRegion(
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
                          spreadRadius: 1)
                    ]
                  : [],
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(widget.icon, color: Colors.white, size: 16),
              const SizedBox(width: 5),
              Text(widget.label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ]),
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════
// LOGOUT CONFIRMATION DIALOG
// Only shown when pressing Back or Logout from the dashboard.
// ═══════════════════════════════════════════════════════════════
class _LogoutConfirmDialog extends StatefulWidget {
  const _LogoutConfirmDialog();
  @override
  State<_LogoutConfirmDialog> createState() => _LogoutConfirmDialogState();
}

class _LogoutConfirmDialogState extends State<_LogoutConfirmDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _scale = Tween<double>(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 380,
            decoration: BoxDecoration(
              color: const Color(0xFF1A0A00),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: _kGold.withOpacity(0.55), width: 2),
              boxShadow: [
                BoxShadow(
                  color: _kGold.withOpacity(0.18),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.7),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Gold top accent bar
                Container(
                  height: 4,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _kCrimson,
                        _kGold,
                        _kGoldBright,
                        _kGold,
                        _kCrimson
                      ],
                    ),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(2)),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
                  child: Column(
                    children: [
                      // Anchor icon
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _kGold.withOpacity(0.12),
                          border: Border.all(
                              color: _kGold.withOpacity(0.4), width: 1.5),
                        ),
                        child: Center(
                          child: Text('⚓', style: TextStyle(fontSize: 26)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title
                      const Text(
                        'LEAVE THE SHIP?',
                        style: TextStyle(
                          fontFamily: 'PirataOne',
                          color: _kGoldBright,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),

                      // Subtitle
                      Text(
                        'Are you sure you want to log out\nand leave your crew behind?',
                        style: TextStyle(
                          color: _kParchment.withOpacity(0.55),
                          fontSize: 13,
                          height: 1.55,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 26),

                      // Buttons
                      Row(
                        children: [
                          // NO — Stay
                          Expanded(
                            child: _DialogBtn(
                              label: 'Stay on Ship',
                              icon: Icons.anchor_rounded,
                              filled: false,
                              onTap: () => Navigator.pop(context, false),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // YES — Log out
                          Expanded(
                            child: _DialogBtn(
                              label: 'Log Out',
                              icon: Icons.logout_rounded,
                              filled: true,
                              onTap: () => Navigator.pop(context, true),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Gold bottom accent bar
                Container(
                  height: 4,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _kCrimson,
                        _kGold,
                        _kGoldBright,
                        _kGold,
                        _kCrimson
                      ],
                    ),
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(2)),
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

class _DialogBtn extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;
  const _DialogBtn({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });
  @override
  State<_DialogBtn> createState() => _DialogBtnState();
}

class _DialogBtnState extends State<_DialogBtn> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    final bg = widget.filled
        ? (_h ? _kCrimson : _kCrimson.withOpacity(0.85))
        : (_h ? _kGold.withOpacity(0.15) : Colors.transparent);
    final border = widget.filled
        ? Colors.transparent
        : (_h ? _kGold.withOpacity(0.7) : _kGold.withOpacity(0.35));
    final fg = widget.filled ? Colors.white : _kParchment.withOpacity(0.8);

    return MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          transform: Matrix4.identity()..translate(0.0, _h ? -2.0 : 0.0),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: border),
            boxShadow: _h && widget.filled
                ? [
                    BoxShadow(
                        color: _kCrimson.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 1)
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: fg, size: 15),
              const SizedBox(width: 7),
              Text(widget.label,
                  style: TextStyle(
                    color: fg,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/pallen_prince_dunhill.dart';
import '../models/albaniel_karl_angelo.dart';
import '../models/fajardo_aldhy.dart';
import '../models/sub_user.dart';
import '../models/user_base.dart';
import '../utils/constants.dart';
import '../utils/image_helper.dart';
import '../widgets/edit_subuser_dialog.dart';

// ═══════════════════════════════════════════════════════════════
// ONE PIECE WANTED POSTER — PROFILE DETAIL SCREEN
// ═══════════════════════════════════════════════════════════════
// Palette
const _kParchment = Color(0xFFF2D98B);
const _kParchDark = Color(0xFFD4A843);
const _kParchLight = Color(0xFFFAEBBB);
const _kInk = Color(0xFF1A0900);
const _kInkMid = Color(0xFF3B1F0A);
const _kInkLight = Color(0xFF5C3318);
const _kCrimson = Color(0xFF8B1A1A);
const _kCrimsonLit = Color(0xFFB52222);
const _kGold = Color(0xFFD4A017);
const _kGoldBright = Color(0xFFFFD700);
const _kNavy = Color(0xFF0F1B2D);
const _kSeaBlue = Color(0xFF1E3A5F);
const _kWoodDark = Color(0xFF2C1A0A);
const _kWoodMid = Color(0xFF4A2E12);

class ProfileDetailScreen extends StatefulWidget {
  final String profileId;
  const ProfileDetailScreen({super.key, required this.profileId});
  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen>
    with TickerProviderStateMixin {
  UserBase? _user;
  bool _isLoading = true;
  String? _error;

  // Bounty counter animation
  late AnimationController _bountyCtrl;
  late Animation<int> _bountyAnim;
  int _bountyTarget = 0;

  // Entry animation
  late AnimationController _entryCtrl;
  late Animation<double> _entryFade;
  late Animation<Offset> _entrySlide;

  // Stamp animation
  late AnimationController _stampCtrl;
  late Animation<double> _stampScale;
  late Animation<double> _stampOpacity;

  // Scroll controller for parallax
  final ScrollController _scrollCtrl = ScrollController();
  double _scrollOffset = 0;

  final List<String> _mainProfileIds = ['profile_1', 'profile_2', 'profile_3'];

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _entryFade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _entrySlide = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));

    _bountyCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600));
    _bountyAnim = IntTween(begin: 0, end: 0)
        .animate(CurvedAnimation(parent: _bountyCtrl, curve: Curves.easeOut));

    _stampCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _stampScale = Tween<double>(begin: 2.5, end: 1.0)
        .animate(CurvedAnimation(parent: _stampCtrl, curve: Curves.elasticOut));
    _stampOpacity = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _stampCtrl, curve: Curves.easeIn));

    _scrollCtrl.addListener(() {
      setState(() => _scrollOffset = _scrollCtrl.offset);
    });

    _loadProfile();
  }

  void _startAnimations(UserBase user) {
    _entryCtrl.forward();
    // Bounty based on name hash
    _bountyTarget = _computeBounty(user.name);
    _bountyAnim = IntTween(begin: 0, end: _bountyTarget)
        .animate(CurvedAnimation(parent: _bountyCtrl, curve: Curves.easeOut));
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _bountyCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _stampCtrl.forward();
    });
  }

  int _computeBounty(String name) {
    int seed = name.codeUnits.fold(0, (p, e) => p + e);
    return ((seed * 137 + 500) % 900 + 100) * 1000000;
  }

  String _formatBounty(int val) {
    if (val == 0) return '฿ 0';
    final formatted = val.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return '฿ $formatted';
  }

  @override
  void dispose() {
    _bountyCtrl.dispose();
    _entryCtrl.dispose();
    _stampCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── DATA LOADING ───────────────────────────────────────────────
  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    if (_mainProfileIds.contains(widget.profileId)) {
      final u = _getMainProfile(widget.profileId);
      setState(() {
        _user = u;
        _isLoading = false;
      });
      _startAnimations(u);
      return;
    }

    final auth = context.read<AuthProvider>();
    final local = auth.subUsers.where((u) => u.id == widget.profileId).toList();

    if (local.isNotEmpty) {
      setState(() {
        _user = local.first;
        _isLoading = false;
      });
      _startAnimations(local.first);
      _refreshFromBackend(auth, local.first);
      return;
    }

    await _fetchFromBackend(auth);
  }

  Future<void> _refreshFromBackend(AuthProvider auth, UserBase local) async {
    try {
      final res = await auth.apiService.getProfileById(widget.profileId);
      if (!res.containsKey('error')) {
        final data = res.containsKey('data') && res['data'] is Map
            ? Map<String, dynamic>.from(res['data'] as Map)
            : res['profile'] ?? res;
        final backend = SubUser.fromJson(data);
        final merged = backend.copyWith({
          'profile_picture_bytes': local.profilePictureBytes,
          'cover_photo_bytes': local.coverPhotoBytes,
          if (local.profilePictureBytes == null)
            'profile_picture_url': backend.profilePicture,
          if (local.coverPhotoBytes == null)
            'cover_photo_url': backend.coverPhoto,
        });
        if (mounted) {
          setState(() => _user = merged);
          auth.updateSubUser(merged);
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchFromBackend(AuthProvider auth) async {
    try {
      final res = await auth.apiService.getProfileById(widget.profileId);
      if (!res.containsKey('error')) {
        final data = res.containsKey('data') && res['data'] is Map
            ? Map<String, dynamic>.from(res['data'] as Map)
            : res['profile'] ?? res;
        final loaded = SubUser.fromJson(data);
        auth.updateSubUser(loaded);
        setState(() {
          _user = loaded;
          _isLoading = false;
        });
        _startAnimations(loaded);
        return;
      }
      final all = await auth.apiService.getAllSubUsers();
      if (!all.containsKey('error')) {
        final list = all['sub_users'] ?? all['profiles'] ?? [];
        final match =
            list.where((p) => p['id'].toString() == widget.profileId).toList();
        if (match.isNotEmpty) {
          final loaded =
              SubUser.fromJson(Map<String, dynamic>.from(match.first as Map));
          auth.updateSubUser(loaded);
          setState(() {
            _user = loaded;
            _isLoading = false;
          });
          _startAnimations(loaded);
          return;
        }
      }
      setState(() {
        _error = 'Profile not found.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load: $e';
        _isLoading = false;
      });
    }
  }

  UserBase _getMainProfile(String id) {
    switch (id) {
      case 'profile_1':
        return PallenPrinceDunhill();
      case 'profile_2':
        return AlbanielKarlAngelo();
      case 'profile_3':
        return FajardoAldhy();
      default:
        return SubUser(id: id, name: 'Unknown');
    }
  }

  bool get _isMainProfile => _mainProfileIds.contains(widget.profileId);

  bool _canEdit(AuthProvider auth) {
    if (_user == null || _isMainProfile) return false;
    if (auth.isMainUser) return true;
    return auth.isOwnProfile(_user!);
  }

  bool _canDelete(AuthProvider auth) => !_isMainProfile && auth.isMainUser;

  void _editProfile(AuthProvider auth) {
    if (_user == null) return;
    showDialog(
      context: context,
      builder: (ctx) => EditSubUserDialog(
        user: _user!,
        onSave: (data) async {
          final updated = _user!.copyWith(data);
          setState(() => _user = updated);
          auth.updateSubUser(updated);
          _refreshFromBackend(auth, updated);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('✅ Wanted poster updated!'),
            backgroundColor: _kCrimson,
            duration: Duration(seconds: 2),
          ));
        },
      ),
    );
  }

  void _deleteProfile(AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => _WantedConfirmDialog(
        name: _user?.name ?? '',
        onConfirm: () async {
          if (_user != null) {
            await auth.apiService.deleteProfile(_user!.id);
            auth.removeSubUser(_user!.id);
          }
          if (mounted) {
            Navigator.pop(ctx);
            context.pop();
          }
        },
      ),
    );
  }

  // ── BUILD ──────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (_isLoading) return const _WantedLoadingScreen();

    if (_error != null || _user == null) {
      return _WantedErrorScreen(error: _error, onRetry: _loadProfile);
    }

    final user = _user!;
    final canEdit = _canEdit(auth);
    final canDelete = _canDelete(auth);

    return Scaffold(
      backgroundColor: _kNavy,
      body: FadeTransition(
        opacity: _entryFade,
        child: SlideTransition(
          position: _entrySlide,
          child: Stack(children: [
            // Sea background
            Positioned.fill(child: _SeaBackground(scrollOffset: _scrollOffset)),

            // Main scroll
            CustomScrollView(
              controller: _scrollCtrl,
              slivers: [
                // Top bar
                SliverToBoxAdapter(
                  child: _TopBar(
                    canEdit: canEdit,
                    canDelete: canDelete,
                    onBack: () => context.pop(),
                    onEdit: () => _editProfile(auth),
                    onDelete: () => _deleteProfile(auth),
                  ),
                ),

                // Hero — Wanted Poster
                SliverToBoxAdapter(
                  child: _WantedPosterHero(
                    user: user,
                    bountyAnim: _bountyAnim,
                    bountyCtrl: _bountyCtrl,
                    stampCtrl: _stampCtrl,
                    stampScale: _stampScale,
                    stampOpacity: _stampOpacity,
                    formatBounty: _formatBounty,
                  ),
                ),

                // Info sections
                SliverToBoxAdapter(
                  child: _ProfileBody(user: user),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SEA BACKGROUND PAINTER
// ═══════════════════════════════════════════════════════════════
class _SeaBackground extends StatelessWidget {
  final double scrollOffset;
  const _SeaBackground({required this.scrollOffset});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF060D1A),
            Color(0xFF0F1B2D),
            Color(0xFF1E3A5F),
            Color(0xFF0A0500),
          ],
          stops: [0.0, 0.3, 0.65, 1.0],
        ),
      ),
      child: CustomPaint(
        painter: _SeaPainter(scrollOffset),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _SeaPainter extends CustomPainter {
  final double scroll;
  _SeaPainter(this.scroll);
  @override
  void paint(Canvas canvas, Size s) {
    // Subtle wave lines
    final p = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 6; i++) {
      final y = (s.height * 0.55 + i * 28.0) - (scroll * 0.08);
      final path = Path();
      path.moveTo(0, y);
      for (double x = 0; x < s.width; x += 40) {
        path.quadraticBezierTo(x + 20, y + (i.isEven ? 8 : -8), x + 40, y);
      }
      canvas.drawPath(path, p);
    }
    // Stars
    final star = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    final rng = math.Random(42);
    for (int i = 0; i < 80; i++) {
      final x = rng.nextDouble() * s.width;
      final y = rng.nextDouble() * s.height * 0.4;
      canvas.drawCircle(Offset(x, y), rng.nextDouble() * 1.2, star);
    }
  }

  @override
  bool shouldRepaint(_SeaPainter old) => old.scroll != scroll;
}

// ═══════════════════════════════════════════════════════════════
// TOP BAR
// ═══════════════════════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  final bool canEdit, canDelete;
  final VoidCallback onBack, onEdit, onDelete;
  const _TopBar({
    required this.canEdit,
    required this.canDelete,
    required this.onBack,
    required this.onEdit,
    required this.onDelete,
  });
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(children: [
          _NavBtn(
            icon: Icons.arrow_back_ios_new_rounded,
            label: 'Back',
            onTap: onBack,
          ),
          const Spacer(),
          // Marine header text
          Column(children: [
            Text('MARINE HQ',
                style: TextStyle(
                  fontFamily: 'PirataOne',
                  color: _kGold.withOpacity(0.7),
                  fontSize: 10,
                  letterSpacing: 4,
                )),
            Text('WANTED RECORDS',
                style: TextStyle(
                  color: _kParchment.withOpacity(0.35),
                  fontSize: 9,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                )),
          ]),
          const Spacer(),
          if (canEdit)
            _NavBtn(icon: Icons.edit_rounded, label: 'Edit', onTap: onEdit),
          if (canDelete) ...[
            const SizedBox(width: 8),
            _NavBtn(
                icon: Icons.delete_rounded,
                label: 'Remove',
                onTap: onDelete,
                danger: true),
          ],
        ]),
      ),
    );
  }
}

class _NavBtn extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
  const _NavBtn(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.danger = false});
  @override
  State<_NavBtn> createState() => _NavBtnState();
}

class _NavBtnState extends State<_NavBtn> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    final c = widget.danger ? _kCrimson : _kGold;
    return MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _h ? c.withOpacity(0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: _h ? c.withOpacity(0.6) : c.withOpacity(0.25)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(widget.icon, color: _h ? c : c.withOpacity(0.6), size: 14),
            const SizedBox(width: 6),
            Text(widget.label,
                style: TextStyle(
                  color: _h ? c : c.withOpacity(0.6),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                )),
          ]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WANTED POSTER HERO
// ═══════════════════════════════════════════════════════════════
class _WantedPosterHero extends StatelessWidget {
  final UserBase user;
  final Animation<int> bountyAnim;
  final AnimationController bountyCtrl, stampCtrl;
  final Animation<double> stampScale, stampOpacity;
  final String Function(int) formatBounty;

  const _WantedPosterHero({
    required this.user,
    required this.bountyAnim,
    required this.bountyCtrl,
    required this.stampCtrl,
    required this.stampScale,
    required this.stampOpacity,
    required this.formatBounty,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: SizedBox(
          width: sw > 800 ? 520 : sw * 0.88,
          child: _PosterCard(
            user: user,
            bountyAnim: bountyAnim,
            stampScale: stampScale,
            stampOpacity: stampOpacity,
            formatBounty: formatBounty,
          ),
        ),
      ),
    );
  }
}

class _PosterCard extends StatefulWidget {
  final UserBase user;
  final Animation<int> bountyAnim;
  final Animation<double> stampScale, stampOpacity;
  final String Function(int) formatBounty;
  const _PosterCard({
    required this.user,
    required this.bountyAnim,
    required this.stampScale,
    required this.stampOpacity,
    required this.formatBounty,
  });
  @override
  State<_PosterCard> createState() => _PosterCardState();
}

class _PosterCardState extends State<_PosterCard> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.identity()..translate(0.0, _hov ? -8.0 : 0.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: _kGold.withOpacity(_hov ? 0.45 : 0.20),
              blurRadius: _hov ? 60 : 30,
              spreadRadius: _hov ? 6 : 2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.7),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(children: [
            // Poster body
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF2D98B),
                    Color(0xFFE8C96A),
                    Color(0xFFD4A843),
                    Color(0xFFF5DEB3),
                  ],
                ),
              ),
              child: Column(children: [
                // ── TOP BORDER BAND ────────────────────────────
                Container(
                  height: 14,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [_kCrimson, _kCrimsonLit, _kCrimson]),
                  ),
                ),

                // ── MARINE HEADER ──────────────────────────────
                Container(
                  color: _kInk,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _AnchorIcon(size: 18),
                      const SizedBox(width: 10),
                      const Text('WORLD GOVERNMENT',
                          style: TextStyle(
                            fontFamily: 'PirataOne',
                            color: _kGoldBright,
                            fontSize: 13,
                            letterSpacing: 4,
                            fontWeight: FontWeight.w900,
                          )),
                      const SizedBox(width: 10),
                      _AnchorIcon(size: 18),
                    ],
                  ),
                ),

                // ── WANTED headline ────────────────────────────
                Container(
                  color: _kInk,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text('WANTED',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'PirataOne',
                        color: _kParchment,
                        fontSize: 72,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6,
                        height: 1.0,
                        shadows: [
                          Shadow(
                            color: _kGold.withOpacity(0.6),
                            blurRadius: 20,
                          ),
                        ],
                      )),
                ),

                // ── Dead or Alive ──────────────────────────────
                Container(
                  color: const Color(0xFF0D0500),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: const Text('DEAD   OR   ALIVE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _kParchment,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6,
                      )),
                ),

                // ── Gold divider ───────────────────────────────
                Container(
                    height: 3,
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [
                      _kCrimson,
                      _kGold,
                      _kGoldBright,
                      _kGold,
                      _kCrimson
                    ]))),

                // ── Photo ──────────────────────────────────────
                Container(
                  color: const Color(0xFFEBC870),
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                  child: Stack(alignment: Alignment.center, children: [
                    // Photo frame
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: _kInk, width: 4),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 16,
                              offset: const Offset(4, 6)),
                        ],
                      ),
                      child: ClipRect(
                        child: SizedBox(
                          height: 280,
                          width: double.infinity,
                          child: Image(
                            image: ImageHelper.buildProvider(
                              widget.user.profilePicture,
                              AssetPaths.defaultAvatar,
                              bytes: widget.user.profilePictureBytes,
                            ),
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFFD4A843),
                              child: const Icon(Icons.person_rounded,
                                  color: _kInk, size: 120),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Vintage sepia overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              _kInk.withOpacity(0.35),
                            ],
                            stops: const [0.6, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // STAMP overlay
                    Positioned(
                      top: 12,
                      right: 12,
                      child: AnimatedBuilder(
                        animation: widget.stampOpacity,
                        builder: (_, __) => Transform.scale(
                          scale: widget.stampScale.value,
                          child: Opacity(
                            opacity: widget.stampOpacity.value,
                            child: Transform.rotate(
                              angle: -0.28,
                              child: Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: _kCrimson.withOpacity(0.85),
                                      width: 4),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('MARINE',
                                        style: TextStyle(
                                          color: _kCrimson.withOpacity(0.85),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 2,
                                        )),
                                    Text('IDENTIFIED',
                                        style: TextStyle(
                                          color: _kCrimson.withOpacity(0.85),
                                          fontSize: 7,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),

                // ── Gold horizontal divider ────────────────────
                Container(
                    height: 3,
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [
                      _kCrimson,
                      _kGold,
                      _kGoldBright,
                      _kGold,
                      _kCrimson
                    ]))),

                // ── Name block ─────────────────────────────────
                Container(
                  color: const Color(0xFF0D0500),
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  child: Column(children: [
                    Text(widget.user.name.toUpperCase(),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: const TextStyle(
                          fontFamily: 'PirataOne',
                          color: _kParchment,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                          height: 1.1,
                        )),
                    if (widget.user.bio != null &&
                        widget.user.bio!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        '"${widget.user.bio}"',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _kParchment.withOpacity(0.55),
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ]),
                ),

                // ── Bounty block ───────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF1A0900), Color(0xFF0D0500)],
                    ),
                    border:
                        Border.all(color: _kGold.withOpacity(0.25), width: 1),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  child: Column(children: [
                    Text('REWARD OFFERED',
                        style: TextStyle(
                          color: _kParchDark.withOpacity(0.55),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 4,
                        )),
                    const SizedBox(height: 8),
                    AnimatedBuilder(
                      animation: widget.bountyAnim,
                      builder: (_, __) => Text(
                        widget.formatBounty(widget.bountyAnim.value),
                        style: const TextStyle(
                          fontFamily: 'PirataOne',
                          color: _kGoldBright,
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(color: _kGold, blurRadius: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('— DEAD OR ALIVE —',
                        style: TextStyle(
                          color: _kParchment.withOpacity(0.35),
                          fontSize: 10,
                          letterSpacing: 3,
                          fontWeight: FontWeight.w600,
                        )),
                  ]),
                ),

                // ── Bottom crimson band ────────────────────────
                Container(
                  height: 14,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [_kCrimson, _kCrimsonLit, _kCrimson]),
                  ),
                ),
              ]),
            ),

            // Aged paper texture overlay
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _PaperTexturePainter()),
              ),
            ),

            // Corner tear effects
            Positioned(top: 0, left: 0, child: _CornerTear(flip: false)),
            Positioned(top: 0, right: 0, child: _CornerTear(flip: true)),
          ]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PROFILE BODY — INFO SECTIONS
// ═══════════════════════════════════════════════════════════════
class _ProfileBody extends StatelessWidget {
  final UserBase user;
  const _ProfileBody({required this.user});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final wide = sw > 800;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: wide ? 60 : 20, vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Section header
        _SectionHeader(label: '— CREW DOSSIER —'),
        const SizedBox(height: 24),

        // Quick stats row
        _QuickStatsRow(user: user),
        const SizedBox(height: 32),

        // Main info grid
        wide ? _WideInfoGrid(user: user) : _NarrowInfoList(user: user),
        const SizedBox(height: 32),

        // Interests
        if (user.interests.isNotEmpty) ...[
          _SectionHeader(label: '— KNOWN INTERESTS —'),
          const SizedBox(height: 16),
          _InterestChips(interests: user.interests),
          const SizedBox(height: 32),
        ],

        // Marine footer stamp
        _MarineFooter(),
      ]),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
          width: 3,
          height: 20,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_kCrimson, _kGold]))),
      const SizedBox(width: 12),
      Text(label,
          style: const TextStyle(
            fontFamily: 'PirataOne',
            color: _kGold,
            fontSize: 16,
            letterSpacing: 3,
            fontWeight: FontWeight.w700,
          )),
      const SizedBox(width: 12),
      Expanded(
          child: Container(
              height: 1,
              decoration: const BoxDecoration(
                  gradient:
                      LinearGradient(colors: [_kGold, Colors.transparent])))),
    ]);
  }
}

class _QuickStatsRow extends StatelessWidget {
  final UserBase user;
  const _QuickStatsRow({required this.user});
  @override
  Widget build(BuildContext context) {
    final stats = <Map<String, String>>[
      if (user.age != null) {'label': 'AGE', 'value': '${user.age}'},
      if (user.gender != null && user.gender!.isNotEmpty)
        {'label': 'GENDER', 'value': user.gender!},
      if (user.yearLevel != null && user.yearLevel!.isNotEmpty)
        {'label': 'YEAR', 'value': user.yearLevel!},
      if (user.birthday != null)
        {
          'label': 'BORN',
          'value': DateFormat('MMM d, yyyy').format(user.birthday!)
        },
    ];
    if (stats.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kWoodDark.withOpacity(0.6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _kGold.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: stats
            .map((s) => _QuickStat(label: s['label']!, value: s['value']!))
            .toList(),
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String label, value;
  const _QuickStat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(label,
          style: TextStyle(
            color: _kGold.withOpacity(0.5),
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          )),
      const SizedBox(height: 4),
      Text(value,
          style: const TextStyle(
            fontFamily: 'PirataOne',
            color: _kParchment,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          )),
    ]);
  }
}

class _WideInfoGrid extends StatelessWidget {
  final UserBase user;
  const _WideInfoGrid({required this.user});
  @override
  Widget build(BuildContext context) {
    final items = _buildItems(user);
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items
          .map((i) => SizedBox(
                width: 300,
                child: _DossierCard(icon: i.$1, title: i.$2, value: i.$3),
              ))
          .toList(),
    );
  }
}

class _NarrowInfoList extends StatelessWidget {
  final UserBase user;
  const _NarrowInfoList({required this.user});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: _buildItems(user)
          .map((i) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _DossierCard(icon: i.$1, title: i.$2, value: i.$3),
              ))
          .toList(),
    );
  }
}

List<(IconData, String, String)> _buildItems(UserBase user) {
  return [
    if (user.email != null && user.email!.isNotEmpty)
      (Icons.alternate_email_rounded, 'EMAIL', user.email!),
    if (user.phone != null && user.phone!.isNotEmpty)
      (Icons.phone_iphone_rounded, 'PHONE', user.phone!),
    if (user.hometown != null && user.hometown!.isNotEmpty)
      (Icons.location_on_rounded, 'HOMETOWN', user.hometown!),
    if (user.education != null && user.education!.isNotEmpty)
      (Icons.school_rounded, 'EDUCATION', user.education!),
    if (user.work != null && user.work!.isNotEmpty)
      (Icons.work_rounded, 'OCCUPATION', user.work!),
    if (user.relationshipStatus != null && user.relationshipStatus!.isNotEmpty)
      (Icons.favorite_rounded, 'STATUS', user.relationshipStatus!),
  ];
}

class _DossierCard extends StatefulWidget {
  final IconData icon;
  final String title, value;
  const _DossierCard(
      {required this.icon, required this.title, required this.value});
  @override
  State<_DossierCard> createState() => _DossierCardState();
}

class _DossierCardState extends State<_DossierCard> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(_h ? 6 : 0, 0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _h ? _kWoodMid.withOpacity(0.7) : _kWoodDark.withOpacity(0.5),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: _h ? _kGold.withOpacity(0.5) : _kGold.withOpacity(0.15),
            width: _h ? 1.5 : 1,
          ),
          boxShadow: _h
              ? [
                  BoxShadow(color: _kGold.withOpacity(0.15), blurRadius: 16),
                ]
              : [],
        ),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _kCrimson.withOpacity(_h ? 0.2 : 0.12),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: _kCrimson.withOpacity(_h ? 0.5 : 0.25)),
            ),
            child: Icon(widget.icon,
                color: _h ? _kGold : _kGold.withOpacity(0.6), size: 16),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title,
                  style: TextStyle(
                    color: _kGold.withOpacity(0.45),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  )),
              const SizedBox(height: 3),
              Text(widget.value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _kParchment,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          )),
        ]),
      ),
    );
  }
}

class _InterestChips extends StatelessWidget {
  final List<String> interests;
  const _InterestChips({required this.interests});
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: interests.map((i) => _InterestChip(label: i)).toList(),
    );
  }
}

class _InterestChip extends StatefulWidget {
  final String label;
  const _InterestChip({required this.label});
  @override
  State<_InterestChip> createState() => _InterestChipState();
}

class _InterestChipState extends State<_InterestChip> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.translationValues(0, _h ? -3 : 0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: _h ? _kCrimson.withOpacity(0.25) : _kWoodDark.withOpacity(0.6),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color: _h ? _kGold.withOpacity(0.6) : _kGold.withOpacity(0.2),
          ),
          boxShadow: _h
              ? [
                  BoxShadow(color: _kGold.withOpacity(0.2), blurRadius: 10),
                ]
              : [],
        ),
        child: Text(widget.label,
            style: TextStyle(
              fontFamily: 'PirataOne',
              color: _h ? _kGoldBright : _kParchment.withOpacity(0.8),
              fontSize: 12,
              letterSpacing: 1,
            )),
      ),
    );
  }
}

class _MarineFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kInk.withOpacity(0.6),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _kCrimson.withOpacity(0.3)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _AnchorIcon(size: 16, color: _kCrimson),
        const SizedBox(width: 12),
        Text('ISSUED BY MARINE HEADQUARTERS  ·  WORLD GOVERNMENT',
            style: TextStyle(
              color: _kParchment.withOpacity(0.25),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            )),
        const SizedBox(width: 12),
        _AnchorIcon(size: 16, color: _kCrimson),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// DECORATIVE WIDGETS
// ═══════════════════════════════════════════════════════════════
class _AnchorIcon extends StatelessWidget {
  final double size;
  final Color color;
  const _AnchorIcon({this.size = 24, this.color = _kGoldBright});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _AnchorPainter(color)),
    );
  }
}

class _AnchorPainter extends CustomPainter {
  final Color color;
  _AnchorPainter(this.color);
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = color
      ..strokeWidth = s.width * 0.12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final cx = s.width / 2;
    // Vertical bar
    canvas.drawLine(
        Offset(cx, s.height * 0.15), Offset(cx, s.height * 0.85), p);
    // Top circle
    canvas.drawCircle(Offset(cx, s.height * 0.22), s.width * 0.14, p);
    // Crossbar
    canvas.drawLine(Offset(cx - s.width * 0.3, s.height * 0.38),
        Offset(cx + s.width * 0.3, s.height * 0.38), p);
    // Left curve
    canvas.drawArc(
        Rect.fromLTWH(
            s.width * 0.1, s.height * 0.45, s.width * 0.8, s.height * 0.4),
        math.pi,
        math.pi / 2,
        false,
        p);
    // Right curve
    canvas.drawArc(
        Rect.fromLTWH(
            s.width * 0.1, s.height * 0.45, s.width * 0.8, s.height * 0.4),
        0,
        -math.pi / 2,
        false,
        p);
  }

  @override
  bool shouldRepaint(_AnchorPainter o) => o.color != color;
}

class _CornerTear extends StatelessWidget {
  final bool flip;
  const _CornerTear({required this.flip});
  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: flip ? -1 : 1,
      child: CustomPaint(
        size: const Size(28, 28),
        painter: _TearPainter(),
      ),
    );
  }
}

class _TearPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = const Color(0x55000000)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(s.width * 0.9, 0)
      ..quadraticBezierTo(s.width * 0.3, s.height * 0.3, 0, s.height * 0.9)
      ..close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_TearPainter _) => false;
}

class _PaperTexturePainter extends CustomPainter {
  static final _rng = math.Random(7);
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 1200; i++) {
      p.color = Colors.black.withOpacity(_rng.nextDouble() * 0.03);
      canvas.drawCircle(
          Offset(_rng.nextDouble() * s.width, _rng.nextDouble() * s.height),
          0.7,
          p);
    }
    // Subtle vertical folds
    for (int i = 0; i < 3; i++) {
      final x = s.width * (0.25 + i * 0.25);
      canvas.drawLine(
          Offset(x, 0),
          Offset(x, s.height),
          Paint()
            ..color = Colors.black.withOpacity(0.04)
            ..strokeWidth = 1.5);
    }
  }

  @override
  bool shouldRepaint(_PaperTexturePainter _) => false;
}

// ═══════════════════════════════════════════════════════════════
// LOADING SCREEN
// ═══════════════════════════════════════════════════════════════
class _WantedLoadingScreen extends StatefulWidget {
  const _WantedLoadingScreen();
  @override
  State<_WantedLoadingScreen> createState() => _WantedLoadingScreenState();
}

class _WantedLoadingScreenState extends State<_WantedLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _a = CurvedAnimation(parent: _c, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kNavy,
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          AnimatedBuilder(
            animation: _a,
            builder: (_, __) => Text('WANTED',
                style: TextStyle(
                  fontFamily: 'PirataOne',
                  color: _kGold.withOpacity(0.3 + 0.7 * _a.value),
                  fontSize: 52,
                  letterSpacing: 8,
                  shadows: [
                    Shadow(
                        color: _kGold.withOpacity(0.4 * _a.value),
                        blurRadius: 20)
                  ],
                )),
          ),
          const SizedBox(height: 16),
          Text('Searching the seas…',
              style: TextStyle(
                  color: _kParchment.withOpacity(0.35), fontSize: 13)),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ERROR SCREEN
// ═══════════════════════════════════════════════════════════════
class _WantedErrorScreen extends StatelessWidget {
  final String? error;
  final VoidCallback onRetry;
  const _WantedErrorScreen({this.error, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kNavy,
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('🏴‍☠️', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text('POSTER NOT FOUND',
              style: TextStyle(
                  fontFamily: 'PirataOne',
                  color: _kGold,
                  fontSize: 24,
                  letterSpacing: 4)),
          const SizedBox(height: 12),
          Text(error ?? 'This pirate has gone missing.',
              style:
                  TextStyle(color: _kParchment.withOpacity(0.5), fontSize: 14),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: _kGold.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('Search Again',
                  style: TextStyle(
                      color: _kGold,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1)),
            ),
          ),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// DELETE CONFIRMATION DIALOG
// ═══════════════════════════════════════════════════════════════
class _WantedConfirmDialog extends StatelessWidget {
  final String name;
  final VoidCallback onConfirm;
  const _WantedConfirmDialog({required this.name, required this.onConfirm});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _kWoodDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: _kCrimson.withOpacity(0.6), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('REMOVE FROM\nWANTED LIST',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'PirataOne',
                  color: _kGoldBright,
                  fontSize: 20,
                  letterSpacing: 2,
                  height: 1.3)),
          const SizedBox(height: 16),
          Text('Tear down $name\'s wanted poster?',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: _kParchment.withOpacity(0.6),
                  fontSize: 13,
                  height: 1.5)),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: _kGold.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('Cancel',
                    style: TextStyle(
                        color: _kParchment.withOpacity(0.6),
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onConfirm,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: _kCrimson.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('Tear It Down',
                    style: TextStyle(
                        color: _kParchment,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

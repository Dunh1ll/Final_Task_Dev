import 'dart:math' as math;
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
// PALETTE
// ═══════════════════════════════════════════════════════════════
const _kParch = Color(0xFFF2D98B);
const _kParchLight = Color(0xFFFAEBBB);
const _kParchDark = Color(0xFFD4A843);
const _kParchMid = Color(0xFFEACF70);
const _kInk = Color(0xFF1A0900);
const _kInkLight = Color(0xFF3B1A08);
const _kCrimson = Color(0xFF8B1111);
const _kGold = Color(0xFFD4A017);
const _kGoldBright = Color(0xFFFFD700);
const _kBrass = Color(0xFFB8860B);
const _kBrassDark = Color(0xFF8B6914);
const _kWood = Color(0xFF3D2010);
const _kWoodLight = Color(0xFF5C3318);
const _kNavy = Color(0xFF050C18);

// ═══════════════════════════════════════════════════════════════
// PROFILE DETAIL SCREEN
// ═══════════════════════════════════════════════════════════════
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

  late AnimationController _entryCtrl;
  late Animation<double> _entryFade;

  late AnimationController _bountyCtrl;
  late Animation<int> _bountyAnim;

  late AnimationController _stampCtrl;
  late Animation<double> _stampScale;
  late Animation<double> _stampOpacity;

  final _mainIds = ['profile_1', 'profile_2', 'profile_3'];

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _entryFade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);

    _bountyCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));
    _bountyAnim = IntTween(begin: 0, end: 0)
        .animate(CurvedAnimation(parent: _bountyCtrl, curve: Curves.easeOut));

    _stampCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _stampScale = Tween<double>(begin: 4.0, end: 1.0)
        .animate(CurvedAnimation(parent: _stampCtrl, curve: Curves.elasticOut));
    _stampOpacity = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _stampCtrl, curve: Curves.easeIn));

    _loadProfile();
  }

  void _startAnimations(UserBase user) {
    _entryCtrl.forward();
    final bounty = _computeBounty(user.name);
    _bountyAnim = IntTween(begin: 0, end: bounty)
        .animate(CurvedAnimation(parent: _bountyCtrl, curve: Curves.easeOut));
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _bountyCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _stampCtrl.forward();
    });
  }

  int _computeBounty(String name) {
    final seed = name.codeUnits.fold(0, (p, e) => p + e);
    return ((seed * 137 + 500) % 900 + 100) * 1000000;
  }

  String _formatBounty(int v) {
    final s = v.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return '\$ $s—';
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _bountyCtrl.dispose();
    _stampCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    if (_mainIds.contains(widget.profileId)) {
      final u = _mainProfile(widget.profileId);
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
      _refresh(auth, local.first);
      return;
    }
    await _fetch(auth);
  }

  Future<void> _refresh(AuthProvider auth, UserBase local) async {
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

  Future<void> _fetch(AuthProvider auth) async {
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
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  UserBase _mainProfile(String id) {
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

  bool get _isMain => _mainIds.contains(widget.profileId);

  bool _canEdit(AuthProvider auth) {
    if (_user == null || _isMain) return false;
    return auth.isMainUser || auth.isOwnProfile(_user!);
  }

  bool _canDelete(AuthProvider auth) => !_isMain && auth.isMainUser;

  void _editProfile(AuthProvider auth) {
    if (_user == null) return;
    showDialog(
      context: context,
      builder: (_) => EditSubUserDialog(
        user: _user!,
        onSave: (data) async {
          final updated = _user!.copyWith(data);
          setState(() => _user = updated);
          auth.updateSubUser(updated);
          _refresh(auth, updated);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Wanted poster updated!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ));
          }
        },
      ),
    );
  }

  void _deleteProfile(AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => _ConfirmDialog(
        name: _user?.name ?? '',
        onConfirm: () async {
          if (_user != null) {
            await auth.apiService.deleteProfile(_user!.id);
            auth.removeSubUser(_user!.id);
          }
          if (mounted) {
            Navigator.pop(context);
            context.pop();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (_isLoading) return const _LoadingScreen();
    if (_error != null || _user == null) {
      return _ErrorScreen(error: _error, onRetry: _loadProfile);
    }
    final user = _user!;

    return Scaffold(
      backgroundColor: _kNavy,
      body: FadeTransition(
        opacity: _entryFade,
        child: Stack(children: [
          // Wood plank background
          Positioned.fill(child: CustomPaint(painter: _WoodPlankPainter())),

          // Main content
          SafeArea(
            child: Column(children: [
              // Nav bar
              _NavBar(
                canEdit: _canEdit(auth),
                canDelete: _canDelete(auth),
                onBack: () => context.pop(),
                onEdit: () => _editProfile(auth),
                onDelete: () => _deleteProfile(auth),
              ),

              // Poster in scrollable area
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: _WantedPoster(
                        user: user,
                        bountyAnim: _bountyAnim,
                        stampScale: _stampScale,
                        stampOpacity: _stampOpacity,
                        formatBounty: _formatBounty,
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// THE WANTED POSTER — matches reference image layout
// ═══════════════════════════════════════════════════════════════
class _WantedPoster extends StatefulWidget {
  final UserBase user;
  final Animation<int> bountyAnim;
  final Animation<double> stampScale, stampOpacity;
  final String Function(int) formatBounty;

  const _WantedPoster({
    required this.user,
    required this.bountyAnim,
    required this.stampScale,
    required this.stampOpacity,
    required this.formatBounty,
  });

  @override
  State<_WantedPoster> createState() => _WantedPosterState();
}

class _WantedPosterState extends State<_WantedPoster> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final narrow = sw < 750;

    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        transform: Matrix4.identity()..translate(0.0, _hov ? -6.0 : 0.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          boxShadow: [
            BoxShadow(
              color: _kGold.withOpacity(_hov ? 0.38 : 0.18),
              blurRadius: _hov ? 55 : 28,
              spreadRadius: _hov ? 4 : 1,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.85),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: Stack(children: [
            // Parchment base
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF5E28A),
                    Color(0xFFEBCE60),
                    Color(0xFFF0D87A),
                    Color(0xFFE6C855),
                    Color(0xFFF3DC88),
                  ],
                  stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                ),
              ),
            ),

            // Paper grain texture
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _PaperGrainPainter()),
              ),
            ),

            // Den Den Mushi (snail) corners — same as reference
            const Positioned(top: 70, left: 10, child: _SnailWidget(size: 42)),
            const Positioned(
                bottom: 55,
                left: 10,
                child: _SnailWidget(size: 34, flipped: true)),

            // Poster body
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── WANTED DEAD OR ALIVE ──────────────────
                  _WantedHeader(),
                  const SizedBox(height: 10),

                  // ── THREE COLUMNS ─────────────────────────
                  narrow
                      ? _NarrowLayout(
                          user: widget.user,
                          bountyAnim: widget.bountyAnim,
                          stampScale: widget.stampScale,
                          stampOpacity: widget.stampOpacity,
                          formatBounty: widget.formatBounty,
                        )
                      : _WideLayout(
                          user: widget.user,
                          bountyAnim: widget.bountyAnim,
                          stampScale: widget.stampScale,
                          stampOpacity: widget.stampOpacity,
                          formatBounty: widget.formatBounty,
                        ),

                  const SizedBox(height: 10),

                  // ── FOOTER: Japanese print + MARINE + Anchor
                  _PosterFooter(),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── WANTED DEAD OR ALIVE HEADER ────────────────────────────────
class _WantedHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _kInk.withOpacity(0.2), width: 1.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Big "WANTED"
          Text('WANTED',
              style: TextStyle(
                fontFamily: 'PirataOne',
                color: _kCrimson,
                fontSize: 80,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
                height: 1.0,
                shadows: [
                  Shadow(
                    color: _kInk.withOpacity(0.45),
                    offset: const Offset(4, 4),
                    blurRadius: 3,
                  ),
                ],
              )),
          const SizedBox(width: 18),
          // "DEAD OR ALIVE" — large, to the right of WANTED
          Expanded(
            child: Text('DEAD OR ALIVE',
                style: TextStyle(
                  fontFamily: 'PirataOne',
                  color: _kCrimson,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  height: 1.0,
                  shadows: [
                    Shadow(
                      color: _kInk.withOpacity(0.4),
                      offset: const Offset(3, 3),
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}

// ── WIDE LAYOUT (3 columns) ─────────────────────────────────────
class _WideLayout extends StatelessWidget {
  final UserBase user;
  final Animation<int> bountyAnim;
  final Animation<double> stampScale, stampOpacity;
  final String Function(int) formatBounty;

  const _WideLayout({
    required this.user,
    required this.bountyAnim,
    required this.stampScale,
    required this.stampOpacity,
    required this.formatBounty,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT — porthole photo + name + bounty
          SizedBox(
            width: 220,
            child: _LeftPanel(
              user: user,
              bountyAnim: bountyAnim,
              stampScale: stampScale,
              stampOpacity: stampOpacity,
              formatBounty: formatBounty,
            ),
          ),
          const SizedBox(width: 16),

          // MIDDLE — Marine logo + Skills scroll
          Expanded(
            flex: 36,
            child: _MiddlePanel(interests: user.interests),
          ),
          const SizedBox(width: 14),

          // RIGHT — Bio + Personal Dossier
          Expanded(
            flex: 44,
            child: _RightPanel(user: user),
          ),
        ],
      ),
    );
  }
}

// ── NARROW LAYOUT (stacked) ─────────────────────────────────────
class _NarrowLayout extends StatelessWidget {
  final UserBase user;
  final Animation<int> bountyAnim;
  final Animation<double> stampScale, stampOpacity;
  final String Function(int) formatBounty;

  const _NarrowLayout({
    required this.user,
    required this.bountyAnim,
    required this.stampScale,
    required this.stampOpacity,
    required this.formatBounty,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _LeftPanel(
        user: user,
        bountyAnim: bountyAnim,
        stampScale: stampScale,
        stampOpacity: stampOpacity,
        formatBounty: formatBounty,
      ),
      const SizedBox(height: 14),
      _MiddlePanel(interests: user.interests),
      const SizedBox(height: 14),
      _RightPanel(user: user),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════
// LEFT PANEL — Porthole + Name + Bounty
// ═══════════════════════════════════════════════════════════════
class _LeftPanel extends StatelessWidget {
  final UserBase user;
  final Animation<int> bountyAnim;
  final Animation<double> stampScale, stampOpacity;
  final String Function(int) formatBounty;

  const _LeftPanel({
    required this.user,
    required this.bountyAnim,
    required this.stampScale,
    required this.stampOpacity,
    required this.formatBounty,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Marine logo at top (like in the reference)
        _MarineEmblem(),
        const SizedBox(height: 8),

        // Brass porthole frame with photo
        _PortholeFrame(user: user),
        const SizedBox(height: 12),

        // Skull and crossbones (exact like reference)
        SizedBox(
          width: 50,
          height: 40,
          child: CustomPaint(painter: _SkullCrossbonesPainter(_kInk)),
        ),
        const SizedBox(height: 8),

        // Name + nickname
        Text(
          user.name.toUpperCase(),
          textAlign: TextAlign.center,
          maxLines: 2,
          style: const TextStyle(
            fontFamily: 'PirataOne',
            color: _kInk,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            height: 1.1,
          ),
        ),

        if (user.work != null && user.work!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            '"${user.work}"',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _kInk.withOpacity(0.55),
              fontSize: 10,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],

        const SizedBox(height: 10),

        // Bounty — animated counter
        _BountyDisplay(
          bountyAnim: bountyAnim,
          formatBounty: formatBounty,
        ),

        const SizedBox(height: 10),

        // Marine stamp — animates in with elastic scale
        AnimatedBuilder(
          animation: stampOpacity,
          builder: (_, __) => Opacity(
            opacity: stampOpacity.value,
            child: Transform.scale(
              scale: stampScale.value,
              child: Transform.rotate(
                angle: -0.22,
                child: _MarineStamp(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── PORTHOLE FRAME ─────────────────────────────────────────────
class _PortholeFrame extends StatelessWidget {
  final UserBase user;
  const _PortholeFrame({required this.user});

  @override
  Widget build(BuildContext context) {
    const double size = 178;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(alignment: Alignment.center, children: [
        // Outer brass ring gradient
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [
                Color(0xFFE8C040),
                Color(0xFFB8860B),
                Color(0xFF8B6914),
                Color(0xFF5C4010),
                Color(0xFF3A2A08),
              ],
              stops: [0.0, 0.5, 0.72, 0.88, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 16,
                  spreadRadius: 3),
              BoxShadow(
                  color: const Color(0xFFE8C040).withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: -4),
            ],
          ),
        ),

        // Brass bolts — 8 evenly spaced around the ring
        ...List.generate(8, (i) {
          final a = i * math.pi / 4;
          const r = 77.0;
          return Positioned(
            left: size / 2 + r * math.cos(a) - 6,
            top: size / 2 + r * math.sin(a) - 6,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3A2A08),
                border: Border.all(color: const Color(0xFFE8C040), width: 1.5),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 3)
                ],
              ),
            ),
          );
        }),

        // Dark porthole inner ring
        Container(
          width: 148,
          height: 148,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF0D0800),
          ),
        ),

        // Sepia/greyscale photo
        ClipOval(
          child: SizedBox(
            width: 138,
            height: 138,
            child: ColorFiltered(
              // Sepia filter matrix — exactly like reference image
              colorFilter: const ColorFilter.matrix([
                0.393,
                0.769,
                0.189,
                0,
                0,
                0.349,
                0.686,
                0.168,
                0,
                0,
                0.272,
                0.534,
                0.131,
                0,
                0,
                0,
                0,
                0,
                1,
                0,
              ]),
              child: Image(
                image: ImageHelper.buildProvider(
                  user.profilePicture,
                  AssetPaths.defaultAvatar,
                  bytes: user.profilePictureBytes,
                ),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF8B7040),
                  child: const Icon(Icons.person_rounded,
                      color: Color(0xFF3A2010), size: 68),
                ),
              ),
            ),
          ),
        ),

        // Inner brass rim
        Container(
          width: 148,
          height: 148,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: const Color(0xFFB8860B).withOpacity(0.5), width: 2.5),
          ),
        ),
      ]),
    );
  }
}

// ── BOUNTY DISPLAY ─────────────────────────────────────────────
class _BountyDisplay extends StatelessWidget {
  final Animation<int> bountyAnim;
  final String Function(int) formatBounty;
  const _BountyDisplay({required this.bountyAnim, required this.formatBounty});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        border: Border.all(color: _kInk.withOpacity(0.4), width: 1.5),
        color: const Color(0xFFEBC850).withOpacity(0.4),
      ),
      child: Column(children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Berry symbol (฿ styled like reference)
            Text('\$',
                style: const TextStyle(
                  fontFamily: 'PirataOne',
                  color: _kInk,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                )),
            const SizedBox(width: 4),
            AnimatedBuilder(
              animation: bountyAnim,
              builder: (_, __) => Text(
                _numOnly(formatBounty(bountyAnim.value)),
                style: const TextStyle(
                  fontFamily: 'PirataOne',
                  color: _kInk,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        Text('SKILLS',
            style: TextStyle(
              color: _kInk.withOpacity(0.45),
              fontSize: 7,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
            )),
      ]),
    );
  }

  String _numOnly(String s) => s.replaceAll('\$ ', '');
}

// ── MARINE EMBLEM ──────────────────────────────────────────────
class _MarineEmblem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Seagull wings
        SizedBox(
          width: 38,
          height: 22,
          child: CustomPaint(painter: _SeagullPainter(_kInk.withOpacity(0.7))),
        ),
        const SizedBox(height: 2),
        Text('MARINE',
            style: TextStyle(
              color: _kInk.withOpacity(0.65),
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
            )),
      ],
    );
  }
}

// ── MARINE STAMP ───────────────────────────────────────────────
class _MarineStamp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _kCrimson.withOpacity(0.72), width: 3.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('MARINE',
              style: TextStyle(
                color: _kCrimson.withOpacity(0.72),
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              )),
          const SizedBox(height: 1),
          SizedBox(
            width: 20,
            height: 16,
            child: CustomPaint(
                painter: _SkullCrossbonesPainter(_kCrimson.withOpacity(0.65))),
          ),
          Text('VERIFIED',
              style: TextStyle(
                color: _kCrimson.withOpacity(0.72),
                fontSize: 6,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              )),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MIDDLE PANEL — Marine logo + SKILLS scroll
// ═══════════════════════════════════════════════════════════════
class _MiddlePanel extends StatelessWidget {
  final List<String> interests;
  const _MiddlePanel({required this.interests});

  @override
  Widget build(BuildContext context) {
    final skills = interests.isNotEmpty ? interests : ['(No skills listed)'];

    return Column(
      children: [
        // Marine logo — centered, like in reference image
        Column(children: [
          SizedBox(
            width: 50,
            height: 30,
            child:
                CustomPaint(painter: _SeagullPainter(_kInk.withOpacity(0.65))),
          ),
          Text('MARINE',
              style: TextStyle(
                color: _kInk.withOpacity(0.6),
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              )),
        ]),
        const SizedBox(height: 8),

        // Skills parchment scroll
        Expanded(
          child: _ParchmentScroll(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // SKILLS header in bordered box
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: _kInk.withOpacity(0.55), width: 1.5),
                  ),
                  child: Text('SKILLS',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'PirataOne',
                        color: _kInk,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                      )),
                ),
                const SizedBox(height: 14),

                // Each skill — centered, bold, like reference
                ...skills.map((s) => _SkillLine(label: s)),

                const Spacer(),

                // Skull at the bottom — same as reference
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: SizedBox(
                    width: 44,
                    height: 35,
                    child: CustomPaint(
                        painter:
                            _SkullCrossbonesPainter(_kInk.withOpacity(0.35))),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SkillLine extends StatefulWidget {
  final String label;
  const _SkillLine({required this.label});
  @override
  State<_SkillLine> createState() => _SkillLineState();
}

class _SkillLineState extends State<_SkillLine> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        transform: Matrix4.translationValues(_h ? 5 : 0, 0, 0),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Text(
          widget.label.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'PirataOne',
            color: _kInk.withOpacity(_h ? 1.0 : 0.78),
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// RIGHT PANEL — BIO + PERSONAL DOSSIER
// ═══════════════════════════════════════════════════════════════
class _RightPanel extends StatelessWidget {
  final UserBase user;
  const _RightPanel({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // BIO scroll — top
        _ParchmentScroll(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ScrollHeader(label: 'BIO'),
              const SizedBox(height: 8),
              Text(
                (user.bio != null && user.bio!.isNotEmpty)
                    ? user.bio!
                    : '${user.name} — a mysterious soul whose legend echoes across the Grand Line.',
                style: const TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  color: _kInk,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  height: 1.7,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // PERSONAL DOSSIER scroll — bottom
        _ParchmentScroll(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with emoji icons — same as reference
              Row(children: [
                const Text('🌍', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('PERSONAL DOSSIER',
                      style: TextStyle(
                        fontFamily: 'PirataOne',
                        color: _kInk,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      )),
                ),
                const Text('🧭', style: TextStyle(fontSize: 14)),
              ]),
              Container(
                margin: const EdgeInsets.only(top: 4, bottom: 10),
                height: 1.5,
                color: _kInk.withOpacity(0.3),
              ),

              // DETAILS & STATUS
              _DossierSection(label: 'DETAILS & STATUS'),
              const SizedBox(height: 6),
              Wrap(
                spacing: 14,
                runSpacing: 4,
                children: [
                  if (user.age != null)
                    _DossierChip('🎂', 'Age', '${user.age}'),
                  if (user.gender != null && user.gender!.isNotEmpty)
                    _DossierChip('⚧', 'Gender', user.gender!),
                  if (user.birthday != null)
                    _DossierChip('📅', 'Birthday',
                        DateFormat('dd MMM').format(user.birthday!)),
                  if (user.yearLevel != null && user.yearLevel!.isNotEmpty)
                    _DossierChip('🎓', 'Year Level', user.yearLevel!),
                  if (user.relationshipStatus != null &&
                      user.relationshipStatus!.isNotEmpty)
                    _DossierChip(
                        '💔', 'Relationship Status', user.relationshipStatus!),
                  if (user.hometown != null && user.hometown!.isNotEmpty)
                    _DossierChip('📍', 'Hometown/Location', user.hometown!),
                ],
              ),

              const SizedBox(height: 10),

              // HISTORY & CAREER
              _DossierSection(label: 'HISTORY & CAREER'),
              const SizedBox(height: 6),
              if (user.education != null && user.education!.isNotEmpty)
                _DossierRow('Education', user.education!),
              if (user.work != null && user.work!.isNotEmpty)
                _DossierRow('Work', user.work!),
              if ((user.education == null || user.education!.isEmpty) &&
                  (user.work == null || user.work!.isEmpty))
                Text('Records classified by the World Government.',
                    style: TextStyle(
                      color: _kInk.withOpacity(0.4),
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                    )),

              const SizedBox(height: 10),

              // CONTACT SIGNALS
              _DossierSection(label: 'CONTACT SIGNALS'),
              const SizedBox(height: 6),
              if (user.email != null && user.email!.isNotEmpty)
                _ContactRow('🐌', 'Snail Post', user.email!),
              if (user.phone != null && user.phone!.isNotEmpty)
                _ContactRow('📻', 'Den Den Mushi', user.phone!),
              if ((user.email == null || user.email!.isEmpty) &&
                  (user.phone == null || user.phone!.isEmpty))
                Text('Whereabouts unknown.',
                    style: TextStyle(
                      color: _kInk.withOpacity(0.4),
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                    )),
            ],
          ),
        ),
      ],
    );
  }
}

// ── PARCHMENT SCROLL CONTAINER ─────────────────────────────────
class _ParchmentScroll extends StatelessWidget {
  final Widget child;
  const _ParchmentScroll({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8ECA0),
            Color(0xFFEDD870),
            Color(0xFFF2E285),
            Color(0xFFE8D260),
          ],
        ),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: _kInk.withOpacity(0.45), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _kInk.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ── SCROLL HEADER ──────────────────────────────────────────────
class _ScrollHeader extends StatelessWidget {
  final String label;
  const _ScrollHeader({required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
            fontFamily: 'PirataOne',
            color: _kInk,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          )),
      Container(
        margin: const EdgeInsets.only(top: 3),
        width: 36,
        height: 2,
        color: _kInk.withOpacity(0.4),
      ),
    ]);
  }
}

// ── DOSSIER SECTION HEADER ─────────────────────────────────────
class _DossierSection extends StatelessWidget {
  final String label;
  const _DossierSection({required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
            fontFamily: 'PirataOne',
            color: _kInk,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          )),
      Container(
        margin: const EdgeInsets.only(top: 2),
        width: 55,
        height: 1.5,
        color: _kInk.withOpacity(0.22),
      ),
    ]);
  }
}

// ── DOSSIER CHIPS (Details & Status row items) ─────────────────
class _DossierChip extends StatelessWidget {
  final String emoji, label, value;
  const _DossierChip(this.emoji, this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text(emoji, style: const TextStyle(fontSize: 11)),
      const SizedBox(width: 3),
      RichText(
        text: TextSpan(children: [
          TextSpan(
              text: '$label: ',
              style: TextStyle(
                color: _kInk.withOpacity(0.5),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              )),
          TextSpan(
              text: value,
              style: const TextStyle(
                color: _kInk,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              )),
        ]),
      ),
    ]);
  }
}

// ── DOSSIER ROW (History & Career) ─────────────────────────────
class _DossierRow extends StatelessWidget {
  final String label, value;
  const _DossierRow(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(children: [
          TextSpan(
              text: '$label: ',
              style: TextStyle(
                color: _kInk.withOpacity(0.5),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              )),
          TextSpan(
              text: value,
              style: const TextStyle(
                color: _kInk,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              )),
        ]),
      ),
    );
  }
}

// ── CONTACT ROW (with snail/radio prefix) ──────────────────────
class _ContactRow extends StatelessWidget {
  final String emoji, label, value;
  const _ContactRow(this.emoji, this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(emoji, style: const TextStyle(fontSize: 11)),
        const SizedBox(width: 4),
        Text('[$label] ',
            style: TextStyle(
              color: _kInk.withOpacity(0.5),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            )),
        Expanded(
          child: Text(value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _kInk,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              )),
        ),
      ]),
    );
  }
}

// ── POSTER FOOTER ──────────────────────────────────────────────
class _PosterFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: _kInk.withOpacity(0.2), width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Japanese fine print — exactly like reference
          Expanded(
            child: Text(
              'KONO SAKUHIN WA FICTION DE JITSUZAISURU JINBUTSU DANTAI\n'
              'SONOTA NO SOSHKI TO DOITSO NO MASHOU GA GEKICHU NI TOUJYOU\n'
              'SHITATOSHITEMO JITSUZAI NA MONOTO WA ISSAI MUKANKEIDETH.',
              style: TextStyle(
                color: _kInk.withOpacity(0.4),
                fontSize: 7,
                height: 1.5,
                letterSpacing: 0.3,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // MARINE bold text
          Text('MARINE',
              style: TextStyle(
                fontFamily: 'PirataOne',
                color: _kInk.withOpacity(0.8),
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              )),

          const SizedBox(width: 10),

          // Anchor icon
          SizedBox(
            width: 34,
            height: 44,
            child:
                CustomPaint(painter: _AnchorPainter(_kInk.withOpacity(0.65))),
          ),
        ],
      ),
    );
  }
}

// ── SNAIL WIDGET ───────────────────────────────────────────────
class _SnailWidget extends StatelessWidget {
  final double size;
  final bool flipped;
  const _SnailWidget({required this.size, this.flipped = false});
  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: flipped ? -1 : 1,
      child: Text('🐌', style: TextStyle(fontSize: size * 0.65)),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// NAV BAR
// ═══════════════════════════════════════════════════════════════
class _NavBar extends StatelessWidget {
  final bool canEdit, canDelete;
  final VoidCallback onBack, onEdit, onDelete;
  const _NavBar({
    required this.canEdit,
    required this.canDelete,
    required this.onBack,
    required this.onEdit,
    required this.onDelete,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(children: [
        _NavBtn(
            icon: Icons.arrow_back_ios_new_rounded,
            label: 'Back',
            onTap: onBack),
        const Spacer(),
        Text('MARINE HQ  ·  WANTED RECORDS',
            style: TextStyle(
              fontFamily: 'PirataOne',
              color: _kGold.withOpacity(0.65),
              fontSize: 11,
              letterSpacing: 3,
            )),
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
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: _h ? c.withOpacity(0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
                color: _h ? c.withOpacity(0.6) : c.withOpacity(0.22)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(widget.icon, color: _h ? c : c.withOpacity(0.5), size: 13),
            const SizedBox(width: 5),
            Text(widget.label,
                style: TextStyle(
                  color: _h ? c : c.withOpacity(0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                )),
          ]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CUSTOM PAINTERS
// ═══════════════════════════════════════════════════════════════
class _WoodPlankPainter extends CustomPainter {
  static final _rng = math.Random(31);
  @override
  void paint(Canvas canvas, Size s) {
    // Base dark brown
    canvas.drawRect(Rect.fromLTWH(0, 0, s.width, s.height),
        Paint()..color = const Color(0xFF2C1508));

    // Wood grain lines — horizontal
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (int i = 0; i < 60; i++) {
      final y = _rng.nextDouble() * s.height;
      p.color = Color.lerp(const Color(0xFF1A0A00), const Color(0xFF5C3318),
              _rng.nextDouble())!
          .withOpacity(0.55);
      final path = Path()..moveTo(0, y);
      double x = 0;
      while (x < s.width) {
        x += 30 + _rng.nextDouble() * 70;
        path.lineTo(x, y + (_rng.nextDouble() * 5 - 2.5));
      }
      canvas.drawPath(path, p);
    }

    // Plank dividers
    final dp = Paint()
      ..color = const Color(0xFF0D0500)
      ..strokeWidth = 2.5;
    final ph = s.height / 4;
    for (int i = 1; i < 4; i++) {
      canvas.drawLine(Offset(0, ph * i), Offset(s.width, ph * i), dp);
    }

    // Knot holes
    for (int i = 0; i < 5; i++) {
      final kx = _rng.nextDouble() * s.width;
      final ky = _rng.nextDouble() * s.height;
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(kx, ky),
            width: 18 + _rng.nextDouble() * 14,
            height: 10 + _rng.nextDouble() * 8),
        Paint()..color = const Color(0xFF100500).withOpacity(0.4),
      );
    }
  }

  @override
  bool shouldRepaint(_WoodPlankPainter _) => false;
}

class _PaperGrainPainter extends CustomPainter {
  static final _rng = math.Random(55);
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 2000; i++) {
      p.color = Colors.black.withOpacity(_rng.nextDouble() * 0.022);
      canvas.drawCircle(
          Offset(_rng.nextDouble() * s.width, _rng.nextDouble() * s.height),
          0.55,
          p);
    }
    // Age spots
    for (int i = 0; i < 14; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center:
              Offset(_rng.nextDouble() * s.width, _rng.nextDouble() * s.height),
          width: 6 + _rng.nextDouble() * 16,
          height: 4 + _rng.nextDouble() * 10,
        ),
        Paint()..color = const Color(0xFF8B6020).withOpacity(0.05),
      );
    }
  }

  @override
  bool shouldRepaint(_PaperGrainPainter _) => false;
}

class _SkullCrossbonesPainter extends CustomPainter {
  final Color color;
  const _SkullCrossbonesPainter(this.color);
  @override
  void paint(Canvas canvas, Size s) {
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width * 0.05
      ..strokeCap = StrokeCap.round;

    // Skull dome
    canvas.drawOval(
        Rect.fromLTWH(s.width * 0.18, 0, s.width * 0.64, s.height * 0.60),
        fill);
    // Jaw
    canvas.drawRect(
        Rect.fromLTWH(
            s.width * 0.24, s.height * 0.44, s.width * 0.52, s.height * 0.28),
        fill);

    // Eye sockets (cutout)
    final bg = Paint()
      ..color = const Color(0xFFF2D98B)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
        Rect.fromLTWH(
            s.width * 0.26, s.height * 0.12, s.width * 0.18, s.height * 0.22),
        bg);
    canvas.drawOval(
        Rect.fromLTWH(
            s.width * 0.56, s.height * 0.12, s.width * 0.18, s.height * 0.22),
        bg);

    // Teeth gaps
    for (int i = 0; i < 4; i++) {
      canvas.drawRect(
          Rect.fromLTWH(s.width * (0.28 + i * 0.12), s.height * 0.56,
              s.width * 0.07, s.height * 0.13),
          bg);
    }

    // Crossbones
    canvas.drawLine(
        Offset(0, s.height * 0.82), Offset(s.width, s.height * 0.98), stroke);
    canvas.drawLine(
        Offset(0, s.height * 0.98), Offset(s.width, s.height * 0.82), stroke);
    // Bone ends
    for (final o in [
      Offset(0, s.height * 0.90),
      Offset(s.width, s.height * 0.90),
    ]) {
      canvas.drawCircle(o, s.width * 0.07, fill);
    }
  }

  @override
  bool shouldRepaint(_SkullCrossbonesPainter o) => o.color != color;
}

class _SeagullPainter extends CustomPainter {
  final Color color;
  const _SeagullPainter(this.color);
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.height * 0.14
      ..strokeCap = StrokeCap.round;
    // Left wing
    final left = Path()
      ..moveTo(s.width * 0.5, s.height * 0.45)
      ..quadraticBezierTo(s.width * 0.28, s.height * 0.1, 0, s.height * 0.4);
    canvas.drawPath(left, p);
    // Right wing
    final right = Path()
      ..moveTo(s.width * 0.5, s.height * 0.45)
      ..quadraticBezierTo(
          s.width * 0.72, s.height * 0.1, s.width, s.height * 0.4);
    canvas.drawPath(right, p);
  }

  @override
  bool shouldRepaint(_SeagullPainter o) => o.color != color;
}

class _AnchorPainter extends CustomPainter {
  final Color color;
  const _AnchorPainter(this.color);
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width * 0.12
      ..strokeCap = StrokeCap.round;
    final cx = s.width / 2;
    canvas.drawLine(
        Offset(cx, s.height * 0.12), Offset(cx, s.height * 0.88), p);
    canvas.drawCircle(Offset(cx, s.height * 0.20), s.width * 0.13, p);
    canvas.drawLine(Offset(cx - s.width * 0.34, s.height * 0.34),
        Offset(cx + s.width * 0.34, s.height * 0.34), p);
    canvas.drawArc(
        Rect.fromLTWH(
            s.width * 0.08, s.height * 0.42, s.width * 0.84, s.height * 0.44),
        math.pi,
        math.pi / 2,
        false,
        p);
    canvas.drawArc(
        Rect.fromLTWH(
            s.width * 0.08, s.height * 0.42, s.width * 0.84, s.height * 0.44),
        0,
        -math.pi / 2,
        false,
        p);
  }

  @override
  bool shouldRepaint(_AnchorPainter o) => o.color != color;
}

// ═══════════════════════════════════════════════════════════════
// LOADING / ERROR / CONFIRM DIALOG
// ═══════════════════════════════════════════════════════════════
class _LoadingScreen extends StatefulWidget {
  const _LoadingScreen();
  @override
  State<_LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<_LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
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
                  color: _kParchLight.withOpacity(0.35), fontSize: 13)),
        ]),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final String? error;
  final VoidCallback onRetry;
  const _ErrorScreen({this.error, required this.onRetry});
  @override
  Widget build(BuildContext context) => Scaffold(
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
                style: TextStyle(
                    color: _kParchLight.withOpacity(0.5), fontSize: 14),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: _kGold.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(3),
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

class _ConfirmDialog extends StatelessWidget {
  final String name;
  final VoidCallback onConfirm;
  const _ConfirmDialog({required this.name, required this.onConfirm});
  @override
  Widget build(BuildContext context) => Dialog(
        backgroundColor: const Color(0xFF2C1A00),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
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
            const SizedBox(height: 14),
            Text('Tear down $name\'s wanted poster?',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _kParchLight.withOpacity(0.6),
                    fontSize: 13,
                    height: 1.5)),
            const SizedBox(height: 22),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: _kGold.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text('Cancel',
                      style: TextStyle(
                          color: _kParchLight.withOpacity(0.6),
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
                    color: _kCrimson.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Text('Tear It Down',
                      style: TextStyle(
                          color: _kParchLight,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ]),
        ),
      );
}

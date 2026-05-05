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
const _kParchLight = Color(0xFFFAEBBB);
const _kInk = Color(0xFF1A0900);
const _kCrimson = Color(0xFF8B1111);
const _kGold = Color(0xFFD4A017);
const _kGoldBright = Color(0xFFFFD700);
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
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _stampCtrl.forward();
    });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
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
              content: Text('✅ Wanted poster updated!'),
              backgroundColor: _kCrimson,
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

          SafeArea(
            child: Column(children: [
              _NavBar(
                canEdit: _canEdit(auth),
                canDelete: _canDelete(auth),
                onBack: () => context.pop(),
                onEdit: () => _editProfile(auth),
                onDelete: () => _deleteProfile(auth),
              ),

              // ── Poster — fills remaining space, NO scroll ──
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1160),
                      child: _WantedPoster(
                        user: user,
                        stampScale: _stampScale,
                        stampOpacity: _stampOpacity,
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
// WANTED POSTER — static, fills available height
// ═══════════════════════════════════════════════════════════════
class _WantedPoster extends StatelessWidget {
  final UserBase user;
  final Animation<double> stampScale, stampOpacity;

  const _WantedPoster({
    required this.user,
    required this.stampScale,
    required this.stampOpacity,
  });

  @override
  Widget build(BuildContext context) {
    // sub_cover.png is 577×433 → ratio ~1.33 (4:3 landscape)
    // We use it as the parchment background of the whole poster.
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        boxShadow: [
          BoxShadow(
            color: _kGold.withOpacity(0.22),
            blurRadius: 32,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.85),
            blurRadius: 40,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Stack(fit: StackFit.expand, children: [
          // ── BACKGROUND: sub_cover.png parchment image ──────
          Image.asset(
            'assets/images/sub_cover.png',
            fit: BoxFit.cover, // fills the poster completely
            alignment: Alignment.center,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFFD4A843),
            ),
          ),

          // ── Subtle dark overlay so text stays readable ──────
          Container(color: Colors.black.withOpacity(0.08)),

          // ── Paper grain texture on top of image ────────────
          IgnorePointer(child: CustomPaint(painter: _PaperGrainPainter())),

          // ── Den Den Mushi corners ───────────────────────────
          const Positioned(top: 52, left: 8, child: _SnailWidget(size: 40)),
          const Positioned(
              bottom: 42,
              left: 8,
              child: _SnailWidget(size: 32, flipped: true)),

          // ── All poster content ──────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(48, 0, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // WANTED DEAD OR ALIVE
                _WantedHeader(),
                const SizedBox(height: 6),

                // Three columns — expanded to fill height
                Expanded(
                  child: _WideLayout(
                    user: user,
                    stampScale: stampScale,
                    stampOpacity: stampOpacity,
                  ),
                ),

                const SizedBox(height: 6),
                _PosterFooter(),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

// ── WANTED DEAD OR ALIVE HEADER ────────────────────────────────
class _WantedHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _kInk.withOpacity(0.25), width: 1.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('WANTED',
              style: TextStyle(
                fontFamily: 'PirataOne',
                color: _kCrimson,
                fontSize: 72,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
                height: 1.0,
                shadows: [
                  Shadow(
                      color: _kInk.withOpacity(0.45),
                      offset: const Offset(3, 3),
                      blurRadius: 2),
                ],
              )),
          const SizedBox(width: 16),
          Expanded(
            child: Text('DEAD OR ALIVE',
                style: TextStyle(
                  fontFamily: 'PirataOne',
                  color: _kCrimson,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  height: 1.0,
                  shadows: [
                    Shadow(
                        color: _kInk.withOpacity(0.4),
                        offset: const Offset(2, 2)),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}

// ── WIDE LAYOUT — 3 columns, fills height ──────────────────────
// Column order (left→right): Photo | Dossier (wide) | Skills (narrow)
// Dossier is wider than Skills because it has more info.
class _WideLayout extends StatelessWidget {
  final UserBase user;
  final Animation<double> stampScale, stampOpacity;

  const _WideLayout({
    required this.user,
    required this.stampScale,
    required this.stampOpacity,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // LEFT — photo panel
        SizedBox(
          width: 240,
          child: _LeftPanel(
            user: user,
            stampScale: stampScale,
            stampOpacity: stampOpacity,
          ),
        ),
        const SizedBox(width: 12),

        // MIDDLE — Personal Dossier (WIDER — more info)
        // Swapped: Dossier is now in the middle (larger column)
        Expanded(
          flex: 52,
          child: _DossierPanel(user: user),
        ),
        const SizedBox(width: 12),

        // RIGHT — Skills (narrower)
        Expanded(
          flex: 30,
          child: _SkillsPanel(interests: user.interests),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// LEFT PANEL — Photo + name BELOW photo + bounty
// ═══════════════════════════════════════════════════════════════
class _LeftPanel extends StatelessWidget {
  final UserBase user;
  final Animation<double> stampScale, stampOpacity;

  const _LeftPanel({
    required this.user,
    required this.stampScale,
    required this.stampOpacity,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _MarineEmblem(),
        const SizedBox(height: 6),

        // Porthole frame
        _PortholeFrame(user: user),

        // ── NAME directly below photo (as requested) ──────────
        const SizedBox(height: 8),
        Text(
          user.name.toUpperCase(),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'PirataOne',
            color: _kInk,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            height: 1.15,
          ),
        ),

        const SizedBox(height: 6),

        // Skull crossbones
        SizedBox(
          width: 44,
          height: 34,
          child: CustomPaint(painter: _SkullCrossbonesPainter(_kInk)),
        ),

        const Spacer(),

        // Marine stamp
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
        const SizedBox(height: 6),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// DOSSIER PANEL — Bio + Personal Dossier (WIDER column, MIDDLE)
// Has push pin at top
// ═══════════════════════════════════════════════════════════════
class _DossierPanel extends StatelessWidget {
  final UserBase user;
  const _DossierPanel({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // BIO — with push pin
        Flexible(
          flex: 3,
          child: _PinnedScroll(
            pinColor: _kCrimson,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ScrollHeader(label: 'BIO'),
                const SizedBox(height: 6),
                Expanded(
                  child: Text(
                    (user.bio != null && user.bio!.isNotEmpty)
                        ? user.bio!
                        : '${user.name} — a mysterious soul whose legend echoes across the Grand Line.',
                    style: const TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      color: _kInk,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      height: 1.65,
                    ),
                    overflow: TextOverflow.fade,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        // PERSONAL DOSSIER — with push pin, gets most of the space
        Flexible(
          flex: 7,
          child: _PinnedScroll(
            pinColor: _kGold,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with globe + compass
                Row(children: [
                  const Text('🌊', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text('PERSONAL DOSSIER',
                        style: TextStyle(
                          fontFamily: 'PirataOne',
                          color: _kInk,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        )),
                  ),
                  const Text('🧭', style: TextStyle(fontSize: 13)),
                ]),
                Container(
                  margin: const EdgeInsets.only(top: 3, bottom: 8),
                  height: 1.5,
                  color: _kInk.withOpacity(0.3),
                ),

                // DETAILS & STATUS
                _DossierSection(label: 'DETAILS & STATUS'),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 12,
                  runSpacing: 3,
                  children: [
                    if (user.age != null)
                      _DossierChip('⚔️', 'Age', '${user.age}'),
                    if (user.gender != null && user.gender!.isNotEmpty)
                      _DossierChip('🏴‍☠️', 'Gender', user.gender!),
                    if (user.birthday != null)
                      _DossierChip('🗓️', 'Birthday',
                          DateFormat('dd MMM').format(user.birthday!)),
                    if (user.yearLevel != null && user.yearLevel!.isNotEmpty)
                      _DossierChip('⚓', 'Year Level', user.yearLevel!),
                    if (user.relationshipStatus != null &&
                        user.relationshipStatus!.isNotEmpty)
                      _DossierChip('🪝', 'Status', user.relationshipStatus!),
                    if (user.hometown != null && user.hometown!.isNotEmpty)
                      _DossierChip('🗺️', 'Hometown', user.hometown!),
                  ],
                ),

                const SizedBox(height: 8),

                // HISTORY & CAREER
                _DossierSection(label: 'HISTORY & CAREER'),
                const SizedBox(height: 5),
                if (user.education != null && user.education!.isNotEmpty)
                  _DossierRow('Education', user.education!),
                if (user.work != null && user.work!.isNotEmpty)
                  _DossierRow('Work', user.work!),
                if ((user.education == null || user.education!.isEmpty) &&
                    (user.work == null || user.work!.isEmpty))
                  Text('Classified by the World Government.',
                      style: TextStyle(
                        color: _kInk.withOpacity(0.4),
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                      )),

                const SizedBox(height: 8),

                // CONTACT SIGNALS
                _DossierSection(label: 'CONTACT SIGNALS'),
                const SizedBox(height: 5),
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
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SKILLS PANEL — with push pin, narrower column on the right
// ═══════════════════════════════════════════════════════════════
class _SkillsPanel extends StatelessWidget {
  final List<String> interests;
  const _SkillsPanel({required this.interests});

  @override
  Widget build(BuildContext context) {
    final skills = interests.isNotEmpty ? interests : ['(No skills listed)'];

    return Column(
      children: [
        // Marine logo
        _MarineEmblem(),
        const SizedBox(height: 6),

        // Skills scroll — fills remaining height
        Expanded(
          child: _PinnedScroll(
            pinColor: const Color(0xFF2E86C1), // blue pin for variety
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // SKILLS header in box
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: _kInk.withOpacity(0.55), width: 1.5),
                  ),
                  child: const Text('SKILLS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'PirataOne',
                        color: _kInk,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                      )),
                ),
                const SizedBox(height: 10),

                // Skills list — no hover effect (removed as requested)
                ...skills.map((s) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        s.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PirataOne',
                          color: _kInk.withOpacity(0.82),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          height: 1.3,
                        ),
                      ),
                    )),

                const Spacer(),

                // Skull at bottom
                SizedBox(
                  width: 38,
                  height: 30,
                  child: CustomPaint(
                      painter: _SkullCrossbonesPainter(_kInk.withOpacity(0.3))),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PINNED SCROLL — parchment card with a push pin at the top center
// ═══════════════════════════════════════════════════════════════
class _PinnedScroll extends StatelessWidget {
  final Widget child;
  final Color pinColor;
  const _PinnedScroll({required this.child, required this.pinColor});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // The parchment card
        Container(
          margin: const EdgeInsets.only(top: 10), // room for pin
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
          decoration: BoxDecoration(
            // Slightly lighter parchment than the background image
            color: const Color(0xFFF5E8A0).withOpacity(0.82),
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: _kInk.withOpacity(0.40), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: _kInk.withOpacity(0.22),
                blurRadius: 8,
                offset: const Offset(3, 4),
              ),
            ],
          ),
          child: child,
        ),

        // Push pin — centered at top, overlapping the card edge
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Center(
            child: _PushPin(color: pinColor),
          ),
        ),
      ],
    );
  }
}

// ── PUSH PIN WIDGET ────────────────────────────────────────────
class _PushPin extends StatelessWidget {
  final Color color;
  const _PushPin({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 22,
      child: CustomPaint(painter: _PushPinPainter(color)),
    );
  }
}

class _PushPinPainter extends CustomPainter {
  final Color color;
  const _PushPinPainter(this.color);

  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;

    // Shadow
    final shadow = Paint()
      ..color = Colors.black.withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(Offset(cx + 1, 7), 7, shadow);

    // Pin head — circular metallic cap
    final headFill = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.4),
        radius: 0.8,
        colors: [
          Color.lerp(color, Colors.white, 0.55)!,
          color,
          Color.lerp(color, Colors.black, 0.35)!,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, 6), radius: 7));
    canvas.drawCircle(Offset(cx, 6), 7, headFill);

    // Pin head rim
    canvas.drawCircle(
      Offset(cx, 6),
      7,
      Paint()
        ..color = Color.lerp(color, Colors.black, 0.4)!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // Pin needle
    final needle = Paint()
      ..color = const Color(0xFFBBBBBB)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, 12), Offset(cx, s.height), needle);

    // Needle tip (darker)
    canvas.drawLine(
      Offset(cx, s.height - 3),
      Offset(cx, s.height),
      Paint()
        ..color = const Color(0xFF888888)
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round,
    );

    // Highlight on pin head
    canvas.drawCircle(
      Offset(cx - 2.5, 3.5),
      2.2,
      Paint()..color = Colors.white.withOpacity(0.55),
    );
  }

  @override
  bool shouldRepaint(_PushPinPainter o) => o.color != color;
}

// ── PORTHOLE FRAME ─────────────────────────────────────────────
class _PortholeFrame extends StatelessWidget {
  final UserBase user;
  const _PortholeFrame({required this.user});

  @override
  Widget build(BuildContext context) {
    const double size = 210;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(alignment: Alignment.center, children: [
        // Outer brass ring
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
                  blurRadius: 14,
                  spreadRadius: 2),
            ],
          ),
        ),

        // Brass bolts
        ...List.generate(8, (i) {
          final a = i * math.pi / 4;
          const r = 90.0;
          return Positioned(
            left: size / 2 + r * math.cos(a) - 5,
            top: size / 2 + r * math.sin(a) - 5,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3A2A08),
                border: Border.all(color: const Color(0xFFE8C040), width: 1.5),
              ),
            ),
          );
        }),

        // Dark inner ring
        Container(
          width: 176,
          height: 176,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF0D0800),
          ),
        ),

        // Sepia photo
        ClipOval(
          child: SizedBox(
            width: 162,
            height: 162,
            child: ColorFiltered(
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
                      color: Color(0xFF3A2010), size: 60),
                ),
              ),
            ),
          ),
        ),

        // Inner brass rim
        Container(
          width: 176,
          height: 176,
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

// ── MARINE EMBLEM ──────────────────────────────────────────────
class _MarineEmblem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        width: 34,
        height: 20,
        child: CustomPaint(painter: _SeagullPainter(_kInk.withOpacity(0.7))),
      ),
      const SizedBox(height: 1),
      Text('MARINE',
          style: TextStyle(
            color: _kInk.withOpacity(0.65),
            fontSize: 7,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          )),
    ]);
  }
}

// ── MARINE STAMP ───────────────────────────────────────────────
class _MarineStamp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _kCrimson.withOpacity(0.72), width: 3),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('MARINE',
            style: TextStyle(
              color: _kCrimson.withOpacity(0.72),
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            )),
        const SizedBox(height: 1),
        SizedBox(
            width: 18,
            height: 14,
            child: CustomPaint(
                painter: _SkullCrossbonesPainter(_kCrimson.withOpacity(0.65)))),
        Text('VERIFIED',
            style: TextStyle(
              color: _kCrimson.withOpacity(0.72),
              fontSize: 5,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            )),
      ]),
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
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          )),
      Container(
        margin: const EdgeInsets.only(top: 2),
        width: 30,
        height: 1.5,
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
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          )),
      Container(
        margin: const EdgeInsets.only(top: 2),
        width: 50,
        height: 1.2,
        color: _kInk.withOpacity(0.22),
      ),
    ]);
  }
}

class _DossierChip extends StatelessWidget {
  final String emoji, label, value;
  const _DossierChip(this.emoji, this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text(emoji, style: const TextStyle(fontSize: 14)),
      const SizedBox(width: 5),
      RichText(
        text: TextSpan(children: [
          TextSpan(
              text: '$label: ',
              style: TextStyle(
                color: _kInk.withOpacity(0.5),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              )),
          TextSpan(
              text: value,
              style: const TextStyle(
                color: _kInk,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              )),
        ]),
      ),
    ]);
  }
}

class _DossierRow extends StatelessWidget {
  final String label, value;
  const _DossierRow(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: RichText(
        text: TextSpan(children: [
          TextSpan(
              text: '$label: ',
              style: TextStyle(
                color: _kInk.withOpacity(0.5),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              )),
          TextSpan(
              text: value,
              style: const TextStyle(
                color: _kInk,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              )),
        ]),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final String emoji, label, value;
  const _ContactRow(this.emoji, this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 5),
        Text('[$label] ',
            style: TextStyle(
              color: _kInk.withOpacity(0.5),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            )),
        Expanded(
          child: Text(value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _kInk,
                fontSize: 13,
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
      padding: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: _kInk.withOpacity(0.2), width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              'KONO SAKUHIN WA FICTION DE JITSUZAISURU JINBUTSU DANTAI\n'
              'SONOTA NO SOSHKI TO DOITSO NO MASHOU GA GEKICHU NI TOUJYOU\n'
              'SHITATOSHITEMO JITSUZAI NA MONOTO WA ISSAI MUKANKEIDETH.',
              style: TextStyle(
                color: _kInk.withOpacity(0.4),
                fontSize: 6.5,
                height: 1.5,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Text('MARINE',
              style: TextStyle(
                fontFamily: 'PirataOne',
                color: _kInk.withOpacity(0.8),
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              )),
          const SizedBox(width: 8),
          SizedBox(
            width: 30,
            height: 40,
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
    canvas.drawRect(Rect.fromLTWH(0, 0, s.width, s.height),
        Paint()..color = const Color(0xFF2C1508));
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
    final dp = Paint()
      ..color = const Color(0xFF0D0500)
      ..strokeWidth = 2.5;
    final ph = s.height / 4;
    for (int i = 1; i < 4; i++) {
      canvas.drawLine(Offset(0, ph * i), Offset(s.width, ph * i), dp);
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
    for (int i = 0; i < 1500; i++) {
      p.color = Colors.black.withOpacity(_rng.nextDouble() * 0.018);
      canvas.drawCircle(
          Offset(_rng.nextDouble() * s.width, _rng.nextDouble() * s.height),
          0.5,
          p);
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
    canvas.drawOval(
        Rect.fromLTWH(s.width * 0.18, 0, s.width * 0.64, s.height * 0.60),
        fill);
    canvas.drawRect(
        Rect.fromLTWH(
            s.width * 0.24, s.height * 0.44, s.width * 0.52, s.height * 0.28),
        fill);
    final bg = Paint()
      ..color = const Color(0xFFF2D98B).withOpacity(0.6)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
        Rect.fromLTWH(
            s.width * 0.26, s.height * 0.12, s.width * 0.18, s.height * 0.22),
        bg);
    canvas.drawOval(
        Rect.fromLTWH(
            s.width * 0.56, s.height * 0.12, s.width * 0.18, s.height * 0.22),
        bg);
    for (int i = 0; i < 4; i++) {
      canvas.drawRect(
          Rect.fromLTWH(s.width * (0.28 + i * 0.12), s.height * 0.56,
              s.width * 0.07, s.height * 0.13),
          bg);
    }
    canvas.drawLine(
        Offset(0, s.height * 0.82), Offset(s.width, s.height * 0.98), stroke);
    canvas.drawLine(
        Offset(0, s.height * 0.98), Offset(s.width, s.height * 0.82), stroke);
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
    canvas.drawPath(
        Path()
          ..moveTo(s.width * 0.5, s.height * 0.45)
          ..quadraticBezierTo(
              s.width * 0.28, s.height * 0.1, 0, s.height * 0.4),
        p);
    canvas.drawPath(
        Path()
          ..moveTo(s.width * 0.5, s.height * 0.45)
          ..quadraticBezierTo(
              s.width * 0.72, s.height * 0.1, s.width, s.height * 0.4),
        p);
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
// LOADING / ERROR / CONFIRM
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

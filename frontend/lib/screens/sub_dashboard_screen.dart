import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/sub_user.dart';
import '../models/user_base.dart';
import '../utils/constants.dart';
import '../utils/image_helper.dart';
import '../widgets/add_subuser_dialog.dart';
import '../widgets/edit_subuser_dialog.dart';
import '../widgets/video_background.dart';

const Color _kGold = Color(0xFFD4A017);
const Color _kBrightGold = Color(0xFFFFD700);
const Color _kCrimson = Color(0xFF8B1A1A);
const Color _kParchment = Color(0xFFF5DEB3);
const Color _kDarkBrown = Color(0xFF1A0A00);
const Color _kAgedGold = Color(0xFF8B6914);
const Color _kPosterBg = Color(0xFFE8D5A3);
const Color _kPosterDark = Color(0xFF3C2000);
const Color _kPosterText = Color(0xFF2A1400);
const Color _kMarineRed = Color(0xFF8B1A1A);

/// SubDashboardScreen — Wanted poster grid.
///
/// ✅ FIXED: Poster layout now accurately matches the reference
/// One Piece wanted poster:
///   - "WANTED" large at the very top
///   - Large portrait photo below it
///   - "DEAD OR ALIVE" text
///   - Name in large bold serif
///   - Bounty amount "฿ XXX,000,000—"
///   - "MARINE" stamp in bottom right
class SubDashboardScreen extends StatefulWidget {
  const SubDashboardScreen({super.key});

  @override
  State<SubDashboardScreen> createState() => _SubDashboardScreenState();
}

class _SubDashboardScreenState extends State<SubDashboardScreen> {
  List<UserBase> _subUsers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSubUsers();
  }

  Future<void> _loadSubUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final auth = context.read<AuthProvider>();
      Map<String, dynamic> response;

      if (auth.isMainUser) {
        response = await auth.apiService.getAllSubUsers();
      } else {
        response = await auth.apiService.getPublicProfiles();
        if (response.containsKey('error')) {
          response = await auth.apiService.getProfiles();
        }
      }

      List<dynamic> list = [];
      if (response.containsKey('sub_users') && response['sub_users'] != null) {
        list = response['sub_users'] as List<dynamic>;
      } else if (response.containsKey('profiles') &&
          response['profiles'] != null) {
        list = response['profiles'] as List<dynamic>;
      }

      final localSubUsers = auth.subUsers;
      final List<UserBase> loaded = list
          .map((p) => SubUser.fromJson(p as Map<String, dynamic>))
          .map((backendUser) {
        final localMatch =
            localSubUsers.where((u) => u.id == backendUser.id).toList();
        if (localMatch.isNotEmpty &&
            (localMatch.first.profilePictureBytes != null ||
                localMatch.first.coverPhotoBytes != null)) {
          return backendUser.copyWith({
            'profile_picture_bytes': localMatch.first.profilePictureBytes,
            'cover_photo_bytes': localMatch.first.coverPhotoBytes,
            'owner_user_id': backendUser.ownerUserId,
          });
        }
        return backendUser;
      }).toList();

      for (final user in loaded) {
        auth.updateSubUser(user);
      }

      setState(() {
        _subUsers = loaded;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _subUsers = [];
        _isLoading = false;
        _error = 'Failed to load: $e';
      });
    }
  }

  void _addSubUser() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AddSubUserDialog(
        onSubmit: (subUser) {
          context.read<AuthProvider>().addSubUser(subUser);
          setState(() => _subUsers.add(subUser));
        },
      ),
    );
  }

  void _editSubUser(UserBase user) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => EditSubUserDialog(
        user: user,
        onSave: (updatedData) {
          if (user is SubUser &&
              user.ownerUserId != null &&
              !updatedData.containsKey('owner_user_id')) {
            updatedData['owner_user_id'] = user.ownerUserId;
            updatedData['user_id'] = user.ownerUserId;
          }
          final updated = user.copyWith(updatedData);
          setState(() {
            final index = _subUsers.indexWhere((u) => u.id == user.id);
            if (index != -1) {
              _subUsers[index] = updated;
            }
          });
          context.read<AuthProvider>().updateSubUser(updated);
        },
      ),
    );
  }

  void _deleteSubUser(UserBase user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C1A00),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: _kGold.withOpacity(0.4), width: 1.5),
        ),
        title: const Text('Remove from Wanted List',
            style: TextStyle(color: _kParchment)),
        content: Text(
          'Remove ${user.name}\'s wanted poster?',
          style: TextStyle(color: _kParchment.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: _kParchment.withOpacity(0.6))),
          ),
          ElevatedButton(
            onPressed: () async {
              final auth = context.read<AuthProvider>();
              final response = await auth.apiService.deleteProfile(user.id);
              if (response.containsKey('error')) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(response['error']),
                    backgroundColor: _kCrimson,
                  ));
                }
              } else {
                auth.removeSubUser(user.id);
                setState(() => _subUsers.removeWhere((p) => p.id == user.id));
                if (mounted) {
                  Navigator.pop(context);
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _kCrimson),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Stack(
        children: [
          const VideoBackground(
            videoPath: AssetPaths.subDashboardBackgroundVideo,
          ),
          Container(color: Colors.black.withOpacity(0.55)),

          Column(
            children: [
              const SizedBox(height: 90),
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: _kGold,
                          strokeWidth: 2,
                        ),
                      )
                    : _error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline,
                                    color: _kCrimson, size: 48),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(
                                    _error!,
                                    style: const TextStyle(
                                        color: _kParchment, fontSize: 15),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _loadSubUsers,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Retry'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _kGold,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _subUsers.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('🏴‍☠️',
                                        style: TextStyle(fontSize: 64)),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'No Wanted Posters',
                                      style: TextStyle(
                                        color: _kParchment,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      auth.isMainUser
                                          ? 'Add crew members!'
                                          : 'No crew wanted yet',
                                      style: TextStyle(
                                        color: _kParchment.withOpacity(0.5),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : GridView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 16, 20, 32),
                                gridDelegate:
                                    const SliverGridDelegateWithMaxCrossAxisExtent(
                                  // Each poster max width 200px
                                  // childAspectRatio matches the
                                  // reference poster proportions:
                                  // roughly 0.65 wide:tall
                                  maxCrossAxisExtent: 200,
                                  childAspectRatio: 0.62,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 20,
                                ),
                                itemCount: _subUsers.length,
                                itemBuilder: (context, index) {
                                  final user = _subUsers[index];
                                  final bool showEdit = auth.isMainUser ||
                                      auth.isOwnProfile(user);
                                  final bool showDelete = auth.isMainUser;

                                  return _WantedPosterCard(
                                    user: user,
                                    showEdit: showEdit,
                                    showDelete: showDelete,
                                    onTap: () =>
                                        context.push('/profile/${user.id}'),
                                    onEdit: () => _editSubUser(user),
                                    onDelete: () => _deleteSubUser(user),
                                  );
                                },
                              ),
              ),
            ],
          ),

          // Top nav bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: _kDarkBrown.withOpacity(0.85),
                    border: Border(
                      bottom: BorderSide(
                        color: _kGold.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          _TopBarButton(
                            icon: Icons.arrow_back,
                            label: 'Back',
                            onTap: () => context.pop(),
                            outlined: true,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            '🏴‍☠️  Wanted Posters',
                            style: TextStyle(
                              color: _kBrightGold,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Spacer(),
                          if (auth.isMainUser)
                            _TopBarButton(
                              icon: Icons.person_add,
                              label: 'Add Crew',
                              onTap: _addSubUser,
                              filled: true,
                            ),
                          if (_subUsers.isNotEmpty) ...[
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _kGold.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _kGold.withOpacity(0.4),
                                ),
                              ),
                              child: Text(
                                '${_subUsers.length} wanted',
                                style: const TextStyle(
                                  color: _kBrightGold,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// WANTED POSTER CARD
//
// ✅ ACCURATE to reference image:
//
//   ┌─────────────────────────┐
//   │  ██ WANTED ██           │  ← very large bold black
//   ├─────────────────────────┤  ← thin inner border
//   │                         │
//   │    [  PHOTO  ]          │  ← tall portrait, ~55% height
//   │                         │
//   ├─────────────────────────┤
//   │  DEAD OR ALIVE          │  ← medium bold
//   │  MONKEY·D·LUFFY         │  ← large name
//   │  ฿ 400,000,000—         │  ← bounty
//   │  fine print...  MARINE  │  ← fine print + red stamp
//   └─────────────────────────┘
//
// Background: aged parchment tan (#E8D5A3)
// Outer border: dark brown 3px
// Inner border: thin inset 1px
// ─────────────────────────────────────────────────────────────────

class _WantedPosterCard extends StatefulWidget {
  final UserBase user;
  final bool showEdit;
  final bool showDelete;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _WantedPosterCard({
    required this.user,
    required this.showEdit,
    required this.showDelete,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_WantedPosterCard> createState() => _WantedPosterCardState();
}

class _WantedPosterCardState extends State<_WantedPosterCard> {
  bool _hovered = false;

  /// Generate a deterministic fake bounty from the name
  String _bountyAmount(String name) {
    final int seed = name.codeUnits.fold(0, (p, e) => p + e);
    final int hundreds = (seed * 137 + 50) % 900 + 100;
    return '฿  $hundreds,000,000—';
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          transform: Matrix4.identity()..translate(0.0, _hovered ? -6.0 : 0.0),
          child: Stack(
            children: [
              // ── OUTER POSTER CONTAINER ─────────────
              Container(
                decoration: BoxDecoration(
                  color: _kPosterBg,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: _hovered ? _kBrightGold : _kPosterDark,
                    width: 3.5,
                  ),
                  boxShadow: _hovered
                      ? [
                          BoxShadow(
                            color: _kGold.withOpacity(0.55),
                            blurRadius: 20,
                            spreadRadius: 3,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 12,
                            offset: const Offset(3, 5),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.55),
                            blurRadius: 10,
                            offset: const Offset(4, 4),
                          ),
                        ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── WANTED HEADER ───────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 4),
                      child: Text(
                        'WANTED',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                          height: 1.0,
                          color: _kPosterText,
                          // Slight shadow for depth
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(1, 2),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // ── THIN INNER BORDER ───────────────
                    Container(
                      height: 2,
                      color: _kPosterDark,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                    const SizedBox(height: 3),

                    // ── PORTRAIT PHOTO ──────────────────
                    // Takes up majority of the poster height
                    Expanded(
                      flex: 7,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _kPosterDark,
                            width: 2,
                          ),
                          image: DecorationImage(
                            image: ImageHelper.buildProvider(
                              widget.user.profilePicture,
                              AssetPaths.defaultAvatar,
                              bytes: widget.user.profilePictureBytes,
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    // ── THIN INNER BORDER ───────────────
                    Container(
                      height: 2,
                      color: _kPosterDark,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                    ),

                    // ── DEAD OR ALIVE ───────────────────
                    Padding(
                      padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
                      child: Text(
                        'DEAD  OR  ALIVE',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: _kPosterText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // ── NAME ────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      child: Text(
                        widget.user.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: _kPosterText,
                          height: 1.1,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // ── BOUNTY ──────────────────────────
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 5, right: 5, bottom: 1),
                      child: Text(
                        _bountyAmount(widget.user.name),
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: _kPosterText,
                          letterSpacing: 0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // ── FINE PRINT + MARINE STAMP ───────
                    Container(
                      height: 2,
                      color: _kPosterDark,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 2, 4, 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Fine print text
                          Expanded(
                            child: Text(
                              'Kono sakuhin wa fiction de'
                              ' jitsuzaisuru jinbutsu...',
                              style: TextStyle(
                                fontSize: 4.5,
                                color: _kPosterDark.withOpacity(0.6),
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 3),
                          // "MARINE" stamp
                          Text(
                            'MARINE',
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: _kMarineRed,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── INNER SECOND BORDER (inset) ─────────
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _kPosterDark.withOpacity(0.25),
                        width: 0.8,
                      ),
                    ),
                  ),
                ),
              ),

              // ── EDIT + DELETE BUTTONS ───────────────
              if (widget.showEdit || widget.showDelete)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.showEdit)
                        _PosterActionButton(
                          icon: Icons.edit,
                          color: _kGold,
                          onTap: widget.onEdit,
                        ),
                      if (widget.showEdit && widget.showDelete)
                        const SizedBox(width: 3),
                      if (widget.showDelete)
                        _PosterActionButton(
                          icon: Icons.delete_outline,
                          color: _kCrimson,
                          onTap: widget.onDelete,
                        ),
                    ],
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
// POSTER ACTION BUTTON
// ─────────────────────────────────────────────────────────────────

class _PosterActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _PosterActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_PosterActionButton> createState() => _PosterActionButtonState();
}

class _PosterActionButtonState extends State<_PosterActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: _hovered ? widget.color : widget.color.withOpacity(0.85),
            shape: BoxShape.circle,
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ]
                : [],
          ),
          child: Icon(widget.icon, color: Colors.white, size: 12),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// TOP BAR BUTTON
// ─────────────────────────────────────────────────────────────────

class _TopBarButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool outlined;
  final bool filled;

  const _TopBarButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.outlined = false,
    this.filled = false,
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: widget.filled
                ? (_hovered ? _kGold : _kGold.withOpacity(0.85))
                : (_hovered
                    ? _kGold.withOpacity(0.12)
                    : Colors.white.withOpacity(0.06)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.filled
                  ? Colors.transparent
                  : widget.outlined
                      ? _kAgedGold.withOpacity(0.45)
                      : _kGold.withOpacity(0.4),
            ),
            boxShadow: widget.filled && _hovered
                ? [
                    BoxShadow(
                      color: _kGold.withOpacity(0.4),
                      blurRadius: 16,
                      spreadRadius: 1,
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: widget.filled
                    ? Colors.white
                    : (_hovered ? _kBrightGold : _kParchment.withOpacity(0.8)),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.filled
                      ? Colors.white
                      : (_hovered ? _kBrightGold : _kParchment),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

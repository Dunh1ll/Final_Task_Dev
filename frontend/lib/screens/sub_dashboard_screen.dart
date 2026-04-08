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

/// SubDashboardScreen — 3:4 grid of all registered sub user profiles.
///
/// ✅ FEATURE 3: After editing a profile picture, auth.updateSubUser()
/// is called immediately so the grid card updates without reload.
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

      // Merge backend data with local photo bytes
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
        _error = 'Failed to load profiles: $e';
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

  /// Edit a sub user profile.
  ///
  /// ✅ FEATURE 3: After save, the updated user (with new photo bytes
  /// and profile_picture_url) is pushed to AuthProvider immediately.
  /// The grid card will show the new photo without needing a reload.
  void _editSubUser(UserBase user) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => EditSubUserDialog(
        user: user,
        onSave: (updatedData) {
          final updated = user.copyWith(updatedData);

          // Update local list immediately
          setState(() {
            final index = _subUsers.indexWhere((u) => u.id == user.id);
            if (index != -1) _subUsers[index] = updated;
          });

          // ✅ Push to provider — dashboard badge and
          // any other screen watching this user will update
          context.read<AuthProvider>().updateSubUser(updated);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Profile updated successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  void _deleteSubUser(UserBase user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:
            const Text('Delete Profile', style: TextStyle(color: Colors.white)),
        content: Text(
          'Permanently delete ${user.name}?\n'
          'They can re-register after deletion.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () async {
              final auth = context.read<AuthProvider>();
              final response = await auth.apiService.deleteProfile(user.id);
              if (response.containsKey('error')) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(response['error']),
                    backgroundColor: Colors.red,
                  ));
                }
              } else {
                auth.removeSubUser(user.id);
                setState(() => _subUsers.removeWhere((p) => p.id == user.id));
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('${user.name} deleted.'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 2),
                  ));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
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
          Container(color: Colors.black.withOpacity(0.45)),

          Column(
            children: [
              const SizedBox(height: 90),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryBlue,
                          strokeWidth: 2,
                        ),
                      )
                    : _error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.red, size: 48),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(
                                    _error!,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 15),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _loadSubUsers,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Retry'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryBlue,
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
                                    Icon(
                                      Icons.people_outline,
                                      size: 64,
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No registered profiles yet',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      auth.isMainUser
                                          ? 'Tap "Add Profile" to create one'
                                          : 'No profiles created yet',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.4),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : GridView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(24, 16, 24, 32),
                                gridDelegate:
                                    const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 220,
                                  childAspectRatio: 3 / 4,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 20,
                                ),
                                itemCount: _subUsers.length,
                                itemBuilder: (context, index) {
                                  final user = _subUsers[index];
                                  final bool showEdit = auth.isMainUser ||
                                      auth.isOwnProfile(user);
                                  final bool showDelete = auth.isMainUser;

                                  return _ProfileGridCard(
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

          // Fixed top nav bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.primaryBlue.withOpacity(0.3),
                        width: 1,
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
                            label: 'Main View',
                            onTap: () => context.pop(),
                            outlined: true,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Registered Profiles',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const Spacer(),
                          if (auth.isMainUser)
                            _TopBarButton(
                              icon: Icons.person_add_outlined,
                              label: 'Add Profile',
                              onTap: _addSubUser,
                              filled: true,
                            ),
                          if (_subUsers.isNotEmpty) ...[
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.primaryBlue.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                '${_subUsers.length} profile'
                                '${_subUsers.length > 1 ? 's' : ''}',
                                style: const TextStyle(
                                  color: AppColors.lightGreen,
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
                ? (_hovered
                    ? AppColors.primaryBlue
                    : AppColors.primaryBlue.withOpacity(0.85))
                : (_hovered
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.06)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.filled
                  ? Colors.transparent
                  : widget.outlined
                      ? Colors.white.withOpacity(0.25)
                      : AppColors.primaryBlue.withOpacity(0.4),
            ),
            boxShadow: widget.filled && _hovered
                ? [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.4),
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
                    : (_hovered ? AppColors.lightGreen : Colors.white70),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.filled
                      ? Colors.white
                      : (_hovered ? AppColors.lightGreen : Colors.white),
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

// ─────────────────────────────────────────────────────────────────
// PROFILE GRID CARD — 3:4 transparent card
// ─────────────────────────────────────────────────────────────────

class _ProfileGridCard extends StatefulWidget {
  final UserBase user;
  final bool showEdit;
  final bool showDelete;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProfileGridCard({
    required this.user,
    required this.showEdit,
    required this.showDelete,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_ProfileGridCard> createState() => _ProfileGridCardState();
}

class _ProfileGridCardState extends State<_ProfileGridCard> {
  bool _hovered = false;

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
          transform: Matrix4.identity()..translate(0.0, _hovered ? -4.0 : 0.0),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovered
                  ? AppColors.primaryBlue.withOpacity(0.8)
                  : Colors.white.withOpacity(0.15),
              width: _hovered ? 2.0 : 1.0,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.35),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cardHeight = constraints.maxHeight;
                  final coverHeight = cardHeight * 0.45;
                  final avatarSize = 52.0;
                  final avatarTop = coverHeight - (avatarSize / 2);

                  return Stack(
                    children: [
                      Column(
                        children: [
                          // Cover photo
                          SizedBox(
                            height: coverHeight,
                            width: double.infinity,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image(
                                  image: ImageHelper.buildProvider(
                                    widget.user.coverPhoto,
                                    AssetPaths.defaultCover,
                                    bytes: widget.user.coverPhotoBytes,
                                  ),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.black.withOpacity(0.3),
                                  ),
                                ),
                                Positioned.fill(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.45),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Info panel
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              color: Colors.black.withOpacity(0.30),
                              padding: EdgeInsets.fromLTRB(
                                  8, (avatarSize / 2) + 8, 8, 8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.user.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  if (widget.user.yearLevel != null)
                                    Text(
                                      widget.user.yearLevel!,
                                      style: const TextStyle(
                                        color: AppColors.lightGreen,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  const Spacer(),
                                  AnimatedOpacity(
                                    opacity: _hovered ? 1.0 : 0.0,
                                    duration: const Duration(milliseconds: 200),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryBlue
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.primaryBlue
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                      child: const Text(
                                        'View Profile',
                                        style: TextStyle(
                                          color: AppColors.lightGreen,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Profile picture (no glow on circle)
                      Positioned(
                        top: avatarTop,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: avatarSize,
                            height: avatarSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
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
                      ),

                      // Edit + Delete buttons
                      if (widget.showEdit || widget.showDelete)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.showEdit)
                                _CardActionButton(
                                  icon: Icons.edit,
                                  color: AppColors.primaryBlue,
                                  onTap: widget.onEdit,
                                ),
                              if (widget.showEdit && widget.showDelete)
                                const SizedBox(width: 4),
                              if (widget.showDelete)
                                _CardActionButton(
                                  icon: Icons.delete_outline,
                                  color: Colors.red,
                                  onTap: widget.onDelete,
                                ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CardActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_CardActionButton> createState() => _CardActionButtonState();
}

class _CardActionButtonState extends State<_CardActionButton> {
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
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _hovered ? widget.color : widget.color.withOpacity(0.8),
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
          child: Icon(widget.icon, color: Colors.white, size: 13),
        ),
      ),
    );
  }
}

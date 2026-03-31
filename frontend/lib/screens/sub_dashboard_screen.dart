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

/// SubDashboardScreen shows all registered sub user profiles in a scrollable list.
///
/// ROLE-BASED BEHAVIOR:
///
/// MAIN USER:
///   - Calls /profiles/all — sees every sub user
///   - Edit button on ALL profiles
///   - Delete button on ALL profiles
///   - No "Add Profile" button
///
/// SUB USER:
///   - Calls /profiles/public — sees all sub users (read-only for others)
///   - Edit button ONLY on their OWN profile
///     (checked via auth.isOwnProfile which compares SubUser.ownerUserId == auth.userID)
///   - No delete button
///   - "Add Profile" button to create their own profile
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

  /// Load sub user profiles from the backend.
  ///
  /// MAIN USER → /profiles/all (sees everyone, admin access)
  /// SUB USER  → /profiles/public (sees everyone, but edit restricted in UI)
  ///             falls back to /profiles (own only) if public fails
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

      // Extract list — backend uses 'sub_users' or 'profiles' key
      List<dynamic> list = [];
      if (response.containsKey('sub_users') && response['sub_users'] != null) {
        list = response['sub_users'] as List<dynamic>;
      } else if (response.containsKey('profiles') &&
          response['profiles'] != null) {
        list = response['profiles'] as List<dynamic>;
      }

      // Merge backend data with local photo bytes from this session
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

      // Sync to provider cache so photo bytes survive navigation
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

  /// Show Add Profile dialog — sub users only.
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

  /// Show Edit Profile dialog.
  /// Permissions are enforced in the UI via showEdit flag.
  /// Backend also validates permissions on PUT /api/profiles/:id.
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

          // Update provider so profile detail screen reflects changes too
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

  /// Show delete confirmation — main users only.
  void _deleteSubUser(UserBase user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:
            const Text('Delete Profile', style: TextStyle(color: Colors.white)),
        content: Text(
          'Permanently delete ${user.name}?\nThey can re-register after deletion.',
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response['error']),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } else {
                auth.removeSubUser(user.id);
                setState(() => _subUsers.removeWhere((p) => p.id == user.id));
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${user.name} deleted.'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 2),
                    ),
                  );
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
          // Background video
          const VideoBackground(
            videoPath: AssetPaths.subDashboardBackgroundVideo,
          ),
          Container(color: Colors.black.withOpacity(0.4)),

          // Scrollable content
          Column(
            children: [
              const SizedBox(height: 90),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primaryBlue),
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
                                      color: Colors.white.withOpacity(0.4),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No registered profiles yet',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      auth.isSubUser
                                          ? 'Tap "Add Profile" to create yours'
                                          : 'No sub users registered yet',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(24, 8, 24, 24),
                                itemCount: _subUsers.length,
                                itemBuilder: (context, index) {
                                  final user = _subUsers[index];

                                  // ── PERMISSION LOGIC ──────────────
                                  //
                                  // showEdit is true when:
                                  //   a) User is main user (can edit all) OR
                                  //   b) User is sub user AND owns this profile
                                  //
                                  // auth.isOwnProfile(user) does:
                                  //   1. Casts user to SubUser
                                  //   2. Reads SubUser.ownerUserId
                                  //      (the account UUID that created this profile)
                                  //   3. Compares with auth.userID
                                  //      (the logged-in user's account UUID)
                                  //   4. Returns true when they match
                                  final bool showEdit = auth.isMainUser ||
                                      auth.isOwnProfile(user);

                                  // showDelete is only true for main users
                                  final bool showDelete = auth.isMainUser;

                                  return GestureDetector(
                                    onTap: () =>
                                        context.push('/profile/${user.id}'),
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.15),
                                        ),
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),

                                        // Profile picture
                                        // Uses Container+DecorationImage
                                        // (not CircleAvatar) for base64 support
                                        leading: Container(
                                          width: 56,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color:
                                                  Colors.white.withOpacity(0.3),
                                              width: 2,
                                            ),
                                            image: DecorationImage(
                                              image: ImageHelper.buildProvider(
                                                user.profilePicture,
                                                AssetPaths.defaultAvatar,
                                                bytes: user.profilePictureBytes,
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),

                                        title: Text(
                                          user.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),

                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (user.yearLevel != null)
                                              Text(
                                                user.yearLevel!,
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.6),
                                                  fontSize: 13,
                                                ),
                                              ),
                                            if (user.bio != null &&
                                                user.bio!.isNotEmpty)
                                              Text(
                                                user.bio!,
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.5),
                                                  fontSize: 12,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                          ],
                                        ),

                                        // Action buttons
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // EDIT button
                                            // Main users: visible on all profiles
                                            // Sub users: visible only on own profile
                                            if (showEdit)
                                              GestureDetector(
                                                onTap: () => _editSubUser(user),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration:
                                                      const BoxDecoration(
                                                    color:
                                                        AppColors.primaryBlue,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.edit,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),

                                            if (showEdit && showDelete)
                                              const SizedBox(width: 8),

                                            // DELETE button
                                            // Only visible to main users
                                            if (showDelete)
                                              GestureDetector(
                                                onTap: () =>
                                                    _deleteSubUser(user),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.red,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.delete,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          ),

          // Fixed top navigation bar
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
                    // Back to main dashboard
                    ElevatedButton.icon(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 18),
                      label: const Text(
                        'Main View',
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

                    const SizedBox(width: 12),

                    Text(
                      'Registered Profiles',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Spacer(),

                    // Add Profile — sub users only
                    if (auth.isSubUser)
                      ElevatedButton.icon(
                        onPressed: _addSubUser,
                        icon: const Icon(Icons.add,
                            color: Colors.white, size: 18),
                        label: const Text(
                          'Add Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          elevation: 4,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                      ),

                    // Profile count badge
                    if (_subUsers.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_subUsers.length} profile${_subUsers.length > 1 ? 's' : ''}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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

/// SubDashboardScreen shows all registered sub user profiles in a list.
///
/// Role-based behavior:
///   MAIN USER:
///     - Sees ALL sub users via /profiles/all
///     - Can edit any sub user profile
///     - Can delete any sub user (permanently removes account)
///     - Does NOT see Add Profile button
///
///   SUB USER:
///     - Sees ALL sub users via /profiles/public
///     - Can only edit their OWN profile
///     - Cannot delete anyone
///     - Sees Add Profile button to create their own profile
///
/// Vertical scroll is enabled on this screen (unlike main dashboard).
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
    // Always reload from backend when this screen opens
    // This ensures newly registered users appear immediately
    _loadSubUsers();
  }

  /// Load sub users from the backend based on the logged-in user's role.
  ///
  /// MAIN USER flow:
  ///   1. Call /profiles/all (returns every sub user in the system)
  ///
  /// SUB USER flow:
  ///   1. Call /profiles/public (returns all sub users — read access for all)
  ///   2. If that fails, fall back to /profiles (own profiles only)
  ///
  /// After loading from backend, merge with local photo bytes
  /// so recently uploaded images are preserved.
  Future<void> _loadSubUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final auth = context.read<AuthProvider>();
      Map<String, dynamic> response;

      if (auth.isMainUser) {
        // Main users call the admin endpoint that returns ALL sub users
        response = await auth.apiService.getAllSubUsers();
      } else {
        // Sub users call the public endpoint — sees everyone, edits only own
        response = await auth.apiService.getPublicProfiles();

        // If public endpoint returns error, fall back to own profiles
        if (response.containsKey('error')) {
          response = await auth.apiService.getProfiles();
        }
      }

      // Extract the profiles list from the response
      // Backend may use either 'sub_users' or 'profiles' key
      List<dynamic> list = [];
      if (response.containsKey('sub_users') && response['sub_users'] != null) {
        list = response['sub_users'] as List<dynamic>;
      } else if (response.containsKey('profiles') &&
          response['profiles'] != null) {
        list = response['profiles'] as List<dynamic>;
      }

      // ── Merge backend data with local photo bytes ──────────────
      // The backend stores base64 strings for profile_picture_url.
      // The local cache (AuthProvider._subUsers) has Uint8List bytes
      // from photos uploaded this session.
      // We prefer local bytes when available because they display faster.
      final localSubUsers = auth.subUsers;
      final List<UserBase> loaded = list
          .map((p) => SubUser.fromJson(p as Map<String, dynamic>))
          .map((backendUser) {
        // Check if we have a local version with photo bytes
        final localMatch =
            localSubUsers.where((u) => u.id == backendUser.id).toList();
        if (localMatch.isNotEmpty &&
            (localMatch.first.profilePictureBytes != null ||
                localMatch.first.coverPhotoBytes != null)) {
          // Merge: use backend text data + local photo bytes
          return backendUser.copyWith({
            'profile_picture_bytes': localMatch.first.profilePictureBytes,
            'cover_photo_bytes': localMatch.first.coverPhotoBytes,
          });
        }
        return backendUser;
      }).toList();

      // Sync all loaded profiles into the AuthProvider cache
      // This ensures photo bytes are available when navigating to detail screen
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

  /// Show the Add Profile dialog — for sub users only.
  void _addSubUser() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AddSubUserDialog(
        onSubmit: (subUser) {
          // Add to provider cache and refresh the list
          context.read<AuthProvider>().addSubUser(subUser);
          setState(() => _subUsers.add(subUser));
        },
      ),
    );
  }

  /// Show the Edit Profile dialog.
  ///
  /// Permission check happens in the UI (showEdit flag).
  /// The backend also validates permissions on the PUT request.
  void _editSubUser(UserBase user) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => EditSubUserDialog(
        user: user,
        onSave: (updatedData) {
          // Create updated copy with new data + preserved photo bytes
          final updated = user.copyWith(updatedData);

          // Update the list so the UI reflects changes immediately
          setState(() {
            final index = _subUsers.indexWhere((u) => u.id == user.id);
            if (index != -1) _subUsers[index] = updated;
          });

          // Update provider so profile detail screen also gets the update
          context.read<AuthProvider>().updateSubUser(updated);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Profile updated!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  /// Show delete confirmation dialog — main users only.
  ///
  /// On confirm: deletes profile AND user account from PostgreSQL.
  /// The user can re-register with the same email after deletion.
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

              // Call backend — deletes profile + user account
              final response = await auth.apiService.deleteProfile(user.id);

              if (response.containsKey('error')) {
                // Show error if delete failed
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response['error']),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } else {
                // Remove from local cache and list
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
          // ── Background video ──────────────────────────────────────
          const VideoBackground(
            videoPath: AssetPaths.subDashboardBackgroundVideo,
          ),
          Container(color: Colors.black.withOpacity(0.4)),

          // ── Scrollable content ────────────────────────────────────
          Column(
            children: [
              // Space for the fixed top bar
              const SizedBox(height: 90),

              Expanded(
                child: _isLoading
                    // ── Loading spinner ────────────────────────────────
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primaryBlue),
                      )
                    : _error != null
                        // ── Error state with retry ─────────────────────
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
                            // ── Empty state ────────────────────────────
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
                            // ── Profile list ───────────────────────────
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(24, 8, 24, 24),
                                itemCount: _subUsers.length,
                                itemBuilder: (context, index) {
                                  final user = _subUsers[index];

                                  // ── Permission logic ─────────────────
                                  // Is this profile owned by logged-in user?
                                  final bool isOwnProfile =
                                      user.id == auth.userID;

                                  // Show edit: main users edit all, sub users edit own only
                                  final bool showEdit =
                                      auth.isMainUser || isOwnProfile;

                                  // Show delete: main users only
                                  final bool showDelete = auth.isMainUser;

                                  return GestureDetector(
                                    // Tap to open full profile detail
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

                                        // ── Profile picture ──────────────
                                        // Uses Container+DecorationImage
                                        // (not CircleAvatar) for reliable
                                        // base64 image display
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
                                              // ImageHelper handles base64 URLs
                                              image: ImageHelper.buildProvider(
                                                user.profilePicture,
                                                AssetPaths.defaultAvatar,
                                                bytes: user.profilePictureBytes,
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),

                                        // Name
                                        title: Text(
                                          user.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),

                                        // Year level + bio preview
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

                                        // ── Action buttons ───────────────
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Edit button
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
                                            // Delete button — main only
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

          // ── Fixed top bar ─────────────────────────────────────────
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

                    // Screen title
                    Text(
                      'Registered Profiles',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Spacer(),

                    // Add Profile — only visible to sub users
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

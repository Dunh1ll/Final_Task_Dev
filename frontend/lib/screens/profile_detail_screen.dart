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

/// ProfileDetailScreen shows the full profile information for any user.
///
/// Supports both main profiles (profile_1/2/3) and sub user UUIDs.
///
/// Loading priority:
///   1. Hardcoded main profiles — no API call needed
///   2. Local AuthProvider cache — has photo bytes, fastest
///   3. Backend by ID — fresh text data, then merge with local bytes
///   4. Backend all profiles — fallback search
///
/// FIX: After editing, the updated profile (with photo) is immediately
/// reflected by updating both local state and AuthProvider cache.
class ProfileDetailScreen extends StatefulWidget {
  final String profileId;

  const ProfileDetailScreen({
    super.key,
    required this.profileId,
  });

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  UserBase? _user;
  bool _isLoading = true;
  String? _error;

  /// IDs for the 3 hardcoded main profiles (not in UUID format)
  final List<String> _mainProfileIds = [
    'profile_1',
    'profile_2',
    'profile_3',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  /// Load the profile using a 4-step fallback strategy.
  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // ── Step 1: Hardcoded main profiles ───────────────────────────
    // These are stored in local Dart files, no API call needed
    if (_mainProfileIds.contains(widget.profileId)) {
      setState(() {
        _user = _getMainProfile(widget.profileId);
        _isLoading = false;
      });
      return;
    }

    final auth = context.read<AuthProvider>();

    // ── Step 2: Check local cache first ───────────────────────────
    // The local cache has photo bytes (Uint8List) that the backend
    // doesn't return directly. Using local data prevents a blank
    // profile picture while waiting for the backend.
    final localMatch =
        auth.subUsers.where((u) => u.id == widget.profileId).toList();

    if (localMatch.isNotEmpty) {
      // Show local data immediately for instant display
      setState(() {
        _user = localMatch.first;
        _isLoading = false;
      });
      // Also fetch backend data in background to get latest text changes
      // but keep the local photo bytes
      _refreshFromBackend(auth, localMatch.first);
      return;
    }

    // ── Steps 3 & 4: Fetch from backend ───────────────────────────
    await _fetchFromBackend(auth);
  }

  /// Background refresh — gets latest text data while keeping photo bytes.
  ///
  /// This runs AFTER local data is already displayed.
  /// It updates the profile with any text changes made elsewhere
  /// without losing the photo bytes from the local cache.
  Future<void> _refreshFromBackend(
      AuthProvider auth, UserBase localUser) async {
    try {
      final response = await auth.apiService.getProfileById(widget.profileId);
      if (!response.containsKey('error')) {
        final profileData =
            response.containsKey('data') && response['data'] is Map
                ? Map<String, dynamic>.from(response['data'] as Map)
                : response['profile'] ?? response;

        final backendUser = SubUser.fromJson(profileData);

        // Merge: prefer local bytes, use backend URL as fallback
        final merged = backendUser.copyWith({
          // Keep local bytes if available (uploaded this session)
          'profile_picture_bytes': localUser.profilePictureBytes,
          'cover_photo_bytes': localUser.coverPhotoBytes,
          // Use backend base64 URL if no local bytes
          if (localUser.profilePictureBytes == null)
            'profile_picture_url': backendUser.profilePicture,
          if (localUser.coverPhotoBytes == null)
            'cover_photo_url': backendUser.coverPhoto,
        });

        if (mounted) {
          setState(() => _user = merged);
          auth.updateSubUser(merged);
        }
      }
    } catch (_) {
      // Silently fail — local data is already displayed
    }
  }

  /// Fetch profile from backend when local cache has no match.
  Future<void> _fetchFromBackend(AuthProvider auth) async {
    try {
      final response = await auth.apiService.getProfileById(widget.profileId);

      if (!response.containsKey('error')) {
        final profileData =
            response.containsKey('data') && response['data'] is Map
                ? Map<String, dynamic>.from(response['data'] as Map)
                : response['profile'] ?? response;

        final loaded = SubUser.fromJson(profileData);
        // Cache for future navigation (preserves photo bytes)
        auth.updateSubUser(loaded);
        setState(() {
          _user = loaded;
          _isLoading = false;
        });
        return;
      }

      // ── Step 4: Fallback — search all profiles ─────────────────
      final allResponse = await auth.apiService.getAllSubUsers();
      if (!allResponse.containsKey('error')) {
        List<dynamic> list =
            allResponse['sub_users'] ?? allResponse['profiles'] ?? [];
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
          return;
        }
      }

      setState(() {
        _error = 'Profile not found.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load profile.\nError: $e';
        _isLoading = false;
      });
    }
  }

  /// Return the hardcoded main profile for a given ID.
  UserBase _getMainProfile(String id) {
    switch (id) {
      case 'profile_1':
        return PallenPrinceDunhill();
      case 'profile_2':
        return AlbanielKarlAngelo();
      case 'profile_3':
        return FajardoAldhy();
      default:
        return SubUser(
            id: id, name: 'Unknown', age: 0, gender: '', yearLevel: '');
    }
  }

  bool get _isMainProfile => _mainProfileIds.contains(widget.profileId);

  /// Can the logged-in user edit this profile?
  ///
  /// Rules:
  ///   Main user + main profile → only if it's their own profile
  ///   Main user + sub profile → always yes
  ///   Sub user + any profile → only if it's their own
  bool _canEdit(AuthProvider auth) {
    if (_user == null) return false;
    if (_isMainProfile) {
      return auth.isMainUser && auth.ownProfileId == widget.profileId;
    }
    if (auth.isMainUser) return true;
    return auth.userID != null && _user!.id == auth.userID;
  }

  /// Can the logged-in user delete this profile?
  /// Only main users can delete, and only sub user profiles.
  bool _canDelete(AuthProvider auth) {
    if (_isMainProfile) return false;
    return auth.isMainUser;
  }

  /// Open edit dialog and update state on save.
  ///
  /// FIX: After save, we update both local _user state AND
  /// the AuthProvider cache so the sub dashboard also reflects
  /// the changes when navigating back.
  void _editProfile(AuthProvider auth) {
    if (_user == null) return;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => EditSubUserDialog(
        user: _user!,
        onSave: (updatedData) {
          final updated = _user!.copyWith(updatedData);
          // ✅ Update local state — shows changes immediately on this screen
          setState(() => _user = updated);
          // ✅ Update provider — so sub dashboard also reflects changes
          auth.updateSubUser(updated);
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

  void _deleteProfile(AuthProvider auth) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:
            const Text('Delete Profile', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Permanently delete this profile?\nThe user can re-register after deletion.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_user != null) {
                await auth.apiService.deleteProfile(_user!.id);
                auth.removeSubUser(_user!.id);
              }
              Navigator.pop(context);
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile deleted.'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                ),
              );
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

    // ── Loading state ───────────────────────────────────────────────
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1E1E2E),
        body: Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue)),
      );
    }

    // ── Error state ─────────────────────────────────────────────────
    if (_error != null || _user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1E1E2E),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E1E2E),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  _error ?? 'Profile not found.',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'ID: ${widget.profileId}',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.4), fontSize: 12),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loadProfile,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final user = _user!;
    final canEdit = _canEdit(auth);
    final canDelete = _canDelete(auth);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () => context.pop(),
        ),
        actions: [
          // ── Edit button ──────────────────────────────────────────
          // Visible based on role + ownership rules
          if (canEdit)
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, color: Colors.white),
              ),
              onPressed: () => _editProfile(auth),
            ),

          // ── Delete button ────────────────────────────────────────
          // Only visible to main users on sub user profiles
          if (canDelete)
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onPressed: () => _deleteProfile(auth),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Cover photo + profile picture ────────────────────────
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                // Cover photo — full width banner at top
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    image: DecorationImage(
                      // ✅ ImageHelper decodes base64 URLs from DB
                      image: ImageHelper.buildProvider(
                        user.coverPhoto,
                        AssetPaths.defaultCover,
                        bytes: user.coverPhotoBytes,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                ),

                // Profile picture — circular, overlapping cover bottom
                Positioned(
                  bottom: -60,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                      border: Border.all(color: Colors.white, width: 5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                      image: DecorationImage(
                        // ✅ ImageHelper decodes base64 URLs from DB
                        image: ImageHelper.buildProvider(
                          user.profilePicture,
                          AssetPaths.defaultAvatar,
                          bytes: user.profilePictureBytes,
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 70),

            // ── Name, year level, bio ────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  if (user.yearLevel != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.primaryBlue.withOpacity(0.3)),
                      ),
                      child: Text(
                        user.yearLevel!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  if (user.bio != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      user.bio!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Info cards ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _infoCard(Icons.school, 'Education',
                      user.education ?? 'Not specified'),
                  _infoCard(Icons.work, 'Work', user.work ?? 'Not specified'),
                  _infoCard(Icons.location_on, 'Hometown',
                      user.hometown ?? 'Not specified'),
                  _infoCard(Icons.favorite, 'Relationship Status',
                      user.relationshipStatus ?? 'Not specified'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Personal details ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Details',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _detailRow('Age', '${user.age ?? 'Not specified'}'),
                  _detailRow('Gender', user.gender ?? 'Not specified'),
                  _detailRow('Year Level', user.yearLevel ?? 'Not specified'),
                  _detailRow(
                    'Birthday',
                    user.birthday != null
                        ? DateFormat('MMMM dd, yyyy').format(user.birthday!)
                        : 'Not specified',
                  ),
                  _detailRow('Email', user.email ?? 'Not specified'),
                  _detailRow('Phone', user.phone ?? 'Not specified'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Interests chips ──────────────────────────────────────
            if (user.interests.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Interests',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: user.interests.map((interest) {
                        return Chip(
                          label: Text(interest),
                          backgroundColor:
                              AppColors.primaryBlue.withOpacity(0.1),
                          side: BorderSide.none,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String title, String content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryBlue),
        title: Text(title,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(content,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ),
          Expanded(
            child: Text(value,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

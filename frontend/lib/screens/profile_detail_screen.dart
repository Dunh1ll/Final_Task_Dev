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

/// ProfileDetailScreen — shows full profile info for any user.
///
/// ✅ FEATURE 3: After editing profile picture, the dashboard
/// is immediately updated via auth.updateSubUser().
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

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Hardcoded main profiles — no API needed
    if (_mainProfileIds.contains(widget.profileId)) {
      setState(() {
        _user = _getMainProfile(widget.profileId);
        _isLoading = false;
      });
      return;
    }

    final auth = context.read<AuthProvider>();

    // Check local cache first (has photo bytes)
    final localMatch =
        auth.subUsers.where((u) => u.id == widget.profileId).toList();

    if (localMatch.isNotEmpty) {
      setState(() {
        _user = localMatch.first;
        _isLoading = false;
      });
      // Background refresh for latest text data
      _refreshFromBackend(auth, localMatch.first);
      return;
    }

    await _fetchFromBackend(auth);
  }

  /// Refresh text data from backend while keeping local photo bytes.
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
        // Merge: keep local bytes, use backend URL as fallback
        final merged = backendUser.copyWith({
          'profile_picture_bytes': localUser.profilePictureBytes,
          'cover_photo_bytes': localUser.coverPhotoBytes,
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
      // Silently fail — local data is already showing
    }
  }

  Future<void> _fetchFromBackend(AuthProvider auth) async {
    try {
      final response = await auth.apiService.getProfileById(widget.profileId);

      if (!response.containsKey('error')) {
        final profileData =
            response.containsKey('data') && response['data'] is Map
                ? Map<String, dynamic>.from(response['data'] as Map)
                : response['profile'] ?? response;

        final loaded = SubUser.fromJson(profileData);
        auth.updateSubUser(loaded);
        setState(() {
          _user = loaded;
          _isLoading = false;
        });
        return;
      }

      // Fallback: search all profiles
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

  /// Main profiles are NEVER editable from the UI.
  /// Sub user profiles are editable by:
  ///   - Main users: can edit any sub profile
  ///   - Sub users: can only edit their own profile
  bool _canEdit(AuthProvider auth) {
    if (_user == null) return false;
    if (_isMainProfile) return false;
    if (auth.isMainUser) return true;
    return auth.userID != null && _user!.id == auth.userID;
  }

  bool _canDelete(AuthProvider auth) {
    if (_isMainProfile) return false;
    return auth.isMainUser;
  }

  /// Open edit dialog and update ALL relevant state on save.
  ///
  /// ✅ FEATURE 3: After saving, the updated profile (with new
  /// photo bytes and URL) is pushed to AuthProvider immediately.
  /// This makes the dashboard badge and sub-dashboard grid
  /// reflect the new profile picture without needing a reload.
  void _editProfile(AuthProvider auth) {
    if (_user == null) return;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => EditSubUserDialog(
        user: _user!,
        onSave: (updatedData) async {
          // 1. Build updated local user with new bytes + URL
          final updated = _user!.copyWith(updatedData);

          // 2. Update screen state immediately
          setState(() => _user = updated);

          // 3. ✅ Push to provider — dashboard badge and
          //    sub-dashboard grid will rebuild automatically
          auth.updateSubUser(updated);

          // 4. Fetch fresh data from backend in background
          //    to get the actual saved URL (not bytes)
          //    and update the provider with the backend URL
          _refreshFromBackend(auth, updated);

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
          'Permanently delete this profile?\n'
          'The user can re-register after deletion.',
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

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1E1E2E),
        body: Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue)),
      );
    }

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
            // Cover + profile picture
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    image: DecorationImage(
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

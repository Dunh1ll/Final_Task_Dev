import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/sub_user.dart';
import '../models/user_base.dart';
import '../utils/constants.dart';
import '../utils/image_helper.dart';

// One Piece colors
const Color _kGold = Color(0xFFD4A017);
const Color _kBrightGold = Color(0xFFFFD700);
const Color _kCrimson = Color(0xFF8B1A1A);
const Color _kParchment = Color(0xFFF5DEB3);
const Color _kDarkBrown = Color(0xFF1A0A00);
const Color _kAgedGold = Color(0xFF8B6914);

/// EditSubUserDialog — allows editing a sub user's profile.
///
/// ✅ FIXED BUG: The dialog now actually calls
///   apiService.updateProfile(id, data) when saving.
///   Previously it only updated local Flutter state but never
///   sent data to the backend — so changes were lost on refresh.
///
/// ✅ FIXED BUG: Photo bytes are preserved in the updatedData
///   map so the dashboard badge updates immediately after saving.
///
/// ✅ FIXED BUG: After successful API save, the backend returns
///   the updated profile including the saved profile_picture_url.
///   This URL is stored in the profile and persists across refreshes
///   because it comes from the database.
class EditSubUserDialog extends StatefulWidget {
  final UserBase user;
  final Function(Map<String, dynamic>) onSave;

  const EditSubUserDialog({
    super.key,
    required this.user,
    required this.onSave,
  });

  @override
  State<EditSubUserDialog> createState() => _EditSubUserDialogState();
}

class _EditSubUserDialogState extends State<EditSubUserDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _genderCtrl;
  late final TextEditingController _yearLevelCtrl;
  late final TextEditingController _hometownCtrl;
  late final TextEditingController _relationshipCtrl;
  late final TextEditingController _educationCtrl;
  late final TextEditingController _workCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _interestsCtrl;

  Uint8List? _profileImageBytes;
  Uint8List? _coverImageBytes;
  String? _profileImageBase64;
  String? _coverImageBase64;

  DateTime? _birthday;
  bool _isSaving = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.name);
    _bioCtrl = TextEditingController(text: widget.user.bio ?? '');
    _ageCtrl = TextEditingController(text: widget.user.age?.toString() ?? '');
    _genderCtrl = TextEditingController(text: widget.user.gender ?? '');
    _yearLevelCtrl = TextEditingController(text: widget.user.yearLevel ?? '');
    _hometownCtrl = TextEditingController(text: widget.user.hometown ?? '');
    _relationshipCtrl =
        TextEditingController(text: widget.user.relationshipStatus ?? '');
    _educationCtrl = TextEditingController(text: widget.user.education ?? '');
    _workCtrl = TextEditingController(text: widget.user.work ?? '');
    _emailCtrl = TextEditingController(text: widget.user.email ?? '');
    _phoneCtrl = TextEditingController(text: widget.user.phone ?? '');
    _interestsCtrl =
        TextEditingController(text: widget.user.interests.join(', '));

    // Pre-fill existing bytes so they survive even if
    // the user doesn't pick a new photo
    _profileImageBytes = widget.user.profilePictureBytes;
    _coverImageBytes = widget.user.coverPhotoBytes;
    _birthday = widget.user.birthday;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _ageCtrl.dispose();
    _genderCtrl.dispose();
    _yearLevelCtrl.dispose();
    _hometownCtrl.dispose();
    _relationshipCtrl.dispose();
    _educationCtrl.dispose();
    _workCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _interestsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickProfilePicture() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    final base64Str = base64Encode(bytes);
    setState(() {
      _profileImageBytes = bytes;
      _profileImageBase64 = 'data:image/jpeg;base64,$base64Str';
    });
  }

  Future<void> _pickCoverPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 600,
      imageQuality: 85,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    final base64Str = base64Encode(bytes);
    setState(() {
      _coverImageBytes = bytes;
      _coverImageBase64 = 'data:image/jpeg;base64,$base64Str';
    });
  }

  /// Save the profile.
  ///
  /// ✅ FIXED: This method now calls apiService.updateProfile()
  /// to actually persist the changes to PostgreSQL.
  ///
  /// The profile_picture_url stored in the DB is the base64
  /// data URI string. On next load, ImageHelper.buildProvider()
  /// detects the 'data:image' prefix and decodes it as bytes —
  /// so the photo persists across page refreshes.
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    final List<String> interests = _interestsCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    // The URL to store in the database:
    // - If user picked a new photo → base64 data URI
    // - Otherwise → keep the existing URL/path
    final String? profilePicUrl =
        _profileImageBase64 ?? widget.user.profilePicture;
    final String? coverPhotoUrl = _coverImageBase64 ?? widget.user.coverPhoto;

    // Extract ownerUserId safely
    String? ownerUserId;
    if (widget.user is SubUser) {
      ownerUserId = (widget.user as SubUser).ownerUserId;
    }

    // Format birthday for backend (YYYY-MM-DD)
    String? birthdayStr;
    if (_birthday != null) {
      birthdayStr = '${_birthday!.year.toString().padLeft(4, '0')}'
          '-${_birthday!.month.toString().padLeft(2, '0')}'
          '-${_birthday!.day.toString().padLeft(2, '0')}';
    }

    // ✅ Build the data map to send to the backend API
    final Map<String, dynamic> apiData = {
      'name': _nameCtrl.text.trim(),
      'bio': _bioCtrl.text.trim(),
      'age': int.tryParse(_ageCtrl.text.trim()),
      'gender': _genderCtrl.text.trim(),
      'year_level': _yearLevelCtrl.text.trim(),
      'hometown': _hometownCtrl.text.trim(),
      'relationship_status': _relationshipCtrl.text.trim(),
      'education': _educationCtrl.text.trim(),
      'work': _workCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'interests': interests,
      if (birthdayStr != null) 'birthday': birthdayStr,
      // Store the base64 image URL in the database
      // This persists across refreshes
      if (profilePicUrl != null) 'profile_picture_url': profilePicUrl,
      if (coverPhotoUrl != null) 'cover_photo_url': coverPhotoUrl,
    };

    // ✅ CRITICAL FIX: Actually call the API
    final auth = context.read<AuthProvider>();
    final response =
        await auth.apiService.updateProfile(widget.user.id, apiData);

    if (response.containsKey('error')) {
      setState(() {
        _saveError = response['error'];
        _isSaving = false;
      });
      return;
    }

    // API call succeeded — build the local updatedData map
    // which includes bytes for the immediate UI update
    final Map<String, dynamic> updatedData = {
      'id': widget.user.id,
      'owner_user_id': ownerUserId,
      'user_id': ownerUserId,
      'name': _nameCtrl.text.trim(),
      'bio': _bioCtrl.text.trim(),
      'age': int.tryParse(_ageCtrl.text.trim()),
      'gender': _genderCtrl.text.trim(),
      'year_level': _yearLevelCtrl.text.trim(),
      'hometown': _hometownCtrl.text.trim(),
      'relationship_status': _relationshipCtrl.text.trim(),
      'education': _educationCtrl.text.trim(),
      'work': _workCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'interests': interests,
      'birthday': _birthday,
      // URL that was saved to the DB
      'profile_picture_url': profilePicUrl,
      'cover_photo_url': coverPhotoUrl,
      // Bytes for immediate in-memory display
      // (no network round-trip needed for current session)
      'profile_picture_bytes': _profileImageBytes,
      'cover_photo_bytes': _coverImageBytes,
    };

    setState(() => _isSaving = false);

    // Call the parent callback to update local state
    widget.onSave(updatedData);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 520,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: BoxDecoration(
          color: _kDarkBrown.withOpacity(0.93),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _kGold.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: _kGold.withOpacity(0.12),
              blurRadius: 40,
              spreadRadius: 4,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 30,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _kGold.withOpacity(0.12),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(6)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _kGold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:
                        const Icon(Icons.edit, color: _kBrightGold, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _kBrightGold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon:
                        Icon(Icons.close, color: _kParchment.withOpacity(0.6)),
                  ),
                ],
              ),
            ),

            // Scrollable form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Error banner
                      if (_saveError != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: _kCrimson.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: _kCrimson.withOpacity(0.5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: _kCrimson, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _saveError!,
                                  style: const TextStyle(
                                      color: Color(0xFFFF9999), fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Photos
                      _sectionLabel('Photos'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: _pickProfilePicture,
                                  child: Container(
                                    height: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _kGold.withOpacity(0.4),
                                        width: 2,
                                      ),
                                      image: _profileImageBytes != null
                                          ? DecorationImage(
                                              image: MemoryImage(
                                                  _profileImageBytes!),
                                              fit: BoxFit.cover,
                                            )
                                          : DecorationImage(
                                              image: ImageHelper.buildProvider(
                                                widget.user.profilePicture,
                                                AssetPaths.defaultAvatar,
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                    child: _profileImageBytes == null
                                        ? const Center(
                                            child: Icon(
                                              Icons.camera_alt_outlined,
                                              color: _kAgedGold,
                                              size: 28,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Profile Photo',
                                  style: TextStyle(
                                    color: _kParchment.withOpacity(0.5),
                                    fontSize: 11,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: _pickCoverPhoto,
                                  child: Container(
                                    height: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _kGold.withOpacity(0.4),
                                        width: 2,
                                      ),
                                      image: _coverImageBytes != null
                                          ? DecorationImage(
                                              image: MemoryImage(
                                                  _coverImageBytes!),
                                              fit: BoxFit.cover,
                                            )
                                          : DecorationImage(
                                              image: ImageHelper.buildProvider(
                                                widget.user.coverPhoto,
                                                AssetPaths.defaultCover,
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                    child: _coverImageBytes == null
                                        ? const Center(
                                            child: Icon(
                                              Icons
                                                  .add_photo_alternate_outlined,
                                              color: _kAgedGold,
                                              size: 28,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Cover Photo',
                                  style: TextStyle(
                                    color: _kParchment.withOpacity(0.5),
                                    fontSize: 11,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      _sectionLabel('Basic Info'),
                      const SizedBox(height: 12),
                      _buildField(_nameCtrl, 'Full Name', Icons.person_outline,
                          required: true),
                      const SizedBox(height: 12),
                      _buildField(_bioCtrl, 'Bio', Icons.notes, maxLines: 3),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              _ageCtrl,
                              'Age',
                              Icons.cake_outlined,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildField(
                              _genderCtrl,
                              'Gender',
                              Icons.people_outline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        _yearLevelCtrl,
                        'Year Level',
                        Icons.school_outlined,
                      ),

                      const SizedBox(height: 20),
                      _sectionLabel('Birthday'),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _birthday ?? DateTime(2000),
                            firstDate: DateTime(1950),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() => _birthday = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _kAgedGold.withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: _kAgedGold,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _birthday != null
                                    ? DateFormat('MMMM dd, yyyy')
                                        .format(_birthday!)
                                    : 'Select birthday',
                                style: TextStyle(
                                  color: _birthday != null
                                      ? _kParchment
                                      : _kParchment.withOpacity(0.35),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      _sectionLabel('More Info'),
                      const SizedBox(height: 12),
                      _buildField(
                        _hometownCtrl,
                        'Hometown',
                        Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        _relationshipCtrl,
                        'Relationship Status',
                        Icons.favorite_outline,
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        _educationCtrl,
                        'Education',
                        Icons.school_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        _workCtrl,
                        'Work',
                        Icons.work_outline,
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        _emailCtrl,
                        'Email',
                        Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        _phoneCtrl,
                        'Phone',
                        Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        _interestsCtrl,
                        'Interests (comma separated)',
                        Icons.interests_outlined,
                      ),

                      const SizedBox(height: 28),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kGold,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  '⚓  Save Changes',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _kBrightGold,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: _kParchment, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            TextStyle(color: _kParchment.withOpacity(0.6), fontSize: 13),
        prefixIcon: Icon(icon, color: _kAgedGold, size: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _kAgedGold.withOpacity(0.35)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _kGold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _kCrimson),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _kCrimson),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.04),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      validator: required
          ? (v) {
              if (v == null || v.trim().isEmpty) {
                return '$label is required';
              }
              return null;
            }
          : null,
    );
  }
}

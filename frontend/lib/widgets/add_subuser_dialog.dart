import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/sub_user.dart';
import '../utils/constants.dart';

class AddSubUserDialog extends StatefulWidget {
  final Function(SubUser) onSubmit;

  const AddSubUserDialog({
    super.key,
    required this.onSubmit,
  });

  @override
  State<AddSubUserDialog> createState() => _AddSubUserDialogState();
}

class _AddSubUserDialogState extends State<AddSubUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _bioController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _hometownController = TextEditingController();

  String _gender = 'Male';
  String _yearLevel = 'Freshman';
  DateTime? _birthday;
  bool _isLoading = false;
  String? _errorMessage;

  Uint8List? _profilePictureBytes;
  Uint8List? _coverPhotoBytes;
  final ImagePicker _picker = ImagePicker();

  final List<String> _genders = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say'
  ];
  final List<String> _yearLevels = [
    'Freshman',
    'Sophomore',
    'Junior',
    'Senior',
    'Graduate'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _hometownController.dispose();
    super.dispose();
  }

  Future<void> _pickProfilePicture() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() => _profilePictureBytes = bytes);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickCoverPhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 600,
        imageQuality: 80,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() => _coverPhotoBytes = bytes);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryBlue,
              surface: Color(0xFF1E1E2E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _birthday = picked);
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final authProvider = context.read<AuthProvider>();

        // ✅ Build profile data for backend
        final profileData = {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'bio': _bioController.text.trim(),
          'age': int.tryParse(_ageController.text.trim()),
          'gender': _gender,
          'year_level': _yearLevel,
          'birthday': _birthday?.toIso8601String(),
          'hometown': _hometownController.text.trim(),
          'is_main_profile': false,
          'interests': <String>[],
          // ✅ Send photos as base64
          if (_profilePictureBytes != null)
            'profile_picture_url':
                'data:image/jpeg;base64,${base64Encode(_profilePictureBytes!)}',
          if (_coverPhotoBytes != null)
            'cover_photo_url':
                'data:image/jpeg;base64,${base64Encode(_coverPhotoBytes!)}',
        };

        // ✅ Save to backend
        final response =
            await authProvider.apiService.createSubUser(profileData);

        // ✅ Unwrap { success: true, data: { id, name, ... } }
        final Map<String, dynamic> profileResult =
            response.containsKey('data') && response['data'] is Map
                ? Map<String, dynamic>.from(response['data'] as Map)
                : response;

        if (profileResult.containsKey('error')) {
          setState(() {
            _errorMessage = profileResult['error'];
            _isLoading = false;
          });
          return;
        }

        // ✅ Use REAL backend UUID — persists after rerun
        final String backendId = profileResult['id']?.toString() ??
            'sub_${DateTime.now().millisecondsSinceEpoch}';

        // ✅ Build SubUser with backend ID and photo bytes
        final subUser = SubUser(
          id: backendId,
          name: _nameController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          bio: _bioController.text.trim().isEmpty
              ? null
              : _bioController.text.trim(),
          age: int.tryParse(_ageController.text.trim()),
          gender: _gender,
          yearLevel: _yearLevel,
          birthday: _birthday,
          hometown: _hometownController.text.trim().isEmpty
              ? null
              : _hometownController.text.trim(),
          isMainProfile: false,
          profilePictureBytes: _profilePictureBytes,
          coverPhotoBytes: _coverPhotoBytes,
          profilePicture: _profilePictureBytes != null
              ? null
              : 'assets/images/default_avatar.png',
          coverPhoto: _coverPhotoBytes != null
              ? null
              : 'assets/images/default_cover.png',
        );

        if (mounted) {
          setState(() => _isLoading = false);
          widget.onSubmit(subUser);
          Navigator.of(context).pop();
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to create profile: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 520,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.2),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_add, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Add New Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
            ),

            // ── Scrollable Form ──
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Error Message ──
                      if (_errorMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: Colors.red.withOpacity(0.5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // ── Photos ──
                      _sectionTitle('Photos'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Profile Picture
                          Expanded(
                            child: GestureDetector(
                              onTap: _pickProfilePicture,
                              child: Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.07),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _profilePictureBytes != null
                                        ? Colors.green
                                        : AppColors.primaryBlue
                                            .withOpacity(0.4),
                                  ),
                                  image: _profilePictureBytes != null
                                      ? DecorationImage(
                                          image: MemoryImage(
                                              _profilePictureBytes!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: _profilePictureBytes != null
                                    ? Stack(children: [
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.green,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.check,
                                                color: Colors.white, size: 12),
                                          ),
                                        ),
                                        const Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Padding(
                                            padding: EdgeInsets.only(bottom: 6),
                                            child: Text(
                                              'Tap to change',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                shadows: [
                                                  Shadow(
                                                    color: Colors.black,
                                                    blurRadius: 4,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ])
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.person,
                                              color: AppColors.primaryBlue,
                                              size: 32),
                                          const SizedBox(height: 8),
                                          const Text('Profile Picture',
                                              style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 12)),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Tap to upload',
                                            style: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(0.4),
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Cover Photo
                          Expanded(
                            child: GestureDetector(
                              onTap: _pickCoverPhoto,
                              child: Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.07),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _coverPhotoBytes != null
                                        ? Colors.green
                                        : AppColors.primaryBlue
                                            .withOpacity(0.4),
                                  ),
                                  image: _coverPhotoBytes != null
                                      ? DecorationImage(
                                          image: MemoryImage(_coverPhotoBytes!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: _coverPhotoBytes != null
                                    ? Stack(children: [
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.green,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.check,
                                                color: Colors.white, size: 12),
                                          ),
                                        ),
                                        const Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Padding(
                                            padding: EdgeInsets.only(bottom: 6),
                                            child: Text(
                                              'Tap to change',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                shadows: [
                                                  Shadow(
                                                    color: Colors.black,
                                                    blurRadius: 4,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ])
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.image,
                                              color: AppColors.primaryBlue,
                                              size: 32),
                                          const SizedBox(height: 8),
                                          const Text('Cover Photo',
                                              style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 12)),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Tap to upload',
                                            style: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(0.4),
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ── Basic Info ──
                      _sectionTitle('Basic Info'),
                      const SizedBox(height: 12),
                      _buildField(
                        controller: _nameController,
                        label: 'Full Name *',
                        icon: Icons.person,
                        validator: (v) => v == null || v.isEmpty
                            ? 'Please enter a name'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        controller: _phoneController,
                        label: 'Phone',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        controller: _ageController,
                        label: 'Age *',
                        icon: Icons.cake,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter age';
                          if (int.tryParse(v) == null)
                            return 'Enter a valid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Gender
                      DropdownButtonFormField<String>(
                        value: _gender,
                        dropdownColor: const Color(0xFF1E1E2E),
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Gender *', Icons.wc),
                        items: _genders
                            .map((g) => DropdownMenuItem(
                                  value: g,
                                  child: Text(g),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _gender = v!),
                      ),
                      const SizedBox(height: 12),

                      // Year Level
                      DropdownButtonFormField<String>(
                        value: _yearLevel,
                        dropdownColor: const Color(0xFF1E1E2E),
                        style: const TextStyle(color: Colors.white),
                        decoration:
                            _inputDecoration('Year Level *', Icons.school),
                        items: _yearLevels
                            .map((y) => DropdownMenuItem(
                                  value: y,
                                  child: Text(y),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _yearLevel = v!),
                      ),
                      const SizedBox(height: 24),

                      // ── Additional Info ──
                      _sectionTitle('Additional Info'),
                      const SizedBox(height: 12),
                      _buildField(
                        controller: _bioController,
                        label: 'Bio',
                        icon: Icons.info_outline,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        controller: _hometownController,
                        label: 'Hometown',
                        icon: Icons.location_on,
                      ),
                      const SizedBox(height: 12),

                      // Birthday
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  color: Colors.white54, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                _birthday != null
                                    ? DateFormat('MMM dd, yyyy')
                                        .format(_birthday!)
                                    : 'Birthday (tap to select)',
                                style: TextStyle(
                                  color: _birthday != null
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.6),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Submit Button ──
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Add Profile',
                                  style: TextStyle(
                                    fontSize: 16,
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

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: _inputDecoration(label, icon),
      validator: validator,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
      prefixIcon: Icon(icon, color: Colors.white54, size: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primaryBlue),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
    );
  }
}

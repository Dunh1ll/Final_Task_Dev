import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/user_base.dart';
import '../utils/constants.dart';
import '../utils/image_helper.dart';

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
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;
  late final TextEditingController _ageController;
  late final TextEditingController _hometownController;
  late final TextEditingController _relationshipController;
  late final TextEditingController _educationController;
  late final TextEditingController _workController;
  late final TextEditingController _interestsController;
  String? _selectedGender;
  DateTime? _selectedBirthday;
  bool _isLoading = false;
  String? _errorMessage;

  Uint8List? _profilePictureBytes;
  Uint8List? _coverPhotoBytes;
  final ImagePicker _picker = ImagePicker();

  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Non-binary',
    'Prefer not to say'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email ?? '');
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
    _bioController = TextEditingController(text: widget.user.bio ?? '');
    _ageController = TextEditingController(
        text: widget.user.age != null ? widget.user.age.toString() : '');
    _hometownController =
        TextEditingController(text: widget.user.hometown ?? '');
    _relationshipController =
        TextEditingController(text: widget.user.relationshipStatus ?? '');
    _educationController =
        TextEditingController(text: widget.user.education ?? '');
    _workController = TextEditingController(text: widget.user.work ?? '');
    _interestsController =
        TextEditingController(text: widget.user.interests.join(', '));
    _selectedGender = widget.user.gender;
    _selectedBirthday = widget.user.birthday;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _ageController.dispose();
    _hometownController.dispose();
    _relationshipController.dispose();
    _educationController.dispose();
    _workController.dispose();
    _interestsController.dispose();
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

  Future<void> _pickBirthday() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime(2000),
      firstDate: DateTime(1900),
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
    if (picked != null) {
      setState(() => _selectedBirthday = picked);
    }
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final authProvider = context.read<AuthProvider>();

        // ✅ FIX: Send birthday as date-only string "YYYY-MM-DD"
        // NOT as full ISO8601 with timezone which causes Go parse error
        String? birthdayStr;
        if (_selectedBirthday != null) {
          // Format: "2003-05-15" — Go parses this without timezone issues
          birthdayStr = '${_selectedBirthday!.year.toString().padLeft(4, '0')}'
              '-${_selectedBirthday!.month.toString().padLeft(2, '0')}'
              '-${_selectedBirthday!.day.toString().padLeft(2, '0')}';
        }

        final updatedData = {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'bio': _bioController.text.trim(),
          'age': int.tryParse(_ageController.text.trim()),
          'gender': _selectedGender,
          // ✅ Send date-only format — no timezone suffix
          'birthday': birthdayStr,
          'hometown': _hometownController.text.trim(),
          'relationship_status': _relationshipController.text.trim(),
          'education': _educationController.text.trim(),
          'work': _workController.text.trim(),
          'interests': _interestsController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          if (_profilePictureBytes != null)
            'profile_picture_url':
                'data:image/jpeg;base64,${base64Encode(_profilePictureBytes!)}',
          if (_coverPhotoBytes != null)
            'cover_photo_url':
                'data:image/jpeg;base64,${base64Encode(_coverPhotoBytes!)}',
        };

        // Save to backend
        final isLocalOnly = widget.user.id.startsWith('sub_user_');
        if (!isLocalOnly) {
          final response = await authProvider.apiService
              .updateProfile(widget.user.id, updatedData);
          if (response.containsKey('error')) {
            setState(() {
              _errorMessage = response['error'];
              _isLoading = false;
            });
            return;
          }
        }

        // Pass bytes for local display
        if (_profilePictureBytes != null) {
          updatedData['profile_picture_bytes'] = _profilePictureBytes;
        }
        if (_coverPhotoBytes != null) {
          updatedData['cover_photo_bytes'] = _coverPhotoBytes;
        }

        widget.onSave(updatedData);
        setState(() => _isLoading = false);
        if (mounted) Navigator.pop(context);
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to save. Please try again.';
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
        width: 600,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.2),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white70),
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
                      // Error message
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

                      // Photos section
                      _sectionTitle('Photos'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Profile picture
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
                                      : widget.user.profilePicture != null
                                          ? DecorationImage(
                                              image: ImageHelper.buildProvider(
                                                widget.user.profilePicture,
                                                AssetPaths.defaultAvatar,
                                                bytes: widget
                                                    .user.profilePictureBytes,
                                              ),
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

                          // Cover photo
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
                                      : widget.user.coverPhoto != null
                                          ? DecorationImage(
                                              image: ImageHelper.buildProvider(
                                                widget.user.coverPhoto,
                                                AssetPaths.defaultCover,
                                                bytes:
                                                    widget.user.coverPhotoBytes,
                                              ),
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

                      // Basic info
                      _sectionTitle('Basic Info'),
                      const SizedBox(height: 12),
                      _buildField(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: Icons.person,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Name is required' : null,
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
                      const SizedBox(height: 24),

                      // Bio
                      _sectionTitle('Bio'),
                      const SizedBox(height: 12),
                      _buildField(
                        controller: _bioController,
                        label: 'About me',
                        icon: Icons.info_outline,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),

                      // Personal details
                      _sectionTitle('Personal Details'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              controller: _ageController,
                              label: 'Age',
                              icon: Icons.cake,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedGender,
                              dropdownColor: const Color(0xFF1E1E2E),
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputDecoration('Gender', Icons.wc),
                              items: _genderOptions
                                  .map((g) => DropdownMenuItem(
                                        value: g,
                                        child: Text(g),
                                      ))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedGender = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ✅ Birthday picker — shows date clearly
                      GestureDetector(
                        onTap: _pickBirthday,
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
                                _selectedBirthday != null
                                    ? 'Birthday: ${_selectedBirthday!.year}'
                                        '-${_selectedBirthday!.month.toString().padLeft(2, '0')}'
                                        '-${_selectedBirthday!.day.toString().padLeft(2, '0')}'
                                    : 'Birthday (tap to select)',
                                style: TextStyle(
                                  color: _selectedBirthday != null
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.6),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        controller: _hometownController,
                        label: 'Hometown',
                        icon: Icons.location_on,
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        controller: _relationshipController,
                        label: 'Relationship Status',
                        icon: Icons.favorite,
                      ),
                      const SizedBox(height: 24),

                      // Education & Work
                      _sectionTitle('Education & Work'),
                      const SizedBox(height: 12),
                      _buildField(
                        controller: _educationController,
                        label: 'Education',
                        icon: Icons.school,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        controller: _workController,
                        label: 'Work',
                        icon: Icons.work,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),

                      // Interests
                      _sectionTitle('Interests'),
                      const SizedBox(height: 12),
                      _buildField(
                        controller: _interestsController,
                        label: 'Interests (comma separated)',
                        icon: Icons.star,
                        maxLines: 2,
                        helperText: 'e.g. Music, Travel, Photography',
                      ),
                      const SizedBox(height: 32),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _save,
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
                                  'Save Changes',
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
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? helperText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: _inputDecoration(label, icon).copyWith(
        helperText: helperText,
        helperStyle: TextStyle(
          color: Colors.white.withOpacity(0.4),
          fontSize: 11,
        ),
      ),
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

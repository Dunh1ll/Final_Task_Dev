import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/sub_user.dart';
import '../models/user_base.dart';
import '../utils/constants.dart';
import '../utils/image_helper.dart';

// ─── One Piece Palette ─────────────────────────────────────────
const Color _kOceanDeep = Color(0xFF0B1C2E);
const Color _kOceanMid = Color(0xFF0F2538);
const Color _kOceanSurface = Color(0xFF163044);
const Color _kOceanHigher = Color(0xFF1D3A52);
const Color _kGold = Color(0xFFD4A017);
const Color _kBrightGold = Color(0xFFFFD700);
const Color _kAgedGold = Color(0xFF9B7B1A);
const Color _kStrawHatRed = Color(0xFFCC2200);
const Color _kCrimson = Color(0xFF8B1A1A);
const Color _kParchment = Color(0xFFF5DEB3);
const Color _kParchmentDim = Color(0xFFB8965A);
const Color _kError = Color(0xFFE05C6F);

const List<String> _kRelationshipOptions = [
  'Single',
  'In a Relationship',
  'Engaged',
  'Married',
  'Separated',
  'Divorced',
  'Widowed',
  "It's Complicated",
  'Prefer not to say',
];

const List<String> _kGenderOptions = [
  'Male',
  'Female',
  'Non-binary',
  'Genderqueer',
  'Genderfluid',
  'Agender',
  'Prefer not to say',
];

/// EditSubUserDialog
///
/// Email is read-only and cannot be changed after account creation.
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

class _EditSubUserDialogState extends State<EditSubUserDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _yearLevelCtrl;
  late final TextEditingController _hometownCtrl;
  late final TextEditingController _educationCtrl;
  late final TextEditingController _schoolCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _interestsCtrl;
  String? _selectedGender;
  String? _selectedRelationship;

  Uint8List? _profileImageBytes;
  String? _profileImageBase64;
  DateTime? _birthday;

  bool _isSaving = false;
  String? _saveError;
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.name);
    _bioCtrl = TextEditingController(text: widget.user.bio ?? '');
    _ageCtrl = TextEditingController(text: widget.user.age?.toString() ?? '');
    _yearLevelCtrl = TextEditingController(text: widget.user.yearLevel ?? '');
    _hometownCtrl = TextEditingController(text: widget.user.hometown ?? '');
    _educationCtrl = TextEditingController(text: widget.user.education ?? '');
    _schoolCtrl = TextEditingController(text: '');
    _emailCtrl = TextEditingController(text: widget.user.email ?? '');
    _phoneCtrl = TextEditingController(text: widget.user.phone ?? '');
    _interestsCtrl =
        TextEditingController(text: widget.user.interests.join(', '));
    final existingRel = widget.user.relationshipStatus?.trim() ?? '';
    _selectedRelationship = _kRelationshipOptions.firstWhere(
      (o) => o.toLowerCase() == existingRel.toLowerCase(),
      orElse: () => '',
    );
    if (_selectedRelationship!.isEmpty) _selectedRelationship = null;

    final existingGender = widget.user.gender?.trim() ?? '';
    _selectedGender = _kGenderOptions.firstWhere(
      (o) => o.toLowerCase() == existingGender.toLowerCase(),
      orElse: () => '',
    );
    if (_selectedGender!.isEmpty) _selectedGender = null;

    _profileImageBytes = widget.user.profilePictureBytes;
    _birthday = widget.user.birthday;

    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _ageCtrl.dispose();
    _yearLevelCtrl.dispose();
    _hometownCtrl.dispose();
    _educationCtrl.dispose();
    _schoolCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _interestsCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickProfilePicture() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _profileImageBytes = bytes;
      _profileImageBase64 = 'data:image/jpeg;base64,${base64Encode(bytes)}';
    });
  }

  // ── Save tapped ────────────────────────────────────────────────
  Future<void> _onSaveTapped() async {
    if (!_formKey.currentState!.validate()) return;
    await _performSave();
  }

  // ── Actual save to backend ──────────────────────────────────────
  Future<void> _performSave() async {
    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    final interests = _interestsCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final profilePicUrl = _profileImageBase64 ?? widget.user.profilePicture;

    String? ownerUserId;
    if (widget.user is SubUser) {
      ownerUserId = (widget.user as SubUser).ownerUserId;
    }

    String? birthdayStr;
    if (_birthday != null) {
      birthdayStr = '${_birthday!.year.toString().padLeft(4, '0')}'
          '-${_birthday!.month.toString().padLeft(2, '0')}'
          '-${_birthday!.day.toString().padLeft(2, '0')}';
    }

    final apiData = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      'bio': _bioCtrl.text.trim(),
      'age': int.tryParse(_ageCtrl.text.trim()),
      'gender': _selectedGender ?? '',
      'year_level': _yearLevelCtrl.text.trim(),
      'hometown': _hometownCtrl.text.trim(),
      'relationship_status': _selectedRelationship ?? '',
      'education': _educationCtrl.text.trim(),
      'school': _schoolCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'interests': interests,
      if (birthdayStr != null) 'birthday': birthdayStr,
      if (profilePicUrl != null) 'profile_picture_url': profilePicUrl,
    };

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

    final updatedData = <String, dynamic>{
      'id': widget.user.id,
      'owner_user_id': ownerUserId,
      'user_id': ownerUserId,
      'name': _nameCtrl.text.trim(),
      'bio': _bioCtrl.text.trim(),
      'age': int.tryParse(_ageCtrl.text.trim()),
      'gender': _selectedGender ?? '',
      'year_level': _yearLevelCtrl.text.trim(),
      'hometown': _hometownCtrl.text.trim(),
      'relationship_status': _selectedRelationship ?? '',
      'education': _educationCtrl.text.trim(),
      'school': _schoolCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'interests': interests,
      'birthday': _birthday,
      'profile_picture_url': profilePicUrl,
      'profile_picture_bytes': _profileImageBytes,
    };

    setState(() => _isSaving = false);
    widget.onSave(updatedData);
    if (mounted) Navigator.pop(context);
  }

  // ══════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final dialogWidth = sw < 600 ? sw * 0.95 : 560.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: Container(
            width: dialogWidth,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.90,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_kOceanMid, _kOceanDeep],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: _kAgedGold.withOpacity(0.55), width: 1.5),
              boxShadow: [
                BoxShadow(
                    color: _kGold.withOpacity(0.14),
                    blurRadius: 48,
                    spreadRadius: 2,
                    offset: const Offset(0, 6)),
                BoxShadow(
                    color: Colors.black.withOpacity(0.65), blurRadius: 32),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  Flexible(
                    child: _buildMainForm(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── HEADER ──────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _kStrawHatRed.withOpacity(0.22),
            _kOceanDeep.withOpacity(0.0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          bottom: BorderSide(color: _kAgedGold.withOpacity(0.4), width: 1),
        ),
      ),
      child: Row(children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_kStrawHatRed, Color(0xFF8B1A1A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kGold.withOpacity(0.5), width: 1),
            boxShadow: [
              BoxShadow(
                  color: _kStrawHatRed.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 3)),
            ],
          ),
          child: Center(
            child: Text(
              '⚓',
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Crew Member',
                style: const TextStyle(
                  color: _kBrightGold,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
              Text(
                "Update the navigator's log",
                style: TextStyle(
                  color: _kParchmentDim.withOpacity(0.75),
                  fontSize: 11.5,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _kOceanHigher,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _kAgedGold.withOpacity(0.3)),
            ),
            child: Icon(Icons.close_rounded, color: _kParchmentDim, size: 17),
          ),
        ),
      ]),
    );
  }

  // ── MAIN FORM ───────────────────────────────────────────────────
  Widget _buildMainForm() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 30),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_saveError != null) ...[
              _buildErrorBanner(_saveError!),
              const SizedBox(height: 18),
            ],

            _sectionLabel('⚓  Crew Photo'),
            const SizedBox(height: 12),
            _buildPhotoSection(),

            const SizedBox(height: 24),
            _buildRopeSeparator('🗺️  Basic Info'),
            const SizedBox(height: 16),
            _buildField(_nameCtrl, 'Full Name', Icons.badge_outlined,
                required: true),
            const SizedBox(height: 14),
            _buildField(_bioCtrl, 'Bio / About', Icons.notes_rounded,
                maxLines: 3),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: _buildField(_ageCtrl, 'Age', Icons.cake_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
              ),
              const SizedBox(width: 12),
              Expanded(child: _buildGenderDropdown()),
            ]),
            const SizedBox(height: 14),
            _buildField(_yearLevelCtrl, 'Year Level', Icons.layers_outlined),

            const SizedBox(height: 24),
            _buildRopeSeparator('🎂  Birthday'),
            const SizedBox(height: 16),
            _buildBirthdayPicker(),

            const SizedBox(height: 24),
            _buildRopeSeparator('📡  Contact'),
            const SizedBox(height: 16),

            // Email with change-indicator badge
            _buildEmailField(),
            const SizedBox(height: 14),
            _buildPhoneField(),

            const SizedBox(height: 24),
            _buildRopeSeparator('🌊  Background'),
            const SizedBox(height: 16),
            _buildField(
                _hometownCtrl, 'Hometown / Island', Icons.location_on_outlined),
            const SizedBox(height: 14),
            _buildRelationshipDropdown(),
            const SizedBox(height: 14),
            _buildField(
                _educationCtrl, 'Education Level', Icons.school_outlined),
            const SizedBox(height: 14),
            _buildField(_schoolCtrl, 'School / University',
                Icons.account_balance_outlined),
            const SizedBox(height: 14),
            _buildField(_interestsCtrl, 'Interests (comma separated)',
                Icons.interests_outlined),

            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  // ── HELPERS ─────────────────────────────────────────────────────
  Widget _sectionLabel(String text) => Text(text,
      style: const TextStyle(
          color: _kBrightGold,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5));

  Widget _buildRopeSeparator(String label) => Row(children: [
        Text(label,
            style: const TextStyle(
                color: _kGold,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4)),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                _kAgedGold.withOpacity(0.7),
                _kAgedGold.withOpacity(0.0),
              ]),
            ),
          ),
        ),
      ]);

  Widget _buildErrorBanner(String msg) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _kCrimson.withOpacity(0.18),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _kCrimson.withOpacity(0.5)),
        ),
        child: Row(children: [
          const Icon(Icons.error_outline_rounded, color: _kError, size: 17),
          const SizedBox(width: 10),
          Expanded(
              child: Text(msg,
                  style:
                      const TextStyle(color: Color(0xFFFF9999), fontSize: 13))),
        ]),
      );

  Widget _buildPhotoSection() => Row(children: [
        GestureDetector(
          onTap: _pickProfilePicture,
          child: Stack(children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _kGold.withOpacity(0.55), width: 2),
                boxShadow: [
                  BoxShadow(
                      color: _kGold.withOpacity(0.12),
                      blurRadius: 14,
                      offset: const Offset(0, 4)),
                ],
                image: _profileImageBytes != null
                    ? DecorationImage(
                        image: MemoryImage(_profileImageBytes!),
                        fit: BoxFit.cover)
                    : DecorationImage(
                        image: ImageHelper.buildProvider(
                            widget.user.profilePicture,
                            AssetPaths.defaultAvatar),
                        fit: BoxFit.cover),
              ),
            ),
            Positioned(
              right: 4,
              bottom: 4,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: _kStrawHatRed,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: _kGold.withOpacity(0.4), width: 1),
                ),
                child: const Icon(Icons.camera_alt_rounded,
                    color: Colors.white, size: 13),
              ),
            ),
          ]),
        ),
        const SizedBox(width: 16),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Crew Portrait',
                style: TextStyle(
                    color: _kParchment,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 5),
            Text('Tap the portrait to upload a new photo.',
                style: TextStyle(
                    color: _kParchmentDim.withOpacity(0.75),
                    fontSize: 12,
                    height: 1.45)),
          ]),
        ),
      ]);

  Widget _buildBirthdayPicker() => GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: _birthday ?? DateTime(2000),
            firstDate: DateTime(1950),
            lastDate: DateTime.now(),
            builder: (ctx, child) => Theme(
              data: Theme.of(ctx).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: _kGold,
                  onPrimary: _kOceanDeep,
                  surface: _kOceanMid,
                  onSurface: _kParchment,
                ),
              ),
              child: child!,
            ),
          );
          if (picked != null) setState(() => _birthday = picked);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: _kOceanSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _kAgedGold.withOpacity(0.45)),
          ),
          child: Row(children: [
            const Icon(Icons.calendar_month_rounded, color: _kGold, size: 18),
            const SizedBox(width: 10),
            Text(
              _birthday != null
                  ? DateFormat('MMMM dd, yyyy').format(_birthday!)
                  : 'Select birthday',
              style: TextStyle(
                color: _birthday != null ? _kParchment : _kParchmentDim,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: _kAgedGold, size: 18),
          ]),
        ),
      );

  Widget _buildGenderDropdown() => DropdownButtonFormField<String>(
        value: _selectedGender,
        hint: Text('Gender',
            style: TextStyle(color: _kParchmentDim, fontSize: 14)),
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: _kAgedGold),
        dropdownColor: _kOceanHigher,
        style: const TextStyle(color: _kParchment, fontSize: 14),
        isExpanded: true,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.people_alt_outlined, color: _kGold, size: 18),
          labelText: 'Gender',
          labelStyle: TextStyle(color: _kParchmentDim, fontSize: 13),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: _kAgedGold.withOpacity(0.4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _kGold, width: 1.5),
          ),
          filled: true,
          fillColor: _kOceanSurface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        items: _kGenderOptions
            .map((o) => DropdownMenuItem(
                  value: o,
                  child: Text(o, style: const TextStyle(color: _kParchment)),
                ))
            .toList(),
        onChanged: (v) => setState(() => _selectedGender = v),
      );

  Widget _buildRelationshipDropdown() => DropdownButtonFormField<String>(
        value: _selectedRelationship,
        hint: Text('Relationship Status',
            style: TextStyle(color: _kParchmentDim, fontSize: 14)),
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: _kAgedGold),
        dropdownColor: _kOceanHigher,
        style: const TextStyle(color: _kParchment, fontSize: 14),
        decoration: InputDecoration(
          prefixIcon:
              Icon(Icons.favorite_outline_rounded, color: _kGold, size: 18),
          labelText: 'Relationship Status',
          labelStyle: TextStyle(color: _kParchmentDim, fontSize: 13),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: _kAgedGold.withOpacity(0.4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _kGold, width: 1.5),
          ),
          filled: true,
          fillColor: _kOceanSurface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        items: _kRelationshipOptions
            .map((o) => DropdownMenuItem(
                  value: o,
                  child: Text(o, style: const TextStyle(color: _kParchment)),
                ))
            .toList(),
        onChanged: (v) => setState(() => _selectedRelationship = v),
      );

  Widget _buildEmailField() {
    final email = widget.user.email ?? '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: _kOceanSurface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kAgedGold.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.email_outlined,
              color: _kAgedGold.withOpacity(0.5), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Email',
                  style: TextStyle(
                    color: _kParchmentDim.withOpacity(0.55),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email.isNotEmpty ? email : '—',
                  style: TextStyle(
                    color: _kParchment.withOpacity(0.55),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.lock_outline_rounded,
              color: _kAgedGold.withOpacity(0.4), size: 15),
        ],
      ),
    );
  }

  Widget _buildPhoneField() => TextFormField(
        controller: _phoneCtrl,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(color: _kParchment, fontSize: 14),
        decoration: InputDecoration(
          labelText: 'Phone Number',
          labelStyle: TextStyle(color: _kParchmentDim, fontSize: 13),
          prefixIcon: Icon(Icons.phone_outlined, color: _kGold, size: 18),
          helperText: 'Numbers only',
          helperStyle:
              TextStyle(color: _kParchmentDim.withOpacity(0.65), fontSize: 11),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: _kAgedGold.withOpacity(0.4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _kGold, width: 1.5),
          ),
          filled: true,
          fillColor: _kOceanSurface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      );

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) =>
      TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(color: _kParchment, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: _kParchmentDim, fontSize: 13),
          prefixIcon: Icon(icon, color: _kGold, size: 18),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: _kAgedGold.withOpacity(0.4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _kGold, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _kError),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _kError, width: 1.5),
          ),
          filled: true,
          fillColor: _kOceanSurface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        validator: required
            ? (v) {
                if (v == null || v.trim().isEmpty) return '$label is required';
                return null;
              }
            : null,
      );

  Widget _buildSaveButton() => SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _onSaveTapped,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: _isSaving
                  ? null
                  : const LinearGradient(
                      colors: [_kStrawHatRed, Color(0xFFB01800)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              color: _isSaving ? _kOceanHigher : null,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kGold.withOpacity(0.55), width: 1.2),
              boxShadow: _isSaving
                  ? null
                  : [
                      BoxShadow(
                          color: _kStrawHatRed.withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 4))
                    ],
            ),
            child: Container(
              alignment: Alignment.center,
              child: _isSaving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: _kGold))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('⚓', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        const Text(
                          'Save Changes',
                          style: const TextStyle(
                            color: _kParchment,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      );
}

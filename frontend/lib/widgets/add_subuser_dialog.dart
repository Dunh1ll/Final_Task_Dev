import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/sub_user.dart';
import '../utils/constants.dart';

/// AddSubUserDialog — shown when a main user taps "Add Profile".
///
/// ✅ CHANGED: Now asks for name, email, and password.
/// When submitted, it calls the REGISTER endpoint which:
///   1. Creates a user account in the users table
///   2. Auto-creates a default profile in the profiles table
///   3. Returns the new profile so it appears in the dashboard immediately
///
/// The new user can then log in with the email and password set here.
/// They get default profile and cover photos but can edit everything.
class AddSubUserDialog extends StatefulWidget {
  /// Called when the user is successfully created.
  /// Passes the newly created SubUser so the dashboard can add it to the list.
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

  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Submit the form — calls the register API endpoint.
  ///
  /// This creates both:
  ///   1. A user account (email + hashed password in users table)
  ///   2. A default profile (in profiles table with default photos)
  ///
  /// The user can immediately log in with the provided email and password.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final auth = context.read<AuthProvider>();

      // ✅ Call the REGISTER endpoint — not the create profile endpoint
      // This creates a full account + default profile in one shot
      final response = await auth.apiService.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        '', // phone is optional — user can add it when editing their profile
      );

      if (response.containsKey('error')) {
        setState(() {
          _errorMessage = response['error'];
          _isLoading = false;
        });
        return;
      }

      // Registration succeeded — now fetch the newly created profile
      // so we can pass it to the dashboard list
      // The register response contains the user info but not the full profile,
      // so we reload the public profiles to find the new one
      final profilesResponse = await auth.apiService.getPublicProfiles();

      SubUser? newUser;

      if (!profilesResponse.containsKey('error')) {
        final List<dynamic> list =
            profilesResponse['sub_users'] ?? profilesResponse['profiles'] ?? [];

        // Find the profile matching the email we just registered
        final match = list.where((p) {
          final profileEmail = p['email']?.toString() ?? '';
          return profileEmail == _emailController.text.trim();
        }).toList();

        if (match.isNotEmpty) {
          newUser =
              SubUser.fromJson(Map<String, dynamic>.from(match.first as Map));
        }
      }

      // If we couldn't find the profile, create a minimal local one
      // so the dashboard still shows it before the next reload
      newUser ??= SubUser(
        id: response['user']?['id']?.toString() ?? '',
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        profilePicture: AssetPaths.defaultAvatar,
        coverPhoto: AssetPaths.defaultCover,
        age: null,
        gender: null,
        yearLevel: null,
      );

      setState(() => _isLoading = false);

      widget.onSubmit(newUser);

      if (mounted) Navigator.pop(context);

      // Show success message with login credentials
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Account created for ${_nameController.text.trim()}! '
              'They can now log in with their email and password.',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to create account. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 480,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.80,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.15),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.person_add,
                      color: AppColors.lightGreen,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add New User',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Create an account they can log in with',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon:
                        Icon(Icons.close, color: Colors.white.withOpacity(0.6)),
                  ),
                ],
              ),
            ),

            // ── Form ──────────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info banner
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.primaryBlue.withOpacity(0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.lightGreen,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'The user will get default profile and cover '
                                'photos. They can edit their full profile '
                                'after logging in.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Error message
                      if (_errorMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: Colors.red.withOpacity(0.4)),
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

                      // Full Name field
                      _buildLabel('Full Name'),
                      const SizedBox(height: 6),
                      _buildField(
                        controller: _nameController,
                        hint: 'Enter full name',
                        icon: Icons.person_outline,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Full name is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Email field
                      _buildLabel('Email Address'),
                      const SizedBox(height: 6),
                      _buildField(
                        controller: _emailController,
                        hint: 'Enter email address',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!v.contains('@') || !v.contains('.')) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Password field
                      _buildLabel('Password'),
                      const SizedBox(height: 6),
                      _buildField(
                        controller: _passwordController,
                        hint: 'Create a password',
                        icon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white38,
                            size: 20,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Password is required';
                          }
                          if (v.length < 8) {
                            return 'Minimum 8 characters';
                          }
                          if (!v.contains(RegExp(r'[A-Z]'))) {
                            return 'Must include an uppercase letter';
                          }
                          if (!v.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                            return 'Must include a special character';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 8),

                      // Password requirements hint
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          'Min 8 chars · 1 uppercase · 1 special character',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 11,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Submit button
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
                            elevation: 0,
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
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.person_add, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'Create Account',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withOpacity(0.8),
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.3),
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
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
        fillColor: Colors.white.withOpacity(0.04),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: validator,
    );
  }
}

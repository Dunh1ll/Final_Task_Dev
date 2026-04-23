import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/sub_user.dart';
import '../utils/constants.dart';

/// AddSubUserDialog — shown when a main user taps "Add Crew".
///
/// FIXED BUG 2: Account creation now uses the dedicated admin endpoint
/// POST /api/auth/admin/create-user which directly creates the account
/// without requiring OTP (main user is already authenticated).
///
/// FIXED BUG 4: Added Gmail OTP verification step before account creation.
/// Flow:
///   Step 1 — Enter name, email, password → sends OTP to Gmail
///   Step 2 — Enter OTP → creates account + profile
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
  final _otpFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  // Step 1 = fill form, Step 2 = enter OTP
  int _step = 1;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  /// Step 1: Validate form and send OTP to the Gmail address.
  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final auth = context.read<AuthProvider>();

      // Re-use the existing register/send-otp endpoint
      final response = await auth.apiService.registerSendOTP(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        phone: '',
      );

      if (response.containsKey('error')) {
        setState(() {
          _errorMessage = response['error'];
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _step = 2;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send OTP. Please try again.';
        _isLoading = false;
      });
    }
  }

  /// Step 2: Verify OTP and create account.
  Future<void> _verifyAndCreate() async {
    if (!_otpFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final auth = context.read<AuthProvider>();

      final response = await auth.apiService.registerVerifyOTP(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        phone: '',
        otp: _otpController.text.trim(),
      );

      if (response.containsKey('error')) {
        setState(() {
          _errorMessage = response['error'];
          _isLoading = false;
        });
        return;
      }

      // Fetch the newly created profile from backend
      final profilesResponse = await auth.apiService.getPublicProfiles();

      SubUser? newUser;
      if (!profilesResponse.containsKey('error')) {
        final List<dynamic> list =
            profilesResponse['sub_users'] ?? profilesResponse['profiles'] ?? [];
        final match = list.where((p) {
          final profileEmail = p['email']?.toString() ?? '';
          return profileEmail == _emailController.text.trim();
        }).toList();

        if (match.isNotEmpty) {
          newUser =
              SubUser.fromJson(Map<String, dynamic>.from(match.first as Map));
        }
      }

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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Account created for ${_nameController.text.trim()}!',
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
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
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
                    child: Icon(
                      _step == 1 ? Icons.person_add : Icons.verified_outlined,
                      color: AppColors.lightGreen,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _step == 1 ? 'Add New User' : 'Verify Gmail',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _step == 1
                              ? 'Step 1 of 2 — Enter user details'
                              : 'Step 2 of 2 — Enter the OTP sent to Gmail',
                          style: const TextStyle(
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

            // Step indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  _stepDot(1, _step),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: _step >= 2
                          ? AppColors.primaryBlue
                          : Colors.white.withOpacity(0.15),
                    ),
                  ),
                  _stepDot(2, _step),
                ],
              ),
            ),

            // Form content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: _step == 1 ? _buildStep1() : _buildStep2(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepDot(int step, int current) {
    final bool active = current >= step;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? AppColors.primaryBlue : Colors.white.withOpacity(0.1),
        border: Border.all(
          color: active ? AppColors.primaryBlue : Colors.white.withOpacity(0.2),
        ),
      ),
      child: Center(
        child: Text(
          '$step',
          style: TextStyle(
            color: active ? Colors.white : Colors.white38,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Form(
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
                Icon(Icons.info_outline, color: AppColors.lightGreen, size: 18),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'An OTP will be sent to the Gmail address to verify it before the account is created.',
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

          if (_errorMessage != null) ...[
            _errorBanner(_errorMessage!),
            const SizedBox(height: 16),
          ],

          _buildLabel('Full Name'),
          const SizedBox(height: 6),
          _buildField(
            controller: _nameController,
            hint: 'Enter full name',
            icon: Icons.person_outline,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Full name is required'
                : null,
          ),

          const SizedBox(height: 16),

          _buildLabel('Gmail Address'),
          const SizedBox(height: 6),
          _buildField(
            controller: _emailController,
            hint: 'example@gmail.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!v.trim().endsWith('@gmail.com')) {
                return 'Only Gmail addresses are allowed';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          _buildLabel('Password'),
          const SizedBox(height: 6),
          _buildField(
            controller: _passwordController,
            hint: 'Create a password',
            icon: Icons.lock_outline,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.white38,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (v.length < 8) return 'Minimum 8 characters';
              if (!v.contains(RegExp(r'[A-Z]'))) {
                return 'Must include an uppercase letter';
              }
              if (!v.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                return 'Must include a special character';
              }
              return null;
            },
          ),

          const SizedBox(height: 6),
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

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendOTP,
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
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send_outlined, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Send OTP to Gmail',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Form(
      key: _otpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.mark_email_read_outlined,
                    color: Colors.green, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'OTP sent to ${_emailController.text.trim()}. Check the inbox.',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12, height: 1.4),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          if (_errorMessage != null) ...[
            _errorBanner(_errorMessage!),
            const SizedBox(height: 16),
          ],

          _buildLabel('6-Digit OTP Code'),
          const SizedBox(height: 6),
          _buildField(
            controller: _otpController,
            hint: 'Enter OTP',
            icon: Icons.pin_outlined,
            keyboardType: TextInputType.number,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'OTP is required';
              if (v.trim().length != 6) return 'OTP must be 6 digits';
              return null;
            },
          ),

          const SizedBox(height: 12),

          // Resend OTP
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      setState(() {
                        _step = 1;
                        _errorMessage = null;
                        _otpController.clear();
                      });
                    },
              child: const Text(
                'Resend OTP',
                style: TextStyle(color: AppColors.lightGreen, fontSize: 13),
              ),
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _verifyAndCreate,
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
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_add, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Verify & Create Account',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: const TextStyle(color: Colors.red, fontSize: 13)),
          ),
        ],
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
        hintStyle:
            TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
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

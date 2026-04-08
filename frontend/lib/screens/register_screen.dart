import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/video_background.dart';

/// RegisterScreen — 2-step Gmail OTP registration.
///
/// ✅ FEATURE: Before creating an account, the user must verify
/// their Gmail address via a 6-digit OTP sent to their email.
///
/// Step 1 — Fill in form (name, Gmail, password, phone)
///           → validates all fields
///           → calls POST /api/auth/register/send-otp
///           → OTP sent to Gmail
///
/// Step 2 — Enter 6-digit OTP from Gmail
///           → calls POST /api/auth/register/verify-otp
///           → account created + auto-login → /dashboard
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  // Which step is showing: 1 = form, 2 = OTP entry
  int _step = 1;

  // Step 1 — form fields
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSendingOTP = false;
  String? _formError;

  // Step 2 — OTP entry
  final _otpFormKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  bool _isVerifying = false;
  String? _otpError;

  // Resend countdown
  int _resendCountdown = 0;
  bool _canResend = false;

  // Transition animation
  late AnimationController _animController;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _animateToStep(int step) {
    _animController.reset();
    setState(() => _step = step);
    _animController.forward();
  }

  // ── STEP 1: Send OTP ──────────────────────────────────────────

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSendingOTP = true;
      _formError = null;
    });

    final response = await _apiService.registerSendOTP(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim().toLowerCase(),
      password: _passwordController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    if (mounted) {
      if (response.containsKey('error')) {
        setState(() {
          _formError = response['error'];
          _isSendingOTP = false;
        });
      } else {
        setState(() {
          _isSendingOTP = false;
          _resendCountdown = 60;
          _canResend = false;
        });
        _startCountdown();
        _animateToStep(2);
      }
    }
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _resendCountdown--;
        if (_resendCountdown <= 0) {
          _canResend = true;
          _resendCountdown = 0;
        }
      });
      return _resendCountdown > 0;
    });
  }

  // ── STEP 2: Verify OTP + Create Account ───────────────────────

  Future<void> _verifyAndRegister() async {
    if (!_otpFormKey.currentState!.validate()) return;

    setState(() {
      _isVerifying = true;
      _otpError = null;
    });

    final response = await _apiService.registerVerifyOTP(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim().toLowerCase(),
      password: _passwordController.text.trim(),
      phone: _phoneController.text.trim(),
      otp: _otpController.text.trim(),
    );

    if (mounted) {
      if (response.containsKey('error')) {
        setState(() {
          _otpError = response['error'];
          _isVerifying = false;
        });
      } else if (response.containsKey('token')) {
        // Account created — log user in via AuthProvider
        final auth = context.read<AuthProvider>();
        // Manually update auth state with the returned token
        await auth.loginWithToken(response);
        if (mounted) {
          context.go('/dashboard');
        }
      } else {
        setState(() {
          _otpError = 'Unexpected response. Please try again.';
          _isVerifying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              if (_step == 2) {
                _animateToStep(1);
              } else {
                context.go('/');
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                shape: BoxShape.circle,
                border:
                    Border.all(color: Colors.white.withOpacity(0.25), width: 1),
              ),
              child:
                  const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          const VideoBackground(
            videoPath: AssetPaths.loginBackgroundVideo,
          ),
          Container(color: Colors.black.withOpacity(0.55)),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: _step == 1 ? _buildFormStep() : _buildOTPStep(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── STEP 1 UI — Registration Form ─────────────────────────────

  Widget _buildFormStep() {
    return Container(
      width: 480,
      padding: const EdgeInsets.all(36),
      decoration: _cardDecoration(),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                height: 52,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.account_circle,
                  color: Colors.white,
                  size: 52,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Step indicator
            _buildStepDots(1),
            const SizedBox(height: 24),

            const Text(
              'Create Account',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Fill in your details below',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            // Error
            if (_formError != null) ...[
              _errorBox(_formError!),
              const SizedBox(height: 16),
            ],

            // Full Name
            _buildField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person_outline,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Gmail — only @gmail.com allowed
            _buildField(
              controller: _emailController,
              label: 'Gmail Address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please enter your Gmail';
                }
                if (!v.trim().toLowerCase().endsWith('@gmail.com')) {
                  return 'Only Gmail accounts are allowed '
                      '(@gmail.com)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Phone
            _buildField(
              controller: _phoneController,
              label: 'Phone Number (optional)',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Password
            _buildField(
              controller: _passwordController,
              label: 'Password',
              icon: Icons.lock_outline,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white54,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Please enter a password';
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
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                'Min 8 chars · 1 uppercase · 1 special char',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Send OTP button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isSendingOTP ? null : _sendOTP,
                style: _primaryButtonStyle(),
                child: _isSendingOTP
                    ? _loadingSpinner()
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_outlined, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Send Verification Code',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.go('/login'),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── STEP 2 UI — OTP Verification ──────────────────────────────

  Widget _buildOTPStep() {
    return Container(
      width: 460,
      padding: const EdgeInsets.all(36),
      decoration: _cardDecoration(),
      child: Form(
        key: _otpFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Step indicator
            _buildStepDots(2),
            const SizedBox(height: 28),

            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.primaryBlue.withOpacity(0.4), width: 2),
              ),
              child: const Icon(Icons.mark_email_read_outlined,
                  color: AppColors.lightGreen, size: 30),
            ),
            const SizedBox(height: 20),

            const Text(
              'Check Your Gmail',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'We sent a 6-digit code to\n'
              '${_emailController.text.trim()}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.55),
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            // Error
            if (_otpError != null) ...[
              _errorBox(_otpError!),
              const SizedBox(height: 16),
            ],

            // OTP input — large monospace digits
            TextFormField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w800,
                letterSpacing: 14,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '000000',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.15),
                  fontSize: 36,
                  letterSpacing: 14,
                  fontFamily: 'monospace',
                ),
                counterText: '',
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: AppColors.primaryBlue, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                contentPadding: const EdgeInsets.symmetric(vertical: 20),
              ),
              validator: (v) {
                if (v == null || v.trim().length != 6) {
                  return 'Enter the 6-digit code';
                }
                return null;
              },
            ),

            const SizedBox(height: 8),
            Text(
              'Code expires in 10 minutes',
              style: TextStyle(
                color: Colors.white.withOpacity(0.35),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 28),

            // Verify button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isVerifying ? null : _verifyAndRegister,
                style: _primaryButtonStyle(),
                child: _isVerifying
                    ? _loadingSpinner()
                    : const Text(
                        'Verify & Create Account',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Resend
            _canResend
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        _canResend = false;
                        _otpError = null;
                        _otpController.clear();
                      });
                      _sendOTP();
                    },
                    child: Text(
                      'Resend Code',
                      style: TextStyle(
                        color: AppColors.lightGreen,
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.lightGreen.withOpacity(0.5),
                      ),
                    ),
                  )
                : Text(
                    _resendCountdown > 0
                        ? 'Resend in ${_resendCountdown}s'
                        : 'Loading...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 13,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // ── SHARED UI HELPERS ─────────────────────────────────────────

  Widget _buildStepDots(int current) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (i) {
        final step = i + 1;
        final isActive = current == step;
        final isDone = current > step;
        return Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: isActive ? 28 : 10,
              height: 10,
              decoration: BoxDecoration(
                color: isDone || isActive
                    ? AppColors.primaryBlue
                    : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            if (i < 1)
              Container(
                width: 20,
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: isDone
                    ? AppColors.primaryBlue.withOpacity(0.5)
                    : Colors.white.withOpacity(0.1),
              ),
          ],
        );
      }),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.07),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.15)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 40,
          spreadRadius: 5,
        ),
      ],
    );
  }

  ButtonStyle _primaryButtonStyle() => ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      );

  Widget _loadingSpinner() => const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      );

  Widget _errorBox(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
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
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
        prefixIcon: Icon(icon, color: Colors.white54, size: 20),
        suffixIcon: suffixIcon,
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
      ),
      validator: validator,
    );
  }
}

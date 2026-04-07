import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/video_background.dart';

/// ForgotPasswordScreen — 3-step OTP-based password reset.
///
/// ✅ FEATURE 2: Gmail OTP verification flow.
///
/// Step 1 — Enter Gmail:
///   User enters their Gmail address.
///   App sends OTP to their Gmail via backend SMTP.
///
/// Step 2 — Enter OTP:
///   User enters the 6-digit OTP from their email.
///   Backend verifies OTP and returns a reset_token.
///
/// Step 3 — Reset Password:
///   User enters and confirms their new password.
///   Backend updates password_hash in database.
///   User is redirected to login.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  // Current step: 1 = email, 2 = OTP, 3 = new password
  int _currentStep = 1;

  // Step 1 state
  final _emailFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSendingOTP = false;
  String? _emailError;

  // Step 2 state
  final _otpFormKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  bool _isVerifyingOTP = false;
  String? _otpError;
  String? _resetToken; // received after OTP verification

  // Step 3 state
  final _passwordFormKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isResetting = false;
  String? _passwordError;
  bool _resetComplete = false;

  // Resend OTP countdown
  int _resendCountdown = 0;
  bool _canResend = false;

  // Animation for step transitions
  late AnimationController _stepAnimController;
  late Animation<double> _stepFade;
  late Animation<Offset> _stepSlide;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _stepAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _stepFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _stepAnimController, curve: Curves.easeOut),
    );
    _stepSlide = Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _stepAnimController, curve: Curves.easeOut));
    _stepAnimController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _stepAnimController.dispose();
    super.dispose();
  }

  /// Animate transition to a new step
  void _goToStep(int step) {
    _stepAnimController.reset();
    setState(() => _currentStep = step);
    _stepAnimController.forward();
  }

  // ── STEP 1: Send OTP ────────────────────────────────────────────

  Future<void> _sendOTP() async {
    if (!_emailFormKey.currentState!.validate()) return;

    setState(() {
      _isSendingOTP = true;
      _emailError = null;
    });

    final email = _emailController.text.trim().toLowerCase();
    final response = await _apiService.sendOTP(email);

    if (mounted) {
      if (response.containsKey('error')) {
        setState(() {
          _emailError = response['error'];
          _isSendingOTP = false;
        });
      } else {
        setState(() {
          _isSendingOTP = false;
          // Start 60-second resend countdown
          _resendCountdown = 60;
          _canResend = false;
        });
        _startResendCountdown();
        _goToStep(2);
      }
    }
  }

  /// Start the 60-second countdown before resend is allowed
  void _startResendCountdown() {
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

  // ── STEP 2: Verify OTP ──────────────────────────────────────────

  Future<void> _verifyOTP() async {
    if (!_otpFormKey.currentState!.validate()) return;

    setState(() {
      _isVerifyingOTP = true;
      _otpError = null;
    });

    final email = _emailController.text.trim().toLowerCase();
    final otp = _otpController.text.trim();

    final response = await _apiService.verifyOTP(email, otp);

    if (mounted) {
      if (response.containsKey('error')) {
        setState(() {
          _otpError = response['error'];
          _isVerifyingOTP = false;
        });
      } else {
        // Store the reset token for step 3
        _resetToken = response['reset_token']?.toString();
        setState(() => _isVerifyingOTP = false);
        _goToStep(3);
      }
    }
  }

  // ── STEP 3: Reset Password ──────────────────────────────────────

  Future<void> _resetPassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;
    if (_resetToken == null) return;

    setState(() {
      _isResetting = true;
      _passwordError = null;
    });

    final response = await _apiService.resetPassword(
      _resetToken!,
      _newPasswordController.text.trim(),
    );

    if (mounted) {
      if (response.containsKey('error')) {
        setState(() {
          _passwordError = response['error'];
          _isResetting = false;
        });
      } else {
        setState(() {
          _isResetting = false;
          _resetComplete = true;
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
              // If on step 2 or 3, go back to previous step
              if (_currentStep == 2) {
                _goToStep(1);
              } else if (_currentStep == 3) {
                _goToStep(2);
              } else {
                context.go('/login');
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 1,
                ),
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
          Container(color: Colors.black.withOpacity(0.60)),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _stepFade,
                child: SlideTransition(
                  position: _stepSlide,
                  child:
                      _resetComplete ? _buildSuccessCard() : _buildStepCard(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard() {
    return Container(
      width: 460,
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
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
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Step indicator
          _buildStepIndicator(),
          const SizedBox(height: 28),

          // Step content
          if (_currentStep == 1) _buildStep1(),
          if (_currentStep == 2) _buildStep2(),
          if (_currentStep == 3) _buildStep3(),
        ],
      ),
    );
  }

  /// Step progress dots at the top
  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final step = index + 1;
        final isActive = _currentStep == step;
        final isDone = _currentStep > step;
        return Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isActive ? 32 : 10,
              height: 10,
              decoration: BoxDecoration(
                color: isDone
                    ? AppColors.primaryBlue
                    : isActive
                        ? AppColors.primaryBlue
                        : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(5),
              ),
              child: isDone
                  ? const Icon(Icons.check, color: Colors.white, size: 8)
                  : null,
            ),
            if (index < 2)
              Container(
                width: 24,
                height: 2,
                color: isDone
                    ? AppColors.primaryBlue.withOpacity(0.5)
                    : Colors.white.withOpacity(0.1),
                margin: const EdgeInsets.symmetric(horizontal: 4),
              ),
          ],
        );
      }),
    );
  }

  // ── STEP 1 UI: Enter Gmail ──────────────────────────────────────

  Widget _buildStep1() {
    return Form(
      key: _emailFormKey,
      child: Column(
        children: [
          // Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryBlue.withOpacity(0.4),
                width: 2,
              ),
            ),
            child: const Icon(Icons.email_outlined,
                color: AppColors.lightGreen, size: 28),
          ),
          const SizedBox(height: 20),

          const Text(
            'Forgot Password?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your Gmail address and we\'ll\n'
            'send you a 6-digit OTP.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),

          // Error
          if (_emailError != null) ...[
            _buildErrorBox(_emailError!),
            const SizedBox(height: 16),
          ],

          // Gmail field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            decoration: _fieldDecoration(
              'Gmail Address',
              Icons.email_outlined,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Please enter your Gmail address';
              }
              if (!v.trim().toLowerCase().endsWith('@gmail.com')) {
                return 'Only Gmail accounts are allowed';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSendingOTP ? null : _sendOTP,
              style: _primaryButtonStyle(),
              child: _isSendingOTP
                  ? _loadingIndicator()
                  : const Text('Send OTP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
            ),
          ),

          const SizedBox(height: 16),

          GestureDetector(
            onTap: () => context.go('/login'),
            child: Text(
              'Back to Login',
              style: TextStyle(
                color: AppColors.lightGreen,
                fontSize: 13,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.lightGreen.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── STEP 2 UI: Enter OTP ────────────────────────────────────────

  Widget _buildStep2() {
    return Form(
      key: _otpFormKey,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryBlue.withOpacity(0.4),
                width: 2,
              ),
            ),
            child: const Icon(Icons.lock_clock_outlined,
                color: AppColors.lightGreen, size: 28),
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
            'Enter the 6-digit OTP sent to\n'
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
            _buildErrorBox(_otpError!),
            const SizedBox(height: 16),
          ],

          // OTP field — larger text, monospace font
          TextFormField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 12,
              fontFamily: 'monospace',
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: '000000',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.2),
                fontSize: 32,
                letterSpacing: 12,
                fontFamily: 'monospace',
              ),
              counterText: '', // hide the maxLength counter
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primaryBlue, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              contentPadding: const EdgeInsets.symmetric(vertical: 20),
            ),
            validator: (v) {
              if (v == null || v.trim().length != 6) {
                return 'Please enter the 6-digit OTP';
              }
              return null;
            },
          ),

          const SizedBox(height: 8),

          // OTP expiry note
          Text(
            'OTP expires in 10 minutes',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isVerifyingOTP ? null : _verifyOTP,
              style: _primaryButtonStyle(),
              child: _isVerifyingOTP
                  ? _loadingIndicator()
                  : const Text('Verify OTP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
            ),
          ),

          const SizedBox(height: 16),

          // Resend OTP
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
                    'Resend OTP',
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
                      : 'Resend OTP',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 13,
                  ),
                ),
        ],
      ),
    );
  }

  // ── STEP 3 UI: Reset Password ───────────────────────────────────

  Widget _buildStep3() {
    return Form(
      key: _passwordFormKey,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryBlue.withOpacity(0.4),
                width: 2,
              ),
            ),
            child: const Icon(Icons.lock_reset,
                color: AppColors.lightGreen, size: 28),
          ),
          const SizedBox(height: 20),

          const Text(
            'Set New Password',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a strong password for\nyour account.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),

          // Error
          if (_passwordError != null) ...[
            _buildErrorBox(_passwordError!),
            const SizedBox(height: 16),
          ],

          // New password field
          TextFormField(
            controller: _newPasswordController,
            obscureText: _obscureNew,
            style: const TextStyle(color: Colors.white),
            decoration: _fieldDecoration(
              'New Password',
              Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNew ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white38,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscureNew = !_obscureNew),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'Please enter a new password';
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

          const SizedBox(height: 16),

          // Confirm password field
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirm,
            style: const TextStyle(color: Colors.white),
            decoration: _fieldDecoration(
              'Confirm Password',
              Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white38,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'Please confirm your password';
              }
              if (v != _newPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),

          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Min 8 chars · 1 uppercase · 1 special character',
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 11,
              ),
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isResetting ? null : _resetPassword,
              style: _primaryButtonStyle(),
              child: _isResetting
                  ? _loadingIndicator()
                  : const Text('Reset Password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
            ),
          ),
        ],
      ),
    );
  }

  // ── SUCCESS CARD ────────────────────────────────────────────────

  Widget _buildSuccessCard() {
    return Container(
      width: 440,
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.1),
            blurRadius: 40,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryBlue.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: const Icon(Icons.check_circle_outline,
                color: AppColors.lightGreen, size: 38),
          ),
          const SizedBox(height: 20),
          const Text(
            'Password Reset!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Your password has been successfully\n'
            'updated. You can now log in.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => context.go('/login'),
              icon: const Icon(Icons.login, size: 18),
              label: const Text(
                'Go to Login',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: _primaryButtonStyle(),
            ),
          ),
        ],
      ),
    );
  }

  // ── SHARED UI HELPERS ───────────────────────────────────────────

  Widget _buildErrorBox(String message) {
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

  InputDecoration _fieldDecoration(String label, IconData icon,
      {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
      prefixIcon: Icon(icon, color: Colors.white54, size: 20),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
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

  Widget _loadingIndicator() => const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      );
}

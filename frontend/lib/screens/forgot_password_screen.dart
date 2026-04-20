import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/video_background.dart';
import '../widgets/page_loading_overlay.dart';

const Color _kGold = Color(0xFFD4A017);
const Color _kBrightGold = Color(0xFFFFD700);
const Color _kCrimson = Color(0xFF8B1A1A);
const Color _kParchment = Color(0xFFF5DEB3);
const Color _kDarkBrown = Color(0xFF1A0A00);
const Color _kAgedGold = Color(0xFF8B6914);

/// ForgotPasswordScreen — One Piece theme, transparent card,
/// 3-step OTP password reset.
///
/// ✅ ADDED: Full-screen loading overlay on the final step.
///
/// Loading appears when the user taps "Reset Password" on Step 3:
///   1. Overlay fades in.
///   2. API call runs.
///   3. On success → `_resetComplete = true`, overlay fades out,
///      success card shown.
///   4. On failure → overlay fades out, error banner shown.
///
/// There is NO navigate-away here (user stays on screen to see
/// success). The loading just covers the reset action itself.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  int _currentStep = 1;

  // Step 1 — Email
  final _emailFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSendingOTP = false;
  String? _emailError;

  // Step 2 — OTP
  final _otpFormKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  bool _isVerifyingOTP = false;
  String? _otpError;
  String? _resetToken;

  // Step 3 — New password
  final _passwordFormKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isResetting = false;
  String? _passwordError;
  bool _resetComplete = false;

  int _resendCountdown = 0;
  bool _canResend = false;

  // Step transition animations
  late final AnimationController _stepAnimController;
  late final Animation<double> _stepFade;
  late final Animation<Offset> _stepSlide;

  // Loading overlay
  late final AnimationController _loadCtrl;
  late final Animation<double> _loadFade;
  bool _showLoadOverlay = false;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _stepAnimController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _stepFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _stepAnimController, curve: Curves.easeOut));
    _stepSlide = Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _stepAnimController, curve: Curves.easeOut));
    _stepAnimController.forward();

    _loadCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );
    _loadFade = CurvedAnimation(parent: _loadCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _stepAnimController.dispose();
    _loadCtrl.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    _stepAnimController.reset();
    setState(() => _currentStep = step);
    _stepAnimController.forward();
  }

  // ── Step 1: Send OTP ─────────────────────────────────────────────

  Future<void> _sendOTP() async {
    if (!_emailFormKey.currentState!.validate()) return;
    setState(() {
      _isSendingOTP = true;
      _emailError = null;
    });
    final response =
        await _apiService.sendOTP(_emailController.text.trim().toLowerCase());
    if (mounted) {
      if (response.containsKey('error')) {
        setState(() {
          _emailError = response['error'];
          _isSendingOTP = false;
        });
      } else {
        setState(() {
          _isSendingOTP = false;
          _resendCountdown = 60;
          _canResend = false;
        });
        _startResendCountdown();
        _goToStep(2);
      }
    }
  }

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

  // ── Step 2: Verify OTP ────────────────────────────────────────────

  Future<void> _verifyOTP() async {
    if (!_otpFormKey.currentState!.validate()) return;
    setState(() {
      _isVerifyingOTP = true;
      _otpError = null;
    });
    final response = await _apiService.verifyOTP(
        _emailController.text.trim().toLowerCase(), _otpController.text.trim());
    if (mounted) {
      if (response.containsKey('error')) {
        setState(() {
          _otpError = response['error'];
          _isVerifyingOTP = false;
        });
      } else {
        _resetToken = response['reset_token']?.toString();
        setState(() => _isVerifyingOTP = false);
        _goToStep(3);
      }
    }
  }

  // ── Step 3: Reset Password ────────────────────────────────────────

  Future<void> _resetPassword() async {
    if (!_passwordFormKey.currentState!.validate()) {
      return;
    }
    if (_resetToken == null) return;

    setState(() {
      _isResetting = true;
      _passwordError = null;
      _showLoadOverlay = true;
    });

    // Fade in loading overlay
    await _loadCtrl.forward(from: 0.0);

    final response = await _apiService.resetPassword(
        _resetToken!, _newPasswordController.text.trim());

    if (!mounted) return;

    // Fade out loading overlay regardless of result
    await _loadCtrl.reverse();

    if (response.containsKey('error')) {
      setState(() {
        _passwordError = response['error'];
        _isResetting = false;
        _showLoadOverlay = false;
      });
    } else {
      setState(() {
        _isResetting = false;
        _showLoadOverlay = false;
        _resetComplete = true;
      });
    }
  }

  // ── Build ─────────────────────────────────────────────────────────

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
                color: _kDarkBrown.withOpacity(0.4),
                shape: BoxShape.circle,
                border: Border.all(color: _kGold.withOpacity(0.5), width: 1.5),
              ),
              child:
                  const Icon(Icons.arrow_back, color: _kBrightGold, size: 20),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // ── Background ───────────────────────────────────────────
          const VideoBackground(
            videoPath: AssetPaths.loginBackgroundVideo,
          ),
          Container(color: Colors.black.withOpacity(0.35)),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _stepFade,
                child: SlideTransition(
                  position: _stepSlide,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: _resetComplete
                          ? _buildSuccessCard()
                          : _buildStepCard(),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Loading Overlay ───────────────────────────────────────
          // Appears only during the password reset API call.
          FadeTransition(
            opacity: _loadFade,
            child: IgnorePointer(
              ignoring: !_showLoadOverlay,
              child: const PageLoadingOverlay(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step card wrapper ─────────────────────────────────────────────

  Widget _buildStepCard() {
    return Container(
      width: 460,
      padding: const EdgeInsets.all(36),
      decoration: _cardDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStepIndicator(),
          const SizedBox(height: 28),
          if (_currentStep == 1) _buildStep1(),
          if (_currentStep == 2) _buildStep2(),
          if (_currentStep == 3) _buildStep3(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final step = index + 1;
        final isActive = _currentStep == step;
        final isDone = _currentStep > step;
        return Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isActive ? 28 : 10,
            height: 10,
            decoration: BoxDecoration(
              color: isDone || isActive ? _kGold : _kAgedGold.withOpacity(0.25),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          if (index < 2)
            Container(
              width: 20,
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              color: isDone
                  ? _kGold.withOpacity(0.5)
                  : _kAgedGold.withOpacity(0.15),
            ),
        ]);
      }),
    );
  }

  // ── Step 1 ────────────────────────────────────────────────────────

  Widget _buildStep1() {
    return Form(
      key: _emailFormKey,
      child: Column(children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: _kGold.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: _kGold.withOpacity(0.4), width: 2),
          ),
          child: const Icon(Icons.lock_reset_outlined,
              color: _kBrightGold, size: 28),
        ),
        const SizedBox(height: 16),
        const Text(
          'Forgot Password?',
          style: TextStyle(
            color: _kBrightGold,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your Gmail and we\'ll send\n'
          'a verification code.',
          style: TextStyle(
              color: _kParchment.withOpacity(0.5), fontSize: 13, height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        if (_emailError != null) ...[
          _errorBox(_emailError!),
          const SizedBox(height: 14),
        ],
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: _kParchment),
          decoration: _fieldDecoration('Gmail Address', Icons.email_outlined),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'Enter your Gmail';
            }
            if (!v.trim().toLowerCase().endsWith('@gmail.com')) {
              return 'Only @gmail.com allowed';
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
                ? _loadingSpinner()
                : const Text('Send OTP',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => context.go('/login'),
          child: const Text(
            'Back to Login',
            style: TextStyle(
              color: _kGold,
              fontSize: 13,
              decoration: TextDecoration.underline,
              decorationColor: _kGold,
            ),
          ),
        ),
      ]),
    );
  }

  // ── Step 2 ────────────────────────────────────────────────────────

  Widget _buildStep2() {
    return Form(
      key: _otpFormKey,
      child: Column(children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: _kGold.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: _kGold.withOpacity(0.4), width: 2),
          ),
          child: const Icon(Icons.lock_clock_outlined,
              color: _kBrightGold, size: 28),
        ),
        const SizedBox(height: 16),
        const Text(
          'Check Your Gmail',
          style: TextStyle(
            color: _kBrightGold,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the 6-digit OTP sent to\n'
          '${_emailController.text.trim()}',
          style: TextStyle(
              color: _kParchment.withOpacity(0.5), fontSize: 13, height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        if (_otpError != null) ...[
          _errorBox(_otpError!),
          const SizedBox(height: 14),
        ],
        TextFormField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          style: const TextStyle(
            color: _kParchment,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: 12,
            fontFamily: 'monospace',
          ),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: '000000',
            hintStyle: TextStyle(
              color: _kParchment.withOpacity(0.2),
              fontSize: 32,
              letterSpacing: 12,
            ),
            counterText: '',
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _kAgedGold.withOpacity(0.4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _kGold, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _kCrimson),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _kCrimson),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.06),
            contentPadding: const EdgeInsets.symmetric(vertical: 20),
          ),
          validator: (v) {
            if (v == null || v.trim().length != 6) {
              return 'Enter 6-digit code';
            }
            return null;
          },
        ),
        const SizedBox(height: 6),
        Text(
          'Code expires in 10 minutes',
          style: TextStyle(color: _kAgedGold.withOpacity(0.5), fontSize: 12),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isVerifyingOTP ? null : _verifyOTP,
            style: _primaryButtonStyle(),
            child: _isVerifyingOTP
                ? _loadingSpinner()
                : const Text('Verify OTP',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 16),
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
                child: const Text(
                  'Resend OTP',
                  style: TextStyle(
                    color: _kBrightGold,
                    fontSize: 13,
                    decoration: TextDecoration.underline,
                    decorationColor: _kBrightGold,
                  ),
                ),
              )
            : Text(
                _resendCountdown > 0 ? 'Resend in ${_resendCountdown}s' : '...',
                style: TextStyle(
                    color: _kAgedGold.withOpacity(0.5), fontSize: 13)),
      ]),
    );
  }

  // ── Step 3 ────────────────────────────────────────────────────────

  Widget _buildStep3() {
    return Form(
      key: _passwordFormKey,
      child: Column(children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: _kGold.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: _kGold.withOpacity(0.4), width: 2),
          ),
          child: const Icon(Icons.lock_reset, color: _kBrightGold, size: 28),
        ),
        const SizedBox(height: 16),
        const Text(
          'Set New Password',
          style: TextStyle(
            color: _kBrightGold,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Choose a strong password.',
          style: TextStyle(color: _kParchment.withOpacity(0.5), fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        if (_passwordError != null) ...[
          _errorBox(_passwordError!),
          const SizedBox(height: 14),
        ],
        TextFormField(
          controller: _newPasswordController,
          obscureText: _obscureNew,
          style: const TextStyle(color: _kParchment),
          decoration: _fieldDecoration(
            'New Password',
            Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility,
                  color: _kAgedGold.withOpacity(0.7), size: 20),
              onPressed: () => setState(() => _obscureNew = !_obscureNew),
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) {
              return 'Enter new password';
            }
            if (v.length < 8) return 'Min 8 characters';
            if (!v.contains(RegExp(r'[A-Z]'))) {
              return 'Need uppercase letter';
            }
            if (!v.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
              return 'Need special character';
            }
            return null;
          },
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirm,
          style: const TextStyle(color: _kParchment),
          decoration: _fieldDecoration(
            'Confirm Password',
            Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                  _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                  color: _kAgedGold.withOpacity(0.7),
                  size: 20),
              onPressed: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) {
              return 'Confirm password';
            }
            if (v != _newPasswordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isResetting ? null : _resetPassword,
            style: _primaryButtonStyle(),
            child: _isResetting
                ? _loadingSpinner()
                : const Text('Reset Password',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
    );
  }

  // ── Success card ──────────────────────────────────────────────────

  Widget _buildSuccessCard() {
    return Container(
      width: 440,
      padding: const EdgeInsets.all(36),
      decoration: _cardDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _kGold.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: _kGold.withOpacity(0.5), width: 2),
            ),
            child: const Icon(Icons.check_circle_outline,
                color: _kBrightGold, size: 38),
          ),
          const SizedBox(height: 20),
          const Text(
            '⚓  Password Reset!',
            style: TextStyle(
              color: _kBrightGold,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Your password has been updated.\n'
            'You can now set sail!',
            style: TextStyle(
              color: _kParchment.withOpacity(0.6),
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
              label: const Text('Return to Login',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              style: _primaryButtonStyle(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────

  Widget _errorBox(String message) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _kCrimson.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _kCrimson.withOpacity(0.5)),
        ),
        child: Row(children: [
          const Icon(Icons.error_outline, color: _kCrimson, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: const TextStyle(color: Color(0xFFFF9999), fontSize: 13)),
          ),
        ]),
      );

  InputDecoration _fieldDecoration(String label, IconData icon,
          {Widget? suffixIcon}) =>
      InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: _kParchment.withOpacity(0.6)),
        prefixIcon: Icon(icon, color: _kAgedGold, size: 20),
        suffixIcon: suffixIcon,
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
          borderSide: const BorderSide(color: _kCrimson),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kCrimson),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),
      );

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kGold.withOpacity(0.55), width: 2),
        boxShadow: [
          BoxShadow(
            color: _kGold.withOpacity(0.12),
            blurRadius: 40,
            spreadRadius: 4,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
          ),
        ],
      );

  ButtonStyle _primaryButtonStyle() => ElevatedButton.styleFrom(
        backgroundColor: _kGold,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      );

  Widget _loadingSpinner() => const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white));
}

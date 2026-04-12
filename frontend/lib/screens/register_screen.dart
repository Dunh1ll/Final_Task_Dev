import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/video_background.dart';
import '../main.dart';
import 'package:provider/provider.dart';

const Color _kGold = Color(0xFFD4A017);
const Color _kBrightGold = Color(0xFFFFD700);
const Color _kCrimson = Color(0xFF8B1A1A);
const Color _kParchment = Color(0xFFF5DEB3);
const Color _kDarkBrown = Color(0xFF1A0A00);
const Color _kAgedGold = Color(0xFF8B6914);

/// RegisterScreen — One Piece theme, transparent card, 2-step OTP.
///
/// ✅ CHANGED: Card is now transparent glassmorphism so the
/// video background shows through while keeping the gold theme.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  int _step = 1;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSendingOTP = false;
  String? _formError;

  final _otpFormKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  bool _isVerifying = false;
  String? _otpError;

  int _resendCountdown = 0;
  bool _canResend = false;

  late AnimationController _animController;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
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
        final auth = context.read<AuthProvider>();
        await auth.loginWithToken(response);
        if (mounted) context.go('/dashboard');
      } else {
        setState(() {
          _otpError = 'Unexpected response. Try again.';
          _isVerifying = false;
        });
      }
    }
  }

  /// The shared transparent glassmorphism card decoration
  BoxDecoration _cardDecoration() => BoxDecoration(
        // ✅ Transparent — video shows through
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
          const VideoBackground(
            videoPath: AssetPaths.loginBackgroundVideo,
          ),
          Container(color: Colors.black.withOpacity(0.35)),
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

  Widget _buildFormStep() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: 480,
          padding: const EdgeInsets.all(36),
          decoration: _cardDecoration(),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 56,
                    errorBuilder: (_, __, ___) =>
                        const Text('⚓', style: TextStyle(fontSize: 48)),
                  ),
                ),
                const SizedBox(height: 16),
                _buildStepDots(1),
                const SizedBox(height: 20),
                const Text(
                  'Join the Crew!',
                  style: TextStyle(
                    color: _kBrightGold,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Fill in your details to set sail',
                  style: TextStyle(
                    color: _kParchment.withOpacity(0.55),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (_formError != null) ...[
                  _errorBox(_formError!),
                  const SizedBox(height: 14),
                ],
                _buildField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _buildField(
                  controller: _emailController,
                  label: 'Gmail Address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
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
                const SizedBox(height: 14),
                _buildField(
                  controller: _phoneController,
                  label: 'Phone (optional)',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 14),
                _buildField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: _kAgedGold.withOpacity(0.7),
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Enter a password';
                    }
                    if (v.length < 8) {
                      return 'Min 8 characters';
                    }
                    if (!v.contains(RegExp(r'[A-Z]'))) {
                      return 'Need uppercase letter';
                    }
                    if (!v.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                      return 'Need special character';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 6),
                Text(
                  'Min 8 chars · 1 uppercase · 1 special',
                  style: TextStyle(
                    color: _kAgedGold.withOpacity(0.5),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSendingOTP ? null : _sendOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kGold,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: _isSendingOTP
                        ? _loadingSpinner()
                        : const Text(
                            '📡  Send Verification Code',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already a crew member? ',
                      style: TextStyle(
                        color: _kParchment.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: _kBrightGold,
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
        ),
      ),
    );
  }

  Widget _buildOTPStep() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: 460,
          padding: const EdgeInsets.all(36),
          decoration: _cardDecoration(),
          child: Form(
            key: _otpFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStepDots(2),
                const SizedBox(height: 24),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _kGold.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: _kGold.withOpacity(0.5), width: 2),
                  ),
                  child: const Icon(Icons.mark_email_read_outlined,
                      color: _kBrightGold, size: 30),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Den Den Mushi Sent!',
                  style: TextStyle(
                    color: _kBrightGold,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Check Gmail:\n${_emailController.text.trim()}',
                  style: TextStyle(
                    color: _kParchment.withOpacity(0.55),
                    fontSize: 13,
                    height: 1.5,
                  ),
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
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 14,
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: '000000',
                    hintStyle: TextStyle(
                      color: _kParchment.withOpacity(0.2),
                      fontSize: 36,
                      letterSpacing: 14,
                    ),
                    counterText: '',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: _kAgedGold.withOpacity(0.4)),
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
                  style: TextStyle(
                    color: _kAgedGold.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isVerifying ? null : _verifyAndRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kGold,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: _isVerifying
                        ? _loadingSpinner()
                        : const Text(
                            'Verify & Join the Crew',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                          'Resend Code',
                          style: TextStyle(
                            color: _kBrightGold,
                            fontSize: 13,
                            decoration: TextDecoration.underline,
                            decorationColor: _kBrightGold,
                          ),
                        ),
                      )
                    : Text(
                        _resendCountdown > 0
                            ? 'Resend in ${_resendCountdown}s'
                            : '...',
                        style: TextStyle(
                          color: _kAgedGold.withOpacity(0.5),
                          fontSize: 13,
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
                color:
                    isDone || isActive ? _kGold : _kAgedGold.withOpacity(0.3),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            if (i < 1)
              Container(
                width: 20,
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: isDone
                    ? _kGold.withOpacity(0.6)
                    : _kAgedGold.withOpacity(0.15),
              ),
          ],
        );
      }),
    );
  }

  Widget _loadingSpinner() => const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white));

  Widget _errorBox(String message) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _kCrimson.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _kCrimson.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: _kCrimson, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message,
                  style:
                      const TextStyle(color: Color(0xFFFF9999), fontSize: 13)),
            ),
          ],
        ),
      );

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: _kParchment),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: _kParchment.withOpacity(0.6)),
          prefixIcon: Icon(icon, color: _kAgedGold, size: 20),
          suffixIcon: suffixIcon,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: _kAgedGold.withOpacity(0.4)),
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
          fillColor: Colors.white.withOpacity(0.06),
        ),
        validator: validator,
      );
}

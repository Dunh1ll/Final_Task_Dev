import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/page_loading_overlay.dart';
import '../widgets/video_background.dart';
import '../main.dart';

const Color _kGold = Color(0xFFD4A017);
const Color _kBrightGold = Color(0xFFFFD700);
const Color _kCrimson = Color(0xFF8B1A1A);
const Color _kParchment = Color(0xFFF5DEB3);
const Color _kDarkBrown = Color(0xFF1A0A00);
const Color _kAgedGold = Color(0xFF8B6914);
const Color _kNavy = Color(0xFF1C3A5C);

/// RegisterScreen — 3-step registration.
///
/// Step 1 — Account Info: name, gmail, phone, password
/// Step 2 — Profile Details: birthday, age, gender, location,
///           education, relationship status
/// Step 3 — OTP: verify Gmail, create account, then auto-update
///           profile with the extra fields collected in step 2
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  int _step = 1;

  // ── Step 1 controllers ─────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isSendingOTP = false;
  String? _formError;

  // ── Step 2 controllers ─────────────────────────────────────────
  final _step2Key = GlobalKey<FormState>();
  final _ageCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _educationCtrl = TextEditingController();
  String? _gender;
  String? _relationshipStatus;
  DateTime? _birthday;

  // ── Step 3 (OTP) ───────────────────────────────────────────────
  final _otpFormKey = GlobalKey<FormState>();
  final _otpCtrl = TextEditingController();
  bool _isVerifying = false;
  String? _otpError;
  int _resendCountdown = 0;
  bool _canResend = false;

  // ── Animations ─────────────────────────────────────────────────
  late AnimationController _stepAnimCtrl;
  late Animation<double> _stepFade;
  late Animation<Offset> _stepSlide;

  bool _pageLoadVisible = true;
  late AnimationController _pageLoadCtrl;
  late Animation<double> _pageLoadFade;

  bool _showActionOverlay = false;
  late AnimationController _actionLoadCtrl;
  late Animation<double> _actionLoadFade;

  final ApiService _apiService = ApiService();

  static const List<String> _genderOptions = [
    'Male',
    'Female',
    'Non-binary',
    'Prefer not to say',
  ];

  static const List<String> _relationshipOptions = [
    'Single',
    'In a relationship',
    'Married',
    'Complicated',
    'Prefer not to say',
  ];

  @override
  void initState() {
    super.initState();

    _stepAnimCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _stepFade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _stepAnimCtrl, curve: Curves.easeOut));
    _stepSlide = Tween<Offset>(begin: const Offset(0.06, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _stepAnimCtrl, curve: Curves.easeOut));
    _stepAnimCtrl.forward();

    _pageLoadCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500), value: 1.0);
    _pageLoadFade =
        CurvedAnimation(parent: _pageLoadCtrl, curve: Curves.easeOut);

    _actionLoadCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 340));
    _actionLoadFade =
        CurvedAnimation(parent: _actionLoadCtrl, curve: Curves.easeOut);

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _pageLoadVisible) _hidePageLoad();
    });
  }

  void _hidePageLoad() {
    if (!_pageLoadVisible) return;
    _pageLoadCtrl.reverse().then((_) {
      if (mounted) setState(() => _pageLoadVisible = false);
    });
  }

  void _onVideoReady() {
    if (mounted) _hidePageLoad();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    _ageCtrl.dispose();
    _locationCtrl.dispose();
    _educationCtrl.dispose();
    _otpCtrl.dispose();
    _stepAnimCtrl.dispose();
    _pageLoadCtrl.dispose();
    _actionLoadCtrl.dispose();
    super.dispose();
  }

  void _animateToStep(int step) {
    _stepAnimCtrl.reset();
    setState(() => _step = step);
    _stepAnimCtrl.forward();
  }

  // ── Step 1 → 2 ─────────────────────────────────────────────────
  void _goToStep2() {
    if (!_formKey.currentState!.validate()) return;
    _animateToStep(2);
  }

  // ── Step 2 → 3 (send OTP) ──────────────────────────────────────
  Future<void> _sendOTP() async {
    if (!_step2Key.currentState!.validate()) return;
    setState(() {
      _isSendingOTP = true;
      _formError = null;
    });

    final response = await _apiService.registerSendOTP(
      fullName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim().toLowerCase(),
      password: _passwordCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
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
        _animateToStep(3);
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

  // ── Step 3: verify OTP, create account, update profile ─────────
  Future<void> _verifyAndRegister() async {
    if (!_otpFormKey.currentState!.validate()) return;

    setState(() {
      _isVerifying = true;
      _otpError = null;
      _showActionOverlay = true;
    });
    await _actionLoadCtrl.forward(from: 0.0);

    // Create account
    final response = await _apiService.registerVerifyOTP(
      fullName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim().toLowerCase(),
      password: _passwordCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      otp: _otpCtrl.text.trim(),
    );

    if (!mounted) return;

    if (response.containsKey('error')) {
      await _actionLoadCtrl.reverse();
      setState(() {
        _otpError = response['error'];
        _isVerifying = false;
        _showActionOverlay = false;
      });
      return;
    }

    if (!response.containsKey('token')) {
      await _actionLoadCtrl.reverse();
      setState(() {
        _otpError = 'Unexpected response. Try again.';
        _isVerifying = false;
        _showActionOverlay = false;
      });
      return;
    }

    // Log in
    final auth = context.read<AuthProvider>();
    await auth.loginWithToken(response);

    // Build profile update payload from step 2 fields
    String? birthdayStr;
    if (_birthday != null) {
      birthdayStr = '${_birthday!.year.toString().padLeft(4, '0')}'
          '-${_birthday!.month.toString().padLeft(2, '0')}'
          '-${_birthday!.day.toString().padLeft(2, '0')}';
    }

    final profileData = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      if (_ageCtrl.text.trim().isNotEmpty)
        'age': int.tryParse(_ageCtrl.text.trim()),
      if (_gender != null) 'gender': _gender,
      if (birthdayStr != null) 'birthday': birthdayStr,
      if (_locationCtrl.text.trim().isNotEmpty)
        'hometown': _locationCtrl.text.trim(),
      if (_educationCtrl.text.trim().isNotEmpty)
        'education': _educationCtrl.text.trim(),
      if (_relationshipStatus != null)
        'relationship_status': _relationshipStatus,
    };

    // Find the newly created profile and update it
    if (auth.userID != null && profileData.length > 1) {
      try {
        final profilesResp = await _apiService.getProfiles();
        final list =
            profilesResp['sub_users'] ?? profilesResp['profiles'] ?? [];
        if (list.isNotEmpty) {
          final profileId = list.first['id']?.toString();
          if (profileId != null) {
            await _apiService.updateProfile(profileId, profileData);
          }
        }
      } catch (_) {
        // Non-critical — user can always edit profile later
      }
    }

    if (mounted) context.go('/dashboard');
  }

  // ── BUILD ───────────────────────────────────────────────────────
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
              if (_step == 3) {
                _animateToStep(2);
              } else if (_step == 2) {
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
          VideoBackground(
            videoPath: AssetPaths.loginBackgroundVideo,
            onInitialized: _onVideoReady,
          ),
          Container(color: Colors.black.withOpacity(0.4)),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
              child: FadeTransition(
                opacity: _stepFade,
                child: SlideTransition(
                  position: _stepSlide,
                  child: _buildCurrentStep(),
                ),
              ),
            ),
          ),

          // Action overlay
          FadeTransition(
            opacity: _actionLoadFade,
            child: IgnorePointer(
              ignoring: !_showActionOverlay,
              child: const PageLoadingOverlay(),
            ),
          ),

          // Page load overlay
          if (_pageLoadVisible)
            FadeTransition(
              opacity: _pageLoadFade,
              child: const PageLoadingOverlay(),
            ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      default:
        return _buildStep1();
    }
  }

  // ── STEP 1: Account Info ────────────────────────────────────────
  Widget _buildStep1() {
    return _card(
      width: 480,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _logo(),
            const SizedBox(height: 16),
            _stepIndicator(current: 1, total: 3),
            const SizedBox(height: 20),
            _heading('Join the Crew!', 'Step 1 of 3 — Account credentials'),
            const SizedBox(height: 24),
            if (_formError != null) ...[
              _errorBox(_formError!),
              const SizedBox(height: 14),
            ],
            _field(
              ctrl: _nameCtrl,
              label: 'Full Name',
              icon: Icons.person_outline,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
            ),
            const SizedBox(height: 14),
            _field(
              ctrl: _emailCtrl,
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
            _field(
              ctrl: _phoneCtrl,
              label: 'Phone (optional)',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),
            _field(
              ctrl: _passwordCtrl,
              label: 'Password',
              icon: Icons.lock_outline,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: _kAgedGold.withOpacity(0.7),
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter a password';
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
            const SizedBox(height: 6),
            Text(
              'Min 8 chars · 1 uppercase · 1 special',
              style:
                  TextStyle(color: _kAgedGold.withOpacity(0.5), fontSize: 11),
            ),
            const SizedBox(height: 24),
            _primaryButton(
              label: 'Next  →',
              icon: Icons.arrow_forward,
              onTap: _goToStep2,
            ),
            const SizedBox(height: 20),
            _loginLink(),
          ],
        ),
      ),
    );
  }

  // ── STEP 2: Profile Details ─────────────────────────────────────
  Widget _buildStep2() {
    return _card(
      width: 500,
      child: Form(
        key: _step2Key,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _logo(),
            const SizedBox(height: 16),
            _stepIndicator(current: 2, total: 3),
            const SizedBox(height: 20),
            _heading(
                'Your Profile', 'Step 2 of 3 — Tell the crew about yourself'),
            const SizedBox(height: 8),
            // Optional badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: _kNavy.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _kGold.withOpacity(0.2), width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: _kGold.withOpacity(0.7), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'All fields are optional — you can always edit them later.',
                      style: TextStyle(
                          color: _kParchment.withOpacity(0.55), fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Birthday picker
            _sectionLabel('Birthday'),
            const SizedBox(height: 8),
            _birthdayPicker(),
            const SizedBox(height: 16),

            // Age + Gender row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel('Age'),
                      const SizedBox(height: 8),
                      _field(
                        ctrl: _ageCtrl,
                        label: 'Age',
                        icon: Icons.cake_outlined,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v != null && v.trim().isNotEmpty) {
                            final n = int.tryParse(v.trim());
                            if (n == null || n < 1 || n > 120) {
                              return 'Invalid age';
                            }
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel('Gender'),
                      const SizedBox(height: 8),
                      _dropdown(
                        value: _gender,
                        hint: 'Select gender',
                        icon: Icons.people_outline,
                        items: _genderOptions,
                        onChanged: (v) => setState(() => _gender = v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _sectionLabel('Hometown / Location'),
            const SizedBox(height: 8),
            _field(
              ctrl: _locationCtrl,
              label: 'City, Country',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 16),

            _sectionLabel('Education'),
            const SizedBox(height: 8),
            _field(
              ctrl: _educationCtrl,
              label: 'e.g. B.S. Computer Engineering',
              icon: Icons.school_outlined,
            ),
            const SizedBox(height: 16),

            _sectionLabel('Relationship Status'),
            const SizedBox(height: 8),
            _dropdown(
              value: _relationshipStatus,
              hint: 'Select status',
              icon: Icons.favorite_outline,
              items: _relationshipOptions,
              onChanged: (v) => setState(() => _relationshipStatus = v),
            ),

            const SizedBox(height: 28),

            if (_formError != null) ...[
              _errorBox(_formError!),
              const SizedBox(height: 14),
            ],

            _primaryButton(
              label:
                  _isSendingOTP ? 'Sending OTP…' : '📡  Send Verification Code',
              icon: Icons.send_outlined,
              onTap: _isSendingOTP ? null : _sendOTP,
              loading: _isSendingOTP,
            ),
            const SizedBox(height: 14),
            Center(
              child: TextButton.icon(
                onPressed: () => _animateToStep(1),
                icon: const Icon(Icons.arrow_back, size: 14, color: _kAgedGold),
                label: Text(
                  'Back to Step 1',
                  style: TextStyle(
                      color: _kAgedGold.withOpacity(0.7), fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── STEP 3: OTP ─────────────────────────────────────────────────
  Widget _buildStep3() {
    return _card(
      width: 460,
      child: Form(
        key: _otpFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _stepIndicator(current: 3, total: 3),
            const SizedBox(height: 24),
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: _kGold.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: _kGold.withOpacity(0.5), width: 2),
              ),
              child: const Icon(Icons.mark_email_read_outlined,
                  color: _kBrightGold, size: 32),
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
              'Check Gmail:\n${_emailCtrl.text.trim()}',
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
              controller: _otpCtrl,
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
              style:
                  TextStyle(color: _kAgedGold.withOpacity(0.5), fontSize: 12),
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
                    ? _miniSpinner()
                    : const Text(
                        'Verify & Join the Crew',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
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
                        _otpCtrl.clear();
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
                        color: _kAgedGold.withOpacity(0.5), fontSize: 13),
                  ),
          ],
        ),
      ),
    );
  }

  // ── HELPERS ─────────────────────────────────────────────────────

  Widget _card({required Widget child, double width = 480}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: width,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.28),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kGold.withOpacity(0.55), width: 2),
            boxShadow: [
              BoxShadow(
                  color: _kGold.withOpacity(0.12),
                  blurRadius: 40,
                  spreadRadius: 4),
              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _logo() => Center(
        child: Image.asset(
          'assets/images/logo.png',
          height: 52,
          errorBuilder: (_, __, ___) =>
              const Text('⚓', style: TextStyle(fontSize: 44)),
        ),
      );

  Widget _stepIndicator({required int current, required int total}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final step = i + 1;
        final active = current == step;
        final done = current > step;
        return Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              width: active ? 30 : 10,
              height: 10,
              decoration: BoxDecoration(
                color: done || active ? _kGold : _kAgedGold.withOpacity(0.28),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            if (i < total - 1)
              Container(
                width: 22,
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: done
                    ? _kGold.withOpacity(0.6)
                    : _kAgedGold.withOpacity(0.15),
              ),
          ],
        );
      }),
    );
  }

  Widget _heading(String title, String subtitle) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _kBrightGold,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(color: _kParchment.withOpacity(0.5), fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          color: _kBrightGold,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      );

  Widget _birthdayPicker() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _birthday ?? DateTime(2000, 1, 1),
          firstDate: DateTime(1920),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: _kGold,
                  onPrimary: Colors.black,
                  surface: Color(0xFF2C1A00),
                  onSurface: _kParchment,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() {
            _birthday = picked;
            // Auto-fill age from birthday
            final age = DateTime.now().year - picked.year;
            _ageCtrl.text = age.toString();
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _birthday != null
                ? _kGold.withOpacity(0.6)
                : _kAgedGold.withOpacity(0.4),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              color: _birthday != null ? _kGold : _kAgedGold,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              _birthday != null
                  ? DateFormat('MMMM dd, yyyy').format(_birthday!)
                  : 'Select your birthday',
              style: TextStyle(
                color: _birthday != null
                    ? _kParchment
                    : _kParchment.withOpacity(0.35),
                fontSize: 14,
              ),
            ),
            const Spacer(),
            if (_birthday != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _kGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Age ${DateTime.now().year - _birthday!.year}',
                  style: const TextStyle(
                      color: _kBrightGold,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _dropdown({
    required String? value,
    required String hint,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: value != null
              ? _kGold.withOpacity(0.6)
              : _kAgedGold.withOpacity(0.4),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Row(
            children: [
              Icon(icon, color: _kAgedGold, size: 18),
              const SizedBox(width: 8),
              Text(
                hint,
                style: TextStyle(
                    color: _kParchment.withOpacity(0.35), fontSize: 14),
              ),
            ],
          ),
          icon: Icon(Icons.expand_more,
              color: _kAgedGold.withOpacity(0.6), size: 20),
          dropdownColor: const Color(0xFF2C1A00),
          isExpanded: true,
          style: const TextStyle(color: _kParchment, fontSize: 14),
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Row(
                children: [
                  Icon(icon, color: _kAgedGold, size: 16),
                  const SizedBox(width: 10),
                  Text(item),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required IconData icon,
    required VoidCallback? onTap,
    bool loading = false,
  }) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _kGold,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: loading
            ? _miniSpinner()
            : Text(
                label,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _loginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already a crew member? ',
          style: TextStyle(color: _kParchment.withOpacity(0.5), fontSize: 14),
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
    );
  }

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

  Widget _miniSpinner() => const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white));

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: ctrl,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: _kParchment),
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              TextStyle(color: _kParchment.withOpacity(0.6), fontSize: 14),
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
        validator: validator,
      );
}

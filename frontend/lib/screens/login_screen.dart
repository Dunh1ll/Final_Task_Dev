import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../utils/constants.dart';
import '../widgets/page_loading_overlay.dart';
import '../widgets/video_background.dart';

const Color _kGold = Color(0xFFD4A017);
const Color _kBrightGold = Color(0xFFFFD700);
const Color _kCrimson = Color(0xFF8B1A1A);
const Color _kParchment = Color(0xFFF5DEB3);
const Color _kDarkBrown = Color(0xFF1A0A00);
const Color _kAgedGold = Color(0xFF8B6914);

/// LoginScreen — One Piece theme, transparent glassmorphism card.
///
/// ✅ LOADING SYSTEM — two layers:
///
///   Layer 1 — Page Load Overlay (initial):
///     Shown immediately when the screen renders.
///     Stays until VideoBackground calls onInitialized
///     (i.e., the video has started playing).
///     Safety timeout: 4 seconds (hides regardless of video state).
///     This covers the "video not ready" scenario.
///
///   Layer 2 — Action Overlay (login submit):
///     Shown when the user taps Sign In.
///     Stays until the API call completes.
///     On success: stays while GoRouter navigates to /dashboard.
///     On failure: fades out, error banner appears.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _forgotHover = false;

  // ── Layer 1: initial page-load overlay ──────────────────────────
  // Starts visible (value = 1.0), fades out when video is ready.
  bool _pageLoadVisible = true;
  late AnimationController _pageLoadCtrl;
  late Animation<double> _pageLoadFade;

  // ── Layer 2: login-action overlay ───────────────────────────────
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _loadCtrl;
  late Animation<double> _loadFade;

  @override
  void initState() {
    super.initState();

    // Layer 1 — starts at 1.0 (fully visible)
    _pageLoadCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      value: 1.0,
    );
    _pageLoadFade = CurvedAnimation(
      parent: _pageLoadCtrl,
      curve: Curves.easeOut,
    );

    // Layer 2 — starts at 0.0 (hidden)
    _loadCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );
    _loadFade = CurvedAnimation(
      parent: _loadCtrl,
      curve: Curves.easeOut,
    );

    // Safety timeout: hide page-load overlay after 4 seconds
    // even if the video never fires onInitialized.
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

  /// Called by VideoBackground when its video has initialized
  /// and started playing. Fades out the page-load overlay.
  void _onVideoReady() {
    if (mounted) _hidePageLoad();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _pageLoadCtrl.dispose();
    _loadCtrl.dispose();
    super.dispose();
  }

  // ── Login action ─────────────────────────────────────────────────
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    await _loadCtrl.forward(from: 0.0);

    try {
      final success = await context.read<AuthProvider>().login(
            _emailController.text.trim().toLowerCase(),
            _passwordController.text.trim(),
          );

      if (!mounted) return;

      if (success) {
        context.go('/dashboard');
      } else {
        await _loadCtrl.reverse();
        if (mounted) {
          setState(() {
            _errorMessage = context.read<AuthProvider>().errorMessage ??
                'Invalid credentials!';
            _isLoading = false;
          });
        }
      }
    } catch (_) {
      await _loadCtrl.reverse();
      if (mounted) {
        setState(() {
          _errorMessage = 'Cannot reach the server!';
          _isLoading = false;
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
            onTap: () => context.go('/'),
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
          // ── Video background ─────────────────────────────────────
          // ✅ onInitialized hides the page-load overlay
          VideoBackground(
            videoPath: AssetPaths.loginBackgroundVideo,
            onInitialized: _onVideoReady,
          ),
          Container(color: Colors.black.withOpacity(0.35)),

          // ── Login form ───────────────────────────────────────────
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    width: 420,
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
                              height: 56,
                              errorBuilder: (_, __, ___) => const Text('⚓',
                                  style: TextStyle(fontSize: 48)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Set Sail!',
                            style: TextStyle(
                              color: _kBrightGold,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sign in to join your crew',
                            style: TextStyle(
                              color: _kParchment.withOpacity(0.65),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 28),

                          // Error banner
                          if (_errorMessage != null) ...[
                            _errorBox(_errorMessage!),
                            const SizedBox(height: 16),
                          ],

                          // Email
                          _buildField(
                            controller: _emailController,
                            label: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Enter your email';
                              }
                              if (!v.contains('@')) {
                                return 'Enter valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Password
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
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Enter password';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 10),

                          // Forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: MouseRegion(
                              onEnter: (_) =>
                                  setState(() => _forgotHover = true),
                              onExit: (_) =>
                                  setState(() => _forgotHover = false),
                              child: GestureDetector(
                                onTap: () => context.go('/forgot-password'),
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: _forgotHover ? _kBrightGold : _kGold,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline,
                                    decorationColor:
                                        _forgotHover ? _kBrightGold : _kGold,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Sign In button
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _kGold,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
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
                                  : const Text(
                                      '⚓  Sign In',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Register link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'No crew yet? ',
                                style: TextStyle(
                                  color: _kParchment.withOpacity(0.55),
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.go('/register'),
                                child: const Text(
                                  'Join the Crew',
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
              ),
            ),
          ),

          // ── Layer 2: Login-action overlay ────────────────────────
          // Appears when Sign In is tapped.
          FadeTransition(
            opacity: _loadFade,
            child: IgnorePointer(
              ignoring: !_isLoading,
              child: const PageLoadingOverlay(),
            ),
          ),

          // ── Layer 1: Initial page-load overlay ───────────────────
          // Starts visible, fades out when video is ready.
          // Must be rendered on top of everything else.
          if (_pageLoadVisible)
            FadeTransition(
              opacity: _pageLoadFade,
              child: const PageLoadingOverlay(),
            ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kGold.withOpacity(0.55), width: 2),
        boxShadow: [
          BoxShadow(
            color: _kGold.withOpacity(0.12),
            blurRadius: 40,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
          ),
        ],
      );

  Widget _errorBox(String message) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _kCrimson.withOpacity(0.2),
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
            borderSide: BorderSide(color: _kAgedGold.withOpacity(0.45)),
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

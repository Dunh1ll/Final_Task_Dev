import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════
// THREE DOTS LOADER
//
// Three gold circles that pulse big → small with a 180ms stagger
// between each dot. This is the standard loading indicator
// used across the entire app.
//
// Usage:
//   const ThreeDotsLoader()                 — default gold 10px
//   ThreeDotsLoader(color: Colors.white)    — custom color
//   ThreeDotsLoader(dotSize: 8)             — smaller dots
// ═══════════════════════════════════════════════════════════════════
class ThreeDotsLoader extends StatefulWidget {
  final Color color;
  final double dotSize;

  const ThreeDotsLoader({
    super.key,
    this.color = const Color(0xFFFFD700), // gold default
    this.dotSize = 10.0,
  });

  @override
  State<ThreeDotsLoader> createState() => _ThreeDotsLoaderState();
}

class _ThreeDotsLoaderState extends State<ThreeDotsLoader>
    with TickerProviderStateMixin {
  late final List<AnimationController> _ctrls;
  late final List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    // Three separate controllers so each dot can be
    // offset in time (staggered pulsing effect)
    _ctrls = List.generate(
      3,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );
    _anims = _ctrls
        .map(
          (c) => Tween<double>(begin: 0.38, end: 1.0).animate(
            CurvedAnimation(parent: c, curve: Curves.easeInOut),
          ),
        )
        .toList();

    // Start each dot 180ms after the previous one
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 180), () {
        if (mounted) _ctrls[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sz = widget.dotSize;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (i) => Padding(
          padding: EdgeInsets.symmetric(horizontal: sz * 0.45),
          child: AnimatedBuilder(
            animation: _anims[i],
            builder: (_, __) => Transform.scale(
              scale: _anims[i].value,
              child: Container(
                width: sz,
                height: sz,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                  // Subtle glow that pulses with the dot
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.45 * _anims[i].value),
                      blurRadius: 10 * _anims[i].value,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// PAGE LOADING OVERLAY
//
// Full-screen black overlay used during:
//   • Page transitions (login, register, forgot-password)
//   • API calls (login submit, OTP verify, password reset)
//   • Dark/Light mode switch on the home page
//
// Layout:
//   [LOGO / ⚓]
//       ↕ 28px
//     [• • •]   ← ThreeDotsLoader
//
// How to use:
//   FadeTransition(
//     opacity: _loadFade,
//     child: IgnorePointer(
//       ignoring: !_isLoading,
//       child: const PageLoadingOverlay(),
//     ),
//   )
// ═══════════════════════════════════════════════════════════════════
class PageLoadingOverlay extends StatelessWidget {
  const PageLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Site logo
            Image.asset(
              'assets/images/logo.png',
              height: 72,
              errorBuilder: (_, __, ___) => const Text(
                '⚓',
                style: TextStyle(
                  fontSize: 60,
                  color: Color(0xFFFFD700),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Three pulsing dots below the logo
            const ThreeDotsLoader(),
          ],
        ),
      ),
    );
  }
}

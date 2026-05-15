// lib/screens/pallen_profile/pallen_home_page.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'pallen_theme.dart';
import 'pallen_widgets.dart';

class PallenHomePage extends StatelessWidget {
  final VoidCallback onGoWork;
  final VoidCallback onGoContact;
  final void Function(String) onOpen;

  const PallenHomePage({
    super.key,
    required this.onGoWork,
    required this.onGoContact,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sh = constraints.maxHeight > 0
            ? constraints.maxHeight
            : MediaQuery.of(context).size.height;

        return Container(
          color: kP03,
          child: Stack(children: [
            // BG photo with subtle zoom animation on load
            Positioned.fill(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 1.1, end: 1.0),
                duration: const Duration(milliseconds: 2000),
                curve: Curves.easeOutCubic,
                builder: (_, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: Image.asset(
                  'assets/images/pallen_bg.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: kP07),
                ),
              ),
            ),

            // Dark overlay with animated gradient
            Positioned.fill(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1500),
                builder: (_, opacity, child) {
                  return Opacity(
                    opacity: opacity,
                    child: child,
                  );
                },
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xCC000000),
                        Color(0xDD000000),
                        Color(0xEE000000),
                        Color(0xFF000000),
                      ],
                      stops: [0.0, 0.3, 0.65, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // Noise texture
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: PallenNoisePainter()),
              ),
            ),

            // Left accent line with glow pulse
            Positioned(
              left: 56,
              top: 100,
              bottom: 100,
              child: Container(
                width: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      kP18.withOpacity(0.8),
                      kP18.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Main content
            Positioned(
              left: 76,
              right: 76,
              bottom: sh * 0.12,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // ── LEFT: Identity ───────────────────────────────
                  Expanded(
                    flex: 58,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FadeSlide(
                          delay: 0.2,
                          child: const PallenGlassChip(
                              'COMPUTER ENGINEER  ·  LAGUNA, PH'),
                        ),
                        const SizedBox(height: 32),
                        FadeSlide(
                          delay: 0.4,
                          child: const Text('Prince Dunhill',
                              style: TextStyle(
                                fontFamily: 'PlayfairDisplay',
                                color: kP70,
                                fontSize: 22,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 4,
                                height: 1.0,
                              )),
                        ),
                        const SizedBox(height: 4),
                        FadeSlide(
                          delay: 0.6,
                          child: const Text('PALLEN',
                              style: TextStyle(
                                fontFamily: 'PlayfairDisplay',
                                color: kPWh,
                                fontSize: 82,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -4,
                                height: 0.88,
                              )),
                        ),
                        const SizedBox(height: 24),
                        const FadeSlide(
                          delay: 0.8,
                          child: Text(
                            'Full-Stack Developer & Embedded Systems Engineer building technology that bridges hardware and software.',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              color: kP55,
                              fontSize: 15,
                              height: 1.65,
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),
                        FadeSlide(
                          delay: 1.0,
                          child: Row(children: [
                            PallenCtaButton(
                              label: 'See My Work',
                              icon: Icons.work_outline_rounded,
                              filled: true,
                              onTap: onGoWork,
                            ),
                            const SizedBox(width: 12),
                            PallenCtaButton(
                              label: 'Contact Me',
                              icon: Icons.mail_outline_rounded,
                              filled: false,
                              onTap: onGoContact,
                            ),
                            const SizedBox(width: 12),
                            PallenCtaButton(
                              label: 'Resume',
                              icon: Icons.download_rounded,
                              filled: false,
                              onTap: () => onOpen(kPallenResume),
                            ),
                          ]),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 48),

                  // ── RIGHT: Profile photo ──────────────────────────
                  Expanded(
                    flex: 32,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        FadeSlide(
                          delay: 0.5,
                          offset: const Offset(0, 50),
                          child: _ProfilePhotoGlow(),
                        ),
                        const SizedBox(height: 18),
                        FadeSlide(
                          delay: 0.7,
                          child: const Text('Prince Dunhill Pallen',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                color: kP93,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center),
                        ),
                        const SizedBox(height: 6),
                        FadeSlide(
                          delay: 0.8,
                          child: const PallenAvailRow(),
                        ),
                        const SizedBox(height: 16),
                        FadeSlide(
                          delay: 0.9,
                          child: const Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              PallenQuickStat('15', 'Languages'),
                              PallenQuickStat('3', 'CAD Tools'),
                              PallenQuickStat('1', 'Thesis'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Scroll indicator at bottom
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: FadeSlide(
                delay: 1.2,
                child: Column(
                  children: [
                    Text(
                      'SCROLL',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        color: kP40,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeInOut,
                      builder: (_, value, __) {
                        return Container(
                          width: 1,
                          height: 30,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                kP40.withOpacity(0.8 * value),
                                kP40.withOpacity(0.0),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ]),
        );
      },
    );
  }
}

// Animated glowing border profile photo
class _ProfilePhotoGlow extends StatefulWidget {
  @override
  State<_ProfilePhotoGlow> createState() => _ProfilePhotoGlowState();
}

class _ProfilePhotoGlowState extends State<_ProfilePhotoGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final pulse = 0.5 + 0.5 * math.sin(_ctrl.value * math.pi * 2);
        return Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.12 + 0.08 * pulse),
                blurRadius: 40 + 20 * pulse,
                spreadRadius: 4 + 4 * pulse,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.04),
                blurRadius: 70,
                spreadRadius: 10,
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.28 + 0.12 * pulse),
              width: 2.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/profile1.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: kP10,
                child: const Icon(Icons.person_rounded, color: kP40, size: 72),
              ),
            ),
          ),
        );
      },
    );
  }
}

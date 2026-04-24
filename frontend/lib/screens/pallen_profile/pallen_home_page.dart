// lib/screens/pallen_profile/pallen_home_page.dart
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
    final sh = MediaQuery.of(context).size.height;
    return Container(
      height: sh,
      color: kP03,
      child: Stack(children: [
        // BG photo
        Positioned.fill(
          child: Image.asset(
            'assets/images/pallen_bg.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: kP07),
          ),
        ),

        // Dark overlay
        Positioned.fill(
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

        // Noise texture
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: PallenNoisePainter()),
          ),
        ),

        // Left accent line
        Positioned(
          left: 56,
          top: 100,
          bottom: 100,
          child: Container(width: 1, color: kP18.withOpacity(0.6)),
        ),

        // Main content
        Positioned(
          left: 76,
          right: 76,
          bottom: sh * 0.12,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // ── LEFT: Identity ──────────────────────────────────
              Expanded(
                flex: 58,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const PallenGlassChip('COMPUTER ENGINEER  ·  LAGUNA, PH'),
                    const SizedBox(height: 32),
                    const Text('Prince Dunhill',
                        style: TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          color: kP70,
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 4,
                          height: 1.0,
                        )),
                    const SizedBox(height: 4),
                    const Text('PALLEN',
                        style: TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          color: kPWh,
                          fontSize: 82,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -4,
                          height: 0.88,
                        )),
                    const SizedBox(height: 24),
                    const Text(
                      'Full-Stack Developer & Embedded Systems Engineer\n'
                      'building technology that bridges hardware and software.',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        color: kP55,
                        fontSize: 15,
                        height: 1.65,
                      ),
                    ),
                    const SizedBox(height: 36),
                    Row(children: [
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
                  ],
                ),
              ),

              const SizedBox(width: 48),

              // ── RIGHT: Profile photo ────────────────────────────
              Expanded(
                flex: 32,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.white.withOpacity(0.15),
                              blurRadius: 40,
                              spreadRadius: 4),
                          BoxShadow(
                              color: Colors.white.withOpacity(0.06),
                              blurRadius: 70,
                              spreadRadius: 10),
                        ],
                        border: Border.all(
                            color: Colors.white.withOpacity(0.28), width: 2.5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/images/profile1.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                              color: kP10,
                              child: const Icon(Icons.person_rounded,
                                  color: kP40, size: 72)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text('Prince Dunhill Pallen',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          color: kP93,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 6),
                    const PallenAvailRow(),
                    const SizedBox(height: 16),
                    const Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        PallenQuickStat('13', 'Languages'),
                        PallenQuickStat('3', 'CAD Tools'),
                        PallenQuickStat('1', 'Thesis'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

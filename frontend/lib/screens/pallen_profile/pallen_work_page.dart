import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'pallen_theme.dart';
import 'pallen_widgets.dart';

class PallenWorkPage extends StatelessWidget {
  final Widget footer;
  const PallenWorkPage({super.key, required this.footer});

  @override
  Widget build(BuildContext context) {
    final d = PTheme.of(context);

    return Column(children: [
      const SizedBox(height: 80),
      Container(
        color: pBg2(d),
        padding: const EdgeInsets.fromLTRB(76, 56, 76, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Page header ─────────────────────────────────────────
            const PallenEyebrowLabel('02 — WORK & PROJECTS'),
            Text(
              'Experience & Engineering.',
              style: TextStyle(
                fontFamily: 'PlayfairDisplay',
                color: pHead(d),
                fontSize: 42,
                fontWeight: FontWeight.w700,
                letterSpacing: -1,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Real-world experience and hands-on engineering projects '
              'that shaped my technical foundation.',
              style: TextStyle(
                  fontFamily: 'DMSans',
                  color: pBody(d),
                  fontSize: 14,
                  height: 1.6),
            ),

            // ════════════════════════════════════════════════════════
            // SECTION A — WORK IMMERSION
            // ════════════════════════════════════════════════════════
            const SizedBox(height: 52),
            const PallenSubLabel('Work Immersion'),
            const SizedBox(height: 20),

            // ── A1. Hero card ────────────────────────────────────────
            PallenHoverCard(
              slideRight: true,
              padding: const EdgeInsets.all(36),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const PallenGlassChip('WORK IMMERSION  ·  2024'),
                          const Spacer(),
                          const PallenGlassChip('Electrical Maintenance'),
                        ]),
                        const SizedBox(height: 24),
                        Text(
                          'Ibayiw Integrated\nNational High School',
                          style: TextStyle(
                            fontFamily: 'PlayfairDisplay',
                            color: pHead(d),
                            fontSize: 52,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -2,
                            height: 0.95,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Providing essential electrical maintenance services '
                          'to ensure a safe and fully functional learning environment '
                          'for students and faculty.',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            color: pBody(d),
                            fontSize: 14,
                            height: 1.65,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Wrap(spacing: 8, runSpacing: 6, children: const [
                          PallenMetaBadge(
                              icon: Icons.engineering_rounded,
                              text: 'Electrical Technician Trainee'),
                          PallenMetaBadge(
                              icon: Icons.calendar_today_rounded, text: '2024'),
                          PallenMetaBadge(
                              icon: Icons.location_on_outlined,
                              text: 'Alaminos, Laguna'),
                          PallenMetaBadge(
                              icon: Icons.school_rounded,
                              text: 'DepEd — Senior High School'),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: pCard(d),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: pBorder(d)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.white.withOpacity(0.06),
                            blurRadius: 24)
                      ],
                    ),
                    child: Icon(Icons.electrical_services_rounded,
                        color: pIcon(d), size: 38),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── A2. What I Did / Key Focus / Safety ──────────────────
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: PallenRcoCard(
                  icon: Icons.manage_accounts_rounded,
                  title: 'What I Did',
                  body: 'Performed hands-on electrical maintenance, '
                      'troubleshooting, and repair of classroom lighting '
                      'fixtures, electrical outlets, and wiring systems '
                      'throughout the school premises.',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PallenRcoCard(
                  icon: Icons.psychology_rounded,
                  title: 'Key Focus',
                  body: 'Assisted in the installation of new electrical '
                      'components and ensured every task was completed '
                      'with precision — from diagnosing faults to restoring '
                      'full electrical function in each area.',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PallenRcoCard(
                  icon: Icons.verified_user_outlined,
                  title: 'Safety & Compliance',
                  body: 'All work was carried out in strict compliance with '
                      'standard electrical safety protocols to maintain a '
                      'secure learning environment for students, teachers, '
                      'and support staff at all times.',
                ),
              ),
            ]),

            const SizedBox(height: 44),
            const PallenSubLabel('Work Activities'),
            const SizedBox(height: 20),

            // ── A3. Three activity detail cards ──────────────────────
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Activity 1 — Lighting
              Expanded(
                child: PallenHoverCard(
                  slideRight: false,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const PallenIconSquare(
                            icon: Icons.lightbulb_outline_rounded),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text('Lighting Maintenance',
                              style: TextStyle(
                                  fontFamily: 'DMSans',
                                  color: pCardText(d),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ]),
                      const SizedBox(height: 14),
                      // Visual: lighting diagram
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 120,
                          color: pBg3(d),
                          child: Stack(children: [
                            Center(
                              child: CustomPaint(
                                size: const Size(120, 80),
                                painter: _LightingPainter(),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              left: 10,
                              child: Text('Fluorescent  ·  LED  ·  Fixtures',
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    color: pMuted(d),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                  )),
                            ),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Inspected, repaired, and replaced faulty lighting '
                        'fixtures across multiple classrooms. Tasks included '
                        'ballast replacements, tube swaps, and socket repairs.',
                        style: TextStyle(
                            fontFamily: 'DMSans',
                            color: pCardSub(d),
                            fontSize: 11,
                            height: 1.6),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Activity 2 — Outlets & Wiring
              Expanded(
                child: PallenHoverCard(
                  slideRight: false,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const PallenIconSquare(icon: Icons.power_outlined),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text('Outlets & Wiring',
                              style: TextStyle(
                                  fontFamily: 'DMSans',
                                  color: pCardText(d),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ]),
                      const SizedBox(height: 14),
                      // Visual: wiring diagram
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 120,
                          color: pBg3(d),
                          child: Stack(children: [
                            Center(
                              child: CustomPaint(
                                size: const Size(120, 80),
                                painter: _WiringPainter(),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              left: 10,
                              child: Text('Outlets  ·  Wiring  ·  Circuits',
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    color: pMuted(d),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                  )),
                            ),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Diagnosed and repaired damaged electrical outlets '
                        'and wiring faults. Ensured correct load distribution '
                        'and safe connections across circuits.',
                        style: TextStyle(
                            fontFamily: 'DMSans',
                            color: pCardSub(d),
                            fontSize: 11,
                            height: 1.6),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Activity 3 — Component Installation
              Expanded(
                child: PallenHoverCard(
                  slideRight: false,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const PallenIconSquare(
                            icon: Icons.construction_rounded),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text('Component Installation',
                              style: TextStyle(
                                  fontFamily: 'DMSans',
                                  color: pCardText(d),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ]),
                      const SizedBox(height: 14),
                      // Visual: installation checklist
                      Container(
                        height: 120,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: pBg3(d),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            'New lighting fixtures',
                            'Electrical outlets',
                            'Circuit breakers',
                            'Switches & panels',
                            'Conduit & cable runs',
                          ]
                              .map((s) => Row(children: [
                                    const Icon(
                                        Icons.check_circle_outline_rounded,
                                        size: 11,
                                        color: kPGreen),
                                    const SizedBox(width: 7),
                                    Text(s,
                                        style: TextStyle(
                                          fontFamily: 'DMSans',
                                          color: pBody(d),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        )),
                                  ]))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Assisted licensed electricians in installing new '
                        'electrical infrastructure across designated areas, '
                        'following blueprints and safety standards.',
                        style: TextStyle(
                            fontFamily: 'DMSans',
                            color: pCardSub(d),
                            fontSize: 11,
                            height: 1.6),
                      ),
                    ],
                  ),
                ),
              ),
            ]),

            const SizedBox(height: 28),

            // ── A4. Skills gained row ────────────────────────────────
            Row(children: [
              Text('SKILLS GAINED',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    color: pMuted(d),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.5,
                  )),
              const SizedBox(width: 16),
              Container(height: 1, width: 24, color: pLine(d)),
              const SizedBox(width: 16),
              const Wrap(spacing: 8, runSpacing: 6, children: [
                PallenGrayPill('Electrical Troubleshooting'),
                PallenGrayPill('Lighting Systems'),
                PallenGrayPill('Wiring & Outlets'),
                PallenGrayPill('Safety Protocols'),
                PallenGrayPill('Component Installation'),
                PallenGrayPill('Circuit Repair'),
                PallenGrayPill('Preventive Maintenance'),
              ]),
            ]),

            // ════════════════════════════════════════════════════════
            // SECTION B — PROJECTS / NAVIRA
            // ════════════════════════════════════════════════════════
            const SizedBox(height: 64),
            Divider(color: pLine(d), height: 1),
            const SizedBox(height: 52),
            const PallenSubLabel('Projects'),
            const SizedBox(height: 20),

            // ── B1. NAVIRA hero card ─────────────────────────────────
            PallenHoverCard(
              slideRight: true,
              padding: const EdgeInsets.all(36),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const PallenGlassChip(
                              'UNDERGRADUATE THESIS  ·  2025–2026'),
                          const Spacer(),
                          const PallenGlassChip('Embedded Systems'),
                        ]),
                        const SizedBox(height: 24),
                        Text('NAVIRA',
                            style: TextStyle(
                              fontFamily: 'PlayfairDisplay',
                              color: pHead(d),
                              fontSize: 64,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -2.5,
                              height: 0.88,
                            )),
                        const SizedBox(height: 12),
                        Text(
                          'An ESP32-Based Smart Blind Stick with Wireless\n'
                          'Armband Integration for Enhanced Mobility of\n'
                          'the Visually Impaired',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            color: pHead(d),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Wrap(spacing: 8, runSpacing: 6, children: const [
                          PallenMetaBadge(
                              icon: Icons.person_outline_rounded,
                              text: 'Lead Designer & Developer'),
                          PallenMetaBadge(
                              icon: Icons.calendar_today_rounded, text: '2025'),
                          PallenMetaBadge(
                              icon: Icons.school_rounded,
                              text: 'BS Computer Engineering'),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: pCard(d),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: pBorder(d)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.white.withOpacity(0.06),
                            blurRadius: 24)
                      ],
                    ),
                    child:
                        Icon(Icons.biotech_rounded, color: pIcon(d), size: 38),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── B2. Role / Challenge / Outcome ───────────────────────
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: PallenRcoCard(
                  icon: Icons.manage_accounts_rounded,
                  title: 'My Role',
                  body: 'As one of seven developers, I contributed to the '
                      'hardware design including PCB layout in KiCad, '
                      'firmware programming in C++ for the ESP32 '
                      'microcontroller, and integration of the UWB-based '
                      'wireless armband communication system.',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PallenRcoCard(
                  icon: Icons.psychology_rounded,
                  title: 'The Challenge',
                  body: 'Developing a cost-effective assistive device that '
                      'accurately detects both ground-level and elevated '
                      'obstacles, identifies wet surfaces to prevent slips, '
                      'and provides intuitive haptic and audio feedback for '
                      'visually impaired users.',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PallenRcoCard(
                  icon: Icons.emoji_events_rounded,
                  title: 'The Outcome',
                  body: 'A functional prototype validated by Computer '
                      'Engineering practitioners with an overall mean score '
                      'of 4.6 / 5.0 (Highly Acceptable). The device '
                      'demonstrated obstacle detection up to 2 m, water '
                      'detection across varying depths, and reliable UWB '
                      'tracking within 10 m.',
                ),
              ),
            ]),

            const SizedBox(height: 44),
            const PallenSubLabel('Project Deliverables'),
            const SizedBox(height: 20),

            // ── B3. Three deliverable cards ──────────────────────────
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Deliverable 1 — 3D Model
              Expanded(
                child: PallenHoverCard(
                  slideRight: false,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const PallenIconSquare(icon: Icons.view_in_ar_rounded),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text('3D Model',
                              style: TextStyle(
                                  fontFamily: 'DMSans',
                                  color: pCardText(d),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ]),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 120,
                          color: pBg3(d),
                          child: Stack(children: [
                            Center(
                              child: CustomPaint(
                                size: const Size(80, 60),
                                painter: PallenThreeDBoxPainter(),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              left: 10,
                              child: Text('Fusion 360',
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    color: pMuted(d),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                  )),
                            ),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Full enclosure designed in Fusion 360. '
                        'Ergonomic grip, sensor mounting ports, '
                        'and compartment for ESP32 PCB.',
                        style: TextStyle(
                            fontFamily: 'DMSans',
                            color: pCardSub(d),
                            fontSize: 11,
                            height: 1.6),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Deliverable 2 — PCB Design
              Expanded(
                child: PallenHoverCard(
                  slideRight: false,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const PallenIconSquare(
                            icon: Icons.developer_board_rounded),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text('Device Design',
                              style: TextStyle(
                                  fontFamily: 'DMSans',
                                  color: pCardText(d),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ]),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 120,
                          color: pBg3(d),
                          child: Stack(children: [
                            Center(
                              child: CustomPaint(
                                size: const Size(100, 70),
                                painter: PallenPcbPainter(),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              left: 10,
                              child: Text('KiCad  ·  ESP32',
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    color: pMuted(d),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                  )),
                            ),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Schematic capture and PCB layout in KiCad. '
                        'Integrates ESP32 UWB, dual VL53L0X ToF sensors, '
                        'vibration motor, and water detection circuit.',
                        style: TextStyle(
                            fontFamily: 'DMSans',
                            color: pCardSub(d),
                            fontSize: 11,
                            height: 1.6),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Deliverable 3 — Research Paper
              Expanded(
                child: PallenHoverCard(
                  slideRight: false,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const PallenIconSquare(icon: Icons.menu_book_rounded),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text('Research Paper',
                              style: TextStyle(
                                  fontFamily: 'DMSans',
                                  color: pCardText(d),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ]),
                      const SizedBox(height: 14),
                      Container(
                        height: 120,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: pBg3(d),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            'Theoretical Framework',
                            'Review of Related Literature',
                            'Flow Chart',
                            'Project Benefits',
                            'Recommendation',
                          ]
                              .map((s) => Row(children: [
                                    Container(
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: pMuted(d),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(s,
                                        style: TextStyle(
                                          fontFamily: 'DMSans',
                                          color: pBody(d),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        )),
                                  ]))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Full academic manuscript covering theoretical framework, '
                        'design methodology, hardware/software testing results, '
                        'and evaluation based on ISO 25010 standards.',
                        style: TextStyle(
                            fontFamily: 'DMSans',
                            color: pCardSub(d),
                            fontSize: 11,
                            height: 1.6),
                      ),
                    ],
                  ),
                ),
              ),
            ]),

            const SizedBox(height: 28),

            // ── B4. Tech stack row ───────────────────────────────────
            Row(children: [
              Text('TECH STACK',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    color: pMuted(d),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.5,
                  )),
              const SizedBox(width: 16),
              Container(height: 1, width: 24, color: pLine(d)),
              const SizedBox(width: 16),
              const Wrap(spacing: 8, runSpacing: 6, children: [
                PallenGrayPill('ESP32'),
                PallenGrayPill('C++'),
                PallenGrayPill('VL53L0X ToF'),
                PallenGrayPill('Copper Wire Water Detection'),
                PallenGrayPill('DFPlayer Mini'),
                PallenGrayPill('KiCad'),
                PallenGrayPill('Fusion 360'),
                PallenGrayPill('ESP-NOW'),
                PallenGrayPill('AutoCAD'),
              ]),
            ]),
          ],
        ),
      ),
      footer,
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════
// CUSTOM PAINTERS — Work Immersion activity visuals
// ═══════════════════════════════════════════════════════════════

/// Lighting fixtures diagram
class _LightingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..style = PaintingStyle.fill;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Draw 3 tube-light fixtures across the width
    for (int i = 0; i < 3; i++) {
      final x = cx - 50 + i * 50.0;

      // Ceiling mount
      canvas.drawRect(
        Rect.fromLTWH(x - 14, cy - 28, 28, 6),
        fill..color = Colors.white.withOpacity(0.18),
      );

      // Tube
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(x - 11, cy - 22, 22, 8), const Radius.circular(4)),
        fill..color = Colors.white.withOpacity(i == 1 ? 0.55 : 0.22),
      );

      // Glow under lit tube
      if (i == 1) {
        final glowPaint = Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.white.withOpacity(0.18),
              Colors.transparent,
            ],
          ).createShader(
              Rect.fromCircle(center: Offset(x, cy + 10), radius: 28));
        canvas.drawCircle(Offset(x, cy + 10), 28, glowPaint);
      }

      // Wires going up
      stroke.color = Colors.white.withOpacity(0.15);
      canvas.drawLine(Offset(x, cy - 34), Offset(x, cy - 28), stroke);
    }

    // Ground line
    canvas.drawLine(
      Offset(cx - 60, cy + 26),
      Offset(cx + 60, cy + 26),
      stroke..color = Colors.white.withOpacity(0.1),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

/// Wiring/outlet diagram
class _WiringPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..style = PaintingStyle.fill;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Draw outlet box on left
    final outletRect = Rect.fromLTWH(cx - 52, cy - 18, 32, 36);
    canvas.drawRRect(
      RRect.fromRectAndRadius(outletRect, const Radius.circular(4)),
      fill..color = Colors.white.withOpacity(0.12),
    );
    // Outlet slots
    for (int i = 0; i < 2; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - 48 + i * 11.0, cy - 8, 7, 14),
            const Radius.circular(2)),
        fill..color = Colors.black.withOpacity(0.35),
      );
    }

    // Wires going right with bends
    stroke
      ..color = Colors.white.withOpacity(0.30)
      ..strokeWidth = 2.0;
    final path = Path()
      ..moveTo(cx - 20, cy - 6)
      ..lineTo(cx + 5, cy - 6)
      ..lineTo(cx + 5, cy - 20)
      ..lineTo(cx + 40, cy - 20);
    canvas.drawPath(path, stroke);

    stroke.color = Colors.white.withOpacity(0.18);
    final path2 = Path()
      ..moveTo(cx - 20, cy + 6)
      ..lineTo(cx + 5, cy + 6)
      ..lineTo(cx + 5, cy + 20)
      ..lineTo(cx + 40, cy + 20);
    canvas.drawPath(path2, stroke);

    // Circuit breaker box on right
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(cx + 40, cy - 28, 20, 56), const Radius.circular(3)),
      fill..color = Colors.white.withOpacity(0.10),
    );
    for (int i = 0; i < 4; i++) {
      canvas.drawRect(
        Rect.fromLTWH(cx + 44, cy - 22 + i * 13.0, 12, 7),
        fill..color = Colors.white.withOpacity(i == 1 ? 0.40 : 0.12),
      );
    }

    // Ground symbol
    stroke
      ..color = Colors.white.withOpacity(0.20)
      ..strokeWidth = 1.2;
    for (int i = 0; i < 3; i++) {
      final len = 14.0 - i * 4;
      canvas.drawLine(
        Offset(cx - 6 + (4 - len) / 2, cy + 32 + i * 4.0),
        Offset(cx - 6 + (4 - len) / 2 + len, cy + 32 + i * 4.0),
        stroke,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

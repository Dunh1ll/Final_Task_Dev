// lib/screens/pallen_profile/pallen_work_page.dart
import 'package:flutter/material.dart';
import 'pallen_theme.dart';
import 'pallen_widgets.dart';

class PallenWorkPage extends StatelessWidget {
  final Widget footer;
  const PallenWorkPage({super.key, required this.footer});

  @override
  Widget build(BuildContext context) {
    final d = PTheme.of(context);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(children: [
        const SizedBox(height: 80),
        Container(
          color: pBg2(d),
          padding: const EdgeInsets.fromLTRB(76, 56, 76, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PallenEyebrowLabel('02 — WORK & PROJECTS'),
              Text(
                'From concept to reality.',
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
                'A showcase of my most significant engineering project — '
                'designed, built, and documented from the ground up.',
                style: TextStyle(
                    fontFamily: 'DMSans',
                    color: pBody(d),
                    fontSize: 14,
                    height: 1.6),
              ),
              const SizedBox(height: 52),

              // NAVIRA hero card
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
                                'UNDERGRADUATE THESIS  ·  2025-2026'),
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
                                icon: Icons.calendar_today_rounded,
                                text: '2025'),
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
                          Icon(Icons.blind_rounded, color: pIcon(d), size: 38),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // Role / Challenge / Outcome
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
                        'of 4.6/5.0 (Highly Acceptable). The device successfully '
                        'demonstrated obstacle detection up to 2m, water '
                        'detection across varying depths, and reliable UWB '
                        'tracking within 10 meters.',
                  ),
                ),
              ]),

              const SizedBox(height: 44),
              const PallenSubLabel('Project Deliverables'),
              const SizedBox(height: 20),

              // Deliverables row
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // 3D Model
                Expanded(
                  child: PallenHoverCard(
                    slideRight: false,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const PallenIconSquare(
                              icon: Icons.view_in_ar_rounded),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text('3D Model Design',
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
                                  size: const Size(80, 80),
                                  painter: PallenThreeDBoxPainter(),
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                left: 10,
                                child: Text('Fusion 360 · AutoCAD',
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
                          'Designed the stick housing and armband enclosure '
                          'using Fusion 360 and AutoCAD for ergonomic fit. '
                          'Prototype ensures durability and user comfort.',
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

                // PCB Design
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

                // Research Paper
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

              // Tech stack
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
                  PallenGrayPill('Autocad'),
                ]),
              ]),
            ],
          ),
        ),
        footer,
      ]),
    );
  }
}

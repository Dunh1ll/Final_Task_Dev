// lib/screens/pallen_profile/pallen_about_page.dart
import 'package:flutter/material.dart';
import 'pallen_theme.dart';
import 'pallen_widgets.dart';

class PallenAboutPage extends StatelessWidget {
  final Widget footer;
  const PallenAboutPage({super.key, required this.footer});

  @override
  Widget build(BuildContext context) {
    final d = PTheme.of(context);

    // FIX: No SingleChildScrollView here — the outer CustomScrollView in
    // profile_detail_pallen.dart handles all scrolling. A nested
    // SingleChildScrollView fights the parent for scroll events and can
    // collapse to zero height inside a SliverToBoxAdapter.
    return Column(children: [
      const SizedBox(height: 80),
      Container(
        color: pBg(d),
        padding: const EdgeInsets.fromLTRB(76, 56, 76, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PallenEyebrowLabel('01 — ABOUT ME'),
            Text(
              'The person behind the profile.',
              style: TextStyle(
                fontFamily: 'PlayfairDisplay',
                color: pHead(d),
                fontSize: 42,
                fontWeight: FontWeight.w700,
                letterSpacing: -1,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 48),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // ── LEFT ──────────────────────────────────────────
              Expanded(
                flex: 44,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Small profile photo
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: pBorder(d).withOpacity(0.7), width: 2),
                        boxShadow: [
                          BoxShadow(color: pGlowLit(d), blurRadius: 20)
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          'assets/images/profile1.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                              color: pCard(d),
                              child: Icon(Icons.person_rounded,
                                  color: pIcon(d), size: 36)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'I\'m a Computer Engineering graduate with a passion '
                      'for building systems that make a tangible difference. '
                      'My journey began with a curiosity for how things work — '
                      'from the circuits on a PCB to the lines of code running '
                      'on a server.',
                      style: TextStyle(
                          fontFamily: 'DMSans',
                          color: pBody(d),
                          fontSize: 14,
                          height: 1.85),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Today, I combine full-stack development with embedded '
                      'systems expertise. I\'m motivated by the challenge of '
                      'solving real-world problems — especially those that '
                      'improve accessibility and quality of life.',
                      style: TextStyle(
                          fontFamily: 'DMSans',
                          color: pBody(d),
                          fontSize: 14,
                          height: 1.85),
                    ),
                    const SizedBox(height: 36),
                    const PallenSubLabel('Education'),
                    const SizedBox(height: 14),
                    PallenHoverCard(
                      slideRight: true,
                      child: Row(children: [
                        const PallenIconSquare(icon: Icons.school_rounded),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('BS in Computer Engineering',
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    color: pCardText(d),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    height: 1.3,
                                  )),
                              const SizedBox(height: 4),
                              const Row(children: [
                                Icon(Icons.check_circle_outline_rounded,
                                    size: 12, color: kPGreen),
                                SizedBox(width: 5),
                                Text('Graduate',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      color: kPGreen,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    )),
                              ]),
                            ],
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 36),
                    const PallenSubLabel('Values & Goals'),
                    const SizedBox(height: 14),
                    ...[
                      (
                        Icons.lightbulb_outline_rounded,
                        'Innovation',
                        'Creating technology that solves real problems.'
                      ),
                      (
                        Icons.handshake_outlined,
                        'Collaboration',
                        'Building systems that connect people and ideas.'
                      ),
                      (
                        Icons.trending_up_rounded,
                        'Growth',
                        'Continuously learning across hardware and software.'
                      ),
                    ].map((v) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: PallenHoverCard(
                            slideRight: true,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(children: [
                              PallenIconSquare(icon: v.$1, size: 32),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(v.$2,
                                        style: TextStyle(
                                          fontFamily: 'DMSans',
                                          color: pCardText(d),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        )),
                                    const SizedBox(height: 2),
                                    Text(v.$3,
                                        style: TextStyle(
                                          fontFamily: 'DMSans',
                                          color: pCardSub(d),
                                          fontSize: 11,
                                          height: 1.4,
                                        )),
                                  ],
                                ),
                              ),
                            ]),
                          ),
                        )),
                    const SizedBox(height: 36),
                    const PallenSubLabel('Engineering Tools'),
                    const SizedBox(height: 14),
                    ...[
                      (
                        Icons.developer_board_rounded,
                        'KiCad',
                        'PCB Design & Schematic Layout'
                      ),
                      (
                        Icons.architecture_rounded,
                        'AutoCAD',
                        '3D Modeling & Technical Drawing'
                      ),
                      (
                        Icons.view_in_ar_rounded,
                        'Fusion 360',
                        '3D CAD Design & Simulation'
                      ),
                    ].map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: PallenHoverCard(
                            slideRight: true,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(children: [
                              PallenIconSquare(icon: t.$1, size: 34),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(t.$2,
                                        style: TextStyle(
                                          fontFamily: 'DMSans',
                                          color: pCardText(d),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        )),
                                    Text(t.$3,
                                        style: TextStyle(
                                          fontFamily: 'DMSans',
                                          color: pCardSub(d),
                                          fontSize: 11,
                                        )),
                                  ],
                                ),
                              ),
                            ]),
                          ),
                        )),
                  ],
                ),
              ),

              const SizedBox(width: 56),

              // ── RIGHT: Technical Skills ────────────────────────
              Expanded(
                flex: 56,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PallenSubLabel('Technical Skills'),
                    const SizedBox(height: 8),
                    Text(
                      'Languages, frameworks, and technologies I use daily.',
                      style: TextStyle(
                          fontFamily: 'DMSans',
                          color: pBody(d),
                          fontSize: 13,
                          height: 1.5),
                    ),
                    const SizedBox(height: 28),
                    const PallenSkillCategoryBlock(
                      label: 'Frontend',
                      items: [
                        PallenLangItem('HTML', PallenLangKind.html),
                        PallenLangItem('CSS', PallenLangKind.css),
                        PallenLangItem('JavaScript', PallenLangKind.js),
                        PallenLangItem('Flutter', PallenLangKind.flutter),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const PallenSkillCategoryBlock(
                      label: 'Backend',
                      items: [
                        PallenLangItem('Go', PallenLangKind.go),
                        PallenLangItem('Java', PallenLangKind.java),
                        PallenLangItem('Python', PallenLangKind.python),
                        PallenLangItem('C++', PallenLangKind.cpp),
                        PallenLangItem('C', PallenLangKind.c),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const PallenSkillCategoryBlock(
                      label: 'Database',
                      items: [
                        PallenLangItem('PostgreSQL', PallenLangKind.postgres),
                        PallenLangItem('MySQL', PallenLangKind.mysql),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const PallenSkillCategoryBlock(
                      label: 'Low-Level / Other',
                      items: [
                        PallenLangItem('Assembly Language', PallenLangKind.asm),
                        PallenLangItem('HDL', PallenLangKind.hdl),
                      ],
                    ),
                  ],
                ),
              ),
            ]),
          ],
        ),
      ),
      footer,
    ]);
  }
}

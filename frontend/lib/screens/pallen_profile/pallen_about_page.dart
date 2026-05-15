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

    return Column(children: [
      const SizedBox(height: 80),
      Container(
        color: pBg(d),
        padding: const EdgeInsets.fromLTRB(76, 56, 76, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScrollReveal(
              child: const PallenEyebrowLabel('01 — ABOUT ME'),
            ),
            ScrollReveal(
              delay: 0.1,
              child: Text(
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
            ),
            const SizedBox(height: 48),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // ── LEFT ──────────────────────────────────────────
              Expanded(
                flex: 44,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScrollReveal(
                      child: Container(
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
                    ),
                    const SizedBox(height: 24),
                    ScrollReveal(
                      delay: 0.1,
                      child: Text(
                        "I'm a Computer Engineering graduate with a passion "
                        "for building systems that make a tangible difference. "
                        "My journey began with a curiosity for how things work — "
                        "from the circuits on a PCB to the lines of code running "
                        "on a server.",
                        style: TextStyle(
                            fontFamily: 'DMSans',
                            color: pBody(d),
                            fontSize: 14,
                            height: 1.85),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ScrollReveal(
                      delay: 0.2,
                      child: Text(
                        "Today, I combine full-stack development with embedded "
                        "systems expertise. I'm motivated by the challenge of "
                        "solving real-world problems — especially those that "
                        "improve accessibility and quality of life.",
                        style: TextStyle(
                            fontFamily: 'DMSans',
                            color: pBody(d),
                            fontSize: 14,
                            height: 1.85),
                      ),
                    ),
                    const SizedBox(height: 36),
                    ScrollReveal(
                      child: const PallenSubLabel('Education'),
                    ),
                    const SizedBox(height: 14),
                    ScrollReveal(
                      delay: 0.1,
                      child: PallenHoverCard(
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
                    ),
                    const SizedBox(height: 36),
                    ScrollReveal(
                      child: const PallenSubLabel('Values & Goals'),
                    ),
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
                    ].asMap().entries.map((e) => ScrollReveal(
                          delay: 0.1 * e.key,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: PallenHoverCard(
                              slideRight: true,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Row(children: [
                                PallenIconSquare(icon: e.value.$1, size: 32),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(e.value.$2,
                                          style: TextStyle(
                                            fontFamily: 'DMSans',
                                            color: pCardText(d),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          )),
                                      const SizedBox(height: 2),
                                      Text(e.value.$3,
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
                          ),
                        )),
                    const SizedBox(height: 36),
                    ScrollReveal(
                      child: const PallenSubLabel('Engineering Tools'),
                    ),
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
                    ].asMap().entries.map((e) => ScrollReveal(
                          delay: 0.1 * e.key,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: PallenHoverCard(
                              slideRight: true,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Row(children: [
                                PallenIconSquare(icon: e.value.$1, size: 34),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(e.value.$2,
                                          style: TextStyle(
                                            fontFamily: 'DMSans',
                                            color: pCardText(d),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          )),
                                      Text(e.value.$3,
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
                    ScrollReveal(
                      child: const PallenSubLabel('Technical Skills'),
                    ),
                    const SizedBox(height: 8),
                    ScrollReveal(
                      delay: 0.1,
                      child: Text(
                        'Languages, frameworks, and technologies I use daily.',
                        style: TextStyle(
                            fontFamily: 'DMSans',
                            color: pBody(d),
                            fontSize: 13,
                            height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 28),
                    ScrollReveal(
                      child: _SkillBlock(
                        label: 'Frontend',
                        items: const [
                          PallenLangItem('HTML', PallenLangKind.html,
                              proficiency: 0.92),
                          PallenLangItem('CSS', PallenLangKind.css,
                              proficiency: 0.88),
                          PallenLangItem('JavaScript', PallenLangKind.js,
                              proficiency: 0.85),
                          PallenLangItem('React', PallenLangKind.react,
                              proficiency: 0.82),
                          PallenLangItem('Flutter', PallenLangKind.flutter,
                              proficiency: 0.90),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    ScrollReveal(
                      delay: 0.15,
                      child: _SkillBlock(
                        label: 'Backend',
                        items: const [
                          PallenLangItem('Go', PallenLangKind.go,
                              proficiency: 0.80),
                          PallenLangItem('Java', PallenLangKind.java,
                              proficiency: 0.85),
                          PallenLangItem('Python', PallenLangKind.python,
                              proficiency: 0.88),
                          PallenLangItem('C++', PallenLangKind.cpp,
                              proficiency: 0.82),
                          PallenLangItem('C', PallenLangKind.c,
                              proficiency: 0.78),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    ScrollReveal(
                      delay: 0.2,
                      child: _SkillBlock(
                        label: 'Database',
                        items: const [
                          PallenLangItem('PostgreSQL', PallenLangKind.postgres,
                              proficiency: 0.80),
                          PallenLangItem('MySQL', PallenLangKind.mysql,
                              proficiency: 0.82),
                          PallenLangItem('JSON', PallenLangKind.json,
                              proficiency: 0.90),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    ScrollReveal(
                      delay: 0.25,
                      child: _SkillBlock(
                        label: 'Low-Level / Other',
                        items: const [
                          PallenLangItem(
                              'Assembly Language', PallenLangKind.asm,
                              proficiency: 0.70),
                          PallenLangItem('HDL', PallenLangKind.hdl,
                              proficiency: 0.65),
                        ],
                      ),
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

// Enhanced skill block with progress bars
class _SkillBlock extends StatelessWidget {
  final String label;
  final List<PallenLangItem> items;

  const _SkillBlock({required this.label, required this.items});

  @override
  Widget build(BuildContext context) {
    final d = PTheme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(),
          style: TextStyle(
            fontFamily: 'DMSans',
            color: pEyebrow(d),
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.5,
          )),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 10,
        children: items
            .map((i) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PallenLangBadge(item: i),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 120,
                      child: AnimatedProgressBar(
                        progress: i.proficiency,
                        color: pallenLangBrand(i.kind),
                        height: 3,
                      ),
                    ),
                  ],
                ))
            .toList(),
      ),
    ]);
  }
}

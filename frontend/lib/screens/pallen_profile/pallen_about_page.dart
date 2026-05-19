// lib/screens/pallen_profile/pallen_about_page.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'pallen_theme.dart';
import 'pallen_widgets.dart';

// ═══════════════════════════════════════════════════════════════════
// DRAWING ASSET GUIDE
// ───────────────────────────────────────────────────────────────────
// Place all drawing images inside:   assets/images/drawings/
//
// RECOMMENDED FILE NAMES & SIZES:
//
//   drawing_01.jpg  →  800 × 1000 px   (portrait 4:5,  top-left slot)
//   drawing_02.jpg  →  800 × 1067 px   (portrait 3:4,  top-center slot)
//   drawing_03.jpg  →  800 × 1000 px   (portrait 4:5,  top-right slot)
//   drawing_04.jpg  → 1600 ×  900 px   (landscape 16:9, bottom-left WIDE)
//   drawing_05.jpg  →  800 × 1000 px   (portrait 4:5,  bottom-center slot)
//   drawing_06.jpg  →  800 × 1000 px   (portrait 4:5,  bottom-right slot)
//
// TIPS:
//   • JPG at 85% quality is fine for web; PNG is okay for transparent art.
//   • Keep file sizes under 500 KB each for fast load.
//   • Artwork can be scanned pencil, digital, or photo of physical art.
//   • Update the title/caption in _DrawingGallery._drawings below.
//   • Add more slots by extending _drawings and adding rows to the builder.
//
// pubspec.yaml — make sure you have:
//   flutter:
//     assets:
//       - assets/images/
//       - assets/images/drawings/
// ═══════════════════════════════════════════════════════════════════

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
            // ── Section header ─────────────────────────────────────
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

            // ── Top row: bio + skills ──────────────────────────────
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // ── LEFT ──────────────────────────────────────────────
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
                        "I'm a Computer Engineering undergraduate with a passion "
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
                                Row(children: [
                                  Icon(Icons.schedule_rounded,
                                      size: 12, color: Color(0xFFFBBF24)),
                                  SizedBox(width: 5),
                                  Text('Undergraduate',
                                      style: TextStyle(
                                        fontFamily: 'DMSans',
                                        color: Color(0xFFFBBF24),
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
                    const SizedBox(height: 10),
                    ScrollReveal(
                      delay: 0.2,
                      child: PallenHoverCard(
                        slideRight: true,
                        child: Row(children: [
                          const PallenIconSquare(
                              icon: Icons.electric_bolt_rounded),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Electrical Installation and Maintenance',
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
                                  Text('Senior High School — Graduate',
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

              // ── RIGHT: Technical Skills ────────────────────────────
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

            // ══════════════════════════════════════════════════════════
            // HOBBIES SECTION
            // ══════════════════════════════════════════════════════════
            const SizedBox(height: 72),
            ScrollReveal(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, pLine(d), Colors.transparent],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 56),
            ScrollReveal(
              delay: 0.05,
              child: const PallenEyebrowLabel('OUTSIDE THE CODE'),
            ),
            const SizedBox(height: 12),
            ScrollReveal(
              delay: 0.1,
              child: Text(
                'When I\'m not building, I\'m...',
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  color: pHead(d),
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  height: 1.15,
                ),
              ),
            ),
            const SizedBox(height: 36),

            // ── Hobby cards row ────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ScrollReveal(
                    delay: 0.0,
                    child: _HobbyCard(
                      icon: Icons.sports_esports_rounded,
                      accentColor: const Color(0xFF3B82F6),
                      title: 'Mobile Games',
                      subtitle: 'Online',
                      description:
                          'Grinding ranked matches and perfecting team comps. MLBB is where strategy meets reflexes.',
                      tag: 'Online Gaming',
                      tagIcon: Icons.videogame_asset_rounded,
                      painter: _MLBBPatternPainter(),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ScrollReveal(
                    delay: 0.1,
                    child: _HobbyCard(
                      icon: Icons.sports_basketball_rounded,
                      accentColor: const Color(0xFFEA580C),
                      title: 'Basketball',
                      subtitle: 'On the court',
                      description:
                          'Hitting the court keeps me sharp and grounded. There\'s nothing like a good game to clear the mind.',
                      tag: 'Sports',
                      tagIcon: Icons.emoji_events_rounded,
                      painter: _BasketballPatternPainter(),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ScrollReveal(
                    delay: 0.2,
                    child: _HobbyCard(
                      icon: Icons.draw_rounded,
                      accentColor: const Color(0xFFA855F7),
                      title: 'Drawing',
                      subtitle: 'Art & illustration',
                      description:
                          'Sketching characters, scenes, and ideas. Drawing is my way of expressing creativity beyond the screen.',
                      tag: 'Visual Art',
                      tagIcon: Icons.palette_rounded,
                      painter: _DrawingPatternPainter(),
                    ),
                  ),
                ),
              ],
            ),

            // ══════════════════════════════════════════════════════════
            // DRAWING GALLERY SECTION — IMPROVED
            // ══════════════════════════════════════════════════════════
            const SizedBox(height: 72),
            ScrollReveal(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, pLine(d), Colors.transparent],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 52),

            // Header row
            ScrollReveal(
              delay: 0.05,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PallenEyebrowLabel('MY DRAWINGS'),
                  Text(
                    'Sketches & Illustrations.',
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      color: pHead(d),
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A glimpse into the art I create in my downtime — '
                    'anime characters, scenes, and original concepts.',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      color: pBody(d),
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // ── Drawing gallery grid ───────────────────────────────
            ScrollReveal(
              delay: 0.2,
              child: _DrawingGallery(),
            ),
          ],
        ),
      ),
      footer,
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════════
// HOBBY CARD
// ═══════════════════════════════════════════════════════════════════
class _HobbyCard extends StatefulWidget {
  final IconData icon;
  final Color accentColor;
  final String title;
  final String subtitle;
  final String description;
  final String tag;
  final IconData tagIcon;
  final CustomPainter painter;

  const _HobbyCard({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.tag,
    required this.tagIcon,
    required this.painter,
  });

  @override
  State<_HobbyCard> createState() => _HobbyCardState();
}

class _HobbyCardState extends State<_HobbyCard>
    with SingleTickerProviderStateMixin {
  bool _hov = false;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = PTheme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: AnimatedBuilder(
        animation: _pulseCtrl,
        builder: (_, __) {
          final pulse = _pulseCtrl.value;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(0, _hov ? -6 : 0, 0),
            decoration: BoxDecoration(
              color: pCard(d),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    _hov ? widget.accentColor.withOpacity(0.5) : pCardBorder(d),
                width: _hov ? 1.5 : 1,
              ),
              boxShadow: _hov
                  ? [
                      BoxShadow(
                        color: widget.accentColor.withOpacity(0.18),
                        blurRadius: 40,
                        spreadRadius: 2,
                      )
                    ]
                  : [
                      BoxShadow(
                        color:
                            widget.accentColor.withOpacity(0.04 + 0.03 * pulse),
                        blurRadius: 20,
                      )
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(painter: widget.painter),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            widget.accentColor.withOpacity(0.06),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: widget.accentColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: widget.accentColor.withOpacity(0.25),
                          ),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.accentColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          color: pCardText(d),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          color: widget.accentColor.withOpacity(0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        widget.description,
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          color: pCardSub(d),
                          fontSize: 12,
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: widget.accentColor.withOpacity(0.09),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: widget.accentColor.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(widget.tagIcon,
                                color: widget.accentColor, size: 10),
                            const SizedBox(width: 5),
                            Text(
                              widget.tag,
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                color: widget.accentColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// HOBBY CARD BACKGROUND PAINTERS
// ═══════════════════════════════════════════════════════════════════

class _MLBBPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0x0A3B82F6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    const spacing = 20.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
    final dp = Paint()
      ..color = const Color(0x0F3B82F6)
      ..style = PaintingStyle.fill;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, dp);
      }
    }
  }

  @override
  bool shouldRepaint(_MLBBPatternPainter _) => false;
}

class _BasketballPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0x0AEA580C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (double r = 40; r <= 180; r += 32) {
      canvas.drawArc(
        Rect.fromCenter(
            center: Offset(size.width, size.height),
            width: r * 2,
            height: r * 2),
        math.pi,
        math.pi / 2,
        false,
        p,
      );
    }
    final lp = Paint()
      ..color = const Color(0x06EA580C)
      ..strokeWidth = 0.8;
    for (double y = 0; y < size.height; y += 16) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), lp);
    }
  }

  @override
  bool shouldRepaint(_BasketballPatternPainter _) => false;
}

class _DrawingPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0x09A855F7)
      ..strokeWidth = 1.0;
    for (double i = -size.height; i < size.width + size.height; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), p);
    }
    final p2 = Paint()
      ..color = const Color(0x05A855F7)
      ..strokeWidth = 0.8;
    for (double i = -size.height; i < size.width + size.height; i += 20) {
      canvas.drawLine(Offset(i + size.height, 0), Offset(i, size.height), p2);
    }
  }

  @override
  bool shouldRepaint(_DrawingPatternPainter _) => false;
}

// ═══════════════════════════════════════════════════════════════════
// DRAWING GALLERY — IMPROVED UI
// ═══════════════════════════════════════════════════════════════════

class _DrawingSlot {
  final String assetPath;
  final String title;
  final String? caption;
  final String? medium; // e.g. 'Pencil', 'Digital', 'Ink'

  const _DrawingSlot({
    required this.assetPath,
    required this.title,
    this.caption,
    this.medium,
  });
}

class _DrawingGallery extends StatelessWidget {
  static const List<_DrawingSlot> _drawings = [
    _DrawingSlot(
      assetPath: 'assets/images/drawings/drawing_01.jpg',
      title: 'Jiraiya',
      caption: '2025',
      medium: 'PEN',
    ),
    _DrawingSlot(
      assetPath: 'assets/images/drawings/drawing_02.jpg',
      title: 'Collection',
      caption: '2026',
      medium: 'PEN',
    ),
    _DrawingSlot(
      assetPath: 'assets/images/drawings/drawing_03.jpg',
      title: 'Roronoa Zoro',
      caption: '2025',
      medium: 'PEN',
    ),
    _DrawingSlot(
      assetPath: 'assets/images/drawings/drawing_04.jpg',
      title: 'Liebe',
      caption: '2024',
      medium: 'PEN',
    ),
    _DrawingSlot(
      assetPath: 'assets/images/drawings/drawing_05.jpg',
      title: 'Luffy',
      caption: '2025',
      medium: 'PEN',
    ),
    _DrawingSlot(
      assetPath: 'assets/images/drawings/drawing_06.jpg',
      title: 'Senku & Tsukasa',
      caption: '2024',
      medium: 'Pencil/Pen',
    ),
  ];

  _DrawingGallery();

  @override
  Widget build(BuildContext context) {
    final d = PTheme.of(context);

    if (_drawings.isEmpty) {
      return _EmptyGallery(d: d);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Row 1: 3 equal portrait tiles ────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < math.min(3, _drawings.length); i++) ...[
              if (i > 0) const SizedBox(width: 14),
              Expanded(
                child: _DrawingTile(
                  slot: _drawings[i],
                  aspectRatio: i == 1 ? 3 / 4 : 4 / 5,
                  index: i,
                ),
              ),
            ],
            for (int i = _drawings.length; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 14),
              Expanded(child: _EmptyDrawingSlot(d: d)),
            ],
          ],
        ),

        if (_drawings.length > 3) ...[
          const SizedBox(height: 14),
          // ── Row 2: wide left + 2 portrait right ─────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 3; i < math.min(6, _drawings.length); i++) ...[
                if (i > 3) const SizedBox(width: 14),
                Expanded(
                  flex: i == 3 ? 2 : 1,
                  child: _DrawingTile(
                    slot: _drawings[i],
                    aspectRatio: i == 3 ? 16 / 9 : 4 / 5,
                    index: i,
                  ),
                ),
              ],
              for (int i = _drawings.length; i < 6; i++) ...[
                if (i > 3) const SizedBox(width: 14),
                Expanded(flex: i == 3 ? 2 : 1, child: _EmptyDrawingSlot(d: d)),
              ],
            ],
          ),
        ],

        const SizedBox(height: 24),

        // ── Bottom info row ────────────────────────────────────────────
        Row(
          children: [
            Icon(Icons.info_outline_rounded, size: 12, color: pMuted(d)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Hover over a drawing to see its title. '
                'Add images to assets/images/drawings/ and update _DrawingGallery._drawings.',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  color: pMuted(d),
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Individual drawing tile ──────────────────────────────────────────
class _DrawingTile extends StatefulWidget {
  final _DrawingSlot slot;
  final double aspectRatio;
  final int index;

  const _DrawingTile({
    required this.slot,
    required this.aspectRatio,
    required this.index,
  });

  @override
  State<_DrawingTile> createState() => _DrawingTileState();
}

class _DrawingTileState extends State<_DrawingTile> {
  bool _hov = false;

  static const List<Color> _accents = [
    Color(0xFFA855F7),
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
    Color(0xFFD946EF),
    Color(0xFF7C3AED),
    Color(0xFFBD5CF6),
  ];

  @override
  Widget build(BuildContext context) {
    final d = PTheme.of(context);
    final accent = _accents[widget.index % _accents.length];

    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hov ? -5 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _hov ? accent.withOpacity(0.45) : pCardBorder(d),
            width: _hov ? 1.5 : 1,
          ),
          boxShadow: _hov
              ? [
                  BoxShadow(
                    color: accent.withOpacity(0.18),
                    blurRadius: 32,
                    spreadRadius: 2,
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: AspectRatio(
            aspectRatio: widget.aspectRatio,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image
                Image.asset(
                  widget.slot.assetPath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _DrawingPlaceholder(
                    index: widget.index,
                    d: d,
                  ),
                ),

                // Hover overlay
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 230),
                  opacity: _hov ? 1.0 : 0.0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.85),
                        ],
                        stops: const [0.35, 1.0],
                      ),
                    ),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Medium pill
                        if (widget.slot.medium != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(4),
                              border:
                                  Border.all(color: accent.withOpacity(0.4)),
                            ),
                            child: Text(
                              widget.slot.medium!.toUpperCase(),
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                color: accent,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                        Text(
                          widget.slot.title,
                          style: const TextStyle(
                            fontFamily: 'PlayfairDisplay',
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (widget.slot.caption != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.slot.caption!,
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              color: Colors.white.withOpacity(0.55),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Index badge (top-right)
                Positioned(
                  top: 12,
                  right: 12,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _hov ? 0.0 : 0.6,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          '${widget.index + 1}',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Placeholder when asset not found ────────────────────────────────
class _DrawingPlaceholder extends StatelessWidget {
  final int index;
  final bool d;
  const _DrawingPlaceholder({required this.index, required this.d});

  static const List<Color> _accents = [
    Color(0xFFA855F7),
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
    Color(0xFFD946EF),
    Color(0xFF7C3AED),
    Color(0xFFBD5CF6),
  ];

  @override
  Widget build(BuildContext context) {
    final accent = _accents[index % _accents.length];
    return Container(
      color: pCard(d),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _DrawingPatternPainter()),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: accent.withOpacity(0.22)),
                  ),
                  child: Icon(Icons.add_photo_alternate_outlined,
                      color: accent.withOpacity(0.65), size: 24),
                ),
                const SizedBox(height: 12),
                Text(
                  'drawing_0${index + 1}.jpg',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    color: accent.withOpacity(0.8),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Place in assets/images/drawings/',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    color: pMuted(d),
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyDrawingSlot extends StatelessWidget {
  final bool d;
  const _EmptyDrawingSlot({required this.d});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: pCardBorder(d).withOpacity(0.5),
              style: BorderStyle.solid,
              width: 1),
          color: pCard(d).withOpacity(0.4),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: pMuted(d), size: 28),
              const SizedBox(height: 6),
              Text(
                'Add drawing',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  color: pMuted(d),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyGallery extends StatelessWidget {
  final bool d;
  const _EmptyGallery({required this.d});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: pCardBorder(d)),
        color: pCard(d),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.palette_outlined, color: pMuted(d), size: 40),
          const SizedBox(height: 16),
          Text(
            'Your drawings gallery is empty.',
            style: TextStyle(
              fontFamily: 'DMSans',
              color: pCardText(d),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add _DrawingSlot entries to _DrawingGallery._drawings\nand place images in assets/images/drawings/',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DMSans',
              color: pMuted(d),
              fontSize: 12,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// SKILL BLOCK
// ═══════════════════════════════════════════════════════════════════
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

// lib/screens/pallen_profile/pallen_design_page.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'pallen_theme.dart';
import 'pallen_widgets.dart';

class PallenDesignPage extends StatelessWidget {
  final Widget footer;
  const PallenDesignPage({super.key, required this.footer});

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
            ScrollReveal(child: const PallenEyebrowLabel('04 — UI/UX DESIGN')),
            ScrollReveal(
              delay: 0.1,
              child: Text(
                'Interfaces that feel right.',
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
            const SizedBox(height: 12),
            ScrollReveal(
              delay: 0.15,
              child: Text(
                'A collection of UI clone projects — built to study design systems, '
                'practice layout precision, and sharpen visual instinct.',
                style: TextStyle(
                    fontFamily: 'DMSans',
                    color: pBody(d),
                    fontSize: 14,
                    height: 1.6),
              ),
            ),
            const SizedBox(height: 52),

            // ── Design Cards in Horizontal Carousel ──────────────────
            ScrollReveal(
              delay: 0.2,
              child: HorizontalCarousel(
                itemWidth: 520,
                gap: 24,
                children: [
                  _DesignCard(
                    d: d,
                    index: '01',
                    title: 'Facebook',
                    subtitle: 'Social Media UI Clone',
                    description:
                        'A pixel-faithful recreation of Facebook\'s web interface — '
                        'including the News Feed, Stories bar, sidebar navigation, '
                        'Marketplace preview, and responsive right-panel widgets. '
                        'Built to study Meta\'s design system and component hierarchy.',
                    tags: const [
                      'Feed Layout',
                      'Stories',
                      'Sidebar Nav',
                      'Marketplace',
                      'Responsive'
                    ],
                    painter: _FBMockPainter(),
                    accentColor:
                        d ? const Color(0xFF1877F2) : const Color(0xFF1877F2),
                  ),
                  _DesignCard(
                    d: d,
                    index: '02',
                    title: 'YouTube',
                    subtitle: 'Video Platform UI Clone',
                    description:
                        'Full recreation of YouTube\'s homepage grid, sidebar, '
                        'search bar, video card components with thumbnail, '
                        'channel avatar, view count, and duration badge. '
                        'Studied Google\'s Material You design language and '
                        'responsive video grid system.',
                    tags: const [
                      'Video Grid',
                      'Thumbnail Cards',
                      'Search UX',
                      'Sidebar',
                      'Material You'
                    ],
                    painter: _YTMockPainter(),
                    accentColor:
                        d ? const Color(0xFFFF0000) : const Color(0xFFFF0000),
                  ),
                  _DesignCard(
                    d: d,
                    index: '03',
                    title: 'Netflix',
                    subtitle: 'Streaming Platform UI Clone',
                    description:
                        'Recreation of Netflix\'s dark-mode streaming interface - '
                        'hero banner with cinematic overlay, horizontal content '
                        'carousels, hover-expand cards, category rows, and the '
                        'profile selector screen. Focused on motion design and '
                        'depth through layered gradients.',
                    tags: const [
                      'Hero Banner',
                      'Content Carousel',
                      'Dark Mode',
                      'Hover Cards',
                      'Profile UI'
                    ],
                    painter: _NetflixMockPainter(),
                    accentColor:
                        d ? const Color(0xFFE50914) : const Color(0xFFE50914),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 56),

            // ── Design philosophy note ─────────────────────────────
            ScrollReveal(
              delay: 0.1,
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: pCard(d),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: pCardBorder(d)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PallenIconSquare(icon: Icons.palette_outlined, size: 42),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Design Philosophy',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                color: pCardText(d),
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              )),
                          const SizedBox(height: 8),
                          Text(
                            'Every clone was built from scratch without templates — '
                            'measuring spacing, studying typographic hierarchy, and '
                            'reverse-engineering component structure. The goal is to '
                            'understand how world-class design teams think, then apply '
                            'those principles to original work.',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              color: pBody(d),
                              fontSize: 13,
                              height: 1.7,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: const [
                              PallenGrayPill('Figma'),
                              PallenGrayPill('Flutter'),
                              PallenGrayPill('HTML/CSS'),
                              PallenGrayPill('Component Design'),
                              PallenGrayPill('Responsive Layout'),
                              PallenGrayPill('Color Theory'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      footer,
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════
// DESIGN CARD (Enhanced with 3D tilt)
// ═══════════════════════════════════════════════════════════════
class _DesignCard extends StatefulWidget {
  final bool d;
  final String index, title, subtitle, description;
  final List<String> tags;
  final CustomPainter painter;
  final Color accentColor;

  const _DesignCard({
    required this.d,
    required this.index,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.tags,
    required this.painter,
    required this.accentColor,
  });

  @override
  State<_DesignCard> createState() => _DesignCardState();
}

class _DesignCardState extends State<_DesignCard> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.d;
    final accent = widget.accentColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: TiltCard(
        maxTilt: 0.06,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: _hov ? pCardH(d) : pCard(d),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hov ? accent.withOpacity(0.45) : pCardBorder(d),
              width: _hov ? 1.5 : 1,
            ),
            boxShadow: _hov
                ? [
                    BoxShadow(
                        color: accent.withOpacity(0.15),
                        blurRadius: 30,
                        spreadRadius: 4)
                  ]
                : [],
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Mock UI preview ──────────────────────────────
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D0D0D),
                      border: Border.all(
                          color: _hov
                              ? accent.withOpacity(0.3)
                              : Colors.white.withOpacity(0.08)),
                    ),
                    child: CustomPaint(
                      painter: widget.painter,
                      child: Container(),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Text content ─────────────────────────────────
                Row(children: [
                  Text(widget.index,
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        color: accent.withOpacity(0.7),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      )),
                  const SizedBox(width: 10),
                  Container(
                      width: 20, height: 1, color: accent.withOpacity(0.3)),
                ]),
                const SizedBox(height: 12),
                Text(widget.title,
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      color: pHead(d),
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      height: 1.0,
                    )),
                const SizedBox(height: 4),
                Text(widget.subtitle,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      color: accent.withOpacity(0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: 12),
                Text(widget.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      color: pBody(d),
                      fontSize: 12.5,
                      height: 1.6,
                    )),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: widget.tags
                      .map((t) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                              border:
                                  Border.all(color: accent.withOpacity(0.22)),
                            ),
                            child: Text(t,
                                style: TextStyle(
                                  fontFamily: 'DMSans',
                                  color: accent.withOpacity(0.9),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                )),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Mock UI Painters ───────────────────────────────────────────

class _FBMockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final fill = Paint()..style = PaintingStyle.fill;
    final line = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawRect(Rect.fromLTWH(0, 0, s.width, 32),
        fill..color = Colors.white.withOpacity(0.05));
    canvas.drawCircle(
        const Offset(20, 16), 8, fill..color = Colors.white.withOpacity(0.15));
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(36, 8, 80, 16), Radius.circular(8)),
        fill..color = Colors.white.withOpacity(0.06));

    for (int i = 0; i < 5; i++) {
      final y = 44.0 + i * 22;
      canvas.drawCircle(
          Offset(22, y + 8), 7, fill..color = Colors.white.withOpacity(0.08));
      canvas.drawRect(Rect.fromLTWH(36, y + 3, 60 + (i % 3) * 20.0, 8),
          fill..color = Colors.white.withOpacity(0.06));
    }

    for (int i = 0; i < 4; i++) {
      final x = 130.0 + i * 42;
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(x, 42, 38, 56), Radius.circular(10)),
          fill..color = Colors.white.withOpacity(0.07));
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(x, 42, 38, 56), Radius.circular(10)),
          line);
    }

    for (int p = 0; p < 2; p++) {
      final py = 108.0 + p * 65;
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(130, py, 172, 58), Radius.circular(6)),
          fill..color = Colors.white.withOpacity(0.05));
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(130, py, 172, 58), Radius.circular(6)),
          line);
      canvas.drawCircle(
          Offset(144, py + 12), 8, fill..color = Colors.white.withOpacity(0.1));
      canvas.drawRect(Rect.fromLTWH(156, py + 7, 60, 6),
          fill..color = Colors.white.withOpacity(0.08));
      canvas.drawRect(Rect.fromLTWH(156, py + 17, 40, 4),
          fill..color = Colors.white.withOpacity(0.05));
      canvas.drawRect(Rect.fromLTWH(140, py + 32, 150, 4),
          fill..color = Colors.white.withOpacity(0.06));
      canvas.drawRect(Rect.fromLTWH(140, py + 40, 120, 4),
          fill..color = Colors.white.withOpacity(0.04));
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _YTMockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final fill = Paint()..style = PaintingStyle.fill;
    final line = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawRect(Rect.fromLTWH(0, 0, s.width, 30),
        fill..color = Colors.white.withOpacity(0.06));
    for (int i = 0; i < 3; i++) {
      canvas.drawRect(Rect.fromLTWH(10, 8 + i * 5.0, 14, 2),
          fill..color = Colors.white.withOpacity(0.15));
    }
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(32, 9, 20, 12), Radius.circular(3)),
        fill..color = Colors.white.withOpacity(0.18));
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(60, 8, 100, 14), Radius.circular(7)),
        fill..color = Colors.white.withOpacity(0.05));
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(60, 8, 100, 14), Radius.circular(7)),
        line);

    final cats = ['All', 'Music', 'Gaming', 'News', 'Live'];
    for (int i = 0; i < cats.length; i++) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(10 + i * 52.0, 36, 48, 14), Radius.circular(7)),
          fill
            ..color = i == 0
                ? Colors.white.withOpacity(0.18)
                : Colors.white.withOpacity(0.05));
    }

    for (int row = 0; row < 2; row++) {
      for (int col = 0; col < 3; col++) {
        final x = 10.0 + col * 104;
        final y = 58.0 + row * 88;
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(x, y, 96, 54), Radius.circular(4)),
            fill..color = Colors.white.withOpacity(0.06));
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(x, y, 96, 54), Radius.circular(4)),
            line);
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(x + 68, y + 40, 24, 10), Radius.circular(2)),
            fill..color = Colors.black.withOpacity(0.4));
        canvas.drawCircle(Offset(x + 8, y + 68), 6,
            fill..color = Colors.white.withOpacity(0.1));
        canvas.drawRect(Rect.fromLTWH(x + 18, y + 62, 60, 5),
            fill..color = Colors.white.withOpacity(0.08));
        canvas.drawRect(Rect.fromLTWH(x + 18, y + 72, 44, 4),
            fill..color = Colors.white.withOpacity(0.05));
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _NetflixMockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final fill = Paint()..style = PaintingStyle.fill;
    final line = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final heroRect = Rect.fromLTWH(0, 0, s.width, 110);
    canvas.drawRect(heroRect, fill..color = Colors.white.withOpacity(0.04));
    final heroGrad = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
        colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
      ).createShader(heroRect);
    canvas.drawRect(heroRect, heroGrad);
    canvas.drawRect(Rect.fromLTWH(16, 50, 80, 10),
        fill..color = Colors.white.withOpacity(0.18));
    canvas.drawRect(Rect.fromLTWH(16, 65, 55, 7),
        fill..color = Colors.white.withOpacity(0.10));
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(16, 78, 36, 14), Radius.circular(3)),
        fill..color = Colors.white.withOpacity(0.70));
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(58, 78, 40, 14), Radius.circular(3)),
        fill..color = Colors.white.withOpacity(0.12));

    canvas.drawRect(Rect.fromLTWH(0, 0, s.width, 24),
        fill..color = Colors.black.withOpacity(0.18));
    canvas.drawRect(Rect.fromLTWH(10, 4, 10, 16),
        fill..color = Colors.white.withOpacity(0.7));
    for (int i = 0; i < 5; i++) {
      canvas.drawRect(Rect.fromLTWH(28 + i * 38.0, 9, 28, 5),
          fill..color = Colors.white.withOpacity(0.2));
    }

    for (int row = 0; row < 2; row++) {
      final ry = 118.0 + row * 60;
      canvas.drawRect(Rect.fromLTWH(10, ry, 70, 6),
          fill..color = Colors.white.withOpacity(0.15));
      for (int i = 0; i < 5; i++) {
        final cx = 10.0 + i * 60;
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(cx, ry + 12, 54, 36), Radius.circular(3)),
            fill..color = Colors.white.withOpacity(i == 1 ? 0.12 : 0.06));
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(cx, ry + 12, 54, 36), Radius.circular(3)),
            line);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
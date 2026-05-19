// lib/screens/pallen_profile/pallen_home_page.dart
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'pallen_theme.dart';
import 'pallen_widgets.dart';

// ═══════════════════════════════════════════════════════════════════
// GLOBAL CURSOR NOTIFIER
// ═══════════════════════════════════════════════════════════════════
class _CursorNotifier extends ValueNotifier<Offset> {
  _CursorNotifier() : super(Offset.zero);
}

class PallenHomePage extends StatefulWidget {
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
  State<PallenHomePage> createState() => _PallenHomePageState();
}

class _PallenHomePageState extends State<PallenHomePage> {
  final _cursorNotifier = _CursorNotifier();

  @override
  void dispose() {
    _cursorNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = PTheme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final sh = constraints.maxHeight > 0
            ? constraints.maxHeight
            : MediaQuery.of(context).size.height;
        final sw = constraints.maxWidth > 0
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;

        return MouseRegion(
          onHover: (event) => _cursorNotifier.value = event.position,
          child: Container(
            color: pBg(d),
            child: Stack(children: [
              // ── Abstract geometric background ──────────────────────
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _PallenGeoBgPainter(dark: d),
                  ),
                ),
              ),

              // ── Radial vignette overlay ────────────────────────────
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0.6, -0.3),
                        radius: 1.4,
                        colors: [
                          Colors.transparent,
                          d ? const Color(0xBB000000) : const Color(0x55FFFFFF),
                          d ? const Color(0xFF000000) : const Color(0xAAF5F5F5),
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Noise texture ──────────────────────────────────────
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: PallenNoisePainter()),
                ),
              ),

              // ── Left accent line ───────────────────────────────────
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
                        pBorder(d).withOpacity(0.8),
                        pBorder(d).withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // ── Floating grid dots accent (top-right area) ─────────
              Positioned(
                right: 0,
                top: 0,
                width: sw * 0.45,
                height: sh * 0.6,
                child: IgnorePointer(
                  child: CustomPaint(painter: _PallenDotGridPainter(dark: d)),
                ),
              ),

              // ── Main content ───────────────────────────────────────
              Positioned(
                left: 76,
                right: 76,
                bottom: sh * 0.12,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // ── LEFT: Identity ─────────────────────────────
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
                            child: Text(
                              'Prince Dunhill',
                              style: TextStyle(
                                fontFamily: 'PlayfairDisplay',
                                color: pBody(d),
                                fontSize: 22,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 4,
                                height: 1.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          FadeSlide(
                            delay: 0.6,
                            child: Text(
                              'PALLEN',
                              style: TextStyle(
                                fontFamily: 'PlayfairDisplay',
                                color: pHead(d),
                                fontSize: 82,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -4,
                                height: 0.88,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          FadeSlide(
                            delay: 0.8,
                            child: Text(
                              'Full-Stack Developer & Embedded Systems Engineer\nbuilding technology that bridges hardware and software.',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                color: pBody(d),
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
                                onTap: widget.onGoWork,
                              ),
                              const SizedBox(width: 12),
                              PallenCtaButton(
                                label: 'Contact Me',
                                icon: Icons.mail_outline_rounded,
                                filled: false,
                                onTap: widget.onGoContact,
                              ),
                              const SizedBox(width: 12),
                              PallenCtaButton(
                                label: 'Resume',
                                icon: Icons.download_rounded,
                                filled: false,
                                onTap: () => widget.onOpen(kPallenResume),
                              ),
                            ]),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 48),

                    // ── RIGHT: Anime Cat + Profile ──────────────────
                    Expanded(
                      flex: 32,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ── Anime Black Cat ──────────────────────
                          FadeSlide(
                            delay: 0.3,
                            offset: const Offset(0, 40),
                            child: _AnimeCatWidget(
                              cursorNotifier: _cursorNotifier,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ── Profile photo ───────────────────────────
                          FadeSlide(
                            delay: 0.5,
                            offset: const Offset(0, 50),
                            child: _ProfilePhotoGlow(),
                          ),
                          const SizedBox(height: 18),
                          FadeSlide(
                            delay: 0.7,
                            child: Text(
                              'Prince Dunhill Pallen',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                color: pHead(d),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
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

              // ── Scroll indicator at bottom ─────────────────────────
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
                          color: pMuted(d),
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
                                  pMuted(d).withOpacity(0.8 * value),
                                  pMuted(d).withOpacity(0.0),
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
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// ANIME BLACK CAT WIDGET
// Realistic anime-style black cat with:
//   - Large expressive anime eyes with catchlights & vertical slit pupils
//   - Detailed fur shading with highlight strokes
//   - Structured muzzle area, well-placed nose & mouth
//   - Sharp angular ears with detailed inner ear
//   - Fluffy curled tail with volume
//   - Cursor-tracking pupils (gaze)
//   - Idle breathing & random blink animation
// Size: 200×200
// ═══════════════════════════════════════════════════════════════════
class _AnimeCatWidget extends StatefulWidget {
  final _CursorNotifier cursorNotifier;
  const _AnimeCatWidget({required this.cursorNotifier});

  @override
  State<_AnimeCatWidget> createState() => _AnimeCatWidgetState();
}

class _AnimeCatWidgetState extends State<_AnimeCatWidget>
    with TickerProviderStateMixin {
  late AnimationController _blinkCtrl;
  late AnimationController _breathCtrl;
  late Animation<double> _breathAnim;

  @override
  void initState() {
    super.initState();

    // Blink controller
    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scheduleBlink();

    // Breathing / idle float
    _breathCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _breathAnim = CurvedAnimation(parent: _breathCtrl, curve: Curves.easeInOut);

    widget.cursorNotifier.addListener(_onCursorMove);
  }

  void _onCursorMove() {
    if (mounted) setState(() {});
  }

  void _scheduleBlink() async {
    await Future.delayed(
      Duration(milliseconds: 2000 + math.Random().nextInt(4000)),
    );
    if (!mounted) return;
    await _blinkCtrl.forward();
    await _blinkCtrl.reverse();
    // Occasionally double-blink
    if (math.Random().nextDouble() < 0.25) {
      await Future.delayed(const Duration(milliseconds: 80));
      await _blinkCtrl.forward();
      await _blinkCtrl.reverse();
    }
    _scheduleBlink();
  }

  @override
  void dispose() {
    widget.cursorNotifier.removeListener(_onCursorMove);
    _blinkCtrl.dispose();
    _breathCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_blinkCtrl, _breathAnim]),
      builder: (_, __) {
        final box = context.findRenderObject() as RenderBox?;
        Offset localCursor = const Offset(100, 100);
        if (box != null && box.hasSize) {
          localCursor = box.globalToLocal(widget.cursorNotifier.value);
        }
        final breathY = _breathAnim.value * 4.0; // gentle float
        return Transform.translate(
          offset: Offset(0, -breathY),
          child: CustomPaint(
            size: const Size(200, 200),
            painter: _AnimeCatPainter(
              cursorLocal: localCursor,
              blinkT: _blinkCtrl.value,
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ANIME CAT PAINTER
// All coordinates designed for a 200×200 canvas.
// ─────────────────────────────────────────────────────────────────
class _AnimeCatPainter extends CustomPainter {
  final Offset cursorLocal;
  final double blinkT;

  const _AnimeCatPainter({
    required this.cursorLocal,
    required this.blinkT,
  });

  // Palette
  static const _black = Color(0xFF0A0A0F); // deepest fur
  static const _fur = Color(0xFF141420); // base fur body
  static const _furMid = Color(0xFF1E1E2E); // mid-fur
  static const _furEdge = Color(0xFF2A2A40); // fur edge highlight
  static const _furSheen = Color(0xFF3C3C58); // high-level sheen
  static const _innerEar = Color(0xFF4A1030); // inner ear pink-dark
  static const _innerEarLit = Color(0xFF7A2050); // inner ear lit
  static const _noseColor = Color(0xFFD4708A); // nose
  static const _noseLit = Color(0xFFF0A0B8); // nose highlight
  static const _muzzle = Color(0xFF1A1A28); // muzzle area
  static const _green1 = Color(0xFF5EE896); // iris outer
  static const _green2 = Color(0xFF34C77A); // iris mid
  static const _green3 = Color(0xFF1A7A4A); // iris edge
  static const _greenGlow = Color(0x664ADE80); // eye glow
  static const _pupilDark = Color(0xFF020210); // slit pupil
  static const _whisker = Color(0xFFCCCCCC); // whisker color
  static const _mouthColor = Color(0xFF404058); // mouth line

  /// Gaze offset toward cursor, clamped.
  Offset _gaze(Offset eyeCenter, double maxDist) {
    final delta = cursorLocal - eyeCenter;
    final dist = delta.distance;
    if (dist < 1) return Offset.zero;
    return (delta / dist) * math.min(dist, maxDist);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2; // 100
    final cy = size.height / 2; // 100

    // ══ 1. AMBIENT GLOW behind everything ═══════════════════════
    canvas.drawCircle(
      Offset(cx, cy + 20),
      90,
      Paint()
        ..color = const Color(0x1A4ADE80)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50),
    );

    // ══ 2. TAIL — behind body, voluminous anime style ════════════
    _drawTail(canvas, cx, cy);

    // ══ 3. BODY — rounded, with fur shading ═════════════════════
    _drawBody(canvas, cx, cy);

    // ══ 4. NECK connector ════════════════════════════════════════
    _drawNeck(canvas, cx, cy);

    // ══ 5. HEAD ══════════════════════════════════════════════════
    _drawHead(canvas, cx, cy);

    // ══ 6. EARS — sharp, layered ══════════════════════════════════
    _drawEar(canvas, cx, cy, isLeft: true);
    _drawEar(canvas, cx, cy, isLeft: false);

    // Ear glow tips
    for (final p in [Offset(cx - 28, cy - 62), Offset(cx + 28, cy - 62)]) {
      canvas.drawCircle(
        p,
        8,
        Paint()
          ..color = _greenGlow
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
    }

    // ══ 7. FUR DETAIL STROKES on head ════════════════════════════
    _drawFurStrokes(canvas, cx, cy);

    // ══ 8. MUZZLE area ════════════════════════════════════════════
    _drawMuzzle(canvas, cx, cy);

    // ══ 9. EYES — large anime style ═══════════════════════════════
    _drawEyes(canvas, cx, cy);

    // ══ 10. NOSE ══════════════════════════════════════════════════
    _drawNose(canvas, cx, cy);

    // ══ 11. MOUTH ══════════════════════════════════════════════════
    _drawMouth(canvas, cx, cy);

    // ══ 12. WHISKERS ══════════════════════════════════════════════
    _drawWhiskers(canvas, cx, cy);

    // ══ 13. BROW MARKS (anime eyebrow lines above eyes) ══════════
    _drawBrowMarks(canvas, cx, cy);

    // ══ 14. BLUSH CHEEKS ══════════════════════════════════════════
    canvas.drawCircle(
      Offset(cx - 38, cy + 2),
      12,
      Paint()
        ..color = const Color(0x22FF8FAB)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
    );
    canvas.drawCircle(
      Offset(cx + 38, cy + 2),
      12,
      Paint()
        ..color = const Color(0x22FF8FAB)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
    );

    // ══ 15. PAWS ══════════════════════════════════════════════════
    _drawPaw(canvas, cx - 26, cy + 78);
    _drawPaw(canvas, cx + 26, cy + 78);

    // ══ 16. SPARKLES ══════════════════════════════════════════════
    _drawSparkles(canvas, cx, cy);
  }

  // ── TAIL ───────────────────────────────────────────────────────
  void _drawTail(Canvas canvas, double cx, double cy) {
    // Outer stroke (thicker, lighter = fur edge)
    final tailOuter = Paint()
      ..color = _furEdge
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    // Mid stroke
    final tailMid = Paint()
      ..color = _furMid
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    // Inner core
    final tailInner = Paint()
      ..color = _fur
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final tailPath = Path()
      ..moveTo(cx + 38, cy + 52)
      ..cubicTo(
        cx + 84,
        cy + 80,
        cx + 108,
        cy + 16,
        cx + 72,
        cy - 18,
      );

    canvas.drawPath(tailPath, tailOuter);
    canvas.drawPath(tailPath, tailMid);
    canvas.drawPath(tailPath, tailInner);

    // Fluffy tail tip — concentric ovals
    final tipC = Offset(cx + 72, cy - 18);
    for (int i = 3; i >= 0; i--) {
      final r = 10.0 + i * 2.5;
      final col = [_furEdge, _furMid, _fur, _black][i];
      canvas.drawOval(
        Rect.fromCenter(center: tipC, width: r * 1.4, height: r),
        Paint()..color = col,
      );
    }
    // Tip highlight
    canvas.drawCircle(
      tipC + const Offset(-2, -2),
      3,
      Paint()
        ..color = _furSheen.withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  // ── BODY ───────────────────────────────────────────────────────
  void _drawBody(Canvas canvas, double cx, double cy) {
    final bodyC = Offset(cx, cy + 38);
    final bodyRect = Rect.fromCenter(center: bodyC, width: 92, height: 80);
    final bodyRRect = RRect.fromRectAndCorners(
      bodyRect,
      topLeft: const Radius.circular(38),
      topRight: const Radius.circular(38),
      bottomLeft: const Radius.circular(30),
      bottomRight: const Radius.circular(30),
    );

    // Drop shadow
    canvas.drawRRect(
      bodyRRect.shift(const Offset(0, 6)),
      Paint()
        ..color = const Color(0x99000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    // Body fill — layered
    canvas.drawRRect(bodyRRect, Paint()..color = _fur);
    // Mid-tone gradient (lighter toward top)
    canvas.drawRRect(
      bodyRRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_furMid, _fur, _black],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(bodyRect),
    );
    // Edge / rim light
    canvas.drawRRect(
      bodyRRect,
      Paint()
        ..color = _furEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
    // Sheen highlight on chest
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 18), width: 38, height: 22),
      Paint()
        ..color = _furSheen.withOpacity(0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  // ── NECK ───────────────────────────────────────────────────────
  void _drawNeck(Canvas canvas, double cx, double cy) {
    final neckPath = Path()
      ..moveTo(cx - 22, cy + 4)
      ..quadraticBezierTo(cx - 26, cy + 18, cx - 28, cy + 26)
      ..lineTo(cx + 28, cy + 26)
      ..quadraticBezierTo(cx + 26, cy + 18, cx + 22, cy + 4)
      ..close();
    canvas.drawPath(neckPath, Paint()..color = _fur);
    canvas.drawPath(
      neckPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_furMid, _fur],
        ).createShader(Rect.fromLTWH(cx - 28, cy + 4, 56, 22)),
    );
  }

  // ── HEAD ───────────────────────────────────────────────────────
  void _drawHead(Canvas canvas, double cx, double cy) {
    // Anime cat head: slightly wide at cheeks, narrower jaw
    final headC = Offset(cx, cy - 14);
    // Main head oval
    final headRect = Rect.fromCenter(center: headC, width: 94, height: 86);
    final headRRect = RRect.fromRectAndCorners(
      headRect,
      topLeft: const Radius.circular(44),
      topRight: const Radius.circular(44),
      bottomLeft: const Radius.circular(28),
      bottomRight: const Radius.circular(28),
    );

    // Shadow
    canvas.drawRRect(
      headRRect.shift(const Offset(0, 4)),
      Paint()
        ..color = const Color(0x88000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Head fill
    canvas.drawRRect(headRRect, Paint()..color = _fur);
    // Gradient — slightly lighter on forehead
    canvas.drawRRect(
      headRRect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.6),
          radius: 0.85,
          colors: [_furMid, _fur, _black.withOpacity(0.8)],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(headRect),
    );

    // Rim light (edge highlight)
    canvas.drawRRect(
      headRRect,
      Paint()
        ..color = _furEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // Cheek puffs — slightly wider bumps on both sides for anime look
    for (final dx in [-1.0, 1.0]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx + dx * 46, cy - 10),
          width: 18,
          height: 22,
        ),
        Paint()..color = _fur,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx + dx * 46, cy - 10),
          width: 18,
          height: 22,
        ),
        Paint()
          ..color = _furEdge
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    }

    // Forehead sheen
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 42), width: 32, height: 14),
      Paint()
        ..color = _furSheen.withOpacity(0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  // ── EARS ───────────────────────────────────────────────────────
  void _drawEar(Canvas canvas, double cx, double cy, {required bool isLeft}) {
    final dx = isLeft ? -1.0 : 1.0;
    final tipX = cx + dx * 28;
    final tipY = cy - 64;
    final baseInner = cx + dx * 6;
    final baseOuter = cx + dx * 50;
    final baseY = cy - 32;

    // Outer ear shape
    final outer = Path()
      ..moveTo(baseInner, baseY)
      ..lineTo(tipX, tipY)
      ..lineTo(baseOuter, baseY)
      ..close();

    canvas.drawPath(outer, Paint()..color = _fur);
    canvas.drawPath(
      outer,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [_fur, _furMid],
        ).createShader(Rect.fromLTWH(
            isLeft ? baseOuter : baseInner, tipY, 44, baseY - tipY)),
    );
    canvas.drawPath(
      outer,
      Paint()
        ..color = _furEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round,
    );

    // Inner ear — two-tone pink
    final innerTipX = tipX + dx * 1;
    final innerTipY = tipY + 14;
    final iBaseInner = baseInner + dx * 6;
    final iBaseOuter = baseOuter - dx * 8;
    final iBaseY = baseY - 4;

    final inner = Path()
      ..moveTo(iBaseInner, iBaseY)
      ..lineTo(innerTipX, innerTipY)
      ..lineTo(iBaseOuter, iBaseY)
      ..close();

    canvas.drawPath(inner, Paint()..color = _innerEar);
    canvas.drawPath(
      inner,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [_innerEar, _innerEarLit],
        ).createShader(Rect.fromLTWH(isLeft ? iBaseOuter : iBaseInner,
            innerTipY, 30, iBaseY - innerTipY)),
    );
  }

  // ── FUR STROKES on head ─────────────────────────────────────────
  void _drawFurStrokes(Canvas canvas, double cx, double cy) {
    final p = Paint()
      ..color = _furSheen.withOpacity(0.35)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    // Crown strokes
    final strokes = [
      [Offset(cx - 16, cy - 52), Offset(cx - 10, cy - 64)],
      [Offset(cx, cy - 54), Offset(cx + 2, cy - 68)],
      [Offset(cx + 16, cy - 52), Offset(cx + 12, cy - 64)],
    ];
    for (final s in strokes) {
      canvas.drawLine(s[0], s[1], p);
    }

    // Cheek micro-strokes
    final cheekP = Paint()
      ..color = _furSheen.withOpacity(0.20)
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 4; i++) {
      final oy = (i - 1.5) * 4.0;
      canvas.drawLine(
        Offset(cx - 52 + i * 1.5, cy - 6 + oy),
        Offset(cx - 40 + i * 1.0, cy - 8 + oy),
        cheekP,
      );
      canvas.drawLine(
        Offset(cx + 52 - i * 1.5, cy - 6 + oy),
        Offset(cx + 40 - i * 1.0, cy - 8 + oy),
        cheekP,
      );
    }
  }

  // ── MUZZLE area ─────────────────────────────────────────────────
  void _drawMuzzle(Canvas canvas, double cx, double cy) {
    // Slightly lighter rounded muzzle bump
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 14), width: 44, height: 28),
      Paint()..color = _muzzle,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 14), width: 44, height: 28),
      Paint()
        ..color = _furEdge.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    // Muzzle sheen
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 10), width: 22, height: 10),
      Paint()
        ..color = _furSheen.withOpacity(0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  // ── EYES ────────────────────────────────────────────────────────
  void _drawEyes(Canvas canvas, double cx, double cy) {
    final leftC = Offset(cx - 24, cy - 14);
    final rightC = Offset(cx + 24, cy - 14);
    _drawSingleEye(canvas, leftC);
    _drawSingleEye(canvas, rightC);
  }

  void _drawSingleEye(Canvas canvas, Offset center) {
    // Eye glow halo
    canvas.drawCircle(
      center,
      22,
      Paint()
        ..color = _greenGlow
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );

    // Eye opening height (shrinks when blinking)
    final eyeH = math.max(28.0 * (1.0 - blinkT), 2.0);
    final eyeW = 32.0;

    // ── Eye white area (dark blue-black sclera for cats) ──────
    final eyeRect = Rect.fromCenter(center: center, width: eyeW, height: eyeH);
    canvas.drawOval(eyeRect, Paint()..color = const Color(0xFF050510));
    canvas.drawOval(
      eyeRect,
      Paint()
        ..color = _furEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    if (blinkT >= 1.0) {
      // Fully closed — just a curved line
      final closedP = Paint()
        ..color = _furEdge
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawArc(
        Rect.fromCenter(center: center, width: eyeW, height: 12),
        math.pi,
        math.pi,
        false,
        closedP,
      );
      return;
    }

    // ── IRIS — large anime iris ────────────────────────────────
    final irisH = math.max(eyeH * 0.90, 1.0);
    final irisW = eyeW * 0.90;
    final irisRect =
        Rect.fromCenter(center: center, width: irisW, height: irisH);

    canvas.drawOval(
      irisRect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.3),
          radius: 0.75,
          colors: [_green1, _green2, _green3],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(irisRect),
    );

    // Iris depth ring
    canvas.drawOval(
      irisRect,
      Paint()
        ..color = _green3.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // ── SLIT PUPIL ─────────────────────────────────────────────
    final gaze = _gaze(center, 6.0);
    final pupilC = center + gaze;
    final pupilH = math.max(irisH * 0.7, 1.0);
    final pupilW = 7.0;
    final pupilRect = Rect.fromCenter(
      center: pupilC,
      width: pupilW,
      height: pupilH,
    );

    // Pupil glow shadow
    canvas.drawOval(
      pupilRect.inflate(2.5),
      Paint()
        ..color = const Color(0x40000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    // Pupil fill
    canvas.drawOval(pupilRect, Paint()..color = _pupilDark);

    // ── CATCHLIGHTS — anime style (large + small) ──────────────
    // Main large catchlight (top-left)
    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(-irisW * 0.22, -irisH * 0.25),
        width: 8.0,
        height: 9.0,
      ),
      Paint()..color = Colors.white.withOpacity(0.90),
    );
    // Secondary small catchlight (bottom-right)
    canvas.drawCircle(
      center + Offset(irisW * 0.22, irisH * 0.18),
      3.0,
      Paint()..color = Colors.white.withOpacity(0.55),
    );
    // Tiny tertiary (top-right edge)
    canvas.drawCircle(
      center + Offset(irisW * 0.30, -irisH * 0.20),
      1.5,
      Paint()..color = Colors.white.withOpacity(0.30),
    );

    // ── UPPER EYELID line (thicker = anime look) ───────────────
    final lidPath = Path()
      ..moveTo(center.dx - eyeW / 2 - 1, center.dy)
      ..quadraticBezierTo(
        center.dx,
        center.dy - eyeH / 2 - 3,
        center.dx + eyeW / 2 + 1,
        center.dy,
      );
    canvas.drawPath(
      lidPath,
      Paint()
        ..color = const Color(0xFF202030)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    // ── BLINK EYELID OVERLAY ────────────────────────────────────
    if (blinkT > 0 && blinkT < 1.0) {
      final lidH = eyeH * blinkT;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy - eyeH / 2 + lidH / 2),
          width: eyeW + 4,
          height: lidH,
        ),
        Paint()..color = _fur,
      );
    }
  }

  // ── NOSE ────────────────────────────────────────────────────────
  void _drawNose(Canvas canvas, double cx, double cy) {
    // Anime cat nose: small inverted heart / shield shape
    final nosePath = Path()
      ..moveTo(cx, cy + 10) // bottom tip
      ..lineTo(cx - 7, cy + 3) // left
      ..quadraticBezierTo(cx - 8, cy, cx - 4, cy) // left curve top
      ..lineTo(cx + 4, cy) // top flat
      ..quadraticBezierTo(cx + 8, cy, cx + 7, cy + 3) // right curve top
      ..close();

    canvas.drawPath(nosePath, Paint()..color = _noseColor);
    // Nose highlight
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 2, cy + 2), width: 5, height: 4),
      Paint()..color = _noseLit.withOpacity(0.65),
    );
  }

  // ── MOUTH ────────────────────────────────────────────────────────
  void _drawMouth(Canvas canvas, double cx, double cy) {
    final mP = Paint()
      ..color = _mouthColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    // Philtrum drop
    canvas.drawLine(Offset(cx, cy + 10), Offset(cx, cy + 16), mP);

    // Left smile curve
    canvas.drawPath(
      Path()
        ..moveTo(cx, cy + 16)
        ..quadraticBezierTo(cx - 8, cy + 24, cx - 14, cy + 20),
      mP,
    );
    // Right smile curve
    canvas.drawPath(
      Path()
        ..moveTo(cx, cy + 16)
        ..quadraticBezierTo(cx + 8, cy + 24, cx + 14, cy + 20),
      mP,
    );
  }

  // ── WHISKERS ─────────────────────────────────────────────────────
  void _drawWhiskers(Canvas canvas, double cx, double cy) {
    final wP = Paint()
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round;

    // 3 whiskers per side, slightly tapered in opacity
    final leftWhiskers = [
      [Offset(cx - 10, cy + 5), Offset(cx - 58, cy - 2), 0.55],
      [Offset(cx - 10, cy + 9), Offset(cx - 58, cy + 9), 0.45],
      [Offset(cx - 10, cy + 13), Offset(cx - 56, cy + 18), 0.35],
    ];
    final rightWhiskers = [
      [Offset(cx + 10, cy + 5), Offset(cx + 58, cy - 2), 0.55],
      [Offset(cx + 10, cy + 9), Offset(cx + 58, cy + 9), 0.45],
      [Offset(cx + 10, cy + 13), Offset(cx + 56, cy + 18), 0.35],
    ];

    for (final w in [...leftWhiskers, ...rightWhiskers]) {
      wP.color = _whisker.withOpacity(w[2] as double);
      canvas.drawLine(w[0] as Offset, w[1] as Offset, wP);
    }
  }

  // ── BROW MARKS ───────────────────────────────────────────────────
  void _drawBrowMarks(Canvas canvas, double cx, double cy) {
    final bP = Paint()
      ..color = _furEdge.withOpacity(0.7)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Left brow — subtle angled stroke above left eye
    canvas.drawPath(
      Path()
        ..moveTo(cx - 34, cy - 30)
        ..quadraticBezierTo(cx - 24, cy - 36, cx - 14, cy - 30),
      bP,
    );
    // Right brow
    canvas.drawPath(
      Path()
        ..moveTo(cx + 14, cy - 30)
        ..quadraticBezierTo(cx + 24, cy - 36, cx + 34, cy - 30),
      bP,
    );
  }

  // ── PAWS ─────────────────────────────────────────────────────────
  void _drawPaw(Canvas canvas, double px, double py) {
    // Main paw pad oval
    canvas.drawOval(
      Rect.fromCenter(center: Offset(px, py), width: 28, height: 18),
      Paint()..color = _fur,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(px, py), width: 28, height: 18),
      Paint()
        ..color = _furEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Toe beans — 3 small circles
    for (int i = -1; i <= 1; i++) {
      canvas.drawCircle(
        Offset(px + i * 7.0, py - 5),
        4.0,
        Paint()..color = _furMid,
      );
      canvas.drawCircle(
        Offset(px + i * 7.0, py - 5),
        4.0,
        Paint()
          ..color = _furEdge
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9,
      );
    }

    // Claws — 3 tiny curved lines
    final clawP = Paint()
      ..color = const Color(0xFF666688)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (int i = -1; i <= 1; i++) {
      canvas.drawPath(
        Path()
          ..moveTo(px + i * 7.0, py + 5)
          ..quadraticBezierTo(
            px + i * 7.5 + (i == 0 ? 0 : i * 1.0),
            py + 10,
            px + i * 8.0,
            py + 14,
          ),
        clawP,
      );
    }
  }

  // ── SPARKLES ─────────────────────────────────────────────────────
  void _drawSparkles(Canvas canvas, double cx, double cy) {
    final positions = [
      Offset(cx - 68, cy - 32),
      Offset(cx + 70, cy - 20),
      Offset(cx - 58, cy + 54),
      Offset(cx + 62, cy + 50),
      Offset(cx - 24, cy - 82),
      Offset(cx + 32, cy - 78),
      Offset(cx + 88, cy + 12),
    ];
    final sizes = [2.8, 2.2, 2.0, 2.5, 3.0, 1.8, 1.6];
    for (int i = 0; i < positions.length; i++) {
      _drawSparkle(canvas, positions[i], sizes[i]);
    }
  }

  void _drawSparkle(Canvas canvas, Offset pos, double r) {
    canvas.drawCircle(pos, r, Paint()..color = _green1.withOpacity(0.55));
    final lP = Paint()
      ..color = _green1.withOpacity(0.32)
      ..strokeWidth = r * 0.55
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(pos.dx, pos.dy - r * 2.5),
      Offset(pos.dx, pos.dy + r * 2.5),
      lP,
    );
    canvas.drawLine(
      Offset(pos.dx - r * 2.5, pos.dy),
      Offset(pos.dx + r * 2.5, pos.dy),
      lP,
    );
    final dP = Paint()
      ..color = _green1.withOpacity(0.18)
      ..strokeWidth = r * 0.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(pos.dx - r * 1.6, pos.dy - r * 1.6),
      Offset(pos.dx + r * 1.6, pos.dy + r * 1.6),
      dP,
    );
    canvas.drawLine(
      Offset(pos.dx + r * 1.6, pos.dy - r * 1.6),
      Offset(pos.dx - r * 1.6, pos.dy + r * 1.6),
      dP,
    );
  }

  @override
  bool shouldRepaint(_AnimeCatPainter old) =>
      old.cursorLocal != cursorLocal || old.blinkT != blinkT;
}

// ═══════════════════════════════════════════════════════════════════
// ANIMATED GLOWING BORDER PROFILE PHOTO
// ═══════════════════════════════════════════════════════════════════
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

// ═══════════════════════════════════════════════════════════════════
// ABSTRACT GEOMETRIC BACKGROUND PAINTER
// ═══════════════════════════════════════════════════════════════════
class _PallenGeoBgPainter extends CustomPainter {
  final bool dark;
  const _PallenGeoBgPainter({required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(7);
    final w = size.width;
    final h = size.height;

    final arcBaseColor =
        dark ? const Color(0xFF1E1E1E) : const Color(0xFFD0D0D0);
    final lineColor = dark ? const Color(0xFF161616) : const Color(0xFFDCDCDC);

    // ── Large faint concentric arcs ──────────────────────────────
    final arcPaint = Paint()
      ..color = arcBaseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final focalX = w * 0.78;
    final focalY = h * 0.18;
    for (int i = 0; i < 9; i++) {
      final radius = 80.0 + i * 70.0;
      final opacity = 0.6 - i * 0.06;
      canvas.drawCircle(
        Offset(focalX, focalY),
        radius,
        arcPaint
          ..color = dark
              ? Color.fromRGBO(40, 40, 40, opacity)
              : Color.fromRGBO(180, 180, 180, opacity * 0.7),
      );
    }

    // ── Diagonal ruled lines ─────────────────────────────────────
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.8;
    for (double x = -h; x < w + h; x += 32) {
      canvas.drawLine(Offset(x, h), Offset(x + h, 0), linePaint);
    }

    // ── Scattered small shapes ───────────────────────────────────
    final shapePaint = Paint()..style = PaintingStyle.stroke;
    for (int i = 0; i < 12; i++) {
      final rx = rng.nextDouble() * w;
      final ry = rng.nextDouble() * h;
      final rs = 6.0 + rng.nextDouble() * 18.0;
      final opacity = 0.04 + rng.nextDouble() * 0.06;
      shapePaint.color = dark
          ? Color.fromRGBO(255, 255, 255, opacity)
          : Color.fromRGBO(0, 0, 0, opacity);
      shapePaint.strokeWidth = 0.8;
      final tri = Path()
        ..moveTo(rx, ry - rs)
        ..lineTo(rx + rs * 0.866, ry + rs * 0.5)
        ..lineTo(rx - rs * 0.866, ry + rs * 0.5)
        ..close();
      canvas.drawPath(tri, shapePaint);
    }
    for (int i = 0; i < 8; i++) {
      final rx = rng.nextDouble() * w;
      final ry = rng.nextDouble() * h;
      final rs = 5.0 + rng.nextDouble() * 12.0;
      final opacity = 0.03 + rng.nextDouble() * 0.05;
      shapePaint.color = dark
          ? Color.fromRGBO(255, 255, 255, opacity)
          : Color.fromRGBO(0, 0, 0, opacity);
      shapePaint.strokeWidth = 0.7;
      canvas.save();
      canvas.translate(rx, ry);
      canvas.rotate(math.pi / 4);
      canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: rs, height: rs),
          shapePaint);
      canvas.restore();
    }

    // ── Corner bracket marks ─────────────────────────────────────
    final bracketColor =
        dark ? const Color(0xFF262626) : const Color(0xFFBBBBBB);
    final bracketPaint = Paint()
      ..color = bracketColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.square;
    const bl = 18.0;
    canvas.drawLine(Offset(w - 40, 36), Offset(w - 40 + bl, 36), bracketPaint);
    canvas.drawLine(
        Offset(w - 40 + bl, 36), Offset(w - 40 + bl, 36 + bl), bracketPaint);
    canvas.drawLine(
        Offset(w - 60, 52),
        Offset(w - 60 + 10, 52),
        bracketPaint
          ..color = dark ? const Color(0xFF1E1E1E) : const Color(0xFFCCCCCC));
    canvas.drawLine(
        Offset(w - 60 + 10, 52), Offset(w - 60 + 10, 52 + 10), bracketPaint);

    // ── Dotted cross reticle ─────────────────────────────────────
    final dotColor = dark ? const Color(0xFF2A2A2A) : const Color(0xFFBBBBBB);
    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;
    final reticleX = w * 0.08;
    final reticleY = h * 0.52;
    for (int i = -3; i <= 3; i++) {
      if (i == 0) continue;
      canvas.drawCircle(Offset(reticleX + i * 8.0, reticleY), 1.2, dotPaint);
      canvas.drawCircle(Offset(reticleX, reticleY + i * 8.0), 1.2, dotPaint);
    }
    canvas.drawCircle(
        Offset(reticleX, reticleY),
        2.5,
        dotPaint
          ..color = dark ? const Color(0xFF333333) : const Color(0xFFAAAAAA));

    // ── Large faint hexagon outline ──────────────────────────────
    final hexColor = dark ? const Color(0xFF1A1A1A) : const Color(0xFFCCCCCC);
    final hexPaint = Paint()
      ..color = hexColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final hexCx = w * 0.85;
    final hexCy = h * 0.72;
    const hexR = 90.0;
    final hexPath = Path();
    for (int i = 0; i < 6; i++) {
      final angle = math.pi / 6 + i * math.pi / 3;
      final hx = hexCx + hexR * math.cos(angle);
      final hy = hexCy + hexR * math.sin(angle);
      if (i == 0)
        hexPath.moveTo(hx, hy);
      else
        hexPath.lineTo(hx, hy);
    }
    hexPath.close();
    canvas.drawPath(hexPath, hexPaint);

    final hexPath2 = Path();
    const hexR2 = 58.0;
    for (int i = 0; i < 6; i++) {
      final angle = math.pi / 6 + i * math.pi / 3;
      final hx = hexCx + hexR2 * math.cos(angle);
      final hy = hexCy + hexR2 * math.sin(angle);
      if (i == 0)
        hexPath2.moveTo(hx, hy);
      else
        hexPath2.lineTo(hx, hy);
    }
    hexPath2.close();
    canvas.drawPath(
        hexPath2,
        hexPaint
          ..color = dark ? const Color(0xFF141414) : const Color(0xFFD5D5D5));

    // ── Bottom-left gradient patch ───────────────────────────────
    final patchRect = Rect.fromLTWH(0, h * 0.6, w * 0.45, h * 0.4);
    final patchPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: dark
            ? [const Color(0x22111111), const Color(0x00000000)]
            : [const Color(0x22DDDDDD), const Color(0x00F5F5F5)],
      ).createShader(patchRect);
    canvas.drawRect(patchRect, patchPaint);
  }

  @override
  bool shouldRepaint(_PallenGeoBgPainter old) => old.dark != dark;
}

// ═══════════════════════════════════════════════════════════════════
// DOT GRID PAINTER
// ═══════════════════════════════════════════════════════════════════
class _PallenDotGridPainter extends CustomPainter {
  final bool dark;
  const _PallenDotGridPainter({required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 22.0;
    const dotR = 1.0;
    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        final alphaX = (x / size.width);
        final alphaY = 1.0 - (y / size.height);
        final alpha = (alphaX * alphaY).clamp(0.0, 1.0);
        if (alpha < 0.04) continue;
        canvas.drawCircle(
          Offset(x, y),
          dotR,
          Paint()
            ..color = dark
                ? Color.fromRGBO(50, 50, 50, alpha * 0.9)
                : Color.fromRGBO(160, 160, 160, alpha * 0.7),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_PallenDotGridPainter old) => old.dark != dark;
}

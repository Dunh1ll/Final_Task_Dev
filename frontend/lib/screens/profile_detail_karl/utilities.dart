import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'constants.dart';

// ── Reveal animation ──────────────────────────────────────────────
class KReveal extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const KReveal({
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  State<KReveal> createState() => _KRevealState();
}

class _KRevealState extends State<KReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));

    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _fade,
        child: SlideTransition(position: _slide, child: widget.child),
      );
}

// ── Blinking cursor ───────────────────────────────────────────────
class KCursor extends StatefulWidget {
  @override
  State<KCursor> createState() => _KCursorState();
}

class _KCursorState extends State<KCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _c.repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _c,
        child: Builder(
          builder: (context) => Container(
            width: 3,
            height: 28,
            margin: const EdgeInsets.only(left: 4, bottom: 2),
            color: KTheme.colors(context).textPrimary,
          ),
        ),
      );
}

// ── Noise grain overlay ───────────────────────────────────────────
class KGrain extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _GrainPainter());
}

class _GrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = math.Random(7);
    final p = Paint()..color = Colors.black.withOpacity(0.008);
    for (int i = 0; i < 2400; i++) {
      canvas.drawCircle(
        Offset(
          r.nextDouble() * size.width,
          r.nextDouble() * size.height,
        ),
        0.55,
        p,
      );
    }
  }

  @override
  bool shouldRepaint(_GrainPainter _) => false;
}

// ── Scrolling ticker ──────────────────────────────────────────────
class KTicker extends StatefulWidget {
  final List<String> items;
  const KTicker({required this.items});

  @override
  State<KTicker> createState() => _KTickerState();
}

class _KTickerState extends State<KTicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = KTheme.colors(context).textDim;
    final text = widget.items.map((e) => '$e   /   ').join('');

    return ClipRect(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return CustomPaint(
            painter: _TickerPainter(
              text: text,
              progress: _c.value,
              color: color,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _TickerPainter extends CustomPainter {
  final String text;
  final double progress;
  final Color color;

  const _TickerPainter({
    required this.text,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: KC.fontMono,
          fontWeight: FontWeight.w600,
          fontSize: 9,
          letterSpacing: 2,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    final w = tp.width;
    final dy = (size.height - tp.height) / 2;

    // shift increases from 0 to w over one full cycle, then wraps
    final shift = (progress * w) % w;

    // start one full width to the left so entry is always filled
    double x = -shift;
    while (x < size.width) {
      tp.paint(canvas, Offset(x, dy));
      x += w;
    }
  }

  @override
  bool shouldRepaint(_TickerPainter old) =>
      old.progress != progress || old.color != color;
}

// ── Horizontal rule ───────────────────────────────────────────────
class KRule extends StatelessWidget {
  final Color color;
  final double thickness;
  const KRule({
    this.color = KC.borderStr,
    this.thickness = 2,
  });

  @override
  Widget build(BuildContext context) =>
      Container(height: thickness, color: color);
}

// ── Section label ─────────────────────────────────────────────────
class KLabel extends StatelessWidget {
  final String text;
  const KLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final kc = KTheme.colors(context);
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontFamily: KC.fontMono,
        fontWeight: FontWeight.w600,
        fontSize: 9,
        letterSpacing: 2,
        color: kc.textDim,
      ),
    );
  }
}

// ── Theme Ripple ──────────────────────────────────────────────────
class KThemeRipple extends StatefulWidget {
  final Widget child;
  const KThemeRipple({required this.child, super.key});

  static KThemeRippleState? of(BuildContext context) =>
      context.findAncestorStateOfType<KThemeRippleState>();

  @override
  State<KThemeRipple> createState() => KThemeRippleState();
}

class KThemeRippleState extends State<KThemeRipple>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _radius;
  Offset _origin = Offset.zero;
  bool _rippling = false;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _radius = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void trigger(Offset globalOrigin, VoidCallback onMidpoint) {
    setState(() {
      _origin = globalOrigin;
      _rippling = true;
    });
    _c.forward(from: 0).then((_) {
      setState(() => _rippling = false);
    });
    Future.delayed(const Duration(milliseconds: 300), onMidpoint);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_rippling)
          AnimatedBuilder(
            animation: _radius,
            builder: (context, _) {
              return CustomPaint(
                painter: _RipplePainter(
                  origin: _origin,
                  progress: _radius.value,
                ),
                child: const SizedBox.expand(),
              );
            },
          ),
      ],
    );
  }
}

// ── Ripple Painter ────────────────────────────────────────────────
class _RipplePainter extends CustomPainter {
  final Offset origin;
  final double progress;
  const _RipplePainter({required this.origin, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final maxRadius = (Offset(size.width, size.height) - origin).distance * 1.2;
    final paint = Paint()
      ..color = Colors.black.withOpacity((1 - progress) * 0.85)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(origin, maxRadius * progress, paint);
  }

  @override
  bool shouldRepaint(_RipplePainter old) =>
      old.progress != progress || old.origin != origin;
}
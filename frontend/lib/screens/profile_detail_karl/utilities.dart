import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'constants.dart';

// ── Reveal animation ──────────────────────────────────────────────
class KReveal extends StatefulWidget {
  final Widget child;
  const KReveal({required this.child});
  @override
  State<KReveal> createState() => _KRevealState();
}

class _KRevealState extends State<KReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _f;
  late Animation<Offset> _s;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 420));
    _f = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _s = Tween<Offset>(
            begin: const Offset(0, 0.025), end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _f,
        child: SlideTransition(position: _s, child: widget.child),
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
        child: Container(
          width: 3,
          height: 28,
          margin: const EdgeInsets.only(left: 4, bottom: 2),
          color: KC.white,
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
    final p = Paint()..color = Colors.black.withOpacity(0.008);  // Changed from white to black
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
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final joined =
        widget.items.map((e) => '$e   /   ').join('') * 3;

    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        return ClipRect(
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionalTranslation(
              translation: Offset(-_c.value, 0),
              child: Text(
                joined,
                style: KC.monoLabel,  // <-- THIS IS THE FIX
                maxLines: 1,
                softWrap: false,
              ),
            ),
          ),
        );
      },
    );
  }
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
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: KC.monoLabel,  // Using the new bold style
  );
}
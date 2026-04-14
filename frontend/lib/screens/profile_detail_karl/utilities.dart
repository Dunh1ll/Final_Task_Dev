import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'constants.dart';

class KReveal extends StatefulWidget {
  final Widget child;
  const KReveal({required this.child});
  @override
  State<KReveal> createState() => _KRevealState();
}
class _KRevealState extends State<KReveal> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _f;
  late Animation<Offset> _s;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _f = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _s = Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
    _c.forward();
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _f,
    child: SlideTransition(position: _s, child: widget.child),
  );
}

class KCursor extends StatefulWidget {
  @override
  State<KCursor> createState() => _KCursorState();
}
class _KCursorState extends State<KCursor> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _c.repeat(reverse: true);
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _c,
    child: Container(
      width: 2, height: 15,
      margin: const EdgeInsets.only(left: 1, bottom: 1),
      decoration: BoxDecoration(
        color: KC.amber,
        borderRadius: BorderRadius.circular(1),
      ),
    ),
  );
}

class KGrain extends StatelessWidget {
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _KGP());
}
class _KGP extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = math.Random(42);
    final p = Paint()..color = Colors.white.withOpacity(0.015);
    for (int i = 0; i < 3000; i++) {
      canvas.drawCircle(
        Offset(r.nextDouble() * size.width, r.nextDouble() * size.height),
        0.6, p,
      );
    }
  }
  @override
  bool shouldRepaint(_KGP _) => false;
}

class KGlow extends StatelessWidget {
  final Color color;
  final double size;
  const KGlow({required this.color, required this.size});
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: [BoxShadow(
        color: color,
        blurRadius: size * 0.9,
        spreadRadius: size * 0.2,
      )],
    ),
  );
}
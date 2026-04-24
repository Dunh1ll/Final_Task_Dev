// lib/screens/pallen_profile/pallen_widgets.dart
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'pallen_theme.dart';

// ═══════════════════════════════════════════════════════════════════
// DARK / LIGHT TOGGLE
// ═══════════════════════════════════════════════════════════════════
class PallenDarkToggle extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggle;
  const PallenDarkToggle(
      {super.key, required this.isDark, required this.onToggle});
  @override
  State<PallenDarkToggle> createState() => _PallenDarkToggleState();
}

class _PallenDarkToggleState extends State<PallenDarkToggle> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    final d = widget.isDark;
    return MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: GestureDetector(
        onTap: widget.onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 52,
          height: 28,
          decoration: BoxDecoration(
            color: _h
                ? (d ? kP25 : const Color(0xFFBBBBBB))
                : (d ? kP18 : const Color(0xFFCCCCCC)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _h ? kP40 : kP25, width: 1),
          ),
          child: Stack(children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              left: d ? 3 : 25,
              top: 3,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: d ? kP55 : const Color(0xFFFFFFFF),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.2), blurRadius: 4)
                  ],
                ),
                child: Icon(
                  d ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                  size: 12,
                  color: d ? kP93 : const Color(0xFFF59E0B),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// NAV GHOST BUTTON
// ═══════════════════════════════════════════════════════════════════
class PallenNavGhostBtn extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const PallenNavGhostBtn(
      {super.key, required this.child, required this.onTap});
  @override
  State<PallenNavGhostBtn> createState() => _PallenNavGhostBtnState();
}

class _PallenNavGhostBtnState extends State<PallenNavGhostBtn> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    final d = PTheme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: _h ? pCard(d) : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _h ? pBorderH(d) : Colors.transparent),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// NAV TAB PILL
// ═══════════════════════════════════════════════════════════════════
class PallenNavTab extends StatefulWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const PallenNavTab(
      {super.key,
      required this.label,
      required this.active,
      required this.onTap});
  @override
  State<PallenNavTab> createState() => _PallenNavTabState();
}

class _PallenNavTabState extends State<PallenNavTab> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    final d = PTheme.of(context);
    final lit = widget.active || _h;
    return MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.only(left: 4),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
          decoration: BoxDecoration(
            color: lit ? pCard(d) : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            border:
                Border.all(color: lit ? pCardBorderH(d) : Colors.transparent),
          ),
          child: Text(widget.label,
              style: TextStyle(
                fontFamily: 'DMSans',
                color: lit ? pCardText(d) : pBody(d),
                fontSize: 12,
                fontWeight: lit ? FontWeight.w700 : FontWeight.w400,
              )),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// HOVER CARD
// ═══════════════════════════════════════════════════════════════════
class PallenHoverCard extends StatefulWidget {
  final Widget child;
  final bool slideRight;
  final EdgeInsets padding;
  const PallenHoverCard({
    super.key,
    required this.child,
    required this.slideRight,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
  });
  @override
  State<PallenHoverCard> createState() => _PallenHoverCardState();
}

class _PallenHoverCardState extends State<PallenHoverCard> {
  bool _hov = false;
  Offset get _offset => _hov
      ? (widget.slideRight ? const Offset(8, 0) : const Offset(0, -5))
      : Offset.zero;

  @override
  Widget build(BuildContext context) {
    final d = PTheme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(_offset.dx, _offset.dy, 0),
        decoration: BoxDecoration(
          color: _hov ? pCardH(d) : pCard(d),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _hov ? pCardBorderH(d) : pCardBorder(d),
            width: _hov ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _hov ? pGlowLit(d) : pGlowDim(d),
              blurRadius: _hov ? 28 : 0,
            ),
          ],
        ),
        child: Padding(
          padding: widget.padding,
          child: widget.child,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// GLASS CHIP (hero section pill)
// ═══════════════════════════════════════════════════════════════════
class PallenGlassChip extends StatelessWidget {
  final String text;
  const PallenGlassChip(this.text, {super.key});
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0x0CFFFFFF),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: const Color(0x1EFFFFFF)),
            ),
            child: Text(text,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  color: kP70,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                )),
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
// EYEBROW LABEL
// ═══════════════════════════════════════════════════════════════════
class PallenEyebrowLabel extends StatelessWidget {
  final String label;
  const PallenEyebrowLabel(this.label, {super.key});
  @override
  Widget build(BuildContext context) {
    final d = PTheme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: TextStyle(
            fontFamily: 'DMSans',
            color: pEyebrow(d),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 3.5,
          )),
      const SizedBox(height: 8),
      Container(width: 40, height: 1, color: pLine(d)),
      const SizedBox(height: 20),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════════
// SUB-SECTION LABEL
// ═══════════════════════════════════════════════════════════════════
class PallenSubLabel extends StatelessWidget {
  final String text;
  const PallenSubLabel(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    final d = PTheme.of(context);
    return Text(text,
        style: TextStyle(
          fontFamily: 'PlayfairDisplay',
          color: pHead(d),
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ));
  }
}

// ═══════════════════════════════════════════════════════════════════
// ICON SQUARE
// ═══════════════════════════════════════════════════════════════════
class PallenIconSquare extends StatelessWidget {
  final IconData icon;
  final double size;
  const PallenIconSquare({super.key, required this.icon, this.size = 38});
  @override
  Widget build(BuildContext context) {
    final d = PTheme.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: pBg3(d),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: pBorder(d)),
      ),
      child: Icon(icon, color: pIcon(d), size: size * 0.46),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// RCO CARD (Role / Challenge / Outcome)
// ═══════════════════════════════════════════════════════════════════
class PallenRcoCard extends StatelessWidget {
  final IconData icon;
  final String title, body;
  const PallenRcoCard(
      {super.key, required this.icon, required this.title, required this.body});
  @override
  Widget build(BuildContext context) {
    final d = PTheme.of(context);
    return PallenHoverCard(
      slideRight: false,
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        PallenIconSquare(icon: icon),
        const SizedBox(height: 12),
        Text(title,
            style: TextStyle(
              fontFamily: 'DMSans',
              color: pCardText(d),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            )),
        const SizedBox(height: 8),
        Text(body,
            style: TextStyle(
              fontFamily: 'DMSans',
              color: pCardSub(d),
              fontSize: 11.5,
              height: 1.65,
            )),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// META BADGE
// ═══════════════════════════════════════════════════════════════════
class PallenMetaBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  const PallenMetaBadge({super.key, required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    final d = PTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: pBg3(d),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: pBorder(d)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: pBody(d)),
        const SizedBox(width: 6),
        Text(text,
            style: TextStyle(
              fontFamily: 'DMSans',
              color: pBody(d),
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
            )),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// CTA BUTTON
// ═══════════════════════════════════════════════════════════════════
class PallenCtaButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;
  const PallenCtaButton(
      {super.key,
      required this.label,
      required this.icon,
      required this.filled,
      required this.onTap});
  @override
  State<PallenCtaButton> createState() => _PallenCtaButtonState();
}

class _PallenCtaButtonState extends State<PallenCtaButton> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
        onEnter: (_) => setState(() => _h = true),
        onExit: (_) => setState(() => _h = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            transform: Matrix4.translationValues(0, _h ? -2 : 0, 0),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: widget.filled
                  ? (_h ? kP85 : kP98)
                  : (_h ? const Color(0x1AFFFFFF) : Colors.transparent),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.filled
                    ? Colors.transparent
                    : (_h ? const Color(0x3DFFFFFF) : const Color(0x1EFFFFFF)),
              ),
              boxShadow: widget.filled && _h
                  ? [
                      BoxShadow(
                          color: Colors.white.withOpacity(0.25), blurRadius: 20)
                    ]
                  : [],
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(widget.icon, size: 14, color: widget.filled ? kP00 : kP70),
              const SizedBox(width: 8),
              Text(widget.label,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    color: widget.filled ? kP00 : kP70,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  )),
            ]),
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
// QUICK STAT CHIP
// ═══════════════════════════════════════════════════════════════════
class PallenQuickStat extends StatelessWidget {
  final String value, label;
  const PallenQuickStat(this.value, this.label, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0x0CFFFFFF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0x1EFFFFFF)),
        ),
        child: Column(children: [
          Text(value,
              style: const TextStyle(
                fontFamily: 'PlayfairDisplay',
                color: kP98,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.0,
              )),
          Text(label,
              style: const TextStyle(
                fontFamily: 'DMSans',
                color: kP40,
                fontSize: 9,
              )),
        ]),
      );
}

// ═══════════════════════════════════════════════════════════════════
// GRAY PILL
// ═══════════════════════════════════════════════════════════════════
class PallenGrayPill extends StatelessWidget {
  final String label;
  const PallenGrayPill(this.label, {super.key});
  @override
  Widget build(BuildContext context) {
    final d = PTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: pBg3(d),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: pBorder(d)),
      ),
      child: Text(label,
          style: TextStyle(
            fontFamily: 'DMSans',
            color: pBody(d),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          )),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// ANIMATED AVAILABILITY DOT ROW
// ═══════════════════════════════════════════════════════════════════
class PallenAvailRow extends StatefulWidget {
  const PallenAvailRow({super.key});
  @override
  State<PallenAvailRow> createState() => _PallenAvailRowState();
}

class _PallenAvailRowState extends State<PallenAvailRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1300))
      ..repeat(reverse: true);
    _a = CurvedAnimation(parent: _c, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _a,
        builder: (_, __) =>
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: kPGreen.withOpacity(0.5 + 0.5 * _a.value),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: kPGreen.withOpacity(0.4 * _a.value),
                  blurRadius: 8,
                  spreadRadius: 1,
                )
              ],
            ),
          ),
          const SizedBox(width: 7),
          const Text('Available for opportunities',
              style: TextStyle(
                fontFamily: 'DMSans',
                color: kPGreen,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              )),
        ]),
      );
}

// ═══════════════════════════════════════════════════════════════════
// LANGUAGE SYSTEM
// ═══════════════════════════════════════════════════════════════════
enum PallenLangKind {
  html,
  css,
  js,
  flutter,
  go,
  java,
  python,
  cpp,
  c,
  postgres,
  mysql,
  asm,
  hdl,
}

class PallenLangItem {
  final String name;
  final PallenLangKind kind;
  const PallenLangItem(this.name, this.kind);
}

Color pallenLangBrand(PallenLangKind k) {
  switch (k) {
    case PallenLangKind.html:
      return const Color(0xFFE34F26);
    case PallenLangKind.css:
      return const Color(0xFF1572B6);
    case PallenLangKind.js:
      return const Color(0xFFF7DF1E);
    case PallenLangKind.flutter:
      return const Color(0xFF54C5F8);
    case PallenLangKind.go:
      return const Color(0xFF00ACD7);
    case PallenLangKind.java:
      return const Color(0xFFED8B00);
    case PallenLangKind.python:
      return const Color(0xFF3776AB);
    case PallenLangKind.cpp:
      return const Color(0xFF00599C);
    case PallenLangKind.c:
      return const Color(0xFFA8B9CC);
    case PallenLangKind.postgres:
      return const Color(0xFF336791);
    case PallenLangKind.mysql:
      return const Color(0xFF4479A1);
    case PallenLangKind.asm:
      return const Color(0xFF9D4EDD);
    case PallenLangKind.hdl:
      return const Color(0xFF7C3AED);
  }
}

class PallenLangBadge extends StatefulWidget {
  final PallenLangItem item;
  const PallenLangBadge({super.key, required this.item});
  @override
  State<PallenLangBadge> createState() => _PallenLangBadgeState();
}

class _PallenLangBadgeState extends State<PallenLangBadge> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) {
    final d = PTheme.of(context);
    final brand = pallenLangBrand(widget.item.kind);
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.only(left: 6, right: 12, top: 6, bottom: 6),
        decoration: BoxDecoration(
          color: _hov ? pCardH(d) : pCard(d),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _hov ? brand.withOpacity(0.55) : pCardBorder(d),
            width: _hov ? 1.5 : 1,
          ),
          boxShadow: _hov
              ? [BoxShadow(color: brand.withOpacity(0.20), blurRadius: 14)]
              : [],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          PallenLangLogo(widget.item.kind),
          const SizedBox(width: 9),
          Text(widget.item.name,
              style: TextStyle(
                fontFamily: 'DMSans',
                color: pCardText(d),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              )),
        ]),
      ),
    );
  }
}

class PallenLangLogo extends StatelessWidget {
  final PallenLangKind kind;
  const PallenLangLogo(this.kind, {super.key});
  @override
  Widget build(BuildContext context) {
    final color = pallenLangBrand(kind);
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.35), width: 1),
      ),
      child: CustomPaint(painter: PallenLangLogoPainter(kind, color)),
    );
  }
}

class PallenLangLogoPainter extends CustomPainter {
  final PallenLangKind kind;
  final Color brand;
  const PallenLangLogoPainter(this.kind, this.brand);

  Paint get _stroke => Paint()
    ..color = brand
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  Paint get _fill => Paint()
    ..color = brand
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height / 2;
    switch (kind) {
      case PallenLangKind.html:
        final p = Path()
          ..moveTo(5, 5)
          ..lineTo(4, 23)
          ..lineTo(14, 26)
          ..lineTo(24, 23)
          ..lineTo(23, 5)
          ..close();
        canvas.drawPath(p, _stroke..strokeWidth = 1.3);
        _drawText(canvas, '5', Offset(cx - 4, cy - 6), 10);
        break;
      case PallenLangKind.css:
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTWH(4, 4, 20, 20), const Radius.circular(3)),
            _stroke..strokeWidth = 1.3);
        _drawText(canvas, '3', Offset(cx - 4, cy - 6), 11);
        break;
      case PallenLangKind.js:
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTWH(3, 3, 22, 22), const Radius.circular(3)),
            _fill..color = brand.withOpacity(0.25));
        _drawText(canvas, 'JS', Offset(cx - 8, cy - 7), 10);
        break;
      case PallenLangKind.flutter:
        final p = Path()
          ..moveTo(8, 4)
          ..lineTo(22, 4)
          ..lineTo(14, 13)
          ..lineTo(22, 13)
          ..lineTo(11, 24)
          ..lineTo(5, 24)
          ..lineTo(13, 14)
          ..lineTo(5, 14)
          ..close();
        canvas.drawPath(p, _stroke..strokeWidth = 1.2);
        break;
      case PallenLangKind.go:
        canvas.drawCircle(Offset(cx, cy), 9.5, _stroke..strokeWidth = 1.5);
        _drawText(canvas, 'Go', Offset(cx - 7, cy - 6), 9.5);
        break;
      case PallenLangKind.java:
        final cup = Path()
          ..moveTo(9, 7)
          ..lineTo(11, 21)
          ..lineTo(17, 21)
          ..lineTo(19, 7)
          ..close();
        canvas.drawPath(cup, _stroke..strokeWidth = 1.3);
        final handle = Path()
          ..moveTo(19, 11)
          ..quadraticBezierTo(24, 11, 24, 16)
          ..quadraticBezierTo(24, 21, 19, 21);
        canvas.drawPath(handle, _stroke..strokeWidth = 1.3);
        break;
      case PallenLangKind.python:
        final p = Path()
          ..moveTo(10, 3)
          ..quadraticBezierTo(4, 3, 4, 9)
          ..lineTo(4, 14)
          ..lineTo(14, 14)
          ..lineTo(14, 16)
          ..lineTo(6, 16)
          ..quadraticBezierTo(4, 16, 4, 18)
          ..quadraticBezierTo(4, 25, 10, 25)
          ..lineTo(14, 25)
          ..quadraticBezierTo(24, 25, 24, 19)
          ..lineTo(24, 14)
          ..lineTo(14, 14)
          ..lineTo(14, 12)
          ..lineTo(22, 12)
          ..quadraticBezierTo(24, 12, 24, 10)
          ..quadraticBezierTo(24, 3, 18, 3)
          ..close();
        canvas.drawPath(
            p,
            _stroke
              ..strokeWidth = 1.1
              ..color = brand);
        canvas.drawCircle(const Offset(9, 8.5), 1.2, _fill);
        canvas.drawCircle(const Offset(19, 19.5), 1.2, _fill);
        break;
      case PallenLangKind.cpp:
        _drawText(canvas, 'C', Offset(cx - 11, cy - 7), 12);
        canvas.drawLine(Offset(cx + 2, cy - 5), Offset(cx + 2, cy + 5),
            _stroke..strokeWidth = 1.5);
        canvas.drawLine(
            Offset(cx - 1, cy), Offset(cx + 5, cy), _stroke..strokeWidth = 1.5);
        canvas.drawLine(Offset(cx + 8, cy - 5), Offset(cx + 8, cy + 5),
            _stroke..strokeWidth = 1.5);
        canvas.drawLine(Offset(cx + 5, cy), Offset(cx + 11, cy),
            _stroke..strokeWidth = 1.5);
        break;
      case PallenLangKind.c:
        canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: 9), 0.6,
            math.pi * 1.6, false, _stroke..strokeWidth = 2.0);
        break;
      case PallenLangKind.postgres:
        canvas.drawOval(
            const Rect.fromLTWH(5, 4, 18, 16), _stroke..strokeWidth = 1.5);
        final trunk = Path()
          ..moveTo(11, 20)
          ..quadraticBezierTo(9, 26, 13, 27);
        canvas.drawPath(trunk, _stroke..strokeWidth = 1.5);
        canvas.drawCircle(const Offset(11, 10), 1.5, _fill);
        canvas.drawCircle(const Offset(21, 6), 3, _stroke..strokeWidth = 1.2);
        break;
      case PallenLangKind.mysql:
        canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy - 1), radius: 9),
            math.pi * 1.1, math.pi * 1.4, false, _stroke..strokeWidth = 1.8);
        final fin = Path()
          ..moveTo(cx + 6, cy - 5)
          ..lineTo(cx + 10, cy - 10)
          ..lineTo(cx + 9, cy - 4);
        canvas.drawPath(fin, _stroke..strokeWidth = 1.2);
        _drawText(canvas, 'My', Offset(cx - 7, cy + 2), 8.5);
        break;
      case PallenLangKind.asm:
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTWH(7, 7, 14, 14), const Radius.circular(2)),
            _stroke..strokeWidth = 1.4);
        for (double y = 10; y <= 18; y += 4) {
          canvas.drawLine(
              Offset(4, y), Offset(7, y), _stroke..strokeWidth = 1.1);
          canvas.drawLine(
              Offset(21, y), Offset(24, y), _stroke..strokeWidth = 1.1);
        }
        break;
      case PallenLangKind.hdl:
        final wave = Path()
          ..moveTo(3, cy)
          ..lineTo(7, cy)
          ..lineTo(7, cy - 5)
          ..lineTo(13, cy - 5)
          ..lineTo(13, cy)
          ..lineTo(17, cy)
          ..lineTo(17, cy + 5)
          ..lineTo(22, cy + 5)
          ..lineTo(22, cy)
          ..lineTo(25, cy);
        canvas.drawPath(wave, _stroke..strokeWidth = 1.5);
        break;
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, double size) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
            color: brand,
            fontSize: size,
            fontWeight: FontWeight.w900,
            fontFamily: 'DMSans'),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(PallenLangLogoPainter o) =>
      o.kind != kind || o.brand != brand;
}

class PallenSkillCategoryBlock extends StatelessWidget {
  final String label;
  final List<PallenLangItem> items;
  const PallenSkillCategoryBlock(
      {super.key, required this.label, required this.items});
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
      const SizedBox(height: 10),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items.map((i) => PallenLangBadge(item: i)).toList(),
      ),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════════
// CONTACT CARD
// ═══════════════════════════════════════════════════════════════════
enum PallenContactKind { facebook, github, gmail, linkedin, instagram, phone }

class PallenContactData {
  final PallenContactKind kind;
  final String platform, handle, detail, url;
  const PallenContactData({
    required this.kind,
    required this.platform,
    required this.handle,
    required this.detail,
    required this.url,
  });
}

class PallenContactCard extends StatefulWidget {
  final PallenContactData data;
  final VoidCallback onTap;
  const PallenContactCard({super.key, required this.data, required this.onTap});
  @override
  State<PallenContactCard> createState() => _PallenContactCardState();
}

class _PallenContactCardState extends State<PallenContactCard> {
  bool _hov = false;

  IconData get _icon {
    switch (widget.data.kind) {
      case PallenContactKind.facebook:
        return Icons.people_alt_rounded;
      case PallenContactKind.github:
        return Icons.terminal_rounded;
      case PallenContactKind.gmail:
        return Icons.alternate_email_rounded;
      case PallenContactKind.linkedin:
        return Icons.work_outline_rounded;
      case PallenContactKind.instagram:
        return Icons.camera_alt_outlined;
      case PallenContactKind.phone:
        return Icons.phone_iphone_rounded;
    }
  }

  Color get _brandColor {
    switch (widget.data.kind) {
      case PallenContactKind.facebook:
        return const Color(0xFF1877F2);
      case PallenContactKind.github:
        return const Color(0xFF6E40C9);
      case PallenContactKind.gmail:
        return const Color(0xFFEA4335);
      case PallenContactKind.linkedin:
        return const Color(0xFF0077B5);
      case PallenContactKind.instagram:
        return const Color(0xFFE4405F);
      case PallenContactKind.phone:
        return const Color(0xFF4ADE80);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = PTheme.of(context);
    final brand = _brandColor;
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(_hov ? 6 : 0, 0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _hov ? pCardH(d) : pCard(d),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hov ? brand.withOpacity(0.55) : pCardBorder(d),
              width: _hov ? 1.5 : 1,
            ),
            boxShadow: _hov
                ? [BoxShadow(color: brand.withOpacity(0.18), blurRadius: 16)]
                : [],
          ),
          child: Row(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _hov ? brand.withOpacity(0.18) : brand.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color:
                      _hov ? brand.withOpacity(0.5) : brand.withOpacity(0.25),
                ),
              ),
              child: Icon(_icon, color: brand, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.data.platform,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      color: pEyebrow(d),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    )),
                const SizedBox(height: 2),
                Text(widget.data.handle,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      color: pCardText(d),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    )),
              ],
            )),
            Icon(Icons.open_in_new_rounded,
                size: 12, color: _hov ? brand : pMuted(d)),
          ]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// CUSTOM PAINTERS
// ═══════════════════════════════════════════════════════════════════
class PallenNoisePainter extends CustomPainter {
  static final _rng = math.Random(42);
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 3200; i++) {
      p.color = Colors.white.withOpacity(_rng.nextDouble() * 0.025);
      canvas.drawCircle(
          Offset(_rng.nextDouble() * s.width, _rng.nextDouble() * s.height),
          0.6,
          p);
    }
  }

  @override
  bool shouldRepaint(PallenNoisePainter _) => false;
}

class PallenThreeDBoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final pf = Paint()..style = PaintingStyle.fill;
    final ps = Paint()
      ..color = const Color(0xFF383838)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final cx = s.width / 2;
    final cy = s.height / 2;
    const w = 30.0;
    const h = 18.0;
    const d = 12.0;
    final top = Path()
      ..moveTo(cx, cy - h)
      ..lineTo(cx + w, cy - h / 2)
      ..lineTo(cx, cy)
      ..lineTo(cx - w, cy - h / 2)
      ..close();
    canvas.drawPath(top, pf..color = const Color(0xFF303030));
    canvas.drawPath(top, ps);
    final right = Path()
      ..moveTo(cx + w, cy - h / 2)
      ..lineTo(cx + w, cy - h / 2 + d)
      ..lineTo(cx, cy + d)
      ..lineTo(cx, cy)
      ..close();
    canvas.drawPath(right, pf..color = const Color(0xFF1E1E1E));
    canvas.drawPath(right, ps);
    final left = Path()
      ..moveTo(cx, cy)
      ..lineTo(cx, cy + d)
      ..lineTo(cx - w, cy - h / 2 + d)
      ..lineTo(cx - w, cy - h / 2)
      ..close();
    canvas.drawPath(left, pf..color = const Color(0xFF252525));
    canvas.drawPath(left, ps);
  }

  @override
  bool shouldRepaint(PallenThreeDBoxPainter _) => false;
}

class PallenPcbPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = const Color(0xFF2A2A2A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    for (double y = 10; y <= s.height - 10; y += 12) {
      canvas.drawLine(Offset(8, y), Offset(s.width - 8, y), p);
    }
    for (double x = 20; x <= s.width - 20; x += 20) {
      canvas.drawLine(Offset(x, 10), Offset(x, s.height - 10), p);
    }
    final vp = Paint()
      ..color = const Color(0xFF323232)
      ..style = PaintingStyle.fill;
    for (double x = 20; x <= s.width - 20; x += 20) {
      for (double y = 10; y <= s.height - 10; y += 12) {
        canvas.drawCircle(Offset(x, y), 2.5, vp);
      }
    }
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(s.width / 2, s.height / 2),
                width: 28,
                height: 20),
            const Radius.circular(2)),
        Paint()
          ..color = const Color(0xFF303030)
          ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(PallenPcbPainter _) => false;
}

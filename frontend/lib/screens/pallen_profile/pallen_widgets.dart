// lib/screens/pallen_profile/pallen_widgets.dart
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pallen_theme.dart';

// ═══════════════════════════════════════════════════════════════════
// ANIMATION HELPERS
// ═══════════════════════════════════════════════════════════════════

class FadeSlide extends StatelessWidget {
  final Widget child;
  final double delay;
  final Offset offset;
  final Duration duration;
  final bool isVisible;

  const FadeSlide({
    super.key,
    required this.child,
    this.delay = 0,
    this.offset = const Offset(0, 30),
    this.duration = const Duration(milliseconds: 700),
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: isVisible ? 1 : 0),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(offset.dx * (1 - value), offset.dy * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class StaggeredList extends StatelessWidget {
  final List<Widget> children;
  final double delayStep;
  final Duration duration;
  final bool isVisible;

  const StaggeredList({
    super.key,
    required this.children,
    this.delayStep = 0.08,
    this.duration = const Duration(milliseconds: 600),
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(children.length, (i) {
        return FadeSlide(
          delay: i * delayStep,
          duration: duration,
          isVisible: isVisible,
          child: children[i],
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// SCROLL REVEAL WRAPPER
// ═══════════════════════════════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════
// SCROLL REVEAL WRAPPER — Uses ticker for continuous visibility checks
// ═══════════════════════════════════════════════════════════════════
class ScrollReveal extends StatefulWidget {
  final Widget child;
  final double delay;
  final Offset offset;
  final Duration duration;

  const ScrollReveal({
    super.key,
    required this.child,
    this.delay = 0,
    this.offset = const Offset(0, 40),
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal>
    with SingleTickerProviderStateMixin {
  bool _visible = false;
  late AnimationController _ticker;

  @override
  void initState() {
    super.initState();
    // Create a ticker that runs every frame to check visibility
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _ticker.addListener(_checkVisibility);
    _ticker.repeat();

    // Initial check after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _checkVisibility() {
    if (!mounted || _visible) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final pos = box.localToGlobal(Offset.zero);
    final screenH = MediaQuery.of(context).size.height;
    // Trigger when widget enters viewport (top edge within 85% of screen height)
    if (pos.dy < screenH * 0.85) {
      _ticker.stop();
      Future.delayed(Duration(milliseconds: (widget.delay * 1000).toInt()), () {
        if (mounted) setState(() => _visible = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeSlide(
      delay: widget.delay,
      offset: widget.offset,
      duration: widget.duration,
      isVisible: _visible,
      child: widget.child,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// 3D TILT CARD (Desktop hover / Mobile tap)
// ═══════════════════════════════════════════════════════════════════
class TiltCard extends StatefulWidget {
  final Widget child;
  final double maxTilt;
  final Duration duration;
  final BoxDecoration? decoration;

  const TiltCard({
    super.key,
    required this.child,
    this.maxTilt = 0.15,
    this.duration = const Duration(milliseconds: 200),
    this.decoration,
  });

  @override
  State<TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard> {
  double _x = 0, _y = 0;
  bool _hover = false;

  void _onHover(PointerEvent e, Size size) {
    final px = (e.localPosition.dx / size.width - 0.5) * 2;
    final py = (e.localPosition.dy / size.height - 0.5) * 2;
    setState(() {
      _x = py * widget.maxTilt;
      _y = -px * widget.maxTilt;
      _hover = true;
    });
  }

  void _onExit() => setState(() {
        _x = 0;
        _y = 0;
        _hover = false;
      });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (e) {
        final box = context.findRenderObject() as RenderBox?;
        if (box != null) _onHover(e, box.size);
      },
      onExit: (_) => _onExit(),
      child: GestureDetector(
        onTapDown: (d) {
          final box = context.findRenderObject() as RenderBox?;
          if (box != null) _onHover(d as PointerEvent, box.size);
        },
        onTapUp: (_) => _onExit(),
        onTapCancel: _onExit,
        child: AnimatedContainer(
          duration: widget.duration,
          curve: Curves.easeOut,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(_x)
            ..rotateY(_y),
          decoration: widget.decoration,
          child: widget.child,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// MAGNETIC BUTTON
// ═══════════════════════════════════════════════════════════════════
class MagneticButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double strength;

  const MagneticButton({
    super.key,
    required this.child,
    required this.onTap,
    this.strength = 0.3,
  });

  @override
  State<MagneticButton> createState() => _MagneticButtonState();
}

class _MagneticButtonState extends State<MagneticButton> {
  Offset _offset = Offset.zero;

  void _onHover(PointerEvent e, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final dx = (e.localPosition.dx - cx) * widget.strength;
    final dy = (e.localPosition.dy - cy) * widget.strength;
    setState(() => _offset = Offset(dx, dy));
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (e) {
        final box = context.findRenderObject() as RenderBox?;
        if (box != null) _onHover(e, box.size);
      },
      onExit: (_) => setState(() => _offset = Offset.zero),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(_offset.dx, _offset.dy, 0),
          child: widget.child,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// ANIMATED PROGRESS BAR (for skills)
// ═══════════════════════════════════════════════════════════════════
class AnimatedProgressBar extends StatefulWidget {
  final double progress;
  final Color color;
  final double height;
  final Duration duration;

  const AnimatedProgressBar({
    super.key,
    required this.progress,
    this.color = kPGreen,
    this.height = 4,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _ctrl.forward();
    });
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
      builder: (_, __) => Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(widget.height / 2),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: widget.progress * _ctrl.value,
          child: Container(
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(widget.height / 2),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// DARK / LIGHT TOGGLE (Enhanced)
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
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          width: 56,
          height: 30,
          decoration: BoxDecoration(
            color: _h
                ? (d ? kP25 : const Color(0xFFBBBBBB))
                : (d ? kP18 : const Color(0xFFCCCCCC)),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: _h ? kP40 : kP25, width: 1),
            boxShadow: _h
                ? [
                    BoxShadow(
                      color: d
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
          child: Stack(children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutBack,
              left: d ? 4 : 30,
              top: 3,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: d ? kP55 : const Color(0xFFFFFFFF),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 6,
                        spreadRadius: 1)
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    d ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                    size: 12,
                    color: d ? kP93 : const Color(0xFFF59E0B),
                    key: ValueKey(d),
                  ),
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
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _h ? pCard(d) : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _h ? pBorderH(d) : Colors.transparent),
            boxShadow:
                _h ? [BoxShadow(color: pGlowLit(d), blurRadius: 20)] : [],
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
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(left: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: lit ? pCard(d) : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            border:
                Border.all(color: lit ? pCardBorderH(d) : Colors.transparent),
            boxShadow:
                lit ? [BoxShadow(color: pGlowLit(d), blurRadius: 16)] : [],
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontFamily: 'DMSans',
              color: lit ? pCardText(d) : pBody(d),
              fontSize: 12,
              fontWeight: lit ? FontWeight.w700 : FontWeight.w400,
            ),
            child: Text(widget.label),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// HOVER CARD (Enhanced with 3D tilt option)
// ═══════════════════════════════════════════════════════════════════
class PallenHoverCard extends StatefulWidget {
  final Widget child;
  final bool slideRight;
  final EdgeInsets padding;
  final bool enableTilt;

  const PallenHoverCard({
    super.key,
    required this.child,
    required this.slideRight,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    this.enableTilt = false,
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
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(_offset.dx, _offset.dy, 0),
      decoration: BoxDecoration(
        color: _hov ? pCardH(d) : pCard(d),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _hov ? pCardBorderH(d) : pCardBorder(d),
          width: _hov ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _hov ? pGlowLit(d) : pGlowDim(d),
            blurRadius: _hov ? 32 : 0,
            spreadRadius: _hov ? 2 : 0,
          ),
        ],
      ),
      child: Padding(
        padding: widget.padding,
        child: widget.child,
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: widget.enableTilt
          ? TiltCard(
              maxTilt: 0.08,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: card,
            )
          : card,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// GLASS CHIP (Enhanced)
// ═══════════════════════════════════════════════════════════════════
class PallenGlassChip extends StatelessWidget {
  final String text;
  const PallenGlassChip(this.text, {super.key});
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0x12FFFFFF),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0x24FFFFFF)),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.05),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
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
      AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        width: 40,
        height: 2,
        decoration: BoxDecoration(
          color: pLine(d),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
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
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: pBorder(d)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(icon, color: pIcon(d), size: size * 0.46),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// RCO CARD (Enhanced with scroll reveal)
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
// CTA BUTTON (Enhanced with magnetic effect)
// ═══════════════════════════════════════════════════════════════════
class PallenCtaButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;
  final bool magnetic;

  const PallenCtaButton({
    super.key,
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
    this.magnetic = true,
  });
  @override
  State<PallenCtaButton> createState() => _PallenCtaButtonState();
}

class _PallenCtaButtonState extends State<PallenCtaButton> {
  bool _h = false;

  Widget _buildButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(0, _h ? -3 : 0, 0),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
      decoration: BoxDecoration(
        color: widget.filled
            ? (_h ? kP85 : kP98)
            : (_h ? const Color(0x24FFFFFF) : Colors.transparent),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: widget.filled
              ? Colors.transparent
              : (_h ? const Color(0x50FFFFFF) : const Color(0x24FFFFFF)),
        ),
        boxShadow: widget.filled && _h
            ? [
                BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 24,
                    spreadRadius: 2)
              ]
            : [],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child:
              Icon(widget.icon, size: 14, color: widget.filled ? kP00 : kP70),
        ),
        const SizedBox(width: 8),
        Text(widget.label,
            style: TextStyle(
              fontFamily: 'DMSans',
              color: widget.filled ? kP00 : kP70,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            )),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
        onEnter: (_) => setState(() => _h = true),
        onExit: (_) => setState(() => _h = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: widget.magnetic
              ? MagneticButton(
                  onTap: widget.onTap,
                  strength: 0.2,
                  child: _buildButton(),
                )
              : _buildButton(),
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
// LANGUAGE SYSTEM (Enhanced with progress bars)
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
  final double proficiency; // 0.0 to 1.0
  const PallenLangItem(this.name, this.kind, {this.proficiency = 0.85});
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
        duration: const Duration(milliseconds: 200),
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
// CONTACT CARD (Enhanced with copy-to-clipboard)
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
  bool _copied = false;

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

  void _copyToClipboard() {
    final text = widget.data.handle;
    Clipboard.setData(ClipboardData(text: text));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
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
        onLongPress: _copyToClipboard,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(_hov ? 6 : 0, 0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _hov ? pCardH(d) : pCard(d),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hov ? brand.withOpacity(0.55) : pCardBorder(d),
              width: _hov ? 1.5 : 1,
            ),
            boxShadow: _hov
                ? [
                    BoxShadow(
                        color: brand.withOpacity(0.18),
                        blurRadius: 20,
                        spreadRadius: 2)
                  ]
                : [],
          ),
          child: Row(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _hov ? brand.withOpacity(0.18) : brand.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color:
                      _hov ? brand.withOpacity(0.5) : brand.withOpacity(0.25),
                ),
              ),
              child: Icon(_icon, color: brand, size: 18),
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
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _copied
                  ? Icon(Icons.check_rounded,
                      size: 14, color: kPGreen, key: const ValueKey('check'))
                  : Icon(Icons.open_in_new_rounded,
                      size: 12,
                      color: _hov ? brand : pMuted(d),
                      key: const ValueKey('open')),
            ),
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

// ═══════════════════════════════════════════════════════════════════
// HORIZONTAL SCROLL CAROUSEL (for projects/design)
// ═══════════════════════════════════════════════════════════════════
class HorizontalCarousel extends StatefulWidget {
  final List<Widget> children;
  final double itemWidth;
  final double gap;

  const HorizontalCarousel({
    super.key,
    required this.children,
    this.itemWidth = 360,
    this.gap = 20,
  });

  @override
  State<HorizontalCarousel> createState() => _HorizontalCarouselState();
}

class _HorizontalCarouselState extends State<HorizontalCarousel> {
  final _ctrl = ScrollController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 420,
          child: ListView.separated(
            controller: _ctrl,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            itemCount: widget.children.length,
            separatorBuilder: (_, __) => SizedBox(width: widget.gap),
            itemBuilder: (_, i) => SizedBox(
              width: widget.itemWidth,
              child: widget.children[i],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Scroll indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.children.length, (i) {
            return Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// TEXT REVEAL ANIMATION (for hero section)
// ═══════════════════════════════════════════════════════════════════
class TextReveal extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration delay;
  final Duration duration;

  const TextReveal({
    super.key,
    required this.text,
    required this.style,
    this.delay = const Duration(milliseconds: 0),
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<TextReveal> createState() => _TextRevealState();
}

class _TextRevealState extends State<TextReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final visibleChars = (widget.text.length * _anim.value).round();
        return Text(
          widget.text.substring(0, visibleChars),
          style: widget.style,
        );
      },
    );
  }
}

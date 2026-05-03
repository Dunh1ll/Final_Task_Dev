import 'package:flutter/material.dart';
import 'constants.dart';
import 'package:url_launcher/url_launcher.dart';

class KNavBar extends StatefulWidget {
  final KTab tab;
  final void Function(KTab) onTab;
  final bool isWide;
  const KNavBar({required this.tab, required this.onTab, required this.isWide});

  @override
  State<KNavBar> createState() => _KNavBarState();
}

class _KNavBarState extends State<KNavBar> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        decoration: BoxDecoration(
          color: KC.bg.withOpacity(0.92),
          border: const Border(
            bottom: BorderSide(color: KC.border, width: 1),
          ),
        ),
        child: Row(
          children: [
            // Back button
            _BackButton(),
            const SizedBox(width: 16),
            // Logo hexagon
            _HexLogo(onTap: () => widget.onTab(KTab.home)),
            const Spacer(),
            if (widget.isWide) ...[
              _NavItem('01.', 'About', KTab.about, widget.tab, widget.onTab),
              const SizedBox(width: 8),
             _NavItem('02.', 'Experience', KTab.experience, widget.tab, widget.onTab),
              const SizedBox(width: 8),
              _NavItem('03.', 'Projects', KTab.projects, widget.tab, widget.onTab),
              const SizedBox(width: 8),
              _NavItem('04.', 'Contact', KTab.contact, widget.tab, widget.onTab),
              const SizedBox(width: 20),
              _ResumeButton(),
            ] else
              PopupMenuButton<KTab>(
                color: KC.bgLight,
                icon: const Icon(Icons.menu, color: KC.mint),
                onSelected: widget.onTab,
                itemBuilder: (_) => [
                  _menuItem(KTab.about, '01. About'),
                  _menuItem(KTab.projects, '02. Experience'),
                  _menuItem(KTab.projects, '03. Projects'),
                  _menuItem(KTab.contact, '04. Contact'),
                ],
              ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<KTab> _menuItem(KTab tab, String label) {
    return PopupMenuItem(
      value: tab,
      child: Text(label,
          style: const TextStyle(
              color: KC.mint, fontFamily: 'monospace', fontSize: 13)),
    );
  }
}

class _BackButton extends StatefulWidget {
  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: GestureDetector(
        onTap: () => Navigator.maybePop(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(_hov ? -3 : 0, 0, 0),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _hov ? KC.mint : KC.textSecondary,
            size: 18,
          ),
        ),
      ),
    );
  }
}

// ── Hexagon Logo ────────────────────────────────────────────────
class _HexLogo extends StatefulWidget {
  final VoidCallback onTap;
  const _HexLogo({required this.onTap});
  @override
  State<_HexLogo> createState() => _HexLogoState();
}

class _HexLogoState extends State<_HexLogo> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: _hov
                ? [BoxShadow(
                    color: KC.mint.withOpacity(0.25),
                    blurRadius: 12,
                    spreadRadius: 1,
                  )]
                : [],
          ),
          child: CustomPaint(
            painter: _HexPainter(hovered: false),
            child: const Center(
              child: Text(
                'K',
                style: TextStyle(
                  color: KC.mint,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HexPainter extends CustomPainter {
  final bool hovered;
  const _HexPainter({required this.hovered});

@override
void paint(Canvas canvas, Size s) {
  final cx = s.width / 2;
  final cy = s.height / 2;
  final r = s.width / 2 - 1;
  final path = Path();
  for (int i = 0; i < 6; i++) {
    final angle = (i * 60 - 30) * 3.14159 / 180;
    final x = cx + r * _cos(angle);
    final y = cy + r * _sin(angle);
    i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
  }
  path.close();

  canvas.drawPath(
    path,
    Paint()
      ..color = hovered ? KC.mint : KC.mint.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = hovered ? 2.0 : 1.5,
  );
}

  double _cos(double a) => a == 0
      ? 1.0
      : (a - 1.0472).abs() < 0.001
          ? 0.5
          : (a - 2.0944).abs() < 0.001
              ? -0.5
              : (a - 3.14159).abs() < 0.001
                  ? -1.0
                  : (a - 4.18879).abs() < 0.001
                      ? -0.5
                      : 0.5;

  double _sin(double a) => a == 0
      ? 0.0
      : (a - 1.0472).abs() < 0.001
          ? 0.866
          : (a - 2.0944).abs() < 0.001
              ? 0.866
              : (a - 3.14159).abs() < 0.001
                  ? 0.0
                  : (a - 4.18879).abs() < 0.001
                      ? -0.866
                      : -0.866;

  @override
  bool shouldRepaint(_HexPainter o) => o.hovered != hovered;
}

// ── Nav Item ────────────────────────────────────────────────────
class _NavItem extends StatefulWidget {
  final String number, label;
  final KTab tab, current;
  final void Function(KTab) onTap;
  const _NavItem(this.number, this.label, this.tab, this.current, this.onTap);

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.tab == widget.current;
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: GestureDetector(
        onTap: () => widget.onTap(widget.tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${widget.number} ',
                  style: const TextStyle(
                    color: KC.mint,
                    fontSize: 12,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                TextSpan(
                  text: widget.label,
                  style: TextStyle(
                    color: _hov || active ? KC.mint : KC.textSecondary,
                    fontSize: 13,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
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

// ── Resume Button ───────────────────────────────────────────────
class _ResumeButton extends StatefulWidget {
  @override
  State<_ResumeButton> createState() => _ResumeButtonState();
}

class _ResumeButtonState extends State<_ResumeButton> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: GestureDetector(
      onTap: () async {
        final uri = Uri.parse('https://drive.google.com/file/d/197NgI4I7EYjamOrspb5Iro8Eh1NXzRmF/view');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _hov ? KC.mint.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: KC.mint, width: 1),
          ),
          child: const Text(
            'Resume',
            style: TextStyle(
              color: KC.mint,
              fontSize: 13,
              fontFamily: 'monospace',
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
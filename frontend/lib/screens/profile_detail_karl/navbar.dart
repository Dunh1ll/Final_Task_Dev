import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'constants.dart';

class KNavBar extends StatefulWidget {
  final KTab tab;
  final void Function(KTab) onTab;
  final bool isWide;
  const KNavBar(
      {required this.tab, required this.onTab, required this.isWide});

  @override
  State<KNavBar> createState() => _KNavBarState();
}

class _KNavBarState extends State<KNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: const BoxDecoration(
          color: KC.bg,
          border: Border(
            bottom: BorderSide(color: KC.borderStr, width: 2),
          ),
        ),
        child: Row(
          children: [
            // Back arrow
            _BackBtn(),
            const SizedBox(width: 12),
            // Logo
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => widget.onTab(KTab.home),
                child: Image.asset(
                  'assets/images/logonikaloy.png',
                  height: 64,
                ),
              ),
            ),
            const Spacer(),
            if (widget.isWide) ...[
              _NavItem('01', 'About', KTab.about, widget.tab,
                  widget.onTab),
              _NavItem('02', 'Experience', KTab.experience,
                  widget.tab, widget.onTab),
              _NavItem('03', 'Projects', KTab.projects, widget.tab,
                  widget.onTab),
              _NavItem('04', 'Contact', KTab.contact, widget.tab,
                  widget.onTab),
              const SizedBox(width: 16),
              _ResumeBtn(),
            ] else
              PopupMenuButton<KTab>(
                color: KC.bgCard,
                icon: const Icon(Icons.menu, color: KC.textPrimary, size: 20),
                onSelected: widget.onTab,
                itemBuilder: (_) => [
                  _mi(KTab.about, '01 — About'),
                  _mi(KTab.experience, '02 — Experience'),
                  _mi(KTab.projects, '03 — Projects'),
                  _mi(KTab.contact, '04 — Contact'),
                ],
              ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<KTab> _mi(KTab tab, String label) => PopupMenuItem(
        value: tab,
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: KC.fontMono,
            fontSize: 12,
            letterSpacing: 1.5,
            color: KC.textPrimary,
          ),
        ),
      );
}

// ── Back button ───────────────────────────────────────────────────
class _BackBtn extends StatefulWidget {
  @override
  State<_BackBtn> createState() => _BackBtnState();
}

class _BackBtnState extends State<_BackBtn> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.maybePop(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          transform:
              Matrix4.translationValues(_hov ? -3 : 0, 0, 0),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _hov ? KC.textPrimary : KC.textMuted,
            size: 16,
          ),
        ),
      ),
    );
  }
}

// ── Nav item ──────────────────────────────────────────────────────
class _NavItem extends StatefulWidget {
  final String num, label;
  final KTab tab, current;
  final void Function(KTab) onTap;
  const _NavItem(this.num, this.label, this.tab, this.current, this.onTap);

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
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onTap(widget.tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active
                    ? KC.textPrimary
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
          ),
          child: Text.rich(
            TextSpan(children: [
              TextSpan(
                text: '${widget.num}. ',
                style: TextStyle(
                  fontFamily: KC.fontMono,
                  fontSize: 10,
                  color: active || _hov
                      ? KC.textSecondary
                      : KC.textDim,
                  letterSpacing: 1,
                ),
              ),
              TextSpan(
                text: widget.label,
                style: TextStyle(
                  fontFamily: KC.fontMono,
                  fontSize: 11,
                  letterSpacing: 2,
                  color: active || _hov
                      ? KC.textPrimary
                      : KC.textMuted,
                  fontWeight: active
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Resume button ─────────────────────────────────────────────────
class _ResumeBtn extends StatefulWidget {
  @override
  State<_ResumeBtn> createState() => _ResumeBtnState();
}

class _ResumeBtnState extends State<_ResumeBtn> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          final uri = Uri.parse(
              'https://drive.google.com/file/d/197NgI4I7EYjamOrspb5Iro8Eh1NXzRmF/view');
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color:
                _hov ? KC.textPrimary.withOpacity(0.1) : Colors.transparent,
            border: Border.all(color: KC.textPrimary, width: 1),
          ),
          child: Text(
            'RESUME',
            style: TextStyle(
              fontFamily: KC.fontMono,
              fontSize: 9,
              letterSpacing: 3,
              color: KC.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
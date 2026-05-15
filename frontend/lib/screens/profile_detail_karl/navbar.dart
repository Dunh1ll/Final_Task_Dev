import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'constants.dart';

class KNavBar extends StatefulWidget {
  final KTab tab;
  final void Function(KTab) onTab;
  final bool isWide;
  const KNavBar({
    required this.tab,
    required this.onTab,
    required this.isWide,
  });

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
    final isHome = widget.tab == KTab.home;

    return FadeTransition(
      opacity: _fade,
      child: Container(
        height: 68,
        // Single bottom border retained as a structural separator — part of
        // the page layout, not a decorative border on the navbar itself.
        decoration: const BoxDecoration(
          color: KC.bg,
          border: Border(
            bottom: BorderSide(color: KC.borderStr, width: 2),
          ),
        ),
        child: widget.isWide
            ? _WideNav(isHome: isHome, tab: widget.tab, onTab: widget.onTab)
            : _NarrowNav(isHome: isHome, tab: widget.tab, onTab: widget.onTab),
      ),
    );
  }
}

// ── Wide Nav ──────────────────────────────────────────────────────
class _WideNav extends StatelessWidget {
  final bool isHome;
  final KTab tab;
  final void Function(KTab) onTab;
  const _WideNav({
    required this.isHome,
    required this.tab,
    required this.onTab,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Back
          _BackBtn(),

          const SizedBox(width: 20),

          // Logo — home indicator
          _LogoBlock(isHome: isHome, onTap: () => onTab(KTab.home)),

          const Spacer(),

          // Nav items
          _NavItem('01', 'About',      KTab.about,      tab, onTab),
          _NavItem('02', 'Experience', KTab.experience, tab, onTab),
          _NavItem('03', 'Projects',   KTab.projects,   tab, onTab),
          _NavItem('04', 'Contact',    KTab.contact,    tab, onTab),

          const SizedBox(width: 24),

          // Resume CTA
          _ResumeBtn(),
        ],
      ),
    );
  }
}

// ── Narrow Nav ────────────────────────────────────────────────────
class _NarrowNav extends StatelessWidget {
  final bool isHome;
  final KTab tab;
  final void Function(KTab) onTab;
  const _NarrowNav({
    required this.isHome,
    required this.tab,
    required this.onTab,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _BackBtn(),
          const SizedBox(width: 16),
          _LogoBlock(isHome: isHome, onTap: () => onTab(KTab.home)),
          const Spacer(),
          _HamburgerMenu(tab: tab, onTab: onTab),
        ],
      ),
    );
  }
}

// ── Logo Block ────────────────────────────────────────────────────
class _LogoBlock extends StatefulWidget {
  final bool isHome;
  final VoidCallback onTap;
  const _LogoBlock({required this.isHome, required this.onTap});

  @override
  State<_LogoBlock> createState() => _LogoBlockState();
}

class _LogoBlockState extends State<_LogoBlock> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.isHome;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo — dims when not home, brightens when active/hover
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: active || _hov ? 1.0 : 0.55,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  KC.textPrimary,
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  'assets/images/logonikaloy.png',
                  height: 34,
                ),
              ),
            ),

            // Active dot + HOME label
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: (active || _hov)
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 10),

                        // Pulse dot — only when truly active (home)
                        if (active) ...[
                          _PulseDot(),
                          const SizedBox(width: 6),
                        ],

                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 180),
                          opacity: active || _hov ? 1.0 : 0.0,
                          child: Text(
                            active ? 'HOME' : 'HOME',
                            style: TextStyle(
                              fontFamily: KC.fontMono,
                              fontSize: 9,
                              letterSpacing: 3,
                              fontWeight: FontWeight.w700,
                              color: active
                                  ? KC.textPrimary
                                  : KC.textMuted,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pulse Dot ─────────────────────────────────────────────────────
class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _o;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _o = Tween<double>(begin: 1.0, end: 0.2)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _o,
        child: Container(
          width: 5,
          height: 5,
          decoration: const BoxDecoration(
            color: KC.textPrimary,
            shape: BoxShape.circle,
          ),
        ),
      );
}

// ── Back Button ───────────────────────────────────────────────────
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
          transform: Matrix4.translationValues(_hov ? -3 : 0, 0, 0),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _hov ? KC.textPrimary : KC.textMuted,
            size: 15,
          ),
        ),
      ),
    );
  }
}

// ── Nav Item ──────────────────────────────────────────────────────
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Number — fades in only on active/hover
              AnimatedOpacity(
                duration: const Duration(milliseconds: 160),
                opacity: active || _hov ? 1.0 : 0.0,
                child: Text(
                  widget.num,
                  style: TextStyle(
                    fontFamily: KC.fontMono,
                    fontSize: 8,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                    color: active ? KC.textMuted : KC.textDim,
                  ),
                ),
              ),

              const SizedBox(height: 2),

              // Label
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 160),
                style: TextStyle(
                  fontFamily: KC.fontMono,
                  fontSize: 11,
                  letterSpacing: 2.2,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                  color: active
                      ? KC.textPrimary
                      : (_hov ? KC.textSecondary : KC.textDim),
                ),
                child: Text(widget.label.toUpperCase()),
              ),

              const SizedBox(height: 3),

              // Underline dot row — active state indicator
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    width: active ? 16 : (_hov ? 6 : 0),
                    height: 1.5,
                    color: active ? KC.textPrimary : KC.textDim,
                  ),
                  if (active) ...[
                    const SizedBox(width: 3),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        color: KC.textPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Resume Button ─────────────────────────────────────────────────
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
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          decoration: BoxDecoration(
            // Subtle filled pill — no hard border, just a soft background
            color: _hov
                ? KC.textPrimary
                : KC.textPrimary.withOpacity(0.08),
          ),
          child: Text(
            'RESUME',
            style: TextStyle(
              fontFamily: KC.fontMono,
              fontSize: 10,
              letterSpacing: 3,
              fontWeight: FontWeight.w700,
              color: _hov ? KC.bg : KC.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Hamburger Menu (narrow) ───────────────────────────────────────
class _HamburgerMenu extends StatefulWidget {
  final KTab tab;
  final void Function(KTab) onTab;
  const _HamburgerMenu({required this.tab, required this.onTab});

  @override
  State<_HamburgerMenu> createState() => _HamburgerMenuState();
}

class _HamburgerMenuState extends State<_HamburgerMenu> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      cursor: SystemMouseCursors.click,
      child: PopupMenuButton<KTab>(
        color: KC.bg,
        offset: const Offset(0, 52),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        elevation: 2,
        constraints: const BoxConstraints(minWidth: 180),
        onSelected: widget.onTab,
        itemBuilder: (_) => [
          _mi(KTab.about,      '01', 'About'),
          _mi(KTab.experience, '02', 'Experience'),
          _mi(KTab.projects,   '03', 'Projects'),
          _mi(KTab.contact,    '04', 'Contact'),
        ],
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 160),
          opacity: _hov ? 1.0 : 0.6,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _HLine(width: 22),
              const SizedBox(height: 5),
              _HLine(width: 14),
              const SizedBox(height: 5),
              _HLine(width: 22),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<KTab> _mi(KTab tab, String num, String label) {
    final active = widget.tab == tab;
    return PopupMenuItem(
      value: tab,
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Text(
              '$num  ',
              style: TextStyle(
                fontFamily: KC.fontMono,
                fontSize: 9,
                letterSpacing: 1.5,
                color: active ? KC.textMuted : KC.textDim,
              ),
            ),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontFamily: KC.fontMono,
                fontSize: 12,
                letterSpacing: 2,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                color: active ? KC.textPrimary : KC.textMuted,
              ),
            ),
            if (active) ...[
              const SizedBox(width: 8),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: KC.textPrimary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HLine extends StatelessWidget {
  final double width;
  const _HLine({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 1.5,
      color: KC.textPrimary,
    );
  }
}
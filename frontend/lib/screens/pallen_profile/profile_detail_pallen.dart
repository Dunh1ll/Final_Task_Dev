// lib/screens/pallen_profile/profile_detail_pallen.dart
//
// ARCHITECTURE — Single continuous scrollable page with scroll-aware nav bar.
//
// All 5 sections live in ONE CustomScrollView.
// The nav bar watches scroll position and highlights whichever section
// is currently in view. Clicking a nav tab smoothly scrolls to that section.
//
// NEW FEATURES:
//   - Scroll progress bar at top
//   - Nav bar hides on scroll down, shows on scroll up
//   - Cursor glow follower (desktop only)
//   - Enhanced glassmorphism nav
//   - Smooth section transitions
//
// SECTIONS (in scroll order):
//   0 — Home      (full-screen hero, SliverFillViewport)
//   1 — About     (bio, education, skills)
//   2 — Work      (NAVIRA project)
//   3 — Design    (FB / YouTube / Netflix UI clones)
//   4 — Contact   (contact grid)

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pallen_theme.dart';
import 'pallen_widgets.dart';
import 'pallen_home_page.dart';
import 'pallen_about_page.dart';
import 'pallen_work_page.dart';
import 'pallen_design_page.dart';
import 'pallen_contact_page.dart';

const _kLabels = ['Home', 'About', 'Work', 'Design', 'Contact'];

class ProfileDetailPallen extends StatefulWidget {
  const ProfileDetailPallen({super.key});
  @override
  State<ProfileDetailPallen> createState() => _ProfileDetailPallenState();
}

class _ProfileDetailPallenState extends State<ProfileDetailPallen>
    with SingleTickerProviderStateMixin {
  bool _isDark = true;

  final ScrollController _scroll = ScrollController();
  final List<GlobalKey> _keys = List.generate(5, (_) => GlobalKey());
  int _activeSection = 0;

  // Nav bar visibility
  bool _navVisible = true;
  double _lastScrollOffset = 0;

  late AnimationController _underlineCtrl;
  late Animation<double> _underlineAnim;

  void _open(String url) => html.window.open(url, '_blank');

  @override
  void initState() {
    super.initState();
    _underlineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _underlineAnim = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _underlineCtrl, curve: Curves.easeInOutCubic),
    );
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _underlineCtrl.dispose();
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    final offset = _scroll.offset;

    // Nav hide/show logic
    if (offset > _lastScrollOffset && offset > 100 && _navVisible) {
      setState(() => _navVisible = false);
    } else if (offset < _lastScrollOffset && !_navVisible) {
      setState(() => _navVisible = true);
    }
    _lastScrollOffset = offset;

    // Section detection
    final viewportTop = offset;
    int detected = 0;
    for (int i = _keys.length - 1; i >= 0; i--) {
      final ctx = _keys[i].currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final sectionTop = box.localToGlobal(Offset.zero, ancestor: null).dy +
          viewportTop -
          MediaQuery.of(context).padding.top -
          56;
      if (viewportTop >= sectionTop - 80) {
        detected = i;
        break;
      }
    }

    if (detected != _activeSection) {
      setState(() => _activeSection = detected);
      _animateUnderlineTo(detected.toDouble());
    }
  }

  void _animateUnderlineTo(double target) {
    final current = _underlineAnim.value;
    _underlineAnim = Tween<double>(begin: current, end: target).animate(
      CurvedAnimation(parent: _underlineCtrl, curve: Curves.easeInOutCubic),
    );
    _underlineCtrl
      ..reset()
      ..forward();
  }

  void _goToSection(int index) {
    final ctx = _keys[index].currentContext;
    if (ctx == null) {
      setState(() => _activeSection = index);
      _animateUnderlineTo(index.toDouble());
      return;
    }
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
      alignment: 0.0,
      alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
    );
    setState(() => _activeSection = index);
    _animateUnderlineTo(index.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    return PTheme(
      dark: _isDark,
      child: Scaffold(
        backgroundColor: pBg(_isDark),
        body: Stack(children: [
          // ── Single continuous scroll view ──────────────────────
          NotificationListener<ScrollNotification>(
            onNotification: (_) {
              // Trigger scroll reveal checks
              return false;
            },
            child: CustomScrollView(
              controller: _scroll,
              physics: const ClampingScrollPhysics(),
              slivers: [
                // 0 — Home
                SliverFillViewport(
                  delegate: SliverChildBuilderDelegate(
                    (_, __) => KeyedSubtree(
                      key: _keys[0],
                      child: PallenHomePage(
                        onGoWork: () => _goToSection(2),
                        onGoContact: () => _goToSection(4),
                        onOpen: _open,
                      ),
                    ),
                    childCount: 1,
                  ),
                ),

                // 1 — About
                SliverToBoxAdapter(
                  child: KeyedSubtree(
                    key: _keys[1],
                    child: PallenAboutPage(footer: const SizedBox.shrink()),
                  ),
                ),

                // 2 — Work
                SliverToBoxAdapter(
                  child: KeyedSubtree(
                    key: _keys[2],
                    child: PallenWorkPage(footer: const SizedBox.shrink()),
                  ),
                ),

                // 3 — Design
                SliverToBoxAdapter(
                  child: KeyedSubtree(
                    key: _keys[3],
                    child: PallenDesignPage(footer: const SizedBox.shrink()),
                  ),
                ),

                // 4 — Contact
                SliverToBoxAdapter(
                  child: KeyedSubtree(
                    key: _keys[4],
                    child: PallenContactPage(
                      onOpen: _open,
                      footer: _footerWidget(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Scroll Progress Bar ────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _ScrollProgressBar(
              scrollController: _scroll,
              isDark: _isDark,
            ),
          ),

          // ── Fixed nav bar on top ───────────────────────────────
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            top: _navVisible ? 0 : -80,
            left: 0,
            right: 0,
            child: _NavBar(
              isDark: _isDark,
              activeSection: _activeSection,
              underlineAnim: _underlineAnim,
              onBack: () => context.pop(),
              onToggleDark: () => setState(() => _isDark = !_isDark),
              onTap: _goToSection,
            ),
          ),

          // ── Cursor Glow Follower (Desktop only) ────────────────
          if (!html.window.navigator.userAgent.contains('Mobile'))
            Positioned.fill(
              child: IgnorePointer(
                child: _CursorGlow(isDark: _isDark),
              ),
            ),
        ]),
      ),
    );
  }

  Widget _footerWidget() {
    final d = _isDark;
    return Container(
      color: pBg2(d),
      padding: const EdgeInsets.symmetric(horizontal: 76, vertical: 44),
      child: Column(children: [
        Divider(color: pLine(d), height: 1),
        const SizedBox(height: 28),
        Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('PALLEN',
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  color: pHead(d),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                )),
            const SizedBox(height: 5),
            Text('Prince Dunhill Pallen  ·  Computer Engineer',
                style: TextStyle(
                    fontFamily: 'DMSans', color: pMuted(d), fontSize: 11)),
          ]),
          const Spacer(),
          Text('© 2025  ·  All rights reserved.',
              style: TextStyle(
                  fontFamily: 'DMSans', color: pMuted(d), fontSize: 11)),
        ]),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SCROLL PROGRESS BAR
// ═══════════════════════════════════════════════════════════════
class _ScrollProgressBar extends StatefulWidget {
  final ScrollController scrollController;
  final bool isDark;

  const _ScrollProgressBar({
    required this.scrollController,
    required this.isDark,
  });

  @override
  State<_ScrollProgressBar> createState() => _ScrollProgressBarState();
}

class _ScrollProgressBarState extends State<_ScrollProgressBar> {
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_updateProgress);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_updateProgress);
    super.dispose();
  }

  void _updateProgress() {
    final ctrl = widget.scrollController;
    if (!ctrl.hasClients) return;
    final max = ctrl.position.maxScrollExtent;
    if (max <= 0) return;
    setState(() => _progress = (ctrl.offset / max).clamp(0, 1));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      color: Colors.transparent,
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: _progress,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.isDark ? kP70 : kP40,
                widget.isDark ? kPWh : kP00,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: (widget.isDark ? kPWh : kP00).withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CURSOR GLOW FOLLOWER
// ═══════════════════════════════════════════════════════════════
class _CursorGlow extends StatefulWidget {
  final bool isDark;
  const _CursorGlow({required this.isDark});

  @override
  State<_CursorGlow> createState() => _CursorGlowState();
}

class _CursorGlowState extends State<_CursorGlow> {
  Offset _pos = const Offset(-100, -100);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (e) => setState(() => _pos = e.localPosition),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Stack(children: [
          Positioned(
            left: _pos.dx - 150,
            top: _pos.dy - 150,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    (widget.isDark ? Colors.white : Colors.black)
                        .withOpacity(0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// NAV BAR
// ═══════════════════════════════════════════════════════════════
class _NavBar extends StatelessWidget {
  final bool isDark;
  final int activeSection;
  final Animation<double> underlineAnim;
  final VoidCallback onBack;
  final VoidCallback onToggleDark;
  final void Function(int) onTap;

  const _NavBar({
    required this.isDark,
    required this.activeSection,
    required this.underlineAnim,
    required this.onBack,
    required this.onToggleDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final d = isDark;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 56,
          decoration: BoxDecoration(
            color: d
                ? const Color(0xFF080808).withOpacity(0.92)
                : Colors.white.withOpacity(0.92),
            border: Border(bottom: BorderSide(color: pBorder(d), width: 1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(children: [
            PallenNavGhostBtn(
              onTap: onBack,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.arrow_back_ios_new_rounded,
                    size: 11, color: pBody(d)),
                const SizedBox(width: 5),
                Text('Back',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      color: pBody(d),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    )),
              ]),
            ),
            const SizedBox(width: 16),
            Text('PALLEN',
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  color: pHead(d),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                )),
            const Spacer(),
            AnimatedBuilder(
              animation: underlineAnim,
              builder: (_, __) => _TabRow(
                d: d,
                activeSection: activeSection,
                underlinePos: underlineAnim.value,
                onTap: onTap,
              ),
            ),
            const SizedBox(width: 16),
            PallenDarkToggle(isDark: isDark, onToggle: onToggleDark),
          ]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB ROW with sliding underline
// ═══════════════════════════════════════════════════════════════
class _TabRow extends StatelessWidget {
  final bool d;
  final int activeSection;
  final double underlinePos;
  final void Function(int) onTap;

  const _TabRow({
    required this.d,
    required this.activeSection,
    required this.underlinePos,
    required this.onTap,
  });

  static const double _tabW = 72;
  static const double _tabH = 32;

  @override
  Widget build(BuildContext context) {
    final totalW = _kLabels.length * _tabW;
    final underlineX = underlinePos * _tabW;

    return SizedBox(
      width: totalW,
      height: _tabH,
      child: Stack(children: [
        Row(
          children: List.generate(_kLabels.length, (i) {
            final active = activeSection == i;
            return GestureDetector(
              onTap: () => onTap(i),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  width: _tabW,
                  height: _tabH,
                  alignment: Alignment.center,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      color: active ? pHead(d) : pBody(d),
                      fontSize: 12,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                    ),
                    child: Text(_kLabels[i]),
                  ),
                ),
              ),
            );
          }),
        ),

        // Sliding underline pill
        Positioned(
          bottom: 0,
          left: underlineX + 10,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 50),
            width: _tabW - 20,
            height: 2,
            decoration: BoxDecoration(
              color: pHead(d),
              borderRadius: BorderRadius.circular(1),
              boxShadow: [
                BoxShadow(
                  color: pHead(d).withOpacity(0.4),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ═══════════════════════════════════════════════════════════════════
// SOCIAL LINKS
// ═══════════════════════════════════════════════════════════════════
const _kFacebook = 'https://www.facebook.com/dnhll.plln';
const _kGitHub = 'https://github.com/Dunh1ll';
const _kGmail = 'mailto:cpe.pallen.princedunhill@gmail.com';
const _kLinkedIn = 'https://www.linkedin.com/in/pallen-prince-dunhill/';
const _kInstagram = 'https://www.instagram.com/nturdanii?igsh=eGxsdmVwc3BwMGt5';
const _kPhone = 'tel:+639504647074';
const _kResume =
    'https://drive.google.com/file/d/1392cs0UZbuROHIWIG9S2tzfpIGLvuulo/view?usp=drive_link';

// ═══════════════════════════════════════════════════════════════════
// STATIC DARK-PALETTE CONSTANTS (const context usage)
// ═══════════════════════════════════════════════════════════════════
const _k00 = Color(0xFF000000);
const _k03 = Color(0xFF080808);
const _k07 = Color(0xFF111111);
const _k10 = Color(0xFF1A1A1A);
const _k14 = Color(0xFF242424);
const _k18 = Color(0xFF2E2E2E);
const _k25 = Color(0xFF404040);
const _k40 = Color(0xFF666666);
const _k55 = Color(0xFF8C8C8C);
const _k70 = Color(0xFFB3B3B3);
const _k85 = Color(0xFFD9D9D9);
const _k93 = Color(0xFFEDEDED);
const _k98 = Color(0xFFF7F7F7);
const _kWh = Colors.white;
const _kGreen = Color(0xFF4ADE80);

// ═══════════════════════════════════════════════════════════════════
// THEME INHERITED WIDGET
// Any widget reads dark flag via: _PTheme.of(context)
// ═══════════════════════════════════════════════════════════════════
class _PTheme extends InheritedWidget {
  final bool dark;
  const _PTheme({required this.dark, required super.child});
  static bool of(BuildContext ctx) =>
      ctx.dependOnInheritedWidgetOfExactType<_PTheme>()?.dark ?? true;
  @override
  bool updateShouldNotify(_PTheme o) => o.dark != dark;
}

// ═══════════════════════════════════════════════════════════════════
// DYNAMIC COLOR HELPERS  — pass dark = _PTheme.of(context)
//
// ✅ FIX: Card hover colors are now SOLID (not transparent glass)
// so text is always readable regardless of what's behind the card.
// Dark mode: near-black card, near-white text  → high contrast
// Light mode: white card, near-black text       → high contrast
// ═══════════════════════════════════════════════════════════════════
Color _cBg(bool d) => d ? const Color(0xFF080808) : const Color(0xFFF5F5F5);
Color _cBg2(bool d) => d ? const Color(0xFF0F0F0F) : const Color(0xFFEBEBEB);
Color _cBg3(bool d) => d ? const Color(0xFF161616) : const Color(0xFFE0E0E0);
Color _cHead(bool d) => d ? const Color(0xFFF7F7F7) : const Color(0xFF0D0D0D);
Color _cBody(bool d) => d ? const Color(0xFF8C8C8C) : const Color(0xFF555555);
Color _cMuted(bool d) => d ? const Color(0xFF555555) : const Color(0xFF999999);
Color _cBorder(bool d) => d ? const Color(0xFF2A2A2A) : const Color(0xFFD5D5D5);
Color _cBorderH(bool d) =>
    d ? const Color(0xFF505050) : const Color(0xFF999999);
// SOLID card backgrounds for guaranteed text contrast
Color _cCard(bool d) => d ? const Color(0xFF131313) : const Color(0xFFFFFFFF);
Color _cCardH(bool d) => d ? const Color(0xFF1C1C1C) : const Color(0xFFF0F0F0);
Color _cCardBorder(bool d) =>
    d ? const Color(0xFF2E2E2E) : const Color(0xFFDDDDDD);
Color _cCardBorderH(bool d) =>
    d ? const Color(0xFF545454) : const Color(0xFFAAAAAA);
// Glow — white in dark, subtle shadow in light
Color _cGlowLit(bool d) =>
    d ? const Color(0x33FFFFFF) : const Color(0x18000000);
Color _cGlowDim(bool d) =>
    d ? const Color(0x00FFFFFF) : const Color(0x00000000);
// Icon/badge color
Color _cIcon(bool d) => d ? const Color(0xFFB3B3B3) : const Color(0xFF555555);
// Text ON a card (always readable against _cCard/_cCardH)
Color _cCardText(bool d) =>
    d ? const Color(0xFFEDEDED) : const Color(0xFF111111);
Color _cCardSub(bool d) =>
    d ? const Color(0xFF8C8C8C) : const Color(0xFF666666);
// Eyebrow / label
Color _cEyebrow(bool d) =>
    d ? const Color(0xFF666666) : const Color(0xFF888888);
Color _cLine(bool d) => d ? const Color(0xFF333333) : const Color(0xFFCCCCCC);

// ═══════════════════════════════════════════════════════════════════
// MAIN SCREEN
// ═══════════════════════════════════════════════════════════════════
class ProfileDetailPallen extends StatefulWidget {
  const ProfileDetailPallen({super.key});
  @override
  State<ProfileDetailPallen> createState() => _ProfileDetailPallenState();
}

class _ProfileDetailPallenState extends State<ProfileDetailPallen>
    with TickerProviderStateMixin {
  // ── Page navigation state ────────────────────────────────────────
  // 0 = Home, 1 = About, 2 = Work, 3 = Contact
  int _currentPage = 0;

  // ── Dark / Light mode ────────────────────────────────────────────
  bool _isDark = true;

  // ── Entrance animation ───────────────────────────────────────────
  late final AnimationController _enter;
  late final Animation<double> _fade;
  late final Animation<Offset> _lift;

  void _open(String url) => html.window.open(url, '_blank');

  void _goPage(int i) => setState(() => _currentPage = i);

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _enter, curve: Curves.easeOut);
    _lift = Tween<Offset>(
      begin: const Offset(0, 0.025),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enter, curve: Curves.easeOut));
    _enter.forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  // ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return _PTheme(
      dark: _isDark,
      child: Scaffold(
        backgroundColor: _cBg(_isDark),
        body: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _lift,
            child: Stack(children: [
              // ── Animated page switcher ───────────────────────
              // Each section is a full-screen "page".
              // AnimatedSwitcher fades between pages on nav click.
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 380),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.025),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: KeyedSubtree(
                  key: ValueKey(_currentPage),
                  child: _buildPage(),
                ),
              ),

              // ── Fixed nav bar overlay ────────────────────────
              Positioned(top: 0, left: 0, right: 0, child: _navBar()),
            ]),
          ),
        ),
      ),
    );
  }

  // ── Page dispatcher ─────────────────────────────────────────────
  Widget _buildPage() {
    switch (_currentPage) {
      case 1:
        return _aboutPage();
      case 2:
        return _workPage();
      case 3:
        return _contactPage();
      default:
        return _homePage();
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // NAV BAR
  // ═══════════════════════════════════════════════════════════════
  Widget _navBar() {
    final d = _isDark;
    const labels = ['Home', 'About', 'Work', 'Contact'];
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: d
                ? const Color(0xFF080808).withOpacity(0.90)
                : Colors.white.withOpacity(0.90),
            border: Border(
              bottom: BorderSide(color: _cBorder(d), width: 1),
            ),
          ),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 10,
            bottom: 10,
            left: 28,
            right: 28,
          ),
          child: Row(children: [
            // Back button
            _NavGhostBtn(
              onTap: () => context.pop(),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.arrow_back_ios_new_rounded,
                    size: 12, color: _cBody(d)),
                const SizedBox(width: 6),
                Text('Back',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      color: _cBody(d),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    )),
              ]),
            ),
            const SizedBox(width: 20),

            // Wordmark
            Text('PALLEN · DEV',
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  color: _cHead(d),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                )),

            const Spacer(),

            // Nav tabs
            ...List.generate(
                labels.length,
                (i) => _NavTab(
                      label: labels[i],
                      active: _currentPage == i,
                      onTap: () => _goPage(i),
                    )),

            const SizedBox(width: 14),

            // Dark / Light mode toggle
            _DarkToggle(
              isDark: _isDark,
              onToggle: () => setState(() => _isDark = !_isDark),
            ),
          ]),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ① HOME PAGE — Full-screen hero
  // ═══════════════════════════════════════════════════════════════
  Widget _homePage() {
    final sh = MediaQuery.of(context).size.height;
    // ✅ FIX #1: Removed unused `sw` variable (was line 244)
    return Container(
      height: sh,
      color: _k03,
      child: Stack(children: [
        // BG photo
        Positioned.fill(
            child: Image.asset(
          'assets/images/pallen_bg.jpg',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: _k07),
        )),

        // Dark overlay
        Positioned.fill(
            child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xCC000000),
                Color(0xDD000000),
                Color(0xEE000000),
                Color(0xFF000000),
              ],
              stops: [0.0, 0.3, 0.65, 1.0],
            ),
          ),
        )),

        // Noise texture
        Positioned.fill(
            child: IgnorePointer(
          child: CustomPaint(painter: _NoisePainter()),
        )),

        // Left accent line
        Positioned(
          left: 56,
          top: 100,
          bottom: 100,
          child: Container(width: 1, color: _k18.withOpacity(0.6)),
        ),

        // Main content
        Positioned(
          left: 76,
          right: 76,
          bottom: sh * 0.12,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // ── LEFT: Identity ────────────────────────────────
              Expanded(
                  flex: 58,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _GlassChip('COMPUTER ENGINEER  ·  LAGUNA, PH'),
                      const SizedBox(height: 32),
                      const Text(
                        'Prince Dunhill',
                        style: TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          color: _k70,
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 4,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'PALLEN',
                        style: TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          color: _kWh,
                          fontSize: 82,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -4,
                          height: 0.88,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Full-Stack Developer & Embedded Systems Engineer\n'
                        'building technology that bridges hardware and software.',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          color: _k55,
                          fontSize: 15,
                          height: 1.65,
                        ),
                      ),
                      const SizedBox(height: 36),
                      Row(children: [
                        _CtaButton(
                          label: 'See My Work',
                          icon: Icons.work_outline_rounded,
                          filled: true,
                          onTap: () => _goPage(2),
                        ),
                        const SizedBox(width: 12),
                        _CtaButton(
                          label: 'Contact Me',
                          icon: Icons.mail_outline_rounded,
                          filled: false,
                          onTap: () => _goPage(3),
                        ),
                        const SizedBox(width: 12),
                        _CtaButton(
                          label: 'Resume',
                          icon: Icons.download_rounded,
                          filled: false,
                          onTap: () => _open(_kResume),
                        ),
                      ]),
                    ],
                  )),

              const SizedBox(width: 48),

              // ── RIGHT: Profile photo — SQUARE ──────────────────
              // ✅ CHANGED: BoxShape.circle → borderRadius square
              Expanded(
                  flex: 32,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          // ✅ Square with rounded corners (not circle)
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.15),
                              blurRadius: 40,
                              spreadRadius: 4,
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.06),
                              blurRadius: 70,
                              spreadRadius: 10,
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withOpacity(0.28),
                            width: 2.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/images/profile1.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                                color: _k10,
                                child: const Icon(Icons.person_rounded,
                                    color: _k40, size: 72)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Prince Dunhill Pallen',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          color: _k93,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      _AvailRow(),
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
                          _QuickStat('13', 'Languages'),
                          _QuickStat('3', 'CAD Tools'),
                          _QuickStat('1', 'Thesis'),
                        ],
                      ),
                    ],
                  )),
            ],
          ),
        ),

        Positioned(
            bottom: 20, left: 0, right: 0, child: Center(child: _ScrollCue())),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ② ABOUT PAGE — Full page with scroll
  // ═══════════════════════════════════════════════════════════════
  Widget _aboutPage() {
    final d = _isDark;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(children: [
        // Top padding for nav bar
        const SizedBox(height: 80),

        // Section body
        Container(
          color: _cBg(d),
          padding: const EdgeInsets.fromLTRB(76, 56, 76, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EyebrowLabel('01 — ABOUT ME'),
              const SizedBox(height: 8),
              Text(
                'The person behind the code.',
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  color: _cHead(d),
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 48),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // ── LEFT column ──────────────────────────────────
                Expanded(
                    flex: 44,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Square profile photo (About page repeat)
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _cBorder(d).withOpacity(0.7),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _cGlowLit(d),
                                blurRadius: 20,
                              )
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.asset(
                              'assets/images/profile1.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                  color: _cCard(d),
                                  child: Icon(Icons.person_rounded,
                                      color: _cIcon(d), size: 36)),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        Text(
                          'I\'m a Computer Engineering graduate with a passion '
                          'for building systems that make a tangible difference. '
                          'My journey began with a curiosity for how things work — '
                          'from the circuits on a PCB to the lines of code running '
                          'on a server.',
                          style: TextStyle(
                              fontFamily: 'DMSans',
                              color: _cBody(d),
                              fontSize: 14,
                              height: 1.85),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Today, I combine full-stack development with embedded '
                          'systems expertise. I\'m motivated by the challenge of '
                          'solving real-world problems — especially those that '
                          'improve accessibility and quality of life.',
                          style: TextStyle(
                              fontFamily: 'DMSans',
                              color: _cBody(d),
                              fontSize: 14,
                              height: 1.85),
                        ),

                        const SizedBox(height: 36),
                        _SubLabel('Education'),
                        const SizedBox(height: 14),

                        _HoverCard(
                          slideRight: true,
                          child: Row(children: [
                            _IconSquare(icon: Icons.school_rounded),
                            const SizedBox(width: 16),
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'BS in Computer Engineering',
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    color: _cCardText(d),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(children: [
                                  const Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 12,
                                    color: _kGreen,
                                  ),
                                  const SizedBox(width: 5),
                                  const Text('Graduate',
                                      style: TextStyle(
                                        fontFamily: 'DMSans',
                                        color: _kGreen,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      )),
                                ]),
                              ],
                            )),
                          ]),
                        ),

                        const SizedBox(height: 36),
                        _SubLabel('Values & Goals'),
                        const SizedBox(height: 14),

                        ...[
                          (
                            Icons.lightbulb_outline_rounded,
                            'Innovation',
                            'Creating technology that solves real problems.'
                          ),
                          (
                            Icons.handshake_outlined,
                            'Collaboration',
                            'Building systems that connect people and ideas.'
                          ),
                          (
                            Icons.trending_up_rounded,
                            'Growth',
                            'Continuously learning across hardware and software.'
                          ),
                        ].map((v) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _HoverCard(
                                slideRight: true,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: Row(children: [
                                  _IconSquare(icon: v.$1, size: 32),
                                  const SizedBox(width: 14),
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(v.$2,
                                          style: TextStyle(
                                            fontFamily: 'DMSans',
                                            color: _cCardText(d),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          )),
                                      const SizedBox(height: 2),
                                      Text(v.$3,
                                          style: TextStyle(
                                            fontFamily: 'DMSans',
                                            color: _cCardSub(d),
                                            fontSize: 11,
                                            height: 1.4,
                                          )),
                                    ],
                                  )),
                                ]),
                              ),
                            )),

                        const SizedBox(height: 36),
                        _SubLabel('Engineering Tools'),
                        const SizedBox(height: 14),

                        ...[
                          (
                            Icons.developer_board_rounded,
                            'KiCad',
                            'PCB Design & Schematic Layout'
                          ),
                          (
                            Icons.architecture_rounded,
                            'AutoCAD',
                            '3D Modeling & Technical Drawing'
                          ),
                          (
                            Icons.view_in_ar_rounded,
                            'Fusion 360',
                            '3D CAD Design & Simulation'
                          ),
                        ].map((t) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _HoverCard(
                                slideRight: true,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: Row(children: [
                                  _IconSquare(icon: t.$1, size: 34),
                                  const SizedBox(width: 14),
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(t.$2,
                                          style: TextStyle(
                                            fontFamily: 'DMSans',
                                            color: _cCardText(d),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          )),
                                      Text(t.$3,
                                          style: TextStyle(
                                            fontFamily: 'DMSans',
                                            color: _cCardSub(d),
                                            fontSize: 11,
                                          )),
                                    ],
                                  )),
                                ]),
                              ),
                            )),
                      ],
                    )),

                const SizedBox(width: 56),

                // ── RIGHT column: Language skills ─────────────────
                Expanded(
                    flex: 56,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SubLabel('Technical Skills'),
                        const SizedBox(height: 8),
                        Text(
                          'Languages, frameworks, and technologies I use daily.',
                          style: TextStyle(
                              fontFamily: 'DMSans',
                              color: _cBody(d),
                              fontSize: 13,
                              height: 1.5),
                        ),
                        const SizedBox(height: 28),
                        _SkillCategoryBlock(
                          label: 'Frontend',
                          items: const [
                            _LangItem('HTML', _LangKind.html),
                            _LangItem('CSS', _LangKind.css),
                            _LangItem('JavaScript', _LangKind.js),
                            _LangItem('Flutter', _LangKind.flutter),
                          ],
                        ),
                        const SizedBox(height: 28),
                        _SkillCategoryBlock(
                          label: 'Backend',
                          items: const [
                            _LangItem('Go', _LangKind.go),
                            _LangItem('Java', _LangKind.java),
                            _LangItem('Python', _LangKind.python),
                            _LangItem('C++', _LangKind.cpp),
                            _LangItem('C', _LangKind.c),
                          ],
                        ),
                        const SizedBox(height: 28),
                        _SkillCategoryBlock(
                          label: 'Database',
                          items: const [
                            _LangItem('PostgreSQL', _LangKind.postgres),
                            _LangItem('MySQL', _LangKind.mysql),
                          ],
                        ),
                        const SizedBox(height: 28),
                        _SkillCategoryBlock(
                          label: 'Low-Level / Other',
                          items: const [
                            _LangItem('Assembly Language', _LangKind.asm),
                            _LangItem('HDL', _LangKind.hdl),
                          ],
                        ),
                      ],
                    )),
              ]),
            ],
          ),
        ),

        _footerWidget(),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ③ WORK PAGE — Full page with scroll
  // ═══════════════════════════════════════════════════════════════
  Widget _workPage() {
    final d = _isDark;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(children: [
        const SizedBox(height: 80),
        Container(
          color: _cBg2(d),
          padding: const EdgeInsets.fromLTRB(76, 56, 76, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EyebrowLabel('02 — WORK & PROJECTS'),
              const SizedBox(height: 8),
              Text(
                'From concept to reality.',
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  color: _cHead(d),
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'A showcase of my most significant engineering project — '
                'designed, built, and documented from the ground up.',
                style: TextStyle(
                    fontFamily: 'DMSans',
                    color: _cBody(d),
                    fontSize: 14,
                    height: 1.6),
              ),

              const SizedBox(height: 52),

              // NAVIRA hero card
              _HoverCard(
                slideRight: true,
                padding: const EdgeInsets.all(36),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          _GlassChip('UNDERGRADUATE THESIS  ·  2025'),
                          const Spacer(),
                          _GlassChip('Embedded Systems'),
                        ]),
                        const SizedBox(height: 24),
                        const Text(
                          'NAVIRA',
                          style: TextStyle(
                            fontFamily: 'PlayfairDisplay',
                            color: _kWh,
                            fontSize: 64,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -2.5,
                            height: 0.88,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'An ESP32-Based Smart Blind Stick with Wireless\n'
                          'Armband Integration for Enhanced Mobility of\n'
                          'the Visually Impaired',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            color: _k70,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Wrap(spacing: 8, runSpacing: 6, children: [
                          _MetaBadge(
                              icon: Icons.person_outline_rounded,
                              text: 'Lead Designer & Developer'),
                          _MetaBadge(
                              icon: Icons.calendar_today_rounded, text: '2025'),
                          _MetaBadge(
                              icon: Icons.school_rounded,
                              text: 'BS Computer Engineering'),
                        ]),
                      ],
                    )),
                    const SizedBox(width: 32),
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: _cCard(d),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: _cBorder(d)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.06),
                            blurRadius: 24,
                          )
                        ],
                      ),
                      child: Icon(Icons.biotech_rounded,
                          color: _cIcon(d), size: 38),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // Role / Challenge / Outcome
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                    child: _RcoCard(
                  icon: Icons.manage_accounts_rounded,
                  title: 'My Role',
                  body: 'Led the complete development cycle — from circuit '
                      'design and PCB layout in KiCad, to firmware '
                      'programming in C++ on the ESP32, and integration '
                      'of the Bluetooth LE wireless armband module.',
                )),
                const SizedBox(width: 16),
                Expanded(
                    child: _RcoCard(
                  icon: Icons.psychology_rounded,
                  title: 'The Challenge',
                  body: 'Designing a reliable, real-time obstacle detection '
                      'system that works across varied environments while '
                      'keeping the device lightweight and affordable.',
                )),
                const SizedBox(width: 16),
                Expanded(
                    child: _RcoCard(
                  icon: Icons.emoji_events_rounded,
                  title: 'The Outcome',
                  body: 'A fully functional assistive device with sub-50ms '
                      'sensor response, 10m BLE range, and positive '
                      'usability feedback from test participants.',
                )),
              ]),

              const SizedBox(height: 44),
              _SubLabel('Project Deliverables'),
              const SizedBox(height: 20),

              // Deliverables row
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // 3D Model
                Expanded(
                    child: _HoverCard(
                  slideRight: false,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        _IconSquare(icon: Icons.view_in_ar_rounded),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text('3D Model Design',
                                style: TextStyle(
                                    fontFamily: 'DMSans',
                                    color: _cCardText(d),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700))),
                      ]),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 120,
                          color: _cBg3(d),
                          child: Stack(children: [
                            Center(
                                child: CustomPaint(
                              size: const Size(80, 80),
                              painter: _ThreeDBoxPainter(),
                            )),
                            Positioned(
                              bottom: 8,
                              left: 10,
                              child: Text('Fusion 360 · AutoCAD',
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    color: _cMuted(d),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                  )),
                            ),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Designed the stick housing and armband enclosure '
                        'using Fusion 360 and AutoCAD for ergonomic fit.',
                        style: TextStyle(
                            fontFamily: 'DMSans',
                            color: _cCardSub(d),
                            fontSize: 11,
                            height: 1.6),
                      ),
                    ],
                  ),
                )),

                const SizedBox(width: 16),

                // PCB Design
                Expanded(
                    child: _HoverCard(
                  slideRight: false,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        _IconSquare(icon: Icons.developer_board_rounded),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text('Device Design',
                                style: TextStyle(
                                    fontFamily: 'DMSans',
                                    color: _cCardText(d),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700))),
                      ]),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 120,
                          color: _cBg3(d),
                          child: Stack(children: [
                            Center(
                                child: CustomPaint(
                              size: const Size(100, 70),
                              painter: _PcbPainter(),
                            )),
                            Positioned(
                              bottom: 8,
                              left: 10,
                              child: Text('KiCad  ·  ESP32',
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    color: _cMuted(d),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                  )),
                            ),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Schematic capture and PCB layout in KiCad. '
                        'ESP32 with ultrasonic, IR sensors and BLE module.',
                        style: TextStyle(
                            fontFamily: 'DMSans',
                            color: _cCardSub(d),
                            fontSize: 11,
                            height: 1.6),
                      ),
                    ],
                  ),
                )),

                const SizedBox(width: 16),

                // Research Paper
                Expanded(
                    child: _HoverCard(
                  slideRight: false,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        _IconSquare(icon: Icons.menu_book_rounded),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text('Research Paper',
                                style: TextStyle(
                                    fontFamily: 'DMSans',
                                    color: _cCardText(d),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700))),
                      ]),
                      const SizedBox(height: 14),
                      Container(
                        height: 120,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _cBg3(d),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            'Theoretical Framework',
                            'Review of Related Literature',
                            'Flow Chart & Methodology',
                            'Project Benefits',
                            'Recommendation',
                          ]
                              .map((s) => Row(children: [
                                    Container(
                                        width: 4,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: _cMuted(d),
                                          shape: BoxShape.circle,
                                        )),
                                    const SizedBox(width: 8),
                                    Text(s,
                                        style: TextStyle(
                                          fontFamily: 'DMSans',
                                          color: _cBody(d),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        )),
                                  ]))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Full academic paper: design rationale, '
                        'literature review, methodology, and outcomes.',
                        style: TextStyle(
                            fontFamily: 'DMSans',
                            color: _cCardSub(d),
                            fontSize: 11,
                            height: 1.6),
                      ),
                    ],
                  ),
                )),
              ]),

              const SizedBox(height: 28),

              // Tech stack
              Row(children: [
                Text('TECH STACK',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      color: _cMuted(d),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.5,
                    )),
                const SizedBox(width: 16),
                Container(height: 1, width: 24, color: _cLine(d)),
                const SizedBox(width: 16),
                Wrap(spacing: 8, runSpacing: 6, children: const [
                  _GrayPill('ESP32'),
                  _GrayPill('C++'),
                  _GrayPill('Bluetooth LE'),
                  _GrayPill('Ultrasonic Sensors'),
                  _GrayPill('IR Proximity'),
                  _GrayPill('KiCad'),
                  _GrayPill('Fusion 360'),
                  _GrayPill('RTOS'),
                ]),
              ]),
            ],
          ),
        ),
        _footerWidget(),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ④ CONTACT PAGE — Full page with scroll
  // ═══════════════════════════════════════════════════════════════
  Widget _contactPage() {
    final d = _isDark;
    final contacts = [
      _ContactData(
          kind: _ContactKind.facebook,
          platform: 'Facebook',
          handle: 'Dunhill Pallen',
          detail: 'facebook.com/dnhll.plln',
          url: _kFacebook),
      _ContactData(
          kind: _ContactKind.github,
          platform: 'GitHub',
          handle: 'Dunh1ll',
          detail: 'github.com/Dunh1ll',
          url: _kGitHub),
      _ContactData(
          kind: _ContactKind.gmail,
          platform: 'Gmail',
          handle: 'cpe.pallen.princedunhill@gmail.com',
          detail: 'cpe.pallen.princedunhill@gmail.com',
          url: _kGmail),
      _ContactData(
          kind: _ContactKind.linkedin,
          platform: 'LinkedIn',
          handle: 'Prince Dunhill Pallen',
          detail: 'linkedin.com/in/pallen-prince-dunhill',
          url: _kLinkedIn),
      _ContactData(
          kind: _ContactKind.instagram,
          platform: 'Instagram',
          handle: '@nturdanii',
          detail: 'instagram.com/nturdanii',
          url: _kInstagram),
      _ContactData(
          kind: _ContactKind.phone,
          platform: 'Mobile',
          handle: '0950 464 7074',
          detail: 'Philippines',
          url: _kPhone),
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(children: [
        const SizedBox(height: 80),
        Container(
          color: _cBg(d),
          padding: const EdgeInsets.fromLTRB(76, 56, 76, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EyebrowLabel("03 — CONTACT"),
              const SizedBox(height: 8),
              Text(
                "Let's work together.",
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  color: _cHead(d),
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 52),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // LEFT: intro
                Expanded(
                    flex: 36,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Open to full-time opportunities, freelance projects, '
                          'and interesting collaborations. Whether you have a '
                          'question or just want to say hi — my inbox is open.',
                          style: TextStyle(
                              fontFamily: 'DMSans',
                              color: _cBody(d),
                              fontSize: 14,
                              height: 1.8),
                        ),
                        const SizedBox(height: 28),
                        _HoverCard(
                          slideRight: true,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 14),
                          child: Row(children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: _cBg3(d),
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(color: _cBorder(d)),
                              ),
                              child: Icon(Icons.timer_outlined,
                                  color: _cIcon(d), size: 17),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Response Time',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      color: _cCardText(d),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    )),
                                const SizedBox(height: 2),
                                Text('I typically reply within 48 hours.',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      color: _cCardSub(d),
                                      fontSize: 11,
                                    )),
                              ],
                            )),
                          ]),
                        ),
                        const SizedBox(height: 12),
                        _HoverCard(
                          slideRight: true,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 14),
                          child: Row(children: [
                            _IconSquare(
                                icon: Icons.location_on_outlined, size: 36),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Location',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      color: _cCardText(d),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    )),
                                const SizedBox(height: 2),
                                Text('Philippines  ·  Remote & On-site',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      color: _cCardSub(d),
                                      fontSize: 11,
                                    )),
                              ],
                            ),
                          ]),
                        ),
                        const SizedBox(height: 28),
                        _CtaButton(
                          label: 'Send an Email',
                          icon: Icons.mail_outline_rounded,
                          filled: true,
                          onTap: () => _open(_kGmail),
                        ),
                      ],
                    )),

                const SizedBox(width: 64),

                // RIGHT: contact grid (2 columns)
                Expanded(
                    flex: 64,
                    child: Column(
                      children: [
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 3.2,
                          ),
                          itemCount: contacts.length,
                          itemBuilder: (_, i) => _ContactCard(
                            data: contacts[i],
                            onTap: () => _open(contacts[i].url),
                          ),
                        ),
                      ],
                    )),
              ]),
            ],
          ),
        ),
        _footerWidget(),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // FOOTER
  // ═══════════════════════════════════════════════════════════════
  Widget _footerWidget() {
    final d = _isDark;
    return Container(
      color: _cBg2(d),
      padding: const EdgeInsets.symmetric(horizontal: 76, vertical: 44),
      child: Column(children: [
        Divider(color: _cLine(d), height: 1),
        const SizedBox(height: 28),
        Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('PALLEN  ·  DEV',
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  color: _cHead(d),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                )),
            const SizedBox(height: 5),
            Text('Prince Dunhill Pallen  ·  Computer Engineer',
                style: TextStyle(
                    fontFamily: 'DMSans', color: _cMuted(d), fontSize: 11)),
          ]),
          const Spacer(),
          Text('© 2025  ·  All rights reserved.',
              style: TextStyle(
                  fontFamily: 'DMSans', color: _cMuted(d), fontSize: 11)),
        ]),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// DARK / LIGHT TOGGLE BUTTON
// Pill-shaped toggle with sun/moon icon slide animation.
// ═══════════════════════════════════════════════════════════════════
class _DarkToggle extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggle;
  const _DarkToggle({required this.isDark, required this.onToggle});
  @override
  State<_DarkToggle> createState() => _DarkToggleState();
}

class _DarkToggleState extends State<_DarkToggle> {
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
                ? (d ? _k25 : const Color(0xFFBBBBBB))
                : (d ? _k18 : const Color(0xFFCCCCCC)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _h ? _k40 : _k25,
              width: 1,
            ),
          ),
          child: Stack(children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              // ← dark = thumb on left, light = thumb on right
              left: d ? 3 : 25,
              top: 3,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: d ? _k55 : const Color(0xFFFFFFFF),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                    )
                  ],
                ),
                child: Icon(
                  d ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                  size: 12,
                  color: d ? _k93 : const Color(0xFFF59E0B),
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
// LANGUAGE LOGO SYSTEM
//
// ✅ FIX: Added real brand colors per language.
// Each logo renders with the correct brand color background
// and a matching colored icon/shape inside.
//
// ✅ FIX #2: Removed `{super.key}` from _LangLogo constructor
// (parameter was never passed externally).
// ═══════════════════════════════════════════════════════════════════

enum _LangKind {
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

class _LangItem {
  final String name;
  final _LangKind kind;
  const _LangItem(this.name, this.kind);
}

/// Brand colors per language
Color _langBrand(_LangKind k) {
  switch (k) {
    case _LangKind.html:
      return const Color(0xFFE34F26);
    case _LangKind.css:
      return const Color(0xFF1572B6);
    case _LangKind.js:
      return const Color(0xFFF7DF1E);
    case _LangKind.flutter:
      return const Color(0xFF54C5F8);
    case _LangKind.go:
      return const Color(0xFF00ACD7);
    case _LangKind.java:
      return const Color(0xFFED8B00);
    case _LangKind.python:
      return const Color(0xFF3776AB);
    case _LangKind.cpp:
      return const Color(0xFF00599C);
    case _LangKind.c:
      return const Color(0xFFA8B9CC);
    case _LangKind.postgres:
      return const Color(0xFF336791);
    case _LangKind.mysql:
      return const Color(0xFF4479A1);
    case _LangKind.asm:
      return const Color(0xFF9D4EDD);
    case _LangKind.hdl:
      return const Color(0xFF7C3AED);
  }
}

/// Language logo widget — colored background + recognizable shape
class _LangLogo extends StatelessWidget {
  final _LangKind kind;
  // ✅ FIX #2: Removed `{super.key}` — was never passed
  const _LangLogo(this.kind);

  @override
  Widget build(BuildContext context) {
    final color = _langBrand(kind);
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.35), width: 1),
      ),
      child: CustomPaint(
        painter: _LangLogoPainter(kind, color),
      ),
    );
  }
}

class _LangLogoPainter extends CustomPainter {
  final _LangKind kind;
  final Color brand;
  const _LangLogoPainter(this.kind, this.brand);

  Paint get _stroke => Paint()
    ..color = brand
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  Paint get _fill => Paint()
    ..color = brand
    ..style = PaintingStyle.fill;

  Paint get _bg => Paint()
    ..color = brand.withOpacity(0.08)
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height / 2;

    switch (kind) {
      case _LangKind.html:
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

      case _LangKind.css:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              const Rect.fromLTWH(4, 4, 20, 20), const Radius.circular(3)),
          _stroke..strokeWidth = 1.3,
        );
        _drawText(canvas, '3', Offset(cx - 4, cy - 6), 11);
        break;

      case _LangKind.js:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              const Rect.fromLTWH(3, 3, 22, 22), const Radius.circular(3)),
          _fill..color = brand.withOpacity(0.25),
        );
        _drawText(canvas, 'JS', Offset(cx - 8, cy - 7), 10);
        break;

      case _LangKind.flutter:
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

      case _LangKind.go:
        canvas.drawCircle(Offset(cx, cy), 9.5, _stroke..strokeWidth = 1.5);
        _drawText(canvas, 'Go', Offset(cx - 7, cy - 6), 9.5);
        break;

      case _LangKind.java:
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
        canvas.drawLine(const Offset(11, 4), const Offset(10, 7),
            _stroke..strokeWidth = 1.0);
        canvas.drawLine(const Offset(15, 4), const Offset(14, 7),
            _stroke..strokeWidth = 1.0);
        break;

      case _LangKind.python:
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

      case _LangKind.cpp:
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

      case _LangKind.c:
        canvas.drawArc(
          Rect.fromCircle(center: Offset(cx, cy), radius: 9),
          0.6,
          math.pi * 1.6,
          false,
          _stroke..strokeWidth = 2.0,
        );
        break;

      case _LangKind.postgres:
        canvas.drawOval(
          const Rect.fromLTWH(5, 4, 18, 16),
          _stroke..strokeWidth = 1.5,
        );
        final trunk = Path()
          ..moveTo(11, 20)
          ..quadraticBezierTo(9, 26, 13, 27);
        canvas.drawPath(trunk, _stroke..strokeWidth = 1.5);
        canvas.drawCircle(const Offset(11, 10), 1.5, _fill);
        canvas.drawCircle(const Offset(21, 6), 3, _stroke..strokeWidth = 1.2);
        break;

      case _LangKind.mysql:
        canvas.drawArc(
          Rect.fromCircle(center: Offset(cx, cy - 1), radius: 9),
          math.pi * 1.1,
          math.pi * 1.4,
          false,
          _stroke..strokeWidth = 1.8,
        );
        final fin = Path()
          ..moveTo(cx + 6, cy - 5)
          ..lineTo(cx + 10, cy - 10)
          ..lineTo(cx + 9, cy - 4);
        canvas.drawPath(fin, _stroke..strokeWidth = 1.2);
        _drawText(canvas, 'My', Offset(cx - 7, cy + 2), 8.5);
        break;

      case _LangKind.asm:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              const Rect.fromLTWH(7, 7, 14, 14), const Radius.circular(2)),
          _stroke..strokeWidth = 1.4,
        );
        for (double y = 10; y <= 18; y += 4) {
          canvas.drawLine(
              Offset(4, y), Offset(7, y), _stroke..strokeWidth = 1.1);
          canvas.drawLine(
              Offset(21, y), Offset(24, y), _stroke..strokeWidth = 1.1);
        }
        break;

      case _LangKind.hdl:
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
          fontFamily: 'DMSans',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_LangLogoPainter o) => o.kind != kind || o.brand != brand;
}

// ═══════════════════════════════════════════════════════════════════
// SKILL CATEGORY BLOCK
// Groups language badges under a category label
// ═══════════════════════════════════════════════════════════════════
class _SkillCategoryBlock extends StatelessWidget {
  final String label;
  final List<_LangItem> items;
  const _SkillCategoryBlock({required this.label, required this.items});

  @override
  Widget build(BuildContext context) {
    final d = _PTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: TextStyle(
              fontFamily: 'DMSans',
              color: _cEyebrow(d),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.5,
            )),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) => _LangBadge(item: item)).toList(),
        ),
      ],
    );
  }
}

/// Language badge — colored logo left + name right
/// ✅ FIX #3: `super.key` kept (named param pattern is fine here)
class _LangBadge extends StatefulWidget {
  final _LangItem item;
  const _LangBadge({required this.item, super.key});

  @override
  State<_LangBadge> createState() => _LangBadgeState();
}

class _LangBadgeState extends State<_LangBadge> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    final d = _PTheme.of(context);
    final brand = _langBrand(widget.item.kind);

    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.only(left: 6, right: 12, top: 6, bottom: 6),
        decoration: BoxDecoration(
          // ✅ FIX: Solid card bg for readable text on hover
          color: _hov ? _cCardH(d) : _cCard(d),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _hov ? brand.withOpacity(0.55) : _cCardBorder(d),
            width: _hov ? 1.5 : 1,
          ),
          boxShadow: _hov
              ? [
                  BoxShadow(
                    color: brand.withOpacity(0.20),
                    blurRadius: 14,
                  )
                ]
              : [],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          // Colored logo on the LEFT
          _LangLogo(widget.item.kind),
          const SizedBox(width: 9),
          // ✅ FIX: Text always readable — solid card bg
          Text(widget.item.name,
              style: TextStyle(
                fontFamily: 'DMSans',
                color: _cCardText(d), // always readable
                fontSize: 12,
                fontWeight: FontWeight.w600,
              )),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// HOVER CARD
//
// ✅ FIX #4: Removed `onTap` optional param — was never passed.
// ✅ FIX: Background uses SOLID colors for text contrast.
//   Dark mode: _cCard (dark solid) → _cCardH (slightly lighter)
//   Light mode: _cCard (white) → _cCardH (light gray)
//   This ensures text is always readable regardless of glow.
// ═══════════════════════════════════════════════════════════════════
class _HoverCard extends StatefulWidget {
  final Widget child;
  final bool slideRight;
  final EdgeInsets padding;
  // ✅ FIX #4: `onTap` removed — was never used
  const _HoverCard({
    required this.child,
    required this.slideRight,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
  });

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _hov = false;

  Offset get _offset => _hov
      ? (widget.slideRight ? const Offset(8, 0) : const Offset(0, -5))
      : Offset.zero;

  @override
  Widget build(BuildContext context) {
    final d = _PTheme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(_offset.dx, _offset.dy, 0),
        decoration: BoxDecoration(
          // ✅ FIX: Solid backgrounds for readable text
          color: _hov ? _cCardH(d) : _cCard(d),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _hov ? _cCardBorderH(d) : _cCardBorder(d),
            width: _hov ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              // White glow in dark mode, dark shadow in light
              color: _hov ? _cGlowLit(d) : _cGlowDim(d),
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
// CONTACT CARD
// ✅ FIX #5: Removed `super.key` — was never passed
// ═══════════════════════════════════════════════════════════════════
enum _ContactKind { facebook, github, gmail, linkedin, instagram, phone }

class _ContactData {
  final _ContactKind kind;
  final String platform, handle, detail, url;
  const _ContactData({
    required this.kind,
    required this.platform,
    required this.handle,
    required this.detail,
    required this.url,
  });
}

class _ContactCard extends StatefulWidget {
  final _ContactData data;
  final VoidCallback onTap;
  // ✅ FIX #5: Removed `super.key`
  const _ContactCard({required this.data, required this.onTap});

  @override
  State<_ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<_ContactCard> {
  bool _hov = false;

  IconData get _icon {
    switch (widget.data.kind) {
      case _ContactKind.facebook:
        return Icons.people_alt_rounded;
      case _ContactKind.github:
        return Icons.terminal_rounded;
      case _ContactKind.gmail:
        return Icons.alternate_email_rounded;
      case _ContactKind.linkedin:
        return Icons.work_outline_rounded;
      case _ContactKind.instagram:
        return Icons.camera_alt_outlined;
      case _ContactKind.phone:
        return Icons.phone_iphone_rounded;
    }
  }

  Color get _brandColor {
    switch (widget.data.kind) {
      case _ContactKind.facebook:
        return const Color(0xFF1877F2);
      case _ContactKind.github:
        return const Color(0xFF6E40C9);
      case _ContactKind.gmail:
        return const Color(0xFFEA4335);
      case _ContactKind.linkedin:
        return const Color(0xFF0077B5);
      case _ContactKind.instagram:
        return const Color(0xFFE4405F);
      case _ContactKind.phone:
        return const Color(0xFF4ADE80);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = _PTheme.of(context);
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
            // ✅ FIX: Solid card background for visible text
            color: _hov ? _cCardH(d) : _cCard(d),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hov ? brand.withOpacity(0.55) : _cCardBorder(d),
              width: _hov ? 1.5 : 1,
            ),
            boxShadow: _hov
                ? [
                    BoxShadow(
                      color: brand.withOpacity(0.18),
                      blurRadius: 16,
                    )
                  ]
                : [],
          ),
          child: Row(children: [
            // Brand-colored icon badge
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
                      color: _cEyebrow(d),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    )),
                const SizedBox(height: 2),
                Text(widget.data.handle,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      // ✅ FIX: Always readable solid text
                      color: _cCardText(d),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    )),
              ],
            )),
            Icon(Icons.open_in_new_rounded,
                size: 12, color: _hov ? brand : _cMuted(d)),
          ]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// NAV GHOST BUTTON
// ═══════════════════════════════════════════════════════════════════
class _NavGhostBtn extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _NavGhostBtn({required this.child, required this.onTap});
  @override
  State<_NavGhostBtn> createState() => _NavGhostBtnState();
}

class _NavGhostBtnState extends State<_NavGhostBtn> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    final d = _PTheme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: _h ? _cCard(d) : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _h ? _cBorderH(d) : Colors.transparent),
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
class _NavTab extends StatefulWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavTab(
      {required this.label, required this.active, required this.onTap});
  @override
  State<_NavTab> createState() => _NavTabState();
}

class _NavTabState extends State<_NavTab> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    final d = _PTheme.of(context);
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
            color: lit ? _cCard(d) : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: lit ? _cCardBorderH(d) : Colors.transparent,
            ),
          ),
          child: Text(widget.label,
              style: TextStyle(
                fontFamily: 'DMSans',
                // ✅ Always readable text on card background
                color: lit ? _cCardText(d) : _cBody(d),
                fontSize: 12,
                fontWeight: lit ? FontWeight.w700 : FontWeight.w400,
              )),
        ),
      ),
    );
  }
}

// ✅ FIX #6 & #7: _GlassCard class REMOVED — was never referenced

// ═══════════════════════════════════════════════════════════════════
// GLASS CHIP (transparent pill with blur)
// ═══════════════════════════════════════════════════════════════════
class _GlassChip extends StatelessWidget {
  final String text;
  const _GlassChip(this.text);
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
                  color: _k70,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                )),
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
// EYEBROW LABEL (section numbered header)
// ═══════════════════════════════════════════════════════════════════
class _EyebrowLabel extends StatelessWidget {
  final String label;
  const _EyebrowLabel(this.label);
  @override
  Widget build(BuildContext context) {
    final d = _PTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
              fontFamily: 'DMSans',
              color: _cEyebrow(d),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 3.5,
            )),
        const SizedBox(height: 8),
        Container(width: 40, height: 1, color: _cLine(d)),
        const SizedBox(height: 20),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// SUB-SECTION LABEL
// ═══════════════════════════════════════════════════════════════════
class _SubLabel extends StatelessWidget {
  final String text;
  const _SubLabel(this.text);
  @override
  Widget build(BuildContext context) {
    final d = _PTheme.of(context);
    return Text(text,
        style: TextStyle(
          fontFamily: 'PlayfairDisplay',
          color: _cHead(d),
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ));
  }
}

// ═══════════════════════════════════════════════════════════════════
// ICON SQUARE (rounded icon badge)
// ═══════════════════════════════════════════════════════════════════
class _IconSquare extends StatelessWidget {
  final IconData icon;
  final double size;
  const _IconSquare({required this.icon, this.size = 38});
  @override
  Widget build(BuildContext context) {
    final d = _PTheme.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _cBg3(d),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: _cBorder(d)),
      ),
      child: Icon(icon, color: _cIcon(d), size: size * 0.46),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// RCO CARD (Role / Challenge / Outcome)
// ═══════════════════════════════════════════════════════════════════
class _RcoCard extends StatelessWidget {
  final IconData icon;
  final String title, body;
  const _RcoCard({required this.icon, required this.title, required this.body});
  @override
  Widget build(BuildContext context) {
    final d = _PTheme.of(context);
    return _HoverCard(
      slideRight: false,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconSquare(icon: icon),
          const SizedBox(height: 12),
          Text(title,
              style: TextStyle(
                fontFamily: 'DMSans',
                color: _cCardText(d),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: 8),
          Text(body,
              style: TextStyle(
                fontFamily: 'DMSans',
                color: _cCardSub(d),
                fontSize: 11.5,
                height: 1.65,
              )),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// META BADGE (project metadata pill)
// ═══════════════════════════════════════════════════════════════════
class _MetaBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaBadge({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    final d = _PTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _cBg3(d),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _cBorder(d)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: _cBody(d)),
        const SizedBox(width: 6),
        Text(text,
            style: TextStyle(
              fontFamily: 'DMSans',
              color: _cBody(d),
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
            )),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// CTA BUTTON (filled or outlined)
// ═══════════════════════════════════════════════════════════════════
class _CtaButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;
  const _CtaButton(
      {required this.label,
      required this.icon,
      required this.filled,
      required this.onTap});
  @override
  State<_CtaButton> createState() => _CtaButtonState();
}

class _CtaButtonState extends State<_CtaButton> {
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
                  ? (_h ? _k85 : _k98)
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
                        color: Colors.white.withOpacity(0.25),
                        blurRadius: 20,
                      )
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, size: 14, color: widget.filled ? _k00 : _k70),
                const SizedBox(width: 8),
                Text(widget.label,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      color: widget.filled ? _k00 : _k70,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    )),
              ],
            ),
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
// QUICK STAT CHIP (hero section)
// ═══════════════════════════════════════════════════════════════════
class _QuickStat extends StatelessWidget {
  final String value, label;
  const _QuickStat(this.value, this.label);
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
                color: _k98,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.0,
              )),
          Text(label,
              style: const TextStyle(
                fontFamily: 'DMSans',
                color: _k40,
                fontSize: 9,
              )),
        ]),
      );
}

// ═══════════════════════════════════════════════════════════════════
// GRAY PILL (tech stack list)
// ═══════════════════════════════════════════════════════════════════
class _GrayPill extends StatelessWidget {
  final String label;
  const _GrayPill(this.label);
  @override
  Widget build(BuildContext context) {
    final d = _PTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: _cBg3(d),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cBorder(d)),
      ),
      child: Text(label,
          style: TextStyle(
            fontFamily: 'DMSans',
            color: _cBody(d),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          )),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// ANIMATED AVAILABILITY DOT ROW
// ═══════════════════════════════════════════════════════════════════
class _AvailRow extends StatefulWidget {
  @override
  State<_AvailRow> createState() => _AvailRowState();
}

class _AvailRowState extends State<_AvailRow>
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
              color: _kGreen.withOpacity(0.5 + 0.5 * _a.value),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _kGreen.withOpacity(0.4 * _a.value),
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
                color: _kGreen,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              )),
        ]),
      );
}

// ═══════════════════════════════════════════════════════════════════
// SCROLL CUE (animated bounce arrow)
// ═══════════════════════════════════════════════════════════════════
class _ScrollCue extends StatefulWidget {
  @override
  State<_ScrollCue> createState() => _ScrollCueState();
}

class _ScrollCueState extends State<_ScrollCue>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _y;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
    _y = Tween<double>(begin: 0, end: 10)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _y,
        builder: (_, __) => Transform.translate(
          offset: Offset(0, _y.value),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('SCROLL',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    color: _k25,
                    fontSize: 8.5,
                    letterSpacing: 3.5,
                    fontWeight: FontWeight.w700,
                  )),
              SizedBox(height: 6),
              Icon(Icons.keyboard_arrow_down_rounded, color: _k25, size: 20),
            ],
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
// CUSTOM PAINTERS
// ═══════════════════════════════════════════════════════════════════

class _NoisePainter extends CustomPainter {
  static final _rng = math.Random(42);
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 3200; i++) {
      p.color = Colors.white.withOpacity(_rng.nextDouble() * 0.025);
      canvas.drawCircle(
        Offset(_rng.nextDouble() * s.width, _rng.nextDouble() * s.height),
        0.6,
        p,
      );
    }
  }

  @override
  bool shouldRepaint(_NoisePainter _) => false;
}

class _ThreeDBoxPainter extends CustomPainter {
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
  bool shouldRepaint(_ThreeDBoxPainter _) => false;
}

class _PcbPainter extends CustomPainter {
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
            center: Offset(s.width / 2, s.height / 2), width: 28, height: 20),
        const Radius.circular(2),
      ),
      Paint()
        ..color = const Color(0xFF303030)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_PcbPainter _) => false;
}

// lib/screens/pallen_profile/profile_detail_pallen.dart
//
// FOLDER STRUCTURE:
//   lib/screens/pallen_profile/
//     ├── profile_detail_pallen.dart  ← this file (shell + nav)
//     ├── pallen_theme.dart           ← colors, PTheme, constants
//     ├── pallen_widgets.dart         ← all shared widgets & painters
//     ├── pallen_home_page.dart       ← Home page
//     ├── pallen_about_page.dart      ← About page
//     ├── pallen_work_page.dart       ← Work page
//     └── pallen_contact_page.dart    ← Contact page

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
import 'pallen_contact_page.dart';

class ProfileDetailPallen extends StatefulWidget {
  const ProfileDetailPallen({super.key});
  @override
  State<ProfileDetailPallen> createState() => _ProfileDetailPallenState();
}

class _ProfileDetailPallenState extends State<ProfileDetailPallen>
    with TickerProviderStateMixin {
  // 0=Home 1=About 2=Work 3=Contact
  int _currentPage = 0;
  bool _isDark = true;

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

  @override
  Widget build(BuildContext context) {
    return PTheme(
      dark: _isDark,
      child: Scaffold(
        backgroundColor: pBg(_isDark),
        body: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _lift,
            child: Stack(children: [
              // Page switcher
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

              // Fixed nav bar
              Positioned(top: 0, left: 0, right: 0, child: _navBar()),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildPage() {
    final footer = _footerWidget();
    switch (_currentPage) {
      case 1:
        return PallenAboutPage(footer: footer);
      case 2:
        return PallenWorkPage(footer: footer);
      case 3:
        return PallenContactPage(onOpen: _open, footer: footer);
      default:
        return PallenHomePage(
          onGoWork: () => _goPage(2),
          onGoContact: () => _goPage(3),
          onOpen: _open,
        );
    }
  }

  // ── NAV BAR ────────────────────────────────────────────────────
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
              bottom: BorderSide(color: pBorder(d), width: 1),
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
            PallenNavGhostBtn(
              onTap: () => context.pop(),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.arrow_back_ios_new_rounded,
                    size: 12, color: pBody(d)),
                const SizedBox(width: 6),
                Text('Back',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      color: pBody(d),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    )),
              ]),
            ),
            const SizedBox(width: 20),

            // Wordmark
            Text('PALLEN PROFILE',
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  color: pHead(d),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                )),

            const Spacer(),

            // Nav tabs
            ...List.generate(
              labels.length,
              (i) => PallenNavTab(
                label: labels[i],
                active: _currentPage == i,
                onTap: () => _goPage(i),
              ),
            ),

            const SizedBox(width: 14),

            // Dark / Light toggle
            PallenDarkToggle(
              isDark: _isDark,
              onToggle: () => setState(() => _isDark = !_isDark),
            ),
          ]),
        ),
      ),
    );
  }

  // ── FOOTER ─────────────────────────────────────────────────────
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
            Text('PALLEN ',
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

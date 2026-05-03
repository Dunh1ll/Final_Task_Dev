import 'dart:async';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'navbar.dart';
import 'home_page.dart';
import 'about_page.dart';
import 'projects_page.dart';
import 'experience_page.dart';
import 'contact_page.dart';
import 'utilities.dart';

class ProfileDetailKarl extends StatefulWidget {
  const ProfileDetailKarl({super.key});
  @override
  State<ProfileDetailKarl> createState() => _RootState();
}

class _RootState extends State<ProfileDetailKarl>
    with SingleTickerProviderStateMixin {
  KTab _tab = KTab.home;
  late AnimationController _ctrl;
  late Animation<double> _fade;

  // Typing animation
  final _roles = [
    'things for mobile.',
    'scalable backends.',
    'clean interfaces.',
    'digital experiences.',
  ];
  int _ri = 0;
  String _typed = '';
  bool _del = false;
  Timer? _tmr;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 1200), _type);
  }

  void _type() {
    _tmr = Timer.periodic(const Duration(milliseconds: 72), (_) {
      if (!mounted) return;
      final t = _roles[_ri];
      setState(() {
        if (!_del) {
          if (_typed.length < t.length) {
            _typed = t.substring(0, _typed.length + 1);
          } else {
            Future.delayed(const Duration(milliseconds: 1400), () {
              if (mounted) setState(() => _del = true);
            });
          }
        } else {
          if (_typed.isNotEmpty) {
            _typed = _typed.substring(0, _typed.length - 1);
          } else {
            _del = false;
            _ri = (_ri + 1) % _roles.length;
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _tmr?.cancel();
    super.dispose();
  }

  void _go(KTab t) {
    if (t == _tab) return;
    _ctrl.reverse().then((_) {
      setState(() => _tab = t);
      _ctrl.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      backgroundColor: KC.bg,
      body: Stack(
        children: [
          // ── Background navy base ─────────────────────────────
          Positioned.fill(
            child: Container(color: KC.bg),
          ),

          // ── Subtle grain texture ─────────────────────────────
          Positioned.fill(
            child: IgnorePointer(child: KGrain()),
          ),

          // ── Very subtle top-right glow ───────────────────────
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: KC.mint.withOpacity(0.025),
                    blurRadius: 200,
                    spreadRadius: 80,
                  ),
                ],
              ),
            ),
          ),

          // ── Main content ─────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                KNavBar(tab: _tab, onTab: _go, isWide: isWide),
                Expanded(
                  child: FadeTransition(
                    opacity: _fade,
                    child: _page(isWide),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _page(bool w) {
    switch (_tab) {
      case KTab.home:
        return KHomePage(
          typed: _typed,
          isWide: w,
          onContact: () => _go(KTab.contact),
          onProjects: () => _go(KTab.projects),
        );
      case KTab.about:
        return KAboutPage(isWide: w);
        case KTab.experience:
      return KExperiencePage(isWide: w);
      case KTab.projects:
        return KProjectsPage(isWide: w);
      case KTab.contact:
        return KContactPage(isWide: w);
    }
  }
}
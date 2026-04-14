import 'dart:async';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'navbar.dart';
import 'home_page.dart';
import 'about_page.dart';
import 'projects_page.dart';
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

  final _roles = [
    "Flutter Developer",
    "UI/UX Enthusiast",
    "IS Student",
    "Backend Explorer",
  ];
  int _ri = 0;
  String _typed = "";
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
    Future.delayed(const Duration(milliseconds: 500), _type);
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
            Future.delayed(const Duration(milliseconds: 1200), () {
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
    final isWide = MediaQuery.of(context).size.width > 700;
    return Scaffold(
      backgroundColor: _C.bg,
      body: Stack(children: [
        Positioned.fill(
          child: Image.asset(
            "assets/images/background2.jpg",
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: Container(color: _C.bg.withOpacity(0.55)),
        ),
        Positioned.fill(child: KGrain()),
        Positioned(top: -80, left: -60,
          child: KGlow(color: _C.amber.withOpacity(0.07), size: 300)),
        Positioned(top: 300, right: -80,
          child: KGlow(color: _C.purple.withOpacity(0.06), size: 240)),
        SafeArea(child: Column(children: [
          KNavBar(tab: _tab, onTab: _go, isWide: isWide),
          Expanded(child: FadeTransition(opacity: _fade, child: _page(isWide))),
        ])),
      ]),
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
      case KTab.about:    return KAboutPage(isWide: w);
      case KTab.projects: return KProjectsPage(isWide: w);
      case KTab.contact:  return KContactPage(isWide: w);
    }
  }
}

// keep _C locally for the background overlay color
class _C {
  static const bg     = Color(0xFF1C1814);
  static const amber  = Color(0xFFFBBF24);
  static const purple = Color(0xFFA78BFA);
}
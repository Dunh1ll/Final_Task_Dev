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
  // ── Scroll ───────────────────────────────────────────────────
  final ScrollController _scroll = ScrollController();

  final Map<KTab, GlobalKey> _keys = {
    KTab.home:       GlobalKey(),
    KTab.about:      GlobalKey(),
    KTab.experience: GlobalKey(),
    KTab.projects:   GlobalKey(),
    KTab.contact:    GlobalKey(),
  };

  KTab _activeTab = KTab.home;

  // ── Typing animation ─────────────────────────────────────────
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

  // ── Ticker items ─────────────────────────────────────────────
  static const _tickerItems = [
    'Flutter',
    'Golang',
    'PostgreSQL',
    'REST APIs',
    'UI / UX',
    'JWT Auth',
    'Mobile Dev',
    'Open Source',
  ];

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    Future.delayed(const Duration(milliseconds: 900), _startTyping);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _tmr?.cancel();
    super.dispose();
  }

  // ── Scroll spy ───────────────────────────────────────────────
  void _onScroll() {
    final mid =
        _scroll.offset + _scroll.position.viewportDimension / 2;

    KTab detected = KTab.home;
    double closest = double.infinity;

    for (final entry in _keys.entries) {
      final ctx = entry.value.currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final pos = box.localToGlobal(Offset.zero, ancestor: null);
      final sectionMid =
          _scroll.offset + pos.dy + box.size.height / 2;
      final dist = (sectionMid - mid).abs();
      if (dist < closest) {
        closest = dist;
        detected = entry.key;
      }
    }

    if (detected != _activeTab) {
      setState(() => _activeTab = detected);
    }
  }

  // ── Scroll to section ────────────────────────────────────────
  void _scrollTo(KTab tab) {
    final ctx = _keys[tab]?.currentContext;
    if (ctx == null) return;

    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  // ── Typing animation ─────────────────────────────────────────
  void _startTyping() {
    _tmr = Timer.periodic(const Duration(milliseconds: 70), (_) {
      if (!mounted) return;
      final target = _roles[_ri];
      setState(() {
        if (!_del) {
          if (_typed.length < target.length) {
            _typed = target.substring(0, _typed.length + 1);
          } else {
            Future.delayed(const Duration(milliseconds: 1600), () {
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
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 768;
    final headerHeight = 68.0 + 36.0 + MediaQuery.of(context).padding.top;
    final availableHeight = MediaQuery.of(context).size.height - headerHeight;

    return Scaffold(
      backgroundColor: KC.bg,
      body: Stack(
        children: [
          // Grain texture
          Positioned.fill(
            child: IgnorePointer(child: KGrain()),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Navbar ──────────────────────────────────
                KNavBar(
                  tab: _activeTab,
                  onTab: _scrollTo,
                  isWide: isWide,
                ),

                // ── Scrolling ticker strip ───────────────────
                Container(
                  height: 36,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                          color: KC.borderStr, width: 2),
                    ),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8),
                    child: KTicker(items: _tickerItems),
                  ),
                ),

                // ── Main scrollable content ──────────────────
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scroll,
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // Home / Hero — always full height
                        KeyedSubtree(
                          key: _keys[KTab.home],
                          child: SizedBox(
                            height: availableHeight,
                            child: KHomePage(
                              typed: _typed,
                              isWide: isWide,
                              onContact: () => _scrollTo(KTab.contact),
                              onProjects: () => _scrollTo(KTab.projects),
                            ),
                          ),
                        ),

                        _divider(),

                        // About section
                        KeyedSubtree(
                          key: _keys[KTab.about],
                          child: isWide
                              ? ConstrainedBox(
                                  constraints: BoxConstraints(minHeight: availableHeight),
                                  child: KAboutPage(isWide: isWide),
                                )
                              : KAboutPage(isWide: isWide),  // No height constraint on narrow screens
                        ),

                        _divider(),

                        // Experience — min full height
                        KeyedSubtree(
                          key: _keys[KTab.experience],
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: availableHeight,
                            ),
                            child: KExperiencePage(isWide: isWide),
                          ),
                        ),

                        _divider(),

                        // Projects — min full height
                        KeyedSubtree(
                          key: _keys[KTab.projects],
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: availableHeight,
                            ),
                            child: KProjectsPage(isWide: isWide),
                          ),
                        ),

                        _divider(),

                        // Contact — min full height
                        KeyedSubtree(
                          key: _keys[KTab.contact],
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: availableHeight,
                            ),
                            child: KContactPage(isWide: isWide),
                          ),
                        ),

                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(height: 2, color: KC.borderStr);
}
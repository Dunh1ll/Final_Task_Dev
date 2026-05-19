import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
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
  final ScrollController _scroll = ScrollController();
  double _scrollProgress = 0.0;

  final Map<KTab, GlobalKey> _keys = {
    KTab.home: GlobalKey(),
    KTab.about: GlobalKey(),
    KTab.experience: GlobalKey(),
    KTab.projects: GlobalKey(),
    KTab.contact: GlobalKey(),
  };

  KTab _activeTab = KTab.home;

  final _roles = [
    'backend systems',
    'web applications',
    'REST APIs',
    'modern interfaces',
    'scalable solutions',
    'full-stack systems',
  ];
  int _ri = 0;
  String _typed = '';
  bool _del = false;
  Timer? _tmr;

  static const _tickerItems = [
    'SOFTWARE DEVELOPER INTERN',
    'FLUTTER WEB',
    'GO',
    'POSTGRESQL',
    'REST APIs',
    'FULL-STACK SYSTEMS',
    'MODERN WEB APPLICATIONS',
    'FDS ASYA PHILIPPINES INC.',
  ];

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    Future.delayed(const Duration(milliseconds: 900), _startTyping);
    if (kIsWeb) {
      html.document.title = 'Karl Angelo\'s Portfolio';
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _tmr?.cancel();
    if (kIsWeb) {
      html.document.title = 'PiraTern Profiles';
    }
    super.dispose();
  }

  void _onScroll() {
    final mid = _scroll.offset + _scroll.position.viewportDimension / 2;
    KTab detected = KTab.home;
    double closest = double.infinity;

    for (final entry in _keys.entries) {
      final ctx = entry.value.currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final pos = box.localToGlobal(Offset.zero, ancestor: null);
      final sectionMid = _scroll.offset + pos.dy + box.size.height / 2;
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

  void _scrollTo(KTab tab) {
    final ctx = _keys[tab]?.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOutQuart,
    );
  }

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

    return KThemeProvider(
      child: KThemeRipple(
        child: Builder(
          builder: (context) {
            final kc = KTheme.colors(context);

            return Scaffold(
              backgroundColor: kc.bg,
              body: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification.metrics.maxScrollExtent > 0) {
                    setState(() {
                      _scrollProgress = notification.metrics.pixels /
                          notification.metrics.maxScrollExtent;
                    });
                  }
                  return false;
                },
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: IgnorePointer(child: KGrain()),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: AnimatedFraction(
                        progress: _scrollProgress,
                        color: kc.borderStr,
                      ),
                    ),
                    SafeArea(
                      child: Column(
                        children: [
                          KNavBar(
                            tab: _activeTab,
                            onTab: _scrollTo,
                            isWide: isWide,
                          ),
                          Builder(builder: (context) {
                            final kc = KTheme.colors(context);
                            return Container(
                              height: 36,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom:
                                      BorderSide(color: kc.borderStr, width: 2),
                                ),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: KTicker(items: _tickerItems),
                              ),
                            );
                          }),
                          Expanded(
                            child: SingleChildScrollView(
                              controller: _scroll,
                              physics: const BouncingScrollPhysics(
                                decelerationRate: ScrollDecelerationRate.fast,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  KeyedSubtree(
                                    key: _keys[KTab.home],
                                    child: SizedBox(
                                      height: availableHeight,
                                      child: KHomePage(
                                        typed: _typed,
                                        isWide: isWide,
                                        onContact: () =>
                                            _scrollTo(KTab.contact),
                                        onProjects: () =>
                                            _scrollTo(KTab.projects),
                                      ),
                                    ),
                                  ),
                                  _divider(),
                                  KeyedSubtree(
                                    key: _keys[KTab.about],
                                    child: isWide
                                        ? ConstrainedBox(
                                            constraints: BoxConstraints(
                                                minHeight: availableHeight),
                                            child: KAboutPage(isWide: isWide),
                                          )
                                        : KAboutPage(isWide: isWide),
                                  ),
                                  _divider(),
                                  KeyedSubtree(
                                    key: _keys[KTab.experience],
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                          minHeight: availableHeight),
                                      child: KExperiencePage(isWide: isWide),
                                    ),
                                  ),
                                  _divider(),
                                  KeyedSubtree(
                                    key: _keys[KTab.projects],
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                          minHeight: availableHeight),
                                      child: KProjectsPage(isWide: isWide),
                                    ),
                                  ),
                                  _divider(),
                                  KeyedSubtree(
                                    key: _keys[KTab.contact],
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                          minHeight: availableHeight),
                                      child: KContactPage(isWide: isWide),
                                    ),
                                  ),
                                  _footer(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _divider() => Builder(
        builder: (context) {
          final kc = KTheme.colors(context);
          return Container(height: 2, color: kc.borderStr);
        },
      );

  Widget _footer() => Builder(
        builder: (context) {
          final kc = KTheme.colors(context);
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 40),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: kc.borderStr, width: 2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'DESIGNED & BUILT BY ',
                      style: TextStyle(
                        fontFamily: KC.fontMono,
                        fontSize: 11,
                        letterSpacing: 2,
                        color: kc.textDim,
                      ),
                    ),
                    Text(
                      'KARL ANGELO ALBANIEL',
                      style: TextStyle(
                        fontFamily: KC.fontMono,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        letterSpacing: 2,
                        color: kc.textMuted,
                      ),
                    ),
                  ],
                ),
                Text(
                  '© 2026 Karl Angelo M. Albaniel',
                  style: TextStyle(
                    fontFamily: KC.fontMono,
                    fontSize: 11,
                    letterSpacing: 1.5,
                    color: kc.textDim,
                  ),
                ),
              ],
            ),
          );
        },
      );
}

class AnimatedFraction extends StatelessWidget {
  final double progress;
  final Color color;
  const AnimatedFraction({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          height: 2,
          width: constraints.maxWidth * progress,
          color: color,
        );
      },
    );
  }
}

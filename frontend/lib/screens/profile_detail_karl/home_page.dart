import 'package:flutter/material.dart';
import 'constants.dart';
import 'utilities.dart';

class KHomePage extends StatefulWidget {
  final String typed;
  final bool isWide;
  final VoidCallback onContact;
  final VoidCallback onProjects;

  const KHomePage({
    required this.typed,
    required this.isWide,
    required this.onContact,
    required this.onProjects,
  });

  @override
  State<KHomePage> createState() => _KHomePageState();
}

class _KHomePageState extends State<KHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late List<Animation<double>> _fades;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));

    _fades = List.generate(5, (i) {
      final start = i * 0.14;
      final end = (start + 0.45).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _c,
            curve: Interval(start, end, curve: Curves.easeOut)),
      );
    });

    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isWide) {
      return _WideHero(
        typed: widget.typed,
        fades: _fades,
        onContact: widget.onContact,
        onProjects: widget.onProjects,
      );
    }

    return _NarrowHero(
      typed: widget.typed,
      fades: _fades,
      onContact: widget.onContact,
      onProjects: widget.onProjects,
    );
  }
}

// ── Wide layout ───────────────────────────────────────────────────
class _WideHero extends StatelessWidget {
  final String typed;
  final List<Animation<double>> fades;
  final VoidCallback onContact;
  final VoidCallback onProjects;

  const _WideHero({
    required this.typed,
    required this.fades,
    required this.onContact,
    required this.onProjects,
  });

  Widget _f(int i, Widget child) =>
      FadeTransition(opacity: fades[i], child: child);

  @override
  Widget build(BuildContext context) {
    final kc = KTheme.colors(context);
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              _f(0, Center(child: _BadgeTag('Software Developer Intern'))),

              const SizedBox(height: 60),

              _f(
                1,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'KARL',
                      style: TextStyle(
                        fontFamily: KC.fontDisplay,
                        fontWeight: FontWeight.w900,
                        fontSize: 160,
                        height: 0.78,
                        letterSpacing: -10,
                        color: kc.textPrimary,
                      ),
                    ),
                    _OutlineName('ANGELO', 160, kc),
                    Text(
                      'ALBANIEL',
                      style: TextStyle(
                        fontFamily: KC.fontDisplay,
                        fontWeight: FontWeight.w900,
                        fontSize: 160,
                        height: 0.78,
                        letterSpacing: -10,
                        color: kc.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 44),

              _f(
                2,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'I build ',
                      style: TextStyle(
                        fontFamily: KC.fontMono,
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        letterSpacing: 0.2,
                        color: kc.textSecondary,
                      ),
                    ),
                    Text(
                      typed,
                      style: TextStyle(
                        fontFamily: KC.fontMono,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        letterSpacing: 0.3,
                        color: kc.textPrimary,
                      ),
                    ),
                    KCursor(),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              _f(
                3,
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 780),
                  child: Text(
                    '4th-year Information Systems student building modern mobile apps and scalable backend systems using Flutter, Golang, PostgreSQL, and REST APIs.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: KC.fontMono,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      letterSpacing: 0.2,
                      height: 1.9,
                      color: kc.textSecondary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              _f(
                4,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _HeroButton(
                      label: 'View Work',
                      filled: true,
                      onTap: onProjects,
                    ),
                    const SizedBox(width: 20),
                    _HeroButton(
                      label: 'Contact',
                      filled: false,
                      onTap: onContact,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Narrow layout ─────────────────────────────────────────────────
class _NarrowHero extends StatelessWidget {
  final String typed;
  final List<Animation<double>> fades;
  final VoidCallback onContact;
  final VoidCallback onProjects;

  const _NarrowHero({
    required this.typed,
    required this.fades,
    required this.onContact,
    required this.onProjects,
  });

  Widget _f(int i, Widget child) =>
      FadeTransition(opacity: fades[i], child: child);

  @override
  Widget build(BuildContext context) {
    final kc = KTheme.colors(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 48, 28, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _f(0, _BadgeTag('Backend Developer')),
          const SizedBox(height: 24),
          _f(
            1,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KARL',
                  style: TextStyle(
                    fontFamily: KC.fontDisplay,
                    fontWeight: FontWeight.w900,
                    fontSize: 52,
                    height: 0.9,
                    letterSpacing: -3,
                    color: kc.textPrimary,
                  ),
                ),
                _OutlineName('ANGELO', 52, kc),
                Text(
                  'ALBANIEL',
                  style: TextStyle(
                    fontFamily: KC.fontDisplay,
                    fontWeight: FontWeight.w900,
                    fontSize: 52,
                    height: 0.9,
                    letterSpacing: -3,
                    color: kc.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _f(
            2,
            Row(
              children: [
                Text(
                  'I build ',
                  style: TextStyle(
                    fontFamily: KC.fontMono,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    letterSpacing: 0.2,
                    color: kc.textSecondary,
                  ),
                ),
                Text(
                  typed,
                  style: TextStyle(
                    fontFamily: KC.fontMono,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 0.3,
                    color: kc.textPrimary,
                  ),
                ),
                KCursor(),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _f(
            3,
            Text(
              '4th-year IS student.\nBuilding mobile apps & backends at FDSAP.\nFlutter · Go · PostgreSQL',
              style: TextStyle(
                fontFamily: KC.fontMono,
                fontWeight: FontWeight.w500,
                fontSize: 13,
                letterSpacing: 0.2,
                color: kc.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          _f(
            4,
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _HeroButton(
                    label: 'View Work',
                    filled: true,
                    onTap: onProjects),
                _HeroButton(
                    label: 'Contact',
                    filled: false,
                    onTap: onContact),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              _StatCell(value: '2+', label: 'Years'),
              Container(width: 1, height: 60, color: kc.border),
              _StatCell(value: '10+', label: 'Projects'),
              Container(width: 1, height: 60, color: kc.border),
              _StatCell(value: '1', label: 'Internship'),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Outline name text ─────────────────────────────────────────────
class _OutlineName extends StatelessWidget {
  final String text;
  final double size;
  final KColors kc;
  const _OutlineName(this.text, this.size, this.kc);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          text,
          style: TextStyle(
            fontFamily: KC.fontDisplay,
            fontWeight: FontWeight.w900,
            fontSize: size,
            height: 0.88,
            letterSpacing: -4,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.5
              ..color = kc.textPrimary,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            fontFamily: KC.fontDisplay,
            fontWeight: FontWeight.w900,
            fontSize: size,
            height: 0.88,
            letterSpacing: -4,
            color: kc.bg,
          ),
        ),
      ],
    );
  }
}

// ── Badge tag ─────────────────────────────────────────────────────
class _BadgeTag extends StatelessWidget {
  final String label;
  const _BadgeTag(this.label);

  @override
  Widget build(BuildContext context) {
    final kc = KTheme.colors(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: kc.textPrimary.withOpacity(0.7)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: KC.fontMono,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 2,
          color: kc.textSecondary,
        ),
      ),
    );
  }
}

// ── Hero button ───────────────────────────────────────────────────
class _HeroButton extends StatefulWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;
  const _HeroButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  State<_HeroButton> createState() => _HeroButtonState();
}

class _HeroButtonState extends State<_HeroButton> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    final kc = KTheme.colors(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 17),
          decoration: BoxDecoration(
            color: widget.filled
                ? (_hov
                    ? kc.textPrimary.withOpacity(0.85)
                    : kc.textPrimary)
                : (_hov
                    ? kc.textPrimary.withOpacity(0.08)
                    : Colors.transparent),
            border: Border.all(
              color: kc.textPrimary,
              width: 1,
            ),
          ),
          child: Text(
            widget.label.toUpperCase(),
            style: TextStyle(
              fontFamily: KC.fontMono,
              fontSize: 12,
              letterSpacing: 4,
              color: widget.filled ? kc.bg : kc.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Stat cell ─────────────────────────────────────────────────────
class _StatCell extends StatelessWidget {
  final String value, label;
  const _StatCell({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final kc = KTheme.colors(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: KC.fontDisplay,
              fontWeight: FontWeight.w900,
              fontSize: 44,
              letterSpacing: -2,
              color: kc.textPrimary,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: KC.fontMono,
              fontWeight: FontWeight.w600,
              fontSize: 9,
              letterSpacing: 2,
              color: kc.textDim,
            ),
          ),
        ],
      ),
    );
  }
}
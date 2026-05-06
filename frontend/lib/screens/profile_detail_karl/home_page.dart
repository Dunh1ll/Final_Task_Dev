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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Left column — name + desc + buttons ──────────────
        Expanded(
          flex: 6,
          child: Container(
            padding: const EdgeInsets.fromLTRB(85, 48, 40, 72),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Badge
                _f(0, _BadgeTag('Backend Developer')),

                // Name block — Solid / Outline / Solid
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
                          fontSize: 110,
                          height: 0.88,
                          letterSpacing: -4,
                          color: KC.textPrimary,
                        ),
                      ),
                      _OutlineName('ANGELO', 110),
                      Text(
                        'ALBANIEL',
                        style: TextStyle(
                          fontFamily: KC.fontDisplay,
                          fontWeight: FontWeight.w900,
                          fontSize: 110,
                          height: 0.88,
                          letterSpacing: -4,
                          color: KC.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Typewriter role
                _f(
                  2,
                  Row(
                    children: [
                      Text(
                        'I build ',
                        style: const TextStyle(
                          fontFamily: KC.fontMono,
                          fontSize: 17,
                          color: KC.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        typed,
                        style: const TextStyle(
                          fontFamily: KC.fontMono,
                          fontSize: 17,
                          color: KC.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      KCursor(),
                    ],
                  ),
                ),

                // Description
                _f(
                  3,
                  Text(
                    '4th-year Information Systems student.\n'
                    'Building mobile apps and backends at FDSAP.\n'
                    'Flutter · Golang · PostgreSQL · REST',
                    style: const TextStyle(
                      fontFamily: KC.fontMono,
                      fontSize: 14,
                      color: KC.textMuted,
                      height: 2,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),

                // Buttons
                _f(
                  4,
                  Row(
                    children: [
                      _HeroButton(
                          label: 'View Work',
                          filled: true,
                          onTap: onProjects),
                      const SizedBox(width: 12),
                      _HeroButton(
                          label: 'Contact',
                          filled: false,
                          onTap: onContact),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
                    color: KC.textPrimary,
                  ),
                ),
                _OutlineName('ANGELO', 52),
                Text(
                  'ALBANIEL',
                  style: TextStyle(
                    fontFamily: KC.fontDisplay,
                    fontWeight: FontWeight.w900,
                    fontSize: 52,
                    height: 0.9,
                    letterSpacing: -3,
                    color: KC.textPrimary,
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
                const Text(
                  'I build ',
                  style: TextStyle(
                    fontFamily: KC.fontMono,
                    fontSize: 14,
                    color: KC.textMuted,
                  ),
                ),
                Text(
                  typed,
                  style: const TextStyle(
                    fontFamily: KC.fontMono,
                    fontSize: 14,
                    color: KC.textPrimary,
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
              style: const TextStyle(
                fontFamily: KC.fontMono,
                fontSize: 13,
                color: KC.textMuted,
                height: 2,
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
              Container(width: 1, height: 60, color: KC.border),
              _StatCell(value: '10+', label: 'Projects'),
              Container(width: 1, height: 60, color: KC.border),
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
  const _OutlineName(this.text, this.size);

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
              ..strokeWidth = 2
              ..color = KC.textPrimary,
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
            color: KC.bg,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: KC.textPrimary.withOpacity(0.4)),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontFamily: KC.fontMono,
          fontSize: 11,
          letterSpacing: 3,
          color: KC.textSecondary,
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
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
          decoration: BoxDecoration(
            color: widget.filled
                ? (_hov
                    ? KC.textPrimary.withOpacity(0.85)
                    : KC.textPrimary)
                : (_hov
                    ? KC.textPrimary.withOpacity(0.08)
                    : Colors.transparent),
            border: Border.all(
              color: KC.textPrimary,
              width: 1,
            ),
          ),
          child: Text(
            widget.label.toUpperCase(),
            style: TextStyle(
              fontFamily: KC.fontMono,
              fontSize: 9,
              letterSpacing: 3,
              color: widget.filled ? KC.bg : KC.textPrimary,
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
              color: KC.textPrimary,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontFamily: KC.fontMono,
              fontSize: 9,
              letterSpacing: 3,
              color: KC.textDim,
            ),
          ),
        ],
      ),
    );
  }
}


// Dart extension helper
extension _Also<T> on T {
  T also(void Function(T) f) {
    f(this);
    return this;
  }
}
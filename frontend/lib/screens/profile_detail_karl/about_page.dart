import 'package:flutter/material.dart';
import 'constants.dart';
import 'utilities.dart';

class KAboutPage extends StatelessWidget {
  final bool isWide;
  const KAboutPage({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return KReveal(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section header ─────────────────────────────────
          SectionHeader(number: '01', title: 'About'),

          // ── Body — full viewport height ────────────────────
          SizedBox(
            height: screenH,
            child: isWide ? _wideLayout() : _narrowLayout(),
          ),
        ],
      ),
    );
  }

  Widget _wideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── LEFT PANEL — identity card ──────────────────────
        SizedBox(
          width: 300,
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: KC.borderStr, width: 2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PhotoBox(),
                Container(height: 2, color: KC.borderStr),
                _IdentityBlock(),
              ],
            ),
          ),
        ),

        // ── RIGHT PANEL — scrollable content cells ──────────
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CurrentlyCell(),
                _divider(),
                _BioCell(),
                _divider(),
                _TechCell(),
                _divider(),
                _InterestsCell(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _narrowLayout() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PhotoBox(),
          _divider(),
          _IdentityBlock(),
          _divider(),
          _CurrentlyCell(),
          _divider(),
          _BioCell(),
          _divider(),
          _TechCell(),
          _divider(),
          _InterestsCell(),
        ],
      ),
    );
  }

  Widget _divider() => Container(height: 2, color: KC.borderStr);
}

// ── Public SectionHeader (used by other pages) ─────────────────────
class SectionHeader extends StatelessWidget {
  final String number, title;
  const SectionHeader({required this.number, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: KC.borderStr, width: 2),
        ),
      ),
      child: Row(
        children: [
          if (number.isNotEmpty)
            Text(
              '$number — ',
              style: const TextStyle(
                fontFamily: KC.fontMono,
                fontSize: 11,
                letterSpacing: 2,
                color: KC.textDim,
              ),
            ),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontFamily: KC.fontDisplay,
              fontWeight: FontWeight.w900,
              fontSize: 24,
              letterSpacing: -0.5,
              color: KC.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Photo box ─────────────────────────────────────────────────────
class _PhotoBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Outer hard-border frame with offset shadow border
          Stack(
            children: [
              // Offset accent border (bottom-right)
              Positioned(
                top: 8,
                left: 8,
                right: -8,
                bottom: -8,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: KC.textPrimary.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                ),
              ),
              // Main photo container
              Container(
                height: 260,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: KC.borderStr,
                    width: 2,
                  ),
                  color: KC.bgLight,
                ),
                child: ClipRect(
                  child: Image.asset(
                    'assets/images/profile2.png',
                    fit: BoxFit.cover,
                    alignment: const Alignment(0.0, -0.2),
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(
                        'KA',
                        style: TextStyle(
                          fontFamily: KC.fontDisplay,
                          fontWeight: FontWeight.w900,
                          fontSize: 72,
                          color: KC.textPrimary,
                          letterSpacing: -3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Identity block (below photo on left panel) ─────────────────────
class _IdentityBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Karl Angelo Albaniel',
            style: TextStyle(
              fontFamily: KC.fontDisplay,
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: KC.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _PulseDot(),
              const SizedBox(width: 8),
              const Text(
                'AVAILABLE FOR WORK',
                style: TextStyle(
                  fontFamily: KC.fontMono,
                  fontSize: 9,
                  letterSpacing: 3,
                  color: KC.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _statLine('Year',   '4th — IS Student'),
          _statLine('Role',   'Backend Developer'),
          _statLine('Base',   'Philippines'),
          _statLine('Status', 'Interning @ FDSAP'),
        ],
      ),
    );
  }

  Widget _statLine(String key, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            key,
            style: const TextStyle(
              fontFamily: KC.fontMono,
              fontSize: 10,
              letterSpacing: 1,
              color: KC.textDim,
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: KC.border,
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
          Text(
            val,
            style: const TextStyle(
              fontFamily: KC.fontMono,
              fontSize: 10,
              letterSpacing: 0.5,
              color: KC.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Currently cell ────────────────────────────────────────────────
class _CurrentlyCell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KLabel('// Currently'),
          const SizedBox(height: 16),
          const Text(
            'Interning @ FDSAP',
            style: TextStyle(
              fontFamily: KC.fontDisplay,
              fontWeight: FontWeight.w900,
              fontSize: 28,
              color: KC.textPrimary,
              letterSpacing: -1,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Jan 2025 → Present',
            style: TextStyle(
              fontFamily: KC.fontMono,
              fontSize: 11,
              color: KC.textDim,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: const [
              _StatusChip('Flutter Mobile'),
              _StatusChip('Go Backend'),
              _StatusChip('PostgreSQL'),
              _StatusChip('JWT + OTP Auth'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  const _StatusChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: KC.border),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontFamily: KC.fontMono,
          fontSize: 9,
          letterSpacing: 2,
          color: KC.textMuted,
        ),
      ),
    );
  }
}

// ── Bio cell ──────────────────────────────────────────────────────
class _BioCell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      child: Stack(
        children: [
          // Decorative background quote mark
          Positioned(
            top: -12,
            right: 0,
            child: Text(
              '"',
              style: TextStyle(
                fontFamily: KC.fontDisplay,
                fontWeight: FontWeight.w900,
                fontSize: 180,
                color: KC.textPrimary.withOpacity(0.03),
                height: 1,
              ),
            ),
          ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KLabel('// Who I am'),
              const SizedBox(height: 20),
              const _Para(
                'Hello. I\'m Karl — a 4th-year Information Systems '
                'student who builds things for mobile, web, and '
                'everywhere in between.',
              ),
              const SizedBox(height: 16),
              const _Para(
                'Currently interning at FDSAP where I focus on '
                'Flutter mobile apps and Go backends. I care about '
                'clean architecture, fast systems, and interfaces '
                'that feel right.',
              ),
              const SizedBox(height: 16),
              const _Para(
                'When not coding: exploring tech stacks, '
                'open-source contributions, and leveling up '
                'my UI/UX craft.',
              ),
              const SizedBox(height: 32),
              IntrinsicHeight(
                child: Row(
                  children: [
                    const _StatPill('2+',  'Years\nCoding'),
                    Container(
                      width: 1,
                      color: KC.border,
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    const _StatPill('10+', 'Projects\nBuilt'),
                    Container(
                      width: 1,
                      color: KC.border,
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    const _StatPill('1',   'Active\nInternship'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Para extends StatelessWidget {
  final String text;
  const _Para(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontFamily: KC.fontMono,
          fontSize: 13,
          color: KC.textSecondary,
          height: 1.9,
          letterSpacing: 0.2,
        ),
      );
}

class _StatPill extends StatelessWidget {
  final String value, label;
  const _StatPill(this.value, this.label);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: KC.fontDisplay,
              fontWeight: FontWeight.w900,
              fontSize: 36,
              color: KC.textPrimary,
              letterSpacing: -1,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontFamily: KC.fontMono,
              fontSize: 9,
              letterSpacing: 2.5,
              color: KC.textDim,
              height: 1.6,
            ),
          ),
        ],
      );
}

// ── Tech cell — spec-sheet style ──────────────────────────────────
class _TechCell extends StatelessWidget {
  static const _techs = [
    ('Flutter & Dart', 'Mobile'),
    ('Golang',         'Backend'),
    ('PostgreSQL',     'Database'),
    ('REST APIs',      'Integration'),
    ('UI / UX Design', 'Design'),
    ('JWT Auth',       'Security'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KLabel('// Technologies'),
          const SizedBox(height: 20),
          ..._techs.map(
            (t) => _TechRow(name: t.$1, category: t.$2),
          ),
        ],
      ),
    );
  }
}

class _TechRow extends StatefulWidget {
  final String name, category;
  const _TechRow({required this.name, required this.category});

  @override
  State<_TechRow> createState() => _TechRowState();
}

class _TechRowState extends State<_TechRow> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        color: _hov
            ? KC.textPrimary.withOpacity(0.04)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Text(
              widget.name,
              style: TextStyle(
                fontFamily: KC.fontMono,
                fontSize: 13,
                color: _hov ? KC.textPrimary : KC.textSecondary,
                letterSpacing: 0.3,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _DottedLine(),
              ),
            ),
            Text(
              widget.category.toUpperCase(),
              style: TextStyle(
                fontFamily: KC.fontMono,
                fontSize: 9,
                letterSpacing: 2.5,
                color: _hov ? KC.textMuted : KC.textDim,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DottedLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final dotCount = (constraints.maxWidth / 8).floor();
        return Row(
          children: List.generate(
            dotCount,
            (_) => Expanded(
              child: Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                color: KC.border,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Interests cell ────────────────────────────────────────────────
class _InterestsCell extends StatelessWidget {
  static const _interests = [
    ('🎵', 'Music'),
    ('🎮', 'Gaming'),
    ('🎸', 'Playing Instruments'),
    ('😴', 'Sleeping'),
    ('⚽', 'Playing Sports'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KLabel('// Interests'),
          const SizedBox(height: 20),
          ..._interests.map(
            (i) => _InterestRow(emoji: i.$1, label: i.$2),
          ),
        ],
      ),
    );
  }
}

class _InterestRow extends StatefulWidget {
  final String emoji, label;
  const _InterestRow({required this.emoji, required this.label});

  @override
  State<_InterestRow> createState() => _InterestRowState();
}

class _InterestRowState extends State<_InterestRow> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        color: _hov
            ? KC.textPrimary.withOpacity(0.04)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Text(widget.emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 14),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 160),
              style: TextStyle(
                fontFamily: KC.fontMono,
                fontSize: 13,
                letterSpacing: 0.5,
                color: _hov ? KC.textPrimary : KC.textMuted,
              ),
              child: Text(widget.label),
            ),
            const SizedBox(width: 14),
            Expanded(child: Container(height: 1, color: KC.border)),
          ],
        ),
      ),
    );
  }
}

// ── Pulse dot ─────────────────────────────────────────────────────
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
        vsync: this, duration: const Duration(milliseconds: 1400))
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
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: KC.textPrimary,
            shape: BoxShape.circle,
          ),
        ),
      );
}
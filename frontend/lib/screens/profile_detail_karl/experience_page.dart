import 'package:flutter/material.dart';
import 'constants.dart';
import 'utilities.dart';
import 'about_page.dart' show SectionHeader;

class KExperiencePage extends StatefulWidget {
  final bool isWide;
  const KExperiencePage({required this.isWide});

  @override
  State<KExperiencePage> createState() => _KExperiencePageState();
}

class _KExperiencePageState extends State<KExperiencePage> {
  int _selected = 0;
  int _expandedNarrow = 0;

  static const _experiences = [
    _Exp(
      company: 'FDS Asya Philippines',
      role: 'Software Developer\nIntern',
      range: 'May 2026 — Present',
      type: 'Internship',
      summary:
          'Building collaborative systems and modern applications '
          'in a production environment, working with fellow interns '
          'and senior developers on real-world projects.',
      points: [
        'Developed frontend and backend features using Flutter, Go (Golang), PostgreSQL, Node.js, and Firebase.',
        'Participated in UI/UX improvements, debugging, testing, and feature implementation.',
        'Collaborated using modern development workflows and AI-assisted development tools.',
        'Assisted in developing collaborative systems and improving production-level application quality.',
      ],
      tags: ['Flutter', 'Go (Golang)', 'PostgreSQL', 'Node.js', 'Firebase', 'Git & GitHub'],
      stats: [
        _Stat('2026', 'Started'),
        _Stat('6+', 'Tech Stack'),
        _Stat('Live', 'Production'),
      ],
    ),
    _Exp(
      company: 'SPES Program',
      role: 'SPES\nParticipant',
      range: '2023 — 2024',
      type: 'Gov. Employment',
      summary:
          'Participated in the Special Program for Employment of Students — '
          'a government-supported student employment initiative during '
          'academic breaks, developing workplace skills.',
      points: [
        'Assisted with assigned operational and administrative tasks in the workplace.',
        'Improved communication, adaptability, and professional workplace responsibility.',
        'Balanced work responsibilities alongside full-time academic studies successfully.',
        'Developed time management and professional habits in a structured work environment.',
      ],
      tags: ['Communication', 'Adaptability', 'Work Ethic', 'Time Management'],
      stats: [
        _Stat('2', 'Years'),
        _Stat('Gov.', 'Program'),
        _Stat('2023', 'Started'),
      ],
    ),
    _Exp(
      company: 'Local Retail Shop',
      role: 'Retail\nStore Clerk',
      range: '2023 — 2024',
      type: 'Part-time',
      summary:
          'Managed daily store operations, assisted customers, and '
          'handled cashier duties — all while maintaining academic '
          'performance as a full-time student.',
      points: [
        'Assisted customers and managed daily store operations efficiently.',
        'Handled cashier duties, product organization, and inventory monitoring.',
        'Maintained store cleanliness and assisted with daily opening and closing procedures.',
        'Developed strong communication, customer service, and multitasking skills.',
      ],
      tags: ['Customer Service', 'Cashiering', 'Inventory', 'Multitasking'],
      stats: [
        _Stat('2', 'Years'),
        _Stat('Part', 'Time'),
        _Stat('2023', 'Started'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final availH = MediaQuery.of(context).size.height - 68 - 36 - 74;

    return KReveal(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(number: '02', title: 'Experience'),
          SizedBox(
            height: availH,
            child: widget.isWide ? _wideLayout() : _narrowLayout(),
          ),
        ],
      ),
    );
  }

  // ── Wide layout ──────────────────────────────────────────────
  Widget _wideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // LEFT — timeline panel
        SizedBox(
          width: 300,
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: KC.borderStr, width: 2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Panel header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(28, 20, 28, 20),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: KC.border, width: 1),
                    ),
                  ),
                  child: KLabel('// Timeline'),
                ),

                // Timeline nodes
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(_experiences.length, (i) {
                        final isLast = i == _experiences.length - 1;
                        return _TimelineNode(
                          index: i,
                          exp: _experiences[i],
                          isActive: _selected == i,
                          isLast: isLast,
                          onTap: () => setState(() => _selected = i),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // RIGHT — animated detail panel
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.topLeft,
              children: [
                ...previous,
                if (current != null) current,
              ],
            ),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.02, 0),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: _ExpDetailPanel(
              key: ValueKey(_selected),
              exp: _experiences[_selected],
              index: _selected,
            ),
          ),
        ),
      ],
    );
  }

  // ── Narrow layout — accordion ────────────────────────────────
  Widget _narrowLayout() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: List.generate(
          _experiences.length,
          (i) => _AccordionItem(
            exp: _experiences[i],
            index: i,
            isOpen: _expandedNarrow == i,
            onTap: () => setState(
              () => _expandedNarrow = _expandedNarrow == i ? -1 : i,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Data models ───────────────────────────────────────────────────
class _Exp {
  final String company, role, range, type, summary;
  final List<String> points, tags;
  final List<_Stat> stats;
  const _Exp({
    required this.company,
    required this.role,
    required this.range,
    required this.type,
    required this.summary,
    required this.points,
    required this.tags,
    required this.stats,
  });
}

class _Stat {
  final String value, label;
  const _Stat(this.value, this.label);
}

// ── Timeline node (left panel) ────────────────────────────────────
class _TimelineNode extends StatefulWidget {
  final int index;
  final _Exp exp;
  final bool isActive, isLast;
  final VoidCallback onTap;

  const _TimelineNode({
    required this.index,
    required this.exp,
    required this.isActive,
    required this.isLast,
    required this.onTap,
  });

  @override
  State<_TimelineNode> createState() => _TimelineNodeState();
}

class _TimelineNodeState extends State<_TimelineNode> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Node + vertical connector line ────────────────
            SizedBox(
              width: 32,
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isActive
                          ? KC.textPrimary
                          : Colors.transparent,
                      border: Border.all(
                        color: widget.isActive || _hov
                            ? KC.textPrimary
                            : KC.textDim,
                        width: 1.5,
                      ),
                    ),
                    child: widget.isActive
                        ? null
                        : Center(
                            child: Text(
                              '${widget.index + 1}',
                              style: TextStyle(
                                fontFamily: KC.fontMono,
                                fontSize: 9,
                                color: _hov ? KC.textPrimary : KC.textDim,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                  ),
                  if (!widget.isLast)
                    Container(
                      width: 1,
                      height: 72,
                      color: KC.border,
                    ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            // ── Text content ──────────────────────────────────
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: widget.isLast ? 0 : 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),

                    // Type badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: widget.isActive
                              ? KC.textPrimary.withOpacity(0.4)
                              : KC.border,
                        ),
                      ),
                      child: Text(
                        widget.exp.type.toUpperCase(),
                        style: TextStyle(
                          fontFamily: KC.fontMono,
                          fontSize: 8,
                          letterSpacing: 2,
                          color: widget.isActive
                              ? KC.textMuted
                              : KC.textDim,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Company name
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontFamily: KC.fontDisplay,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: widget.isActive || _hov
                            ? KC.textPrimary
                            : KC.textMuted,
                        letterSpacing: -0.3,
                        height: 1.1,
                      ),
                      child: Text(widget.exp.company),
                    ),

                    const SizedBox(height: 4),

                    // Date range
                    Text(
                      widget.exp.range,
                      style: TextStyle(
                        fontFamily: KC.fontMono,
                        fontSize: 10,
                        letterSpacing: 1.5,
                        color: widget.isActive
                            ? KC.textMuted
                            : KC.textDim,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Active indicator arrow
            if (widget.isActive)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11,
                  color: KC.textMuted,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Experience detail panel (right) ───────────────────────────────
class _ExpDetailPanel extends StatelessWidget {
  final _Exp exp;
  final int index;
  const _ExpDetailPanel({
    required this.exp,
    required this.index,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 28, 40, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Index + type ───────────────────────────────────
            Row(
              children: [
                KLabel('0${index + 1} — ${exp.company}'),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration:
                      BoxDecoration(border: Border.all(color: KC.border)),
                  child: Text(
                    exp.type.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: KC.fontMono,
                      fontSize: 9,
                      letterSpacing: 2,
                      color: KC.textDim,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Role title — big display ───────────────────────
            Text(
              exp.role,
              style: const TextStyle(
                fontFamily: KC.fontDisplay,
                fontWeight: FontWeight.w900,
                fontSize: 44,
                color: KC.textPrimary,
                letterSpacing: -1.5,
                height: 1.0,
              ),
            ),

            const SizedBox(height: 14),

            // ── Company + date row ─────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration:
                      BoxDecoration(border: Border.all(color: KC.border)),
                  child: Text(
                    '@ ${exp.company}',
                    style: const TextStyle(
                      fontFamily: KC.fontMono,
                      fontSize: 11,
                      letterSpacing: 1.5,
                      color: KC.textMuted,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  exp.range,
                  style: const TextStyle(
                    fontFamily: KC.fontMono,
                    fontSize: 11,
                    letterSpacing: 2,
                    color: KC.textDim,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),
            Container(height: 2, color: KC.borderStr),
            const SizedBox(height: 24),

            // ── Stats row ──────────────────────────────────────
            IntrinsicHeight(
              child: Row(
                children: [
                  ...exp.stats.asMap().entries.map((entry) {
                    final i = entry.key;
                    final stat = entry.value;
                    return Row(
                      children: [
                        _StatPill(
                            value: stat.value, label: stat.label),
                        if (i < exp.stats.length - 1)
                          Container(
                            width: 1,
                            color: KC.border,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 24),
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 28),
            Container(height: 1, color: KC.border),
            const SizedBox(height: 24),

            // ── Summary ────────────────────────────────────────
            Text(
              exp.summary,
              style: const TextStyle(
                fontFamily: KC.fontMono,
                fontSize: 14,
                color: KC.textSecondary,
                height: 1.9,
                letterSpacing: 0.2,
              ),
            ),

            const SizedBox(height: 24),

            // ── Bullet points with left rule ───────────────────
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 2,
                    color: KC.border,
                    margin: const EdgeInsets.only(right: 20),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: exp.points
                          .map((p) => _BulletPoint(text: p))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
            Container(height: 1, color: KC.border),
            const SizedBox(height: 20),

            // ── Stack used ─────────────────────────────────────
            KLabel('// Stack used'),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  exp.tags.map((t) => _TechTag(label: t)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stat pill ─────────────────────────────────────────────────────
class _StatPill extends StatelessWidget {
  final String value, label;
  const _StatPill({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: KC.fontDisplay,
              fontWeight: FontWeight.w900,
              fontSize: 42,
              color: KC.textPrimary,
              letterSpacing: -1,
              height: 1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontFamily: KC.fontMono,
              fontSize: 11,
              letterSpacing: 2.5,
              color: KC.textDim,
              height: 1.6,
            ),
          ),
        ],
      );
}

// ── Bullet point ──────────────────────────────────────────────────
class _BulletPoint extends StatelessWidget {
  final String text;
  const _BulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '— ',
            style: TextStyle(
              fontFamily: KC.fontMono,
              fontSize: 14,
              color: KC.textDim,
              height: 1.8,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: KC.fontMono,
                fontSize: 14,
                color: KC.textSecondary,
                height: 1.8,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tech tag ──────────────────────────────────────────────────────
class _TechTag extends StatefulWidget {
  final String label;
  const _TechTag({required this.label});

  @override
  State<_TechTag> createState() => _TechTagState();
}

class _TechTagState extends State<_TechTag> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: _hov ? KC.textPrimary : Colors.transparent,
          border: Border.all(
            color: _hov ? KC.textPrimary : KC.border,
          ),
        ),
        child: Text(
          widget.label.toUpperCase(),
          style: TextStyle(
            fontFamily: KC.fontMono,
            fontSize: 10,
            letterSpacing: 2,
            color: _hov ? KC.bg : KC.textMuted,
          ),
        ),
      ),
    );
  }
}

// ── Accordion item (narrow) ───────────────────────────────────────
class _AccordionItem extends StatelessWidget {
  final _Exp exp;
  final int index;
  final bool isOpen;
  final VoidCallback onTap;

  const _AccordionItem({
    required this.exp,
    required this.index,
    required this.isOpen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: KC.borderStr, width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────
          GestureDetector(
            onTap: onTap,
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isOpen
                          ? KC.textPrimary
                          : Colors.transparent,
                      border: Border.all(
                        color: isOpen ? KC.textPrimary : KC.textDim,
                        width: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '0${index + 1} — ${exp.company}',
                          style: const TextStyle(
                            fontFamily: KC.fontMono,
                            fontSize: 9,
                            letterSpacing: 2,
                            color: KC.textDim,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          exp.role.replaceAll('\n', ' '),
                          style: TextStyle(
                            fontFamily: KC.fontDisplay,
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                            color: isOpen
                                ? KC.textPrimary
                                : KC.textMuted,
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          exp.range,
                          style: const TextStyle(
                            fontFamily: KC.fontMono,
                            fontSize: 10,
                            color: KC.textDim,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isOpen ? 0.25 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: isOpen ? KC.textPrimary : KC.textDim,
                      size: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expandable detail ──────────────────────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: isOpen
                ? Container(
                    decoration: BoxDecoration(
                      border:
                          Border(top: BorderSide(color: KC.border)),
                      color: KC.textPrimary.withOpacity(0.02),
                    ),
                    padding:
                        const EdgeInsets.fromLTRB(24, 20, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stats row
                        IntrinsicHeight(
                          child: Row(
                            children: [
                              ...exp.stats.asMap().entries.map(
                                (entry) {
                                  final i = entry.key;
                                  final stat = entry.value;
                                  return Row(children: [
                                    _StatPill(
                                      value: stat.value,
                                      label: stat.label,
                                    ),
                                    if (i < exp.stats.length - 1)
                                      Container(
                                        width: 1,
                                        color: KC.border,
                                        margin: const EdgeInsets
                                            .symmetric(horizontal: 16),
                                      ),
                                  ]);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          exp.range,
                          style: const TextStyle(
                            fontFamily: KC.fontMono,
                            fontSize: 10,
                            letterSpacing: 2,
                            color: KC.textDim,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          exp.summary,
                          style: const TextStyle(
                            fontFamily: KC.fontMono,
                            fontSize: 13,
                            color: KC.textSecondary,
                            height: 1.8,
                          ),
                        ),
                        const SizedBox(height: 20),
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                width: 2,
                                color: KC.border,
                                margin:
                                    const EdgeInsets.only(right: 16),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: exp.points
                                      .map((p) =>
                                          _BulletPoint(text: p))
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: exp.tags
                              .map((t) => _TechTag(label: t))
                              .toList(),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
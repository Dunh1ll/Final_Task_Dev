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
      company: 'FDSAP',
      role: 'Mobile & Backend\nDeveloper Intern',
      range: 'Jan 2025 — Present',
      summary: 'Building cross-platform mobile apps and REST backends '
          'for a real-world production environment.',
      points: [
        'Built and maintained mobile applications using Flutter & Dart.',
        'Developed RESTful backend APIs using Golang and PostgreSQL.',
        'Collaborated with the team on UI/UX design and implementation.',
        'Implemented JWT-based authentication with OTP email verification.',
      ],
      tags: ['Flutter', 'Golang', 'PostgreSQL', 'JWT'],
    ),
    _Exp(
      company: 'Freelance',
      role: 'Freelance\nDeveloper',
      range: '2023 — 2024',
      summary: 'Sole developer on multiple client projects — '
          'from requirements gathering to final deployment.',
      points: [
        'Designed and built custom web and mobile apps for small clients.',
        'Handled full project lifecycle from requirements to deployment.',
        'Worked with Flutter, Firebase, and REST APIs.',
        'Delivered responsive UI designs based on client specifications.',
      ],
      tags: ['Flutter', 'Firebase', 'REST APIs'],
    ),
    _Exp(
      company: 'Open Source',
      role: 'Open Source\nContributor',
      range: '2022 — Present',
      summary: 'Contributed to the Flutter ecosystem through bug fixes, '
          'feature additions, and community engagement.',
      points: [
        'Contributed bug fixes and feature additions to Flutter packages.',
        'Reviewed and submitted pull requests on GitHub.',
        'Participated in community discussions and issue tracking.',
        'Built personal tools shared publicly on GitHub.',
      ],
      tags: ['Flutter', 'Dart', 'GitHub'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return KReveal(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(number: '02', title: 'Experience'),
          SizedBox(
            height: screenH,
            child: widget.isWide ? _wideLayout() : _narrowLayout(),
          ),
        ],
      ),
    );
  }

  // ── Wide layout ─────────────────────────────────────────────────
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
            child: _TimelinePanel(
              experiences: _experiences,
              selected: _selected,
              onSelect: (i) => setState(() => _selected = i),
            ),
          ),
        ),

        // RIGHT — detail panel
        Expanded(
          child: Align(
            alignment: Alignment.topLeft,
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
        ),
      ],
    );
  }

  // ── Narrow layout — accordion ────────────────────────────────────
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

// ── Experience data model ──────────────────────────────────────────
class _Exp {
  final String company, role, range, summary;
  final List<String> points;
  final List<String> tags;
  const _Exp({
    required this.company,
    required this.role,
    required this.range,
    required this.summary,
    required this.points,
    required this.tags,
  });
}

// ── Timeline panel (left) ──────────────────────────────────────────
class _TimelinePanel extends StatelessWidget {
  final List<_Exp> experiences;
  final int selected;
  final void Function(int) onSelect;

  const _TimelinePanel({
    required this.experiences,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KLabel('// Timeline'),
          const SizedBox(height: 20),
          // Timeline list
          ...List.generate(experiences.length, (i) {
            final isLast = i == experiences.length - 1;
            return _TimelineNode(
              index: i,
              exp: experiences[i],
              isActive: selected == i,
              isLast: isLast,
              onTap: () => onSelect(i),
            );
          }),
        ],
      ),
    );
  }
}

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
            // ── Node + vertical line ──────────────────────────
            SizedBox(
              width: 32,
              child: Column(
                children: [
                  // Circle node
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 20,
                    height: 20,
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
                                fontSize: 8,
                                color: _hov
                                    ? KC.textPrimary
                                    : KC.textDim,
                              ),
                            ),
                          ),
                  ),
                  // Connecting line
                  if (!widget.isLast)
                    Container(
                      width: 1,
                      height: 80,
                      color: KC.border,
                    ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // ── Text content ──────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontFamily: KC.fontDisplay,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: widget.isActive || _hov
                            ? KC.textPrimary
                            : KC.textMuted,
                        letterSpacing: -0.3,
                        height: 1.1,
                      ),
                      child: Text(widget.exp.company),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.exp.range,
                      style: TextStyle(
                        fontFamily: KC.fontMono,
                        fontSize: 9,
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
  const _ExpDetailPanel({required this.exp, required this.index, super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 24, 40, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Index label ───────────────────────────────────
            KLabel('0${index + 1} — ${exp.company}'),
            const SizedBox(height: 10),

            // ── Role title — big display ───────────────────────
            Text(
              exp.role,
              style: const TextStyle(
                fontFamily: KC.fontDisplay,
                fontWeight: FontWeight.w900,
                fontSize: 40,
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
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: KC.border),
                  ),
                  child: Text(
                    '@ ${exp.company}',
                    style: const TextStyle(
                      fontFamily: KC.fontMono,
                      fontSize: 10,
                      letterSpacing: 1.5,
                      color: KC.textMuted,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  exp.range,
                  style: const TextStyle(
                    fontFamily: KC.fontMono,
                    fontSize: 10,
                    letterSpacing: 2,
                    color: KC.textDim,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),
            Container(height: 2, color: KC.borderStr),
            const SizedBox(height: 28),

            // ── Summary line ───────────────────────────────────
            Text(
              exp.summary,
              style: const TextStyle(
                fontFamily: KC.fontMono,
                fontSize: 13,
                color: KC.textSecondary,
                height: 1.9,
                letterSpacing: 0.2,
              ),
            ),

            const SizedBox(height: 28),

            // ── Bullet points with left rule ───────────────────
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left rule
                  Container(
                    width: 2,
                    color: KC.border,
                    margin: const EdgeInsets.only(right: 20),
                  ),
                  // Points
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

            const SizedBox(height: 32),
            Container(height: 1, color: KC.border),
            const SizedBox(height: 20),

            // ── Tech tags ──────────────────────────────────────
            KLabel('// Stack used'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: exp.tags
                  .map((t) => _TechTag(label: t))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

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
              fontSize: 13,
              color: KC.textDim,
              height: 1.8,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: KC.fontMono,
                fontSize: 13,
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
          color:
              _hov ? KC.textPrimary : Colors.transparent,
          border: Border.all(
            color: _hov ? KC.textPrimary : KC.border,
          ),
        ),
        child: Text(
          widget.label.toUpperCase(),
          style: TextStyle(
            fontFamily: KC.fontMono,
            fontSize: 9,
            letterSpacing: 2,
            color: _hov ? KC.bg : KC.textMuted,
          ),
        ),
      ),
    );
  }
}

// ── Accordion item (narrow) ────────────────────────────────────────
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
          // ── Header — always visible ──────────────────────────
          GestureDetector(
            onTap: onTap,
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  // Node circle
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isOpen
                          ? KC.textPrimary
                          : Colors.transparent,
                      border: Border.all(
                        color: isOpen
                            ? KC.textPrimary
                            : KC.textDim,
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
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isOpen ? 0.25 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: isOpen
                          ? KC.textPrimary
                          : KC.textDim,
                      size: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expandable detail ────────────────────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: isOpen
                ? Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: KC.border),
                      ),
                      color: KC.textPrimary.withOpacity(0.02),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Range
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
                        // Summary
                        Text(
                          exp.summary,
                          style: const TextStyle(
                            fontFamily: KC.fontMono,
                            fontSize: 12,
                            color: KC.textSecondary,
                            height: 1.8,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Left rule + bullets
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
                                      .map((p) => _BulletPoint(text: p))
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Tags
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
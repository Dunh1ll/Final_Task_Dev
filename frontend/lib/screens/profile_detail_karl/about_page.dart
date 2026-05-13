import 'package:flutter/material.dart';
import 'constants.dart';
import 'utilities.dart';

class KAboutPage extends StatelessWidget {
  final bool isWide;
  const KAboutPage({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return KReveal(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(number: '01', title: 'About'),
          isWide ? _wideLayout(context) : _narrowLayout(context),
        ],
      ),
    );
  }

  Widget _wideLayout(BuildContext context) {
    // Fill remaining viewport height after navbar + ticker + section header
    final availH = MediaQuery.of(context).size.height - 68 - 36 - 74;

    return SizedBox(
      height: availH,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── LEFT PANEL ──────────────────────────────────────
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
                  Container(height: 2, color: KC.borderStr),
                  const Expanded(child: _QuickStats()),
                ],
              ),
            ),
          ),

          // ── RIGHT PANEL — tabbed ────────────────────────────
          const Expanded(
            child: _TabbedRightPanel(),
          ),
        ],
      ),
    );
  }

  Widget _narrowLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PhotoBox(),
        Container(height: 2, color: KC.borderStr),
        _IdentityBlock(),
        Container(height: 2, color: KC.borderStr),
        _QuickStats(),
        Container(height: 2, color: KC.borderStr),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          child: const _TabbedRightPanel(isNarrow: true),
        ),
      ],
    );
  }
}

// ── Public SectionHeader ──────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String number, title;
  const SectionHeader({required this.number, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
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
                fontSize: 13,
                letterSpacing: 2.5,
                color: KC.textDim,
              ),
            ),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontFamily: KC.fontDisplay,
              fontWeight: FontWeight.w900,
              fontSize: 36,
              letterSpacing: -0.5,
              color: KC.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tabbed Right Panel ────────────────────────────────────────────
class _TabbedRightPanel extends StatefulWidget {
  final bool isNarrow;
  const _TabbedRightPanel({this.isNarrow = false});

  @override
  State<_TabbedRightPanel> createState() => _TabbedRightPanelState();
}

class _TabbedRightPanelState extends State<_TabbedRightPanel> {
  int _tab = 0;
  static const _tabs = ['Bio', 'Stack', 'Journey', 'Interests'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Tab bar ───────────────────────────────────────────
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: KC.borderStr, width: 2),
            ),
          ),
          child: Row(
            children: List.generate(
              _tabs.length,
              (i) => _TabItem(
                label: _tabs[i],
                isActive: _tab == i,
                onTap: () => setState(() => _tab = i),
              ),
            ),
          ),
        ),

        // ── Tab content — fills remaining height, scrolls inside ──
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.012, 0),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: KeyedSubtree(
              key: ValueKey(_tab),
              child: _tabContent(_tab),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tabContent(int tab) {
    switch (tab) {
      case 0: return const _BioTab();
      case 1: return const _StackTab();
      case 2: return const _JourneyTab();
      case 3: return const _InterestsTab();
      default: return const _BioTab();
    }
  }
}

// ── Tab Item ──────────────────────────────────────────────────────
class _TabItem extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _TabItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_TabItem> createState() => _TabItemState();
}

class _TabItemState extends State<_TabItem> {
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
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 17),
          decoration: BoxDecoration(
            color: widget.isActive
                ? KC.textPrimary.withOpacity(0.06)
                : (_hov ? KC.textPrimary.withOpacity(0.03) : Colors.transparent),
            border: Border(
              bottom: BorderSide(
                color: widget.isActive ? KC.textPrimary : Colors.transparent,
                width: 2.5,
              ),
              right: BorderSide(color: KC.border, width: 1),
            ),
          ),
          child: Text(
            widget.label.toUpperCase(),
            style: TextStyle(
              fontFamily: KC.fontMono,
              fontSize: 12,
              letterSpacing: 2.5,
              fontWeight:
                  widget.isActive ? FontWeight.w700 : FontWeight.normal,
              color: widget.isActive
                  ? KC.textPrimary
                  : (_hov ? KC.textSecondary : KC.textDim),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Bio Tab ───────────────────────────────────────────────────────
class _BioTab extends StatelessWidget {
  const _BioTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Currently block
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              border: Border.all(color: KC.border),
              color: KC.textPrimary.withOpacity(0.025),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _PulseDot(),
                    const SizedBox(width: 10),
                    const Text(
                      'CURRENTLY',
                      style: TextStyle(
                        fontFamily: KC.fontMono,
                        fontSize: 10,
                        letterSpacing: 3.5,
                        color: KC.textDim,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Software Developer Intern',
                  style: TextStyle(
                    fontFamily: KC.fontDisplay,
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    color: KC.textPrimary,
                    letterSpacing: -0.5,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'FDS Asya Philippines Inc.  ·  May 2026 → Present',
                  style: TextStyle(
                    fontFamily: KC.fontMono,
                    fontSize: 13,
                    color: KC.textMuted,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _Chip('Flutter'),
                    _Chip('Go (Golang)'),
                    _Chip('PostgreSQL'),
                    _Chip('Node.js'),
                    _Chip('Firebase'),
                    _Chip('AI-Assisted Dev'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
          KLabel('// Who I am'),
          const SizedBox(height: 14),

          const _Para(
            "Hi, I'm Karl — a 4th-year Information Systems student at "
            "CARD MRI Development Institute, passionate about building "
            "modern, user-focused applications.",
          ),
          const SizedBox(height: 14),
          const _Para(
            "I have experience developing web and system-based projects "
            "using Next.js, Node.js, Firebase, Flutter, Go, and PostgreSQL. "
            "I continuously improve through collaborative development, "
            "internship experience, and hands-on system building.",
          ),
          const SizedBox(height: 14),
          const _Para(
            "Currently at FDS Asya Philippines Inc., working on Flutter "
            "mobile apps, Go backends, and AI-assisted development workflows "
            "in a production-level environment.",
          ),

          const SizedBox(height: 28),
          Container(height: 1, color: KC.border),
          const SizedBox(height: 24),

          KLabel('// Education'),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration:
                    BoxDecoration(border: Border.all(color: KC.border)),
                child: const Icon(Icons.school_outlined,
                    color: KC.textMuted, size: 22),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'BS Information Systems',
                      style: TextStyle(
                        fontFamily: KC.fontDisplay,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: KC.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'CARD MRI Development Institute, Inc.',
                      style: TextStyle(
                        fontFamily: KC.fontMono,
                        fontSize: 14,
                        color: KC.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '4th Year  ·  Currently Enrolled',
                      style: TextStyle(
                        fontFamily: KC.fontMono,
                        fontSize: 12,
                        color: KC.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
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

// ── Stack Tab ─────────────────────────────────────────────────────
class _StackTab extends StatelessWidget {
  const _StackTab();

  static const _skills = [
    _SkillData('Flutter & Dart',   0.90),
    _SkillData('Go (Golang)',       0.80),
    _SkillData('REST APIs',         0.85),
    _SkillData('PostgreSQL',        0.75),
    _SkillData('Next.js / Node.js', 0.82),
    _SkillData('Firebase',          0.85),
    _SkillData('UI / UX Design',    0.78),
    _SkillData('Git & GitHub',      0.88),
  ];

  static const _groups = [
    _StackGroup('Frontend', [
      'Flutter', 'Dart', 'HTML', 'CSS', 'JavaScript', 'Next.js',
    ]),
    _StackGroup('Backend & Database', [
      'Node.js', 'Go (Golang)', 'Firebase', 'PostgreSQL',
    ]),
    _StackGroup('Tools', [
      'Git & GitHub', 'VS Code', 'Android Studio',
      'Figma', 'REST API', 'RFID Integration',
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KLabel('// Proficiency'),
          const SizedBox(height: 18),
          ..._skills.map((s) => _SkillBar(skill: s)),

          const SizedBox(height: 22),
          Container(height: 1, color: KC.border),
          const SizedBox(height: 22),

          KLabel('// Full stack'),
          const SizedBox(height: 18),
          ..._groups.map(
            (g) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    g.label.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: KC.fontMono,
                      fontSize: 10,
                      letterSpacing: 2.5,
                      color: KC.textDim,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children:
                        g.items.map((item) => _Chip(item)).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StackGroup {
  final String label;
  final List<String> items;
  const _StackGroup(this.label, this.items);
}

class _SkillData {
  final String name;
  final double level;
  const _SkillData(this.name, this.level);
}

class _SkillBar extends StatefulWidget {
  final _SkillData skill;
  const _SkillBar({required this.skill});

  @override
  State<_SkillBar> createState() => _SkillBarState();
}

class _SkillBarState extends State<_SkillBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100));
    _anim = Tween<double>(begin: 0, end: widget.skill.level).animate(
        CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.skill.name,
                  style: const TextStyle(
                    fontFamily: KC.fontMono,
                    fontSize: 13,
                    color: KC.textSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _anim,
                builder: (_, __) => Text(
                  '${(_anim.value * 100).round()}%',
                  style: const TextStyle(
                    fontFamily: KC.fontMono,
                    fontSize: 12,
                    color: KC.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => Stack(
              children: [
                Container(height: 3, color: KC.border),
                FractionallySizedBox(
                  widthFactor: _anim.value,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        KC.textMuted.withOpacity(0.5),
                        KC.textPrimary,
                      ]),
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
}

// ── Journey Tab ───────────────────────────────────────────────────
class _JourneyTab extends StatelessWidget {
  const _JourneyTab();

  static const _milestones = [
    _Milestone('2023', 'Foundations',
        'Academic projects, frontend & backend fundamentals. '
        'SPES Participant and Retail Store Clerk.'),
    _Milestone('2024', 'Web Development',
        'Academic systems with JavaScript and Next.js. '
        'System design and database integration.'),
    _Milestone('2025', 'Full-Stack Growth',
        'Next.js, Node.js, and Firebase projects. '
        'Authentication systems and real-time database management.'),
    _Milestone('2026', 'Internship @ FDSAP',
        'Flutter, Go, PostgreSQL in production. '
        'AI-assisted workflows at FDS Asya Philippines Inc.'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KLabel('// Journey & milestones'),
          const SizedBox(height: 26),
          ..._milestones.asMap().entries.map((entry) {
            final i = entry.key;
            final m = entry.value;
            return _TimelineRow(
              year: m.year,
              title: m.title,
              desc: m.desc,
              isLast: i == _milestones.length - 1,
            );
          }),

          const SizedBox(height: 26),
          Container(height: 1, color: KC.border),
          const SizedBox(height: 22),

          KLabel('// Featured academic project'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              border: Border.all(color: KC.border),
              color: KC.textPrimary.withOpacity(0.02),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RFID Time Attendance System',
                  style: TextStyle(
                    fontFamily: KC.fontDisplay,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: KC.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Smart attendance monitoring platform for faculty and '
                  'students. RFID scanning, real-time recording, role '
                  'management, admin dashboard, and Firebase integration.',
                  style: TextStyle(
                    fontFamily: KC.fontMono,
                    fontSize: 13,
                    color: KC.textMuted,
                    height: 1.8,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _Chip('Flutter'),
                    _Chip('Node.js'),
                    _Chip('Firebase'),
                    _Chip('RFID Technology'),
                    _Chip('REST API'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Milestone {
  final String year, title, desc;
  const _Milestone(this.year, this.title, this.desc);
}

class _TimelineRow extends StatelessWidget {
  final String year, title, desc;
  final bool isLast;
  const _TimelineRow({
    required this.year,
    required this.title,
    required this.desc,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isLast ? KC.textPrimary : Colors.transparent,
                border: Border.all(
                  color: isLast ? KC.textPrimary : KC.border,
                  width: 2,
                ),
              ),
            ),
            if (!isLast)
              Container(width: 1, height: 62, color: KC.border),
          ],
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  year,
                  style: const TextStyle(
                    fontFamily: KC.fontMono,
                    fontSize: 11,
                    color: KC.textDim,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: KC.fontDisplay,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: isLast ? KC.textPrimary : KC.textSecondary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    fontFamily: KC.fontMono,
                    fontSize: 13,
                    color: KC.textMuted,
                    height: 1.7,
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

// ── Interests Tab ─────────────────────────────────────────────────
class _InterestsTab extends StatelessWidget {
  const _InterestsTab();

  static const _interests = [
    ('📱', 'Mobile & Web Development',   'Flutter, Next.js, React'),
    ('🎨', 'UI/UX Design',               'Figma, Responsive Design'),
    ('🖥️', 'System Development',         'Full-stack, RFID Systems'),
    ('🤖', 'Learning Modern Frameworks', 'Always exploring new stacks'),
    ('🎮', 'Gaming & Technology',         'Tech enthusiast, gamer'),
    ('🎵', 'Music',                       'Playing instruments'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KLabel('// Interests & passions'),
          const SizedBox(height: 22),
          ..._interests.map(
            (i) => _InterestRow(emoji: i.$1, label: i.$2, sub: i.$3),
          ),
        ],
      ),
    );
  }
}

class _InterestRow extends StatefulWidget {
  final String emoji, label, sub;
  const _InterestRow({
    required this.emoji,
    required this.label,
    required this.sub,
  });

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
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
        decoration: BoxDecoration(
          color: _hov
              ? KC.textPrimary.withOpacity(0.05)
              : Colors.transparent,
          border: const Border(
            bottom: BorderSide(color: KC.border, width: 1),
          ),
        ),
        child: Row(
          children: [
            Text(widget.emoji,
                style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 160),
                    style: TextStyle(
                      fontFamily: KC.fontMono,
                      fontSize: 15,
                      letterSpacing: 0.3,
                      color: _hov
                          ? KC.textPrimary
                          : KC.textSecondary,
                    ),
                    child: Text(widget.label),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.sub,
                    style: const TextStyle(
                      fontFamily: KC.fontMono,
                      fontSize: 12,
                      color: KC.textDim,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              transform:
                  Matrix4.translationValues(_hov ? 5 : 0, 0, 0),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: _hov ? KC.textMuted : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared Chip ───────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(border: Border.all(color: KC.border)),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontFamily: KC.fontMono,
          fontSize: 10,
          letterSpacing: 2,
          color: KC.textMuted,
        ),
      ),
    );
  }
}

// ── Para ──────────────────────────────────────────────────────────
class _Para extends StatelessWidget {
  final String text;
  const _Para(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontFamily: KC.fontMono,
          fontSize: 15,
          color: KC.textSecondary,
          height: 1.9,
          letterSpacing: 0.2,
        ),
      );
}

// ── Photo Box ─────────────────────────────────────────────────────
class _PhotoBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Stack(
        children: [
          Positioned(
            top: 8, left: 8, right: -8, bottom: -8,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: KC.textPrimary.withOpacity(0.12),
                  width: 1,
                ),
              ),
            ),
          ),
          Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: KC.borderStr, width: 2),
              color: KC.bgLight,
            ),
            child: ClipRect(
              child: Image.asset(
                'assets/images/profile2.png',
                fit: BoxFit.cover,
                alignment: const Alignment(0.0, -0.2),
                errorBuilder: (_, __, ___) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'KA',
                        style: TextStyle(
                          fontFamily: KC.fontDisplay,
                          fontWeight: FontWeight.w900,
                          fontSize: 64,
                          color: KC.textPrimary,
                          letterSpacing: -3,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Karl Angelo Albaniel',
                        style: TextStyle(
                          fontFamily: KC.fontMono,
                          fontSize: 10,
                          color: KC.textDim,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Identity Block ────────────────────────────────────────────────
class _IdentityBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Karl Angelo M. Albaniel',
            style: TextStyle(
              fontFamily: KC.fontDisplay,
              fontWeight: FontWeight.w900,
              fontSize: 21,
              color: KC.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 7),
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
          const SizedBox(height: 18),
          _statLine('Role',   'Full-Stack Developer'),
          _statLine('Status', '4th Year IS Student'),
          _statLine('Base',   'Philippines'),
          _statLine('School', 'CARD MRI Dev. Institute'),
          _statLine('Email',  'kaloyalbaniel25@gmail.com'),
          _statLine('GitHub', 'github.com/yooolak'),
          _statLine('Phone',  '+63 994 934 2201'),
        ],
      ),
    );
  }

  Widget _statLine(String key, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
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
          Flexible(
            child: Text(
              val,
              style: const TextStyle(
                fontFamily: KC.fontMono,
                fontSize: 10,
                letterSpacing: 0.3,
                color: KC.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick Stats ───────────────────────────────────────────────────
class _QuickStats extends StatelessWidget {
  const _QuickStats();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KLabel('// Quick stats'),
          const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              children: [
                const _StatPill('3+', 'Years\nCoding'),
                Container(
                  width: 1,
                  color: KC.border,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),
                const _StatPill('10+', 'Projects\nBuilt'),
                Container(
                  width: 1,
                  color: KC.border,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),
                const _StatPill('1', 'Active\nIntern'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Pill ─────────────────────────────────────────────────────
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
              fontSize: 38,
              color: KC.textPrimary,
              letterSpacing: -1.5,
              height: 1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontFamily: KC.fontMono,
              fontSize: 9,
              letterSpacing: 2,
              color: KC.textDim,
              height: 1.5,
            ),
          ),
        ],
      );
}

// ── Pulse Dot ─────────────────────────────────────────────────────
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
        vsync: this,
        duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _o = Tween<double>(begin: 1.0, end: 0.2).animate(
        CurvedAnimation(parent: _c, curve: Curves.easeInOut));
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
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: KC.textPrimary,
            shape: BoxShape.circle,
          ),
        ),
      );
}
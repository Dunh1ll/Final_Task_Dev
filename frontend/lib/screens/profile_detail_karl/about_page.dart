import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'constants.dart';
import 'utilities.dart';

class KAboutPage extends StatelessWidget {
  final bool isWide;
  const KAboutPage({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return KReveal(
      delay: const Duration(milliseconds: 100),
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
    final kc = KTheme.colors(context);
    final availH = MediaQuery.of(context).size.height - 68 - 36 - 74;

    return SizedBox(
      height: availH,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 300,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: kc.borderStr, width: 2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PhotoBox(),
                  Container(height: 2, color: kc.borderStr),
                  _IdentityBlock(),
                  Container(height: 2, color: kc.borderStr),
                  const Expanded(child: _ResumeButton()),
                ],
              ),
            ),
          ),
          const Expanded(
            child: _TabbedRightPanel(),
          ),
        ],
      ),
    );
  }

  Widget _narrowLayout(BuildContext context) {
    final kc = KTheme.colors(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PhotoBox(),
        Container(height: 2, color: kc.borderStr),
        _IdentityBlock(),
        Container(height: 2, color: kc.borderStr),
        const _ResumeButton(),
        Container(height: 2, color: kc.borderStr),
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
    final kc = KTheme.colors(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: kc.borderStr, width: 2),
        ),
      ),
      child: Row(
        children: [
          if (number.isNotEmpty)
            Text(
              '$number — ',
              style: TextStyle(
                fontFamily: KC.fontMono,
                fontSize: 14,
                letterSpacing: 2.5,
                color: kc.textDim,
              ),
            ),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontFamily: KC.fontDisplay,
              fontWeight: FontWeight.w900,
              fontSize: 40,
              letterSpacing: -0.5,
              color: kc.textPrimary,
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
  static const _tabs = ['Bio', 'Stack', 'Interests', 'Education'];

  @override
  Widget build(BuildContext context) {
    final kc = KTheme.colors(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: kc.borderStr, width: 2),
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
              child: Align(
                alignment: Alignment.topLeft,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 24, 40, 40),
                  child: _tabContent(_tab),
                ),
              ),
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
      case 2: return const _InterestsTab();
      case 3: return const _EducationTab();
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
    final kc = KTheme.colors(context);
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
                ? kc.textPrimary.withOpacity(0.06)
                : (_hov ? kc.textPrimary.withOpacity(0.03) : Colors.transparent),
            border: Border(
              bottom: BorderSide(
                color: widget.isActive ? kc.textPrimary : Colors.transparent,
                width: 3,
              ),
              right: BorderSide(color: kc.border, width: 1),
            ),
          ),
          child: Text(
            widget.label.toUpperCase(),
            style: TextStyle(
              fontFamily: KC.fontMono,
              fontSize: 13,
              letterSpacing: 2.5,
              fontWeight: widget.isActive ? FontWeight.w700 : FontWeight.normal,
              color: widget.isActive
                  ? kc.textPrimary
                  : (_hov ? kc.textSecondary : kc.textDim),
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
    final kc = KTheme.colors(context);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: kc.border, width: 1.5),
              color: kc.textPrimary.withOpacity(0.025),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _PulseDot(),
                    const SizedBox(width: 10),
                    Text(
                      'CURRENTLY',
                      style: TextStyle(
                        fontFamily: KC.fontMono,
                        fontSize: 11,
                        letterSpacing: 3.5,
                        color: kc.textDim,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Software Developer Intern',
                  style: TextStyle(
                    fontFamily: KC.fontDisplay,
                    fontWeight: FontWeight.w900,
                    fontSize: 26,
                    color: kc.textPrimary,
                    letterSpacing: -0.5,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'FDS Asya Philippines Inc.  ·  May 2026 → Present',
                  style: TextStyle(
                    fontFamily: KC.fontMono,
                    fontSize: 14,
                    color: kc.textMuted,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 18),
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
          Container(height: 1.5, color: kc.border),
          const SizedBox(height: 32),

          KLabel('// Who I am'),
          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: kc.border, width: 1.5),
              color: kc.textPrimary.withOpacity(0.02),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 2,
                    color: kc.borderStr,
                    margin: const EdgeInsets.only(right: 20),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _NumberedPara('01',
                          "Hi, I'm Karl Angelo M. Albaniel, a 4th-year Information Systems student at "
                          "CARD MRI Development Institute, Inc. Passionate about building modern, "
                          "scalable, and user-focused applications across web and mobile."),
                        const SizedBox(height: 20),
                        Center(
                          child: Container(
                            width: 4, height: 4,
                            decoration: BoxDecoration(
                              color: kc.textDim,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _Para(
                          "I have worked on academic and real-world systems using technologies such as "
                          "Next.js, Node.js, Firebase, Flutter, Go, and PostgreSQL. I continue to grow "
                          "my skills through internship experience, collaborative projects, and "
                          "hands-on system development.",
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Container(
                            width: 4, height: 4,
                            decoration: BoxDecoration(
                              color: kc.textDim,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _Para(
                          "Currently at FDS Asya Philippines Inc., working on Flutter mobile apps, "
                          "Go backends, and AI-assisted development workflows in a production-level environment.",
                        ),
                      ],
                    ),
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

// ── Stack Tab ─────────────────────────────────────────────────────
class _StackTab extends StatelessWidget {
  const _StackTab();

  static const _groups = [
    _StackGroup('Frontend', [
      'Flutter', 'Dart', 'HTML', 'CSS', 'JavaScript', 'Next.js',
    ]),
    _StackGroup('Backend & Database', [
      'Node.js', 'Go (Golang)', 'Firebase', 'PostgreSQL',
    ]),
    _StackGroup('Tools & Technologies', [
      'Git & GitHub', 'VS Code', 'Android Studio',
      'Figma', 'REST API Integration', 'System Development Workflows', 'AI-assisted Development Tools',
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final kc = KTheme.colors(context);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KLabel('// Tech Stack'),
          const SizedBox(height: 22),
          ..._groups.map(
            (g) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: kc.border, width: 1.5),
                  color: kc.textPrimary.withOpacity(0.02),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      g.label.toUpperCase(),
                      style: TextStyle(
                        fontFamily: KC.fontMono,
                        fontSize: 11,
                        letterSpacing: 2.5,
                        color: kc.textDim,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: g.items.map((item) => _Chip(item)).toList(),
                    ),
                  ],
                ),
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

// ── Interests Tab ─────────────────────────────────────────────────
class _InterestsTab extends StatelessWidget {
  const _InterestsTab();

  static const _interests = [
    ('📱', 'Mobile & Web Development',      'Flutter, Next.js, React'),
    ('🎨', 'UI/UX Design',                  'Figma, Responsive Design'),
    ('🖥️', 'Full-Stack System Development', 'End-to-end system building'),
    ('⚙️', 'Backend Architecture',          'Scalable APIs & databases'),
    ('🤖', 'Learning Modern Frameworks',    'Always exploring new stacks'),
    ('🏗️', 'Building Real-World Systems',   'Production-ready applications'),
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
    final kc = KTheme.colors(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: _hov ? kc.textPrimary.withOpacity(0.10) : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: kc.border, width: 1),
          ),
        ),
        child: Row(
          children: [
            Text(widget.emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 160),
                    style: TextStyle(
                      fontFamily: KC.fontMono,
                      fontSize: 16,
                      letterSpacing: 0.3,
                      color: _hov ? kc.textPrimary : kc.textSecondary,
                    ),
                    child: Text(widget.label),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.sub,
                    style: TextStyle(
                      fontFamily: KC.fontMono,
                      fontSize: 13,
                      color: kc.textDim,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              transform: Matrix4.translationValues(_hov ? 5 : 0, 0, 0),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: _hov ? kc.textMuted : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Education Tab ─────────────────────────────────────────────────
class _EducationTab extends StatelessWidget {
  const _EducationTab();

  static const _coreAreas = [
    'Software Development',
    'Systems Analysis & Design',
    'Database Management',
    'Web & Mobile Development',
    'Human-Computer Interaction',
  ];

  @override
  Widget build(BuildContext context) {
    final kc = KTheme.colors(context);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KLabel('// Education'),
          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: kc.border, width: 1.5),
              color: kc.textPrimary.withOpacity(0.02),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    border: Border.all(color: kc.borderStr, width: 1.5),
                  ),
                  child: Icon(Icons.school_outlined,
                      color: kc.textMuted, size: 24),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BS Information Systems',
                        style: TextStyle(
                          fontFamily: KC.fontDisplay,
                          fontWeight: FontWeight.w900,
                          fontSize: 26,
                          color: kc.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'CARD MRI Development Institute, Inc.',
                        style: TextStyle(
                          fontFamily: KC.fontMono,
                          fontSize: 15,
                          color: kc.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '4th Year  ·  Currently Enrolled',
                        style: TextStyle(
                          fontFamily: KC.fontMono,
                          fontSize: 13,
                          color: kc.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),
          Container(height: 1.5, color: kc.border),
          const SizedBox(height: 24),

          KLabel('// Core Areas'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _coreAreas.map((area) => _Chip(area)).toList(),
          ),
        ],
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
    final kc = KTheme.colors(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: kc.border, width: 1.5),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: KC.fontMono,
          fontSize: 11,
          letterSpacing: 2,
          color: kc.textMuted,
          fontWeight: FontWeight.w600,
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
        style: TextStyle(
          fontFamily: KC.fontMono,
          fontSize: 15,
          color: KTheme.colors(context).textSecondary,
          height: 2.0,
          letterSpacing: 0.2,
        ),
      );
}

class _NumberedPara extends StatelessWidget {
  final String number, text;
  const _NumberedPara(this.number, this.text);

  @override
  Widget build(BuildContext context) {
    final kc = KTheme.colors(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$number.',
          style: TextStyle(
            fontFamily: KC.fontMono,
            fontSize: 10,
            letterSpacing: 1,
            color: kc.textDim,
            height: 2.2,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: KC.fontMono,
              fontSize: 14,
              color: kc.textSecondary,
              height: 1.85,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Photo Box ─────────────────────────────────────────────────────
class _PhotoBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final kc = KTheme.colors(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Stack(
        children: [
          Positioned(
            top: 10, left: 10, right: -10, bottom: -10,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: kc.textPrimary.withOpacity(0.25),
                  width: 1.5,
                ),
              ),
            ),
          ),
          Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: kc.borderStr, width: 2),
              color: kc.bgLight,
            ),
            child: ClipRect(
              child: Image.asset(
                'assets/images/profile2.png',
                fit: BoxFit.cover,
                alignment: const Alignment(0.0, -0.2),
                errorBuilder: (_, __, ___) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'KA',
                        style: TextStyle(
                          fontFamily: KC.fontDisplay,
                          fontWeight: FontWeight.w900,
                          fontSize: 64,
                          color: kc.textPrimary,
                          letterSpacing: -3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Karl Angelo Albaniel',
                        style: TextStyle(
                          fontFamily: KC.fontMono,
                          fontSize: 10,
                          color: kc.textDim,
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
    final kc = KTheme.colors(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Karl Angelo M. Albaniel',
            style: TextStyle(
              fontFamily: KC.fontDisplay,
              fontWeight: FontWeight.w900,
              fontSize: 20,
              color: kc.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              _PulseDot(),
              const SizedBox(width: 8),
              Text(
                'AVAILABLE FOR WORK',
                style: TextStyle(
                  fontFamily: KC.fontMono,
                  fontSize: 11,
                  letterSpacing: 3,
                  color: kc.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _statLine(kc, 'Role',   'Full-Stack Developer'),
          _statLine(kc, 'Status', '4th Year IS Student'),
          _statLine(kc, 'Base',   'Philippines'),
          _statLine(kc, 'School', 'CARD MRI Dev. Institute'),
        ],
      ),
    );
  }

  Widget _statLine(KColors kc, String key, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          SizedBox(
            width: 58,
            child: Text(
              key,
              style: TextStyle(
                fontFamily: KC.fontMono,
                fontSize: 12,
                letterSpacing: 1,
                color: kc.textDim,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: kc.border,
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
          Expanded(
            child: Text(
              val,
              style: TextStyle(
                fontFamily: KC.fontMono,
                fontSize: 12,
                letterSpacing: 0.3,
                color: kc.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Resume Button ─────────────────────────────────────────────────
class _ResumeButton extends StatefulWidget {
  const _ResumeButton();

  @override
  State<_ResumeButton> createState() => _ResumeButtonState();
}

class _ResumeButtonState extends State<_ResumeButton> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    final kc = KTheme.colors(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 2,
            color: kc.textPrimary,
            margin: const EdgeInsets.only(bottom: 12),
          ),
          Text(
            'Open to opportunities',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: KC.fontDisplay,
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: kc.textPrimary,
              height: 1.3,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'and collaborations.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: KC.fontDisplay,
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: kc.textPrimary,
              height: 1.3,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Let's build something together.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: KC.fontMono,
              fontSize: 13,
              color: kc.textMuted,
              height: 1.5,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 14),
          MouseRegion(
            onEnter: (_) => setState(() => _hov = true),
            onExit: (_) => setState(() => _hov = false),
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () async {
                final uri = Uri.parse(
                    'https://drive.google.com/file/d/197NgI4I7EYjamOrspb5Iro8Eh1NXzRmF/view');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 32),
                decoration: BoxDecoration(
                  color: _hov ? kc.textPrimary : Colors.transparent,
                  border: Border.all(color: kc.textPrimary, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'RESUME',
                      style: TextStyle(
                        fontFamily: KC.fontMono,
                        fontSize: 12,
                        letterSpacing: 4,
                        color: _hov ? kc.bg : kc.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      transform: Matrix4.translationValues(_hov ? 4 : 0, 0, 0),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: _hov ? kc.bg : kc.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
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
  Widget build(BuildContext context) {
    final kc = KTheme.colors(context);
    return FadeTransition(
      opacity: _o,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: kc.textPrimary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
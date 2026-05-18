import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'constants.dart';
import 'utilities.dart';
import 'about_page.dart' show SectionHeader;

class KProjectsPage extends StatelessWidget {
  final bool isWide;
  const KProjectsPage({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return KReveal(
      delay: const Duration(milliseconds: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(number: '03', title: 'Projects'),
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
          // ── Left: tabbed project detail ──────────────────────
          Expanded(
            flex: 6,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: kc.borderStr, width: 2),
                ),
              ),
              child: const _ProjectTabbedPanel(),
            ),
          ),
          // ── Right: fixed image / visual ──────────────────────
          SizedBox(
            width: 820,
            child: _ProjectImagePanel(),
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
        // image on top for narrow
        SizedBox(
          width: double.infinity,
          height: 220,
          child: _ProjectImagePanel(),
        ),
        Container(height: 2, color: kc.borderStr),
        SizedBox(
          height: 520,
          child: const _ProjectTabbedPanel(isNarrow: true),
        ),
      ],
    );
  }
}

// ── Project Image Panel ───────────────────────────────────────────
class _ProjectImagePanel extends StatelessWidget {
  @override
Widget build(BuildContext context) {
  final kc = KTheme.colors(context);
  return Stack(
    fit: StackFit.expand,
    children: [
      // image fills the panel
      Padding(
        padding: const EdgeInsets.all(32),
        child: Image.asset(
          'assets/images/rtas.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Center(
            child: Text(
              'RTAS',
              style: TextStyle(
                fontFamily: KC.fontDisplay,
                fontWeight: FontWeight.w900,
                fontSize: 48,
                color: kc.textPrimary,
                letterSpacing: -2,
              ),
            ),
          ),
        ),
      ),

      // minimalist border around image
      Positioned(
        top: 16,
        left: 65,
        right: 65,
        bottom: 16,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: kc.borderStr.withOpacity(0.65),
              width: 1.5,
            ),
          ),
        ),
      ),

      // rotated side label
      Positioned(
        left: 14,
        top: 0,
        bottom: 0,
        child: Center(
          child: RotatedBox(
            quarterTurns: 3,
            child: Text(
              'FEATURED PROJECT',
              style: TextStyle(
                fontFamily: KC.fontMono,
                fontSize: 9,
                letterSpacing: 4,
                fontWeight: FontWeight.w600,
                color: kc.textDim,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
}

// ── Project Tabbed Panel ──────────────────────────────────────────
class _ProjectTabbedPanel extends StatefulWidget {
  final bool isNarrow;
  const _ProjectTabbedPanel({this.isNarrow = false});

  @override
  State<_ProjectTabbedPanel> createState() => _ProjectTabbedPanelState();
}

class _ProjectTabbedPanelState extends State<_ProjectTabbedPanel> {
  int _tab = 0;
  static const _tabs = ['Overview', 'Stack', 'Features', 'Links'];

  @override
  Widget build(BuildContext context) {
    final kc = KTheme.colors(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Project selector header ───────────────────────────
        _ProjectHeader(),
        // ── Tab bar ───────────────────────────────────────────
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
                index: i,
                isActive: _tab == i,
                onTap: () => setState(() => _tab = i),
              ),
            ),
          ),
        ),
        // ── Tab content ───────────────────────────────────────
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
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
      case 0: return const _OverviewTab();
      case 1: return const _StackTab();
      case 2: return const _FeaturesTab();
      case 3: return const _LinksTab();
      default: return const _OverviewTab();
    }
  }
}

// ── Project Header ────────────────────────────────────────────────
class _ProjectHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final kc = KTheme.colors(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: kc.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          // project number dot
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              border: Border.all(color: kc.borderStr, width: 1.5),
            ),
            child: Center(
              child: Text(
                '01',
                style: TextStyle(
                  fontFamily: KC.fontMono,
                  fontSize: 12,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w700,
                  color: kc.textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RTAS',
                style: TextStyle(
                  fontFamily: KC.fontDisplay,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  letterSpacing: -0.5,
                  color: kc.textPrimary,
                ),
              ),
              Text(
                'RFID-Based Real-Time Attendance System',
                style: TextStyle(
                  fontFamily: KC.fontMono,
                  fontSize: 12,
                  letterSpacing: 0.5,
                  color: kc.textDim,
                ),
              ),
            ],
          ),
          const Spacer(),
          // status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              border: Border.all(color: kc.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PulseDot(),
                const SizedBox(width: 8),
                Text(
                  'COMPLETED',
                  style: TextStyle(
                    fontFamily: KC.fontMono,
                    fontSize: 11,
                    letterSpacing: 2,
                    color: kc.textMuted,
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

// ── Tab Item ──────────────────────────────────────────────────────
class _TabItem extends StatefulWidget {
  final String label;
  final int index;
  final bool isActive;
  final VoidCallback onTap;
  const _TabItem({
    required this.label,
    required this.index,
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
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          decoration: BoxDecoration(
            color: widget.isActive
                ? kc.textPrimary.withOpacity(0.06)
                : (_hov ? kc.textPrimary.withOpacity(0.03) : Colors.transparent),
            border: Border(
              bottom: BorderSide(
                color: widget.isActive ? kc.textPrimary : Colors.transparent,
                width: 2,
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

// ── Overview Tab ──────────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    final kc = KTheme.colors(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(36, 32, 36, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // badges row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Badge('Full-Stack', kc, strong: true),
              _Badge('RFID + Web', kc),
              _Badge('Academic · Real-World', kc),
            ],
          ),
          const SizedBox(height: 24),

          // big title
          Text(
            'RTAS',
            style: TextStyle(
              fontFamily: KC.fontDisplay,
              fontWeight: FontWeight.w900,
              fontSize: 80,
              color: kc.textPrimary,
              letterSpacing: -3,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'RFID-Based Real-Time Attendance System',
            style: TextStyle(
              fontFamily: KC.fontDisplay,
              fontWeight: FontWeight.w700,
              fontSize: 19,
              color: kc.textSecondary,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 24),
          Container(height: 1.5, color: kc.border),
          const SizedBox(height: 24),

          // description
          Text(
            'A web-based attendance monitoring system using RFID hardware '
            'integration for real-time tracking, with admin and faculty '
            'management modules, automated email notifications, and Excel '
            'report generation.',
            style: TextStyle(
              fontFamily: KC.fontMono,
              fontSize: 15,
              color: kc.textSecondary,
              height: 2.0,
              letterSpacing: 0.2,
            ),
          ),

          const SizedBox(height: 32),

          // role + type row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _InfoBlock(
                label: '// My role',
                value: 'Full-Stack Developer',
                sub: '',
                kc: kc,
              ),
              const SizedBox(width: 32),
              Container(width: 1, height: 72, color: kc.border),
              const SizedBox(width: 32),
              _InfoBlock(
                label: '// Project type',
                value: 'Academic · Real-World',
                sub: 'Hardware + Software integration',
                kc: kc,
              ),
              const SizedBox(width: 32),
              Container(width: 1, height: 72, color: kc.border),
              const SizedBox(width: 32),
              _InfoBlock(
                label: '// Year',
                value: '2024',
                sub: 'Capstone Project',
                kc: kc,
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

  static const _groups = [
    _StackGroup('Frontend', [
      'Next.js', 'React.js', 'Tailwind CSS', 'GSAP', 'Lucide Icons',
    ]),
    _StackGroup('Backend & Services', [
      'Next.js API Routes', 'Node.js', 'Firebase Admin SDK', 'Nodemailer',
    ]),
    _StackGroup('Database & Hardware', [
      'Firebase Firestore', 'Firebase Realtime DB', 'RFID RC522 reader', 'Arduino UNO', 'RFID Tags/Stickers/Cards',
    ]),
    _StackGroup('Utilities', [
      'XLSX', 'File-saver', 'React Toastify',
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final kc = KTheme.colors(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(36, 32, 36, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KLabel('// Tech stack'),
          const SizedBox(height: 24),
          Expanded(
            child: Column(
              children: _groups.map((g) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    border: Border.all(color: kc.border, width: 1),
                    color: kc.textPrimary.withOpacity(0.015),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 130,
                        child: Text(
                          g.label.toUpperCase(),
                          style: TextStyle(
                            fontFamily: KC.fontMono,
                            fontSize: 11,
                            letterSpacing: 2,
                            color: kc.textDim,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: null,
                        color: kc.border,
                        margin: const EdgeInsets.only(right: 16),
                      ),
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: g.items
                              .map((item) => _Chip(item, kc))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              )).toList(),
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

// ── Features Tab ──────────────────────────────────────────────────
class _FeaturesTab extends StatelessWidget {
  const _FeaturesTab();

  static const _features = [
    'RFID reader integration via SerialPort',
    'Real-time attendance tracking',
    'Admin and faculty management modules',
    'Automated email notifications',
    'Excel report export (XLSX)',
    'Role-based access control',
  ];

  static const _built = [
    'Integrated RFID hardware with the web system via Node.js SerialPort communication',
    'Built attendance validation logic and data flow between hardware and Firebase',
    'Developed admin and faculty modules with role-based access',
    'Implemented automated email notifications using Nodemailer',
    'Added Excel export functionality for attendance reports using XLSX and File-saver',
    'Handled testing, debugging, and system documentation throughout development',
  ];

  @override
  Widget build(BuildContext context) {
    final kc = KTheme.colors(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(36, 32, 36, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // two column layout
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // left — key features
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      KLabel('// Key features'),
                      const SizedBox(height: 18),
                      ..._features.map((f) => _FeatureRow(text: f)),
                    ],
                  ),
                ),
                const SizedBox(width: 28),
                Container(width: 1, color: kc.border),
                const SizedBox(width: 28),
                // right — what I built
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      KLabel('// What I built'),
                      const SizedBox(height: 18),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              width: 3,
                              color: kc.borderStr,
                              margin: const EdgeInsets.only(right: 16),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _built
                                    .map((b) => _BulletRow(text: b))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

// ── Links Tab ─────────────────────────────────────────────────────
class _LinksTab extends StatelessWidget {
  const _LinksTab();

  @override
  Widget build(BuildContext context) {
    final kc = KTheme.colors(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(36, 32, 36, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KLabel('// Project links'),
          const SizedBox(height: 28),

          _LinkButton(
            icon: Icons.code_rounded,
            label: 'View on GitHub',
            sub: 'github.com/yooolak/rtas-admin-clean',
            url: 'https://github.com/yooolak/rtas-admin-clean.git',
          ),

          const SizedBox(height: 14),

          // placeholder for live demo — commented visually as unavailable
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 28),
            decoration: BoxDecoration(
              border: Border.all(color: kc.border, width: 1),
              color: kc.textPrimary.withOpacity(0.01),
            ),
            child: Row(
              children: [
                Icon(Icons.open_in_new_rounded,
                    size: 17, color: kc.textDim),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live Demo',
                        style: TextStyle(
                          fontFamily: KC.fontMono,
                          fontSize: 15,
                          color: kc.textDim,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Not available — requires local RFID hardware',
                        style: TextStyle(
                          fontFamily: KC.fontMono,
                          fontSize: 13,
                          color: kc.textDim.withOpacity(0.6),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: kc.border),
                  ),
                  child: Text(
                    'N/A',
                    style: TextStyle(
                      fontFamily: KC.fontMono,
                      fontSize: 11,
                      letterSpacing: 2,
                      color: kc.textDim,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // bottom note
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: kc.border),
              color: kc.textPrimary.withOpacity(0.015),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 15, color: kc.textDim),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'More projects coming soon — currently completing '
                    'internship at FDS Asya Philippines Inc.',
                    style: TextStyle(
                      fontFamily: KC.fontMono,
                      fontSize: 13,
                      color: kc.textMuted,
                      height: 1.7,
                      letterSpacing: 0.2,
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

// ── Shared: Badge ─────────────────────────────────────────────────
class _Badge extends StatelessWidget {
  final String label;
  final KColors kc;
  final bool strong;
  const _Badge(this.label, this.kc, {this.strong = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(
          color: strong ? kc.borderStr : kc.border,
          width: strong ? 1.5 : 1,
        ),
        color: kc.textPrimary.withOpacity(0.025),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: KC.fontMono,
          fontSize: 11,
          letterSpacing: 2,
          color: strong ? kc.textSecondary : kc.textMuted,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Shared: Info Block ────────────────────────────────────────────
class _InfoBlock extends StatelessWidget {
  final String label, value, sub;
  final KColors kc;
  const _InfoBlock({
    required this.label,
    required this.value,
    required this.sub,
    required this.kc,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KLabel(label),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontFamily: KC.fontMono,
            fontSize: 15,
            color: kc.textSecondary,
            letterSpacing: 0.3,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          sub,
          style: TextStyle(
            fontFamily: KC.fontMono,
            fontSize: 12,
            color: kc.textDim,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

// ── Shared: Chip ──────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final String label;
  final KColors kc;
  const _Chip(this.label, this.kc);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: kc.border, width: 1.5),
        color: kc.textPrimary.withOpacity(0.02),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: KC.fontMono,
          fontSize: 12,
          letterSpacing: 2,
          color: kc.textMuted,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Shared: Feature Row ───────────────────────────────────────────
class _FeatureRow extends StatefulWidget {
  final String text;
  const _FeatureRow({required this.text});

  @override
  State<_FeatureRow> createState() => _FeatureRowState();
}

class _FeatureRowState extends State<_FeatureRow> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    final kc = KTheme.colors(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        color: _hov ? kc.textPrimary.withOpacity(0.08) : Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '• ',
              style: TextStyle(
                fontFamily: KC.fontMono,
                fontSize: 14,
                color: _hov ? kc.textMuted : kc.textDim,
                height: 1.75,
              ),
            ),
            Expanded(
              child: Text(
                widget.text,
                style: TextStyle(
                  fontFamily: KC.fontMono,
                  fontSize: 14,
                  color: _hov ? kc.textPrimary : kc.textSecondary,
                  height: 1.75,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared: Bullet Row ────────────────────────────────────────────
class _BulletRow extends StatefulWidget {
  final String text;
  const _BulletRow({required this.text});

  @override
  State<_BulletRow> createState() => _BulletRowState();
}

class _BulletRowState extends State<_BulletRow> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    final kc = KTheme.colors(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
        color: _hov ? kc.textPrimary.withOpacity(0.08) : Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '— ',
              style: TextStyle(
                fontFamily: KC.fontMono,
                fontSize: 14,
                color: _hov ? kc.textMuted : kc.textDim,
                height: 1.85,
              ),
            ),
            Expanded(
              child: Text(
                widget.text,
                style: TextStyle(
                  fontFamily: KC.fontMono,
                  fontSize: 14,
                  color: _hov ? kc.textPrimary : kc.textSecondary,
                  height: 1.85,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared: Link Button ───────────────────────────────────────────
class _LinkButton extends StatefulWidget {
  final IconData icon;
  final String label, sub, url;
  const _LinkButton({
    required this.icon,
    required this.label,
    required this.sub,
    required this.url,
  });

  @override
  State<_LinkButton> createState() => _LinkButtonState();
}

class _LinkButtonState extends State<_LinkButton> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    final kc = KTheme.colors(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          final uri = Uri.parse(widget.url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 28),
          decoration: BoxDecoration(
            color: _hov ? kc.textPrimary : Colors.transparent,
            border: Border.all(
              color: kc.textPrimary,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 17,
                color: _hov ? kc.bg : kc.textPrimary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label.toUpperCase(),
                      style: TextStyle(
                        fontFamily: KC.fontMono,
                        fontSize: 14,
                        letterSpacing: 3,
                        color: _hov ? kc.bg : kc.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.sub,
                      style: TextStyle(
                        fontFamily: KC.fontMono,
                        fontSize: 12,
                        color: _hov
                            ? kc.bg.withOpacity(0.6)
                            : kc.textDim,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform:
                    Matrix4.translationValues(_hov ? 4 : 0, 0, 0),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: _hov ? kc.bg : kc.textPrimary,
                ),
              ),
            ],
          ),
        ),
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
  Widget build(BuildContext context) {
    final kc = KTheme.colors(context);
    return FadeTransition(
      opacity: _o,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: kc.textPrimary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
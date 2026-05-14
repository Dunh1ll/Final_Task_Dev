import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'constants.dart';
import 'utilities.dart';
import 'about_page.dart' show SectionHeader;

// ── Main page ─────────────────────────────────────────────────────

class KProjectsPage extends StatelessWidget {
  final bool isWide;
  const KProjectsPage({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return KReveal(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(number: '03', title: 'Projects'),
          isWide ? _wideLayout(context) : _narrowLayout(context),
        ],
      ),
    );
  }

  // ── Wide: left info + right image ───────────────────────────────
  Widget _wideLayout(BuildContext context) {
    final availH = MediaQuery.of(context).size.height - 68 - 36 - 74;

    return SizedBox(
      height: availH,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // LEFT — project info (60%)
          Expanded(
            flex: 6,
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(color: KC.borderStr, width: 2),
                ),
              ),
child: SingleChildScrollView(
  physics: const BouncingScrollPhysics(),
  child: Padding(
    padding: const EdgeInsets.fromLTRB(40, 28, 40, 28),
    child: _ProjectInfo(),
  ),
),
            ),
          ),

// RIGHT — project image (40%)
Expanded(
  flex: 4,
  child: Container(
    color: KC.textPrimary.withOpacity(0.02),
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Image.asset(
          'assets/images/rtas.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Container(
            width: 150,
            height: 150,
            color: KC.bgLight,
            child: const Center(
              child: Text(
                'RTAS',
                style: TextStyle(
                  fontFamily: KC.fontDisplay,
                  fontWeight: FontWeight.w900,
                  fontSize: 32,
                  color: KC.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  ),
),
        ],
      ),
    );
  }

  // ── Narrow: stacked ──────────────────────────────────────────────
  Widget _narrowLayout(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: KC.textPrimary.withOpacity(0.02),
              border: Border(
                bottom: BorderSide(color: KC.borderStr, width: 2),
              ),
            ),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 250),
                decoration: BoxDecoration(
                  border: Border.all(color: KC.borderStr, width: 2),
                ),
                child: Image.asset(
                  'assets/images/rtas.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    width: 150,
                    height: 150,
                    color: KC.bgLight,
                    child: const Center(
                      child: Text(
                        'RTAS',
                        style: TextStyle(
                          fontFamily: KC.fontDisplay,
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                          color: KC.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: _ProjectInfo(),
          ),
        ],
      ),
    );
  }
}

// ── Project Info (Bigger, fills space) ────────────────────────────

class _ProjectInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Top meta ───────────────────────────────────────
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: KC.border),
                color: KC.textPrimary.withOpacity(0.03),
              ),
              child: const Text(
                '01 / 01',
                style: TextStyle(
                  fontFamily: KC.fontMono,
                  fontSize: 10,
                  letterSpacing: 2,
                  color: KC.textMuted,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(border: Border.all(color: KC.border)),
              child: const Text(
                'FULL-STACK',
                style: TextStyle(
                  fontFamily: KC.fontMono,
                  fontSize: 9,
                  letterSpacing: 2,
                  color: KC.textDim,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // ── Title ──────────────────────────────────────────
        const Text(
          'RTAS',
          style: TextStyle(
            fontFamily: KC.fontDisplay,
            fontWeight: FontWeight.w900,
            fontSize: 40,
            color: KC.textPrimary,
            letterSpacing: -2,
            height: 1,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Real-Time Attendance System',
          style: TextStyle(
            fontFamily: KC.fontDisplay,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: KC.textSecondary,
            letterSpacing: -0.3,
            height: 1.2,
          ),
        ),

        const SizedBox(height: 16),

        // ── Overview ─────────────────────────────────────────
        const Text(
          'A web-based attendance monitoring system that uses QR code technology for real-time attendance tracking, student management, and attendance reporting.',
          style: TextStyle(
            fontFamily: KC.fontMono,
            fontSize: 13,
            color: KC.textSecondary,
            height: 1.7,
            letterSpacing: 0.2,
          ),
        ),

        const SizedBox(height: 20),
        Container(height: 1, color: KC.border),
        const SizedBox(height: 20),

        // ── Role + Tech Stack ──────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KLabel('// My role'),
                  const SizedBox(height: 8),
                  const Text(
                    'Full-Stack Developer',
                    style: TextStyle(
                      fontFamily: KC.fontMono,
                      fontSize: 12,
                      color: KC.textSecondary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KLabel('// Tech stack'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _TechChip('Flutter'),
                      _TechChip('Golang'),
                      _TechChip('Firebase'),
                      _TechChip('MySQL'),
                      _TechChip('REST API'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),
        Container(height: 1, color: KC.border),
        const SizedBox(height: 20),

        // ── Key Features ─────────────────────────────────────
        KLabel('// Key features'),
        const SizedBox(height: 12),
        Row(
          children: const [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FeatureItem('QR code attendance scanning'),
                  _FeatureItem('Real-time attendance monitoring'),
                  _FeatureItem('Student and admin management'),
                ],
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FeatureItem('Attendance history and reports'),
                  _FeatureItem('Authentication and role-based access'),
                  _FeatureItem('Responsive modern UI'),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),
        Container(height: 1, color: KC.border),
        const SizedBox(height: 20),

        // ── What I Built ─────────────────────────────────────
        KLabel('// What I built'),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 2,
                color: KC.borderStr,
                margin: const EdgeInsets.only(right: 16),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _BulletPoint('Designed the frontend UI/UX'),
                    _BulletPoint('Developed responsive pages and reusable components'),
                    _BulletPoint('Connected frontend to backend APIs'),
                    _BulletPoint('Managed attendance data and authentication logic'),
                    _BulletPoint('Improved system structure and usability'),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ── GitHub Button ──────────────────────────────────
        _GitHubLink(),
      ],
    );
  }
}

// ── Tech Chip ─────────────────────────────────────────────────────

class _TechChip extends StatelessWidget {
  final String label;
  const _TechChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: KC.border),
        color: KC.textPrimary.withOpacity(0.02),
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

// ── Feature Item ──────────────────────────────────────────────────

class _FeatureItem extends StatelessWidget {
  final String text;
  const _FeatureItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontFamily: KC.fontMono,
              fontSize: 13,
              color: KC.textDim,
              height: 1.5,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: KC.fontMono,
                fontSize: 12,
                color: KC.textSecondary,
                height: 1.5,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bullet Point ──────────────────────────────────────────────────

class _BulletPoint extends StatelessWidget {
  final String text;
  const _BulletPoint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '— ',
            style: TextStyle(
              fontFamily: KC.fontMono,
              fontSize: 13,
              color: KC.textDim,
              height: 1.5,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: KC.fontMono,
                fontSize: 12,
                color: KC.textSecondary,
                height: 1.5,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── GitHub Link ───────────────────────────────────────────────────

class _GitHubLink extends StatefulWidget {
  @override
  State<_GitHubLink> createState() => _GitHubLinkState();
}

class _GitHubLinkState extends State<_GitHubLink> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          final uri = Uri.parse('https://github.com/yooolak/rtas-admin-clean.git');
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          decoration: BoxDecoration(
            color: _hov ? KC.textPrimary : Colors.transparent,
            border: Border.all(color: KC.textPrimary, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.code_rounded,
                size: 14,
                color: _hov ? KC.bg : KC.textPrimary,
              ),
              const SizedBox(width: 10),
              Text(
                'VIEW ON GITHUB',
                style: TextStyle(
                  fontFamily: KC.fontMono,
                  fontSize: 10,
                  letterSpacing: 3,
                  color: _hov ? KC.bg : KC.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: Matrix4.translationValues(_hov ? 4 : 0, 0, 0),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 12,
                  color: _hov ? KC.bg : KC.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
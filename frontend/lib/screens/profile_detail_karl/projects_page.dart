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
          Expanded(
            flex: 6,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: kc.borderStr, width: 2),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
                child: _ProjectInfo(),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              color: kc.bgLight,
              padding: const EdgeInsets.all(32),
              child: Image.asset(
                'assets/images/rtas.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  color: kc.bgLight,
                  child: Center(
                    child: Text(
                      'RTAS',
                      style: TextStyle(
                        fontFamily: KC.fontDisplay,
                        fontWeight: FontWeight.w900,
                        fontSize: 32,
                        color: kc.textPrimary,
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

  Widget _narrowLayout(BuildContext context) {
    final kc = KTheme.colors(context);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            height: 240,
            child: Image.asset(
              'assets/images/rtas.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: kc.bgLight,
                child: Center(
                  child: Text(
                    'RTAS',
                    style: TextStyle(
                      fontFamily: KC.fontDisplay,
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      color: kc.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(height: 2, color: kc.borderStr),
          Padding(
            padding: const EdgeInsets.all(24),
            child: _ProjectInfo(),
          ),
        ],
      ),
    );
  }
}

// ── Project Info ──────────────────────────────────────────────────
class _ProjectInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final kc = KTheme.colors(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [

        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: kc.border, width: 1.5),
                color: kc.textPrimary.withOpacity(0.03),
              ),
              child: Text(
                'FEATURED PROJECT',
                style: TextStyle(
                  fontFamily: KC.fontMono,
                  fontSize: 10,
                  letterSpacing: 2,
                  color: kc.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: kc.borderStr, width: 1.5),
                color: kc.textPrimary.withOpacity(0.03),
              ),
              child: Text(
                'FULL-STACK',
                style: TextStyle(
                  fontFamily: KC.fontMono,
                  fontSize: 10,
                  letterSpacing: 2,
                  color: kc.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Text(
          'RTAS',
          style: TextStyle(
            fontFamily: KC.fontDisplay,
            fontWeight: FontWeight.w900,
            fontSize: 52,
            color: kc.textPrimary,
            letterSpacing: -2.5,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Real-Time Attendance System',
          style: TextStyle(
            fontFamily: KC.fontDisplay,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: kc.textSecondary,
            letterSpacing: -0.3,
            height: 1.2,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          'A web-based attendance monitoring system that uses QR code technology for real-time attendance tracking, student management, and attendance reporting.',
          style: TextStyle(
            fontFamily: KC.fontMono,
            fontSize: 14,
            color: kc.textPrimary,
            height: 1.8,
            letterSpacing: 0.2,
          ),
        ),

        const SizedBox(height: 14),
        Container(height: 1.5, color: kc.border),
        const SizedBox(height: 14),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KLabel('// My role'),
                  const SizedBox(height: 10),
                  Text(
                    'Full-Stack Developer',
                    style: TextStyle(
                      fontFamily: KC.fontMono,
                      fontSize: 14,
                      color: kc.textSecondary,
                      letterSpacing: 0.3,
                      fontWeight: FontWeight.w600,
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
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _TechChip('Flutter', kc),
                      _TechChip('Golang', kc),
                      _TechChip('Firebase', kc),
                      _TechChip('MySQL', kc),
                      _TechChip('REST API', kc),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),
        Container(height: 1.5, color: kc.border),
        const SizedBox(height: 20),

        KLabel('// Key features'),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FeatureItem('QR code attendance scanning', kc),
                  _FeatureItem('Real-time attendance monitoring', kc),
                  _FeatureItem('Student and admin management', kc),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FeatureItem('Attendance history and reports', kc),
                  _FeatureItem('Authentication & role-based access', kc),
                  _FeatureItem('Responsive modern UI', kc),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),
        Container(height: 1.5, color: kc.border),
        const SizedBox(height: 20),

        KLabel('// What I built'),
        const SizedBox(height: 10),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 2,
                color: kc.borderStr,
                margin: const EdgeInsets.only(right: 16),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BulletPoint('Designed the frontend UI/UX', kc),
                    _BulletPoint('Developed responsive pages and reusable components', kc),
                    _BulletPoint('Connected frontend to backend APIs', kc),
                    _BulletPoint('Managed attendance data and authentication logic', kc),
                    _BulletPoint('Improved system structure and usability', kc),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        _GitHubLink(),
      ],
    );
  }
}

// ── Tech Chip ─────────────────────────────────────────────────────
class _TechChip extends StatelessWidget {
  final String label;
  final KColors kc;
  const _TechChip(this.label, this.kc);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: kc.border, width: 1.5),
        color: kc.textPrimary.withOpacity(0.02),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: KC.fontMono,
          fontSize: 10,
          letterSpacing: 2,
          color: kc.textMuted,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Feature Item ──────────────────────────────────────────────────
class _FeatureItem extends StatefulWidget {
  final String text;
  final KColors kc;
  const _FeatureItem(this.text, this.kc);

  @override
  State<_FeatureItem> createState() => _FeatureItemState();
}

class _FeatureItemState extends State<_FeatureItem> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    final kc = widget.kc;
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        color: _hov ? kc.textPrimary.withOpacity(0.10) : Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '• ',
              style: TextStyle(
                fontFamily: KC.fontMono,
                fontSize: 13,
                color: _hov ? kc.textPrimary : kc.textMuted,
                height: 1.6,
              ),
            ),
            Expanded(
              child: Text(
                widget.text,
                style: TextStyle(
                  fontFamily: KC.fontMono,
                  fontSize: 13,
                  color: _hov ? kc.textPrimary : kc.textSecondary,
                  height: 1.6,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bullet Point ──────────────────────────────────────────────────
class _BulletPoint extends StatefulWidget {
  final String text;
  final KColors kc;
  const _BulletPoint(this.text, this.kc);

  @override
  State<_BulletPoint> createState() => _BulletPointState();
}

class _BulletPointState extends State<_BulletPoint> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    final kc = widget.kc;
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        color: _hov ? kc.textPrimary.withOpacity(0.10) : Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '— ',
              style: TextStyle(
                fontFamily: KC.fontMono,
                fontSize: 13,
                color: _hov ? kc.textMuted : kc.textDim,
                height: 1.6,
              ),
            ),
            Expanded(
              child: Text(
                widget.text,
                style: TextStyle(
                  fontFamily: KC.fontMono,
                  fontSize: 13,
                  color: _hov ? kc.textPrimary : kc.textSecondary,
                  height: 1.6,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
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
    final kc = KTheme.colors(context);
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
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
          decoration: BoxDecoration(
            color: _hov ? kc.textPrimary : Colors.transparent,
            border: Border.all(color: kc.textPrimary, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.code_rounded,
                size: 15,
                color: _hov ? kc.bg : kc.textPrimary,
              ),
              const SizedBox(width: 12),
              Text(
                'VIEW ON GITHUB',
                style: TextStyle(
                  fontFamily: KC.fontMono,
                  fontSize: 11,
                  letterSpacing: 3,
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
                  size: 13,
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
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'constants.dart';
import 'utilities.dart';
import 'about_page.dart' show SectionHeader;

// ── Data models ───────────────────────────────────────────────────

class _FeaturedProject {
  final String index, title, description, year;
  final List<String> tags;
  final String? githubUrl, liveUrl;
  final List<_Stat> stats;
  const _FeaturedProject({
    required this.index,
    required this.title,
    required this.description,
    required this.year,
    required this.tags,
    this.githubUrl,
    this.liveUrl,
    required this.stats,
  });
}

class _OtherProject {
  final String title, desc;
  final List<String> tags;
  final String? githubUrl;
  final String year;
  const _OtherProject(this.title, this.desc, this.tags, {this.githubUrl, required this.year});
}

class _Stat {
  final String value, label;
  const _Stat(this.value, this.label);
}

// ── Shared data (single source of truth) ─────────────────────────

const _featuredProjects = [
  _FeaturedProject(
    index: '01',
    title: 'Nakama Profiles',
    year: '2025',
    description:
        'Full-stack profile management app. Flutter Web frontend, '
        'Go backend, PostgreSQL database. Role-based auth (Captain & Crew), '
        'OTP via Gmail, photo upload, One Piece themed UI.',
    tags: ['Flutter', 'Golang', 'PostgreSQL', 'JWT', 'REST API'],
    githubUrl: 'https://github.com/yooolak',
    stats: [
      _Stat('Full', 'Stack'),
      _Stat('5+', 'Features'),
      _Stat('Live', 'Demo'),
    ],
  ),
  _FeaturedProject(
    index: '02',
    title: 'Portfolio Profile UI',
    year: '2025',
    description:
        'Animated developer portfolio with scroll reveals, '
        'grain texture overlays, bento grid layout, and '
        'micro-interactions. Built entirely in Flutter with '
        'custom painters and animation controllers.',
    tags: ['Flutter', 'Dart', 'UI/UX', 'Animation', 'Custom Paint'],
    githubUrl: 'https://github.com/yooolak',
    stats: [
      _Stat('100%', 'Flutter'),
      _Stat('5', 'Sections'),
      _Stat('Dark', 'Theme'),
    ],
  ),
];

const _otherProjects = [
  _OtherProject(
    'Terminal Portfolio',
    'Animated developer terminal card with typewriter effect.',
    ['Flutter', 'Dart'],
    githubUrl: 'https://github.com/yooolak',
    year: '2024',
  ),
  _OtherProject(
    'Auth System',
    'JWT-based auth with OTP Gmail verification flow.',
    ['Golang', 'PostgreSQL'],
    githubUrl: 'https://github.com/yooolak',
    year: '2024',
  ),
  _OtherProject(
    'Wanted Poster UI',
    'One Piece themed profile cards with custom painters.',
    ['Flutter', 'Custom Paint'],
    githubUrl: 'https://github.com/yooolak',
    year: '2024',
  ),
];

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
          isWide ? _wideLayout() : _narrowLayout(),
        ],
      ),
    );
  }

  // ── Wide: left panel (featured list) + right panel (other grid) ─
  Widget _wideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LEFT — featured projects (60%)
        Expanded(
          flex: 6,
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: KC.borderStr, width: 2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PanelLabel('// Featured'),
                ..._featuredProjects.map(
                  (p) => _FeaturedCard(project: p, isWide: true),
                ),
              ],
            ),
          ),
        ),

        // RIGHT — other projects (40%)
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PanelLabel(
                '// Other',
                trailing: '${_otherProjects.length} projects',
              ),
              ..._otherProjects.map(
                (p) => _OtherCard(project: p),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Narrow: stacked ──────────────────────────────────────────────
  Widget _narrowLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PanelLabel('// Featured'),
        ..._featuredProjects.map(
          (p) => _FeaturedCard(project: p, isWide: false),
        ),
        Container(height: 2, color: KC.borderStr),
        _PanelLabel(
          '// Other',
          trailing: '${_otherProjects.length} projects',
        ),
        ..._otherProjects.map((p) => _OtherCard(project: p)),
      ],
    );
  }
}

// ── Panel label ───────────────────────────────────────────────────

class _PanelLabel extends StatelessWidget {
  final String text;
  final String? trailing;
  const _PanelLabel(this.text, {this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: KC.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          Text(
            text.toUpperCase(),
            style: const TextStyle(
              fontFamily: KC.fontMono,
              fontSize: 9,
              letterSpacing: 3.5,
              color: KC.textDim,
            ),
          ),
          if (trailing != null) ...[
            const Spacer(),
            Text(
              trailing!,
              style: const TextStyle(
                fontFamily: KC.fontMono,
                fontSize: 9,
                letterSpacing: 2,
                color: KC.textDim,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Featured card ─────────────────────────────────────────────────

class _FeaturedCard extends StatefulWidget {
  final _FeaturedProject project;
  final bool isWide;
  const _FeaturedCard({required this.project, required this.isWide});

  @override
  State<_FeaturedCard> createState() => _FeaturedCardState();
}

class _FeaturedCardState extends State<_FeaturedCard> {
  bool _hov = false;

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.project;

    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _hov
              ? KC.textPrimary.withOpacity(0.03)
              : Colors.transparent,
          border: const Border(
            bottom: BorderSide(color: KC.borderStr, width: 2),
          ),
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: index + year + links ──────────────────
            Row(
              children: [
                Text(
                  p.index,
                  style: TextStyle(
                    fontFamily: KC.fontDisplay,
                    fontWeight: FontWeight.w900,
                    fontSize: 36,
                    color: _hov ? KC.textPrimary : KC.textDim,
                    letterSpacing: -1.5,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    border: Border.all(color: KC.border),
                  ),
                  child: Text(
                    p.year,
                    style: const TextStyle(
                      fontFamily: KC.fontMono,
                      fontSize: 9,
                      letterSpacing: 2,
                      color: KC.textDim,
                    ),
                  ),
                ),
                const Spacer(),
                if (p.githubUrl != null)
                  _IconLink(
                    icon: Icons.code_rounded,
                    tooltip: 'GitHub',
                    onTap: () => _launch(p.githubUrl!),
                    hov: _hov,
                  ),
                if (p.liveUrl != null) ...[
                  const SizedBox(width: 10),
                  _IconLink(
                    icon: Icons.open_in_new_rounded,
                    tooltip: 'Live',
                    onTap: () => _launch(p.liveUrl!),
                    hov: _hov,
                  ),
                ],
              ],
            ),

            const SizedBox(height: 14),

            // ── Title ─────────────────────────────────────────
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontFamily: KC.fontDisplay,
                fontWeight: FontWeight.w900,
                fontSize: widget.isWide ? 26 : 20,
                color: _hov ? KC.textPrimary : KC.textSecondary,
                letterSpacing: -0.8,
                height: 1.1,
              ),
              child: Text(p.title),
            ),

            const SizedBox(height: 12),

            // ── Description ───────────────────────────────────
            Text(
              p.description,
              style: KC.monoMedium.copyWith(
                fontSize: 12,
                color: KC.textMuted,
                height: 1.9,
              ),
            ),
            const SizedBox(height: 20),
            Container(height: 1, color: KC.border),
            const SizedBox(height: 20),

            // ── Stats row — like About page ────────────────────
            IntrinsicHeight(
              child: Row(
                children: [
                  ...p.stats.asMap().entries.map((entry) {
                    final i = entry.key;
                    final stat = entry.value;
                    return Row(
                      children: [
                        _StatPill(value: stat.value, label: stat.label),
                        if (i < p.stats.length - 1)
                          Container(
                            width: 1,
                            color: KC.border,
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                      ],
                    );
                  }).expand((w) => [w]).toList(),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Tags + arrow ──────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: p.tags.map((t) => _TagChip(t)).toList(),
                  ),
                ),
                if (p.githubUrl != null)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform: Matrix4.translationValues(
                        _hov ? 4 : 0, 0, 0),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: _hov ? KC.textPrimary : KC.textDim,
                      size: 18,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
              fontSize: 28,
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

// ── Other card ────────────────────────────────────────────────────

class _OtherCard extends StatefulWidget {
  final _OtherProject project;
  const _OtherCard({required this.project});

  @override
  State<_OtherCard> createState() => _OtherCardState();
}

class _OtherCardState extends State<_OtherCard> {
  bool _hov = false;

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.project;

    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      cursor: p.githubUrl != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      child: GestureDetector(
        onTap: p.githubUrl != null ? () => _launch(p.githubUrl!) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _hov
                ? KC.textPrimary.withOpacity(0.04)
                : Colors.transparent,
            border: const Border(
              bottom: BorderSide(color: KC.border, width: 1),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ──────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _hov ? KC.textPrimary : KC.border,
                      ),
                    ),
                    child: Icon(
                      Icons.folder_open_outlined,
                      color: _hov ? KC.textPrimary : KC.textDim,
                      size: 15,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      border: Border.all(color: KC.border),
                    ),
                    child: Text(
                      p.year,
                      style: const TextStyle(
                        fontFamily: KC.fontMono,
                        fontSize: 9,
                        letterSpacing: 2,
                        color: KC.textDim,
                      ),
                    ),
                  ),
                  if (p.githubUrl != null) ...[
                    const SizedBox(width: 10),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      transform: Matrix4.translationValues(
                          0, _hov ? -2 : 0, 0),
                      child: Icon(
                        Icons.arrow_outward_rounded,
                        color: _hov ? KC.textPrimary : KC.textDim,
                        size: 14,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 16),

              // ── Title ───────────────────────────────────────
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontFamily: KC.fontDisplay,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: _hov ? KC.textPrimary : KC.textSecondary,
                  letterSpacing: -0.3,
                ),
                child: Text(p.title),
              ),

              const SizedBox(height: 8),

              // ── Description ─────────────────────────────────
              Text(
                p.desc,
                style: const TextStyle(
                  fontFamily: KC.fontMono,
                  fontSize: 11,
                  color: KC.textMuted,
                  height: 1.7,
                ),
              ),

              const SizedBox(height: 14),

              // ── Tags ─────────────────────────────────────────
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: p.tags.map((t) => _TagChip(t)).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tag chip ──────────────────────────────────────────────────────

class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: KC.border),
      ),
      child: Text(
        label.toUpperCase(),
        style: KC.monoChip,  // Changed
      ),
    );
  }
}

// ── Icon link button ──────────────────────────────────────────────

class _IconLink extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool hov;
  const _IconLink({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.hov,
  });

  @override
  State<_IconLink> createState() => _IconLinkState();
}

class _IconLinkState extends State<_IconLink> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: widget.tooltip,
        preferBelow: false,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              border: Border.all(
                color: _hov ? KC.textPrimary : KC.border,
              ),
              color: _hov
                  ? KC.textPrimary.withOpacity(0.08)
                  : Colors.transparent,
            ),
            child: Icon(
              widget.icon,
              color: _hov ? KC.textPrimary : KC.textDim,
              size: 14,
            ),
          ),
        ),
      ),
    );
  }
}
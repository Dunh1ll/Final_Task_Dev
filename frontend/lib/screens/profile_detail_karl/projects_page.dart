import 'package:flutter/material.dart';
import 'constants.dart';
import 'utilities.dart';
import 'about_page.dart' show SectionHeader;

class KProjectsPage extends StatelessWidget {
  final bool isWide;
  const KProjectsPage({required this.isWide});

  @override
  Widget build(BuildContext context) => KReveal(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 160 : 32,
            vertical: 60,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(number: '', title: 'Some Things I\'ve Built'),
              const SizedBox(height: 60),

              // Featured projects
              _FeaturedProject(
                number: '01',
                title: 'Nakama Profiles',
                description:
                    'A full-stack profile management web application built with Flutter Web '
                    'and Go backend. Features role-based auth (Captain & Crew), '
                    'OTP verification via Gmail, profile management with photo upload, '
                    'and One Piece themed UI throughout.',
                tags: ['Flutter', 'Golang', 'PostgreSQL', 'JWT', 'REST API'],
                isWide: isWide,
                flipped: false,
              ),

              const SizedBox(height: 80),

              _FeaturedProject(
                number: '02',
                title: 'Portfolio Profile UI',
                description:
                    'A premium animated developer portfolio featuring scroll reveals, '
                    'grain texture overlays, bento grid layout, and sophisticated '
                    'micro-interactions. Built entirely in Flutter with custom painters '
                    'and animation controllers.',
                tags: ['Flutter', 'Dart', 'UI/UX', 'Animation', 'Custom Paint'],
                isWide: isWide,
                flipped: true,
              ),

              const SizedBox(height: 80),

              // Other projects section
              SectionHeader(number: '', title: 'Other Noteworthy Projects'),
              const SizedBox(height: 40),

              isWide
                  ? _OtherProjectsGrid()
                  : _OtherProjectsList(),
            ],
          ),
        ),
      );
}

// ── Featured Project ─────────────────────────────────────────────
class _FeaturedProject extends StatefulWidget {
  final String number, title, description;
  final List<String> tags;
  final bool isWide, flipped;
  const _FeaturedProject({
    required this.number,
    required this.title,
    required this.description,
    required this.tags,
    required this.isWide,
    required this.flipped,
  });

  @override
  State<_FeaturedProject> createState() => _FeaturedProjectState();
}

class _FeaturedProjectState extends State<_FeaturedProject> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.isWide) return _narrow();

    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: Stack(
        children: [
          // Background image placeholder
          Align(
            alignment:
                widget.flipped ? Alignment.centerLeft : Alignment.centerRight,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 580,
              height: 340,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: KC.bgLight,
                border: Border.all(
                  color:
                      _hov ? KC.mint.withOpacity(0.4) : KC.border,
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(children: [
                  // Project illustration
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.code_rounded,
                            color: KC.mint.withOpacity(0.3), size: 64),
                        const SizedBox(height: 12),
                        Text(
                          widget.title,
                          style: TextStyle(
                            color: KC.mint.withOpacity(0.4),
                            fontSize: 20,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Overlay
                  Container(
                    color: KC.bg.withOpacity(_hov ? 0.55 : 0.75),
                  ),
                ]),
              ),
            ),
          ),

          // Content overlay
          Align(
            alignment:
                widget.flipped ? Alignment.centerRight : Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: widget.flipped
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    'Featured Project',
                    style: TextStyle(
                      color: KC.mint,
                      fontSize: 13,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: KC.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                    textAlign:
                        widget.flipped ? TextAlign.right : TextAlign.left,
                  ),
                  const SizedBox(height: 20),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: KC.bgLight,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _hov
                            ? KC.mint.withOpacity(0.3)
                            : KC.border,
                      ),
                    ),
                    child: Text(
                      widget.description,
                      style: const TextStyle(
                        color: KC.textSecondary,
                        fontSize: 14,
                        height: 1.7,
                      ),
                      textAlign:
                          widget.flipped ? TextAlign.right : TextAlign.left,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    alignment: widget.flipped
                        ? WrapAlignment.end
                        : WrapAlignment.start,
                    children: widget.tags
                        .map((t) => Text(
                              t,
                              style: const TextStyle(
                                color: KC.textSecondary,
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: widget.flipped
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      _IconLink(icon: Icons.code, tooltip: 'GitHub'),
                      const SizedBox(width: 12),
                      _IconLink(
                          icon: Icons.open_in_new, tooltip: 'Live Demo'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _narrow() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: KC.bgLight,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: KC.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.folder_outlined, color: KC.mint, size: 32),
            const Spacer(),
            _IconLink(icon: Icons.code, tooltip: 'GitHub'),
            const SizedBox(width: 8),
            _IconLink(icon: Icons.open_in_new, tooltip: 'Live'),
          ]),
          const SizedBox(height: 16),
          Text(
            widget.title,
            style: const TextStyle(
              color: KC.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.description,
            style: const TextStyle(
              color: KC.textSecondary,
              fontSize: 13,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: widget.tags
                .map((t) => Text(t,
                    style: const TextStyle(
                      color: KC.mint,
                      fontSize: 11,
                      fontFamily: 'monospace',
                    )))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _IconLink extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  const _IconLink({required this.icon, required this.tooltip});

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
      child: Tooltip(
        message: widget.tooltip,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          transform: Matrix4.translationValues(0, _hov ? -3 : 0, 0),
          child:
              Icon(widget.icon, color: _hov ? KC.mint : KC.textSecondary, size: 20),
        ),
      ),
    );
  }
}

// ── Other Projects Grid ──────────────────────────────────────────
class _OtherProjectsGrid extends StatelessWidget {
  final _projects = const [
    _OtherProject('Terminal Portfolio', 'Animated developer terminal card with typewriter effect.', ['Flutter', 'Dart']),
    _OtherProject('Auth System', 'JWT-based auth with OTP Gmail verification flow.', ['Golang', 'PostgreSQL']),
    _OtherProject('Wanted Poster UI', 'One Piece themed profile cards with custom painters.', ['Flutter', 'Custom Paint']),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _projects
          .map((p) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _OtherProjectCard(project: p),
                ),
              ))
          .toList(),
    );
  }
}

class _OtherProjectsList extends StatelessWidget {
  final _projects = const [
    _OtherProject('Terminal Portfolio', 'Animated developer terminal card with typewriter effect.', ['Flutter', 'Dart']),
    _OtherProject('Auth System', 'JWT-based auth with OTP Gmail verification flow.', ['Golang', 'PostgreSQL']),
    _OtherProject('Wanted Poster UI', 'One Piece themed profile cards with custom painters.', ['Flutter', 'Custom Paint']),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _projects
          .map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _OtherProjectCard(project: p),
              ))
          .toList(),
    );
  }
}

class _OtherProject {
  final String title, description;
  final List<String> tags;
  const _OtherProject(this.title, this.description, this.tags);
}

class _OtherProjectCard extends StatefulWidget {
  final _OtherProject project;
  const _OtherProjectCard({required this.project});

  @override
  State<_OtherProjectCard> createState() => _OtherProjectCardState();
}

class _OtherProjectCardState extends State<_OtherProjectCard> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _hov ? -6 : 0, 0),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: _hov ? KC.bgCard : KC.bgLight,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: _hov ? KC.mint.withOpacity(0.4) : KC.border,
          ),
          boxShadow: _hov
              ? [BoxShadow(color: KC.mint.withOpacity(0.08), blurRadius: 20)]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.folder_outlined,
                  color: KC.mint, size: 36),
              const Spacer(),
              _IconLink(icon: Icons.code, tooltip: 'GitHub'),
              const SizedBox(width: 8),
              _IconLink(icon: Icons.open_in_new, tooltip: 'Live'),
            ]),
            const SizedBox(height: 20),
            Text(
              widget.project.title,
              style: const TextStyle(
                color: KC.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.project.description,
              style: const TextStyle(
                color: KC.textSecondary,
                fontSize: 13,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              children: widget.project.tags
                  .map((t) => Text(t,
                      style: const TextStyle(
                        color: KC.textSecondary,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      )))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
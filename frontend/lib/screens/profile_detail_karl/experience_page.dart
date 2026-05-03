import 'package:flutter/material.dart';
import 'constants.dart';
import 'utilities.dart';
import 'about_page.dart' show SectionHeader;

class KExperiencePage extends StatelessWidget {
  final bool isWide;
  const KExperiencePage({required this.isWide});

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
              SectionHeader(number: '02', title: 'Where I\'ve Worked'),
              const SizedBox(height: 48),
              isWide ? _wideLayout() : _narrowLayout(),
            ],
          ),
        ),
      );

  Widget _wideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left — company tabs
        _CompanyTabs(),
        const SizedBox(width: 60),
        // Right — details
        Expanded(child: _ExperienceDetail()),
      ],
    );
  }

  Widget _narrowLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ExperienceDetail(),
      ],
    );
  }
}

// ── Stateful wrapper to track selected company ────────────────────
class _CompanyTabs extends StatefulWidget {
  @override
  State<_CompanyTabs> createState() => _CompanyTabsState();
}

class _CompanyTabsState extends State<_CompanyTabs> {
  int _selected = 0;

  final _companies = [
    'FDSAP',
    'Freelance',
    'Open Source',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        _companies.length,
        (i) => _CompanyTab(
          label: _companies[i],
          isActive: _selected == i,
          onTap: () => setState(() => _selected = i),
        ),
      ),
    );
  }
}

class _CompanyTab extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _CompanyTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_CompanyTab> createState() => _CompanyTabState();
}

class _CompanyTabState extends State<_CompanyTab> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 160,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: widget.isActive ? KC.mint : KC.border,
                width: 2,
              ),
            ),
            color: widget.isActive || _hov
                ? KC.mint.withOpacity(0.05)
                : Colors.transparent,
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.isActive ? KC.mint : KC.textSecondary,
              fontSize: 13,
              fontFamily: 'monospace',
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Experience Detail ─────────────────────────────────────────────
class _ExperienceDetail extends StatelessWidget {
  final _experiences = const [
    _Experience(
      role: 'Mobile & Backend Developer Intern',
      company: 'FDSAP',
      range: 'Jan 2025 — Present',
      points: [
        'Built and maintained mobile applications using Flutter & Dart.',
        'Developed RESTful backend APIs using Golang and PostgreSQL.',
        'Collaborated with the team on UI/UX design and implementation.',
        'Implemented JWT-based authentication with OTP email verification.',
      ],
    ),
    _Experience(
      role: 'Freelance Developer',
      company: 'Self-Employed',
      range: '2023 — 2024',
      points: [
        'Designed and built custom web and mobile apps for small clients.',
        'Handled full project lifecycle from requirements to deployment.',
        'Worked with Flutter, Firebase, and REST APIs.',
        'Delivered responsive UI designs based on client specifications.',
      ],
    ),
    _Experience(
      role: 'Open Source Contributor',
      company: 'Various Projects',
      range: '2022 — Present',
      points: [
        'Contributed bug fixes and feature additions to Flutter packages.',
        'Reviewed and submitted pull requests on GitHub.',
        'Participated in community discussions and issue tracking.',
        'Built personal tools shared publicly on GitHub.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _experiences
          .map((e) => _ExperienceItem(experience: e))
          .toList(),
    );
  }
}

class _Experience {
  final String role, company, range;
  final List<String> points;
  const _Experience({
    required this.role,
    required this.company,
    required this.range,
    required this.points,
  });
}

class _ExperienceItem extends StatelessWidget {
  final _Experience experience;
  const _ExperienceItem({required this.experience});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Role
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: experience.role,
                  style: const TextStyle(
                    color: KC.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                TextSpan(
                  text: ' @ ${experience.company}',
                  style: const TextStyle(
                    color: KC.mint,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // Date range
          Text(
            experience.range,
            style: const TextStyle(
              color: KC.textSecondary,
              fontSize: 13,
              fontFamily: 'monospace',
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          // Bullet points
          ...experience.points.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '▹ ',
                    style: TextStyle(color: KC.mint, fontSize: 14),
                  ),
                  Expanded(
                    child: Text(
                      p,
                      style: const TextStyle(
                        color: KC.textSecondary,
                        fontSize: 15,
                        height: 1.6,
                      ),
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
import 'package:flutter/material.dart';
import 'constants.dart';
import 'utilities.dart';

class KHomePage extends StatefulWidget {
  final String typed;
  final bool isWide;
  final VoidCallback onContact;
  final VoidCallback onProjects;
  const KHomePage({
    required this.typed,
    required this.isWide,
    required this.onContact,
    required this.onProjects,
  });
  @override
  State<KHomePage> createState() => _KHomePageState();
}

class _KHomePageState extends State<KHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late List<Animation<double>> _fades;
  late List<Animation<Offset>> _slides;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));

    // Staggered entrance for each line
    _fades = List.generate(5, (i) {
      final start = i * 0.12;
      final end = (start + 0.4).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _c, curve: Interval(start, end, curve: Curves.easeOut)),
      );
    });

    _slides = List.generate(5, (i) {
      final start = i * 0.12;
      final end = (start + 0.4).clamp(0.0, 1.0);
      return Tween<Offset>(
              begin: const Offset(0, 0.04), end: Offset.zero)
          .animate(CurvedAnimation(
              parent: _c,
              curve: Interval(start, end, curve: Curves.easeOut)));
    });

    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _animated(int i, Widget child) => FadeTransition(
        opacity: _fades[i],
        child: SlideTransition(position: _slides[i], child: child),
      );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Main hero content ────────────────────────────────────
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: widget.isWide ? 160 : 32,
              vertical: 40,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Greeting
                _animated(
                  0,
                  const Text(
                    'Hi, my name is',
                    style: TextStyle(
                      color: KC.mint,
                      fontSize: 16,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 2. Name
                _animated(
                  1,
                  Text(
                    'Karl Angelo Albaniel.',
                    style: TextStyle(
                      color: KC.textPrimary,
                      fontSize: widget.isWide ? 72 : 42,
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                      letterSpacing: -1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // 3. Tagline with typing animation
                _animated(
                  2,
                  Row(
                    children: [
                      Text(
                        'I build ',
                        style: TextStyle(
                          color: KC.textSecondary,
                          fontSize: widget.isWide ? 64 : 36,
                          fontWeight: FontWeight.w800,
                          height: 1.05,
                          letterSpacing: -1.5,
                        ),
                      ),
                      Text(
                        widget.typed,
                        style: TextStyle(
                          color: KC.textSecondary,
                          fontSize: widget.isWide ? 64 : 36,
                          fontWeight: FontWeight.w800,
                          height: 1.05,
                          letterSpacing: -1.5,
                        ),
                      ),
                      KCursor(),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 4. Bio paragraph
                _animated(
                  3,
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: KC.textSecondary,
                          fontSize: 16,
                          height: 1.7,
                          letterSpacing: 0.2,
                        ),
                        children: [
                          const TextSpan(
                            text:
                                "I'm a 4th year Information Systems student specializing in building "
                                "exceptional digital experiences. Currently focused on "
                                "mobile development, UI design, and backend systems at ",
                          ),
                          TextSpan(
                            text: 'FDSAP Internship.',
                            style: const TextStyle(color: KC.mint),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 52),

                // 5. CTA Button
                _animated(
                  4,
                  Row(
                    children: [
                      _CTAButton(
                        label: 'Check out my work!',
                        onTap: widget.onProjects,
                      ),
                      const SizedBox(width: 16),
                      _CTAButton(
                        label: 'Get in Touch',
                        onTap: widget.onContact,
                        outlined: false,
                      ),
                    ],
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

// ── CTA Button ───────────────────────────────────────────────────
class _CTAButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool outlined;
  const _CTAButton(
      {required this.label, required this.onTap, this.outlined = true});

  @override
  State<_CTAButton> createState() => _CTAButtonState();
}

class _CTAButtonState extends State<_CTAButton> {
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
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          decoration: BoxDecoration(
            color: widget.outlined
                ? (_hov ? KC.mint.withOpacity(0.1) : Colors.transparent)
                : (_hov ? KC.mint.withOpacity(0.08) : Colors.transparent),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: KC.mint, width: 1),
          ),
          child: Text(
            widget.label,
            style: const TextStyle(
              color: KC.mint,
              fontSize: 14,
              fontFamily: 'monospace',
              letterSpacing: 0.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Left Social Sidebar ──────────────────────────────────────────
class _SocialSidebar extends StatefulWidget {
  @override
  State<_SocialSidebar> createState() => _SocialSidebarState();
}

class _SocialSidebarState extends State<_SocialSidebar>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    Future.delayed(const Duration(milliseconds: 800), () {
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
    return FadeTransition(
      opacity: _fade,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SocialIcon(icon: Icons.code, tooltip: 'GitHub',
              url: 'https://github.com/yooolak'),
          const SizedBox(height: 20),
          _SocialIcon(icon: Icons.facebook, tooltip: 'Facebook',
              url: 'https://facebook.com'),
          const SizedBox(height: 20),
          _SocialIcon(icon: Icons.phone_outlined, tooltip: '+639949342201',
              url: 'tel:+639949342201'),
          const SizedBox(height: 20),
          // Vertical line
          Container(
            width: 1,
            height: 80,
            color: KC.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _SocialIcon extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final String url;
  const _SocialIcon(
      {required this.icon, required this.tooltip, required this.url});

  @override
  State<_SocialIcon> createState() => _SocialIconState();
}

class _SocialIconState extends State<_SocialIcon> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: Tooltip(
        message: widget.tooltip,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, _hov ? -4 : 0, 0),
          child: Icon(
            widget.icon,
            color: _hov ? KC.mint : KC.textSecondary,
            size: 20,
          ),
        ),
      ),
    );
  }
}

// ── Right Email Sidebar ──────────────────────────────────────────
class _EmailSidebar extends StatefulWidget {
  @override
  State<_EmailSidebar> createState() => _EmailSidebarState();
}

class _EmailSidebarState extends State<_EmailSidebar>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _fade;
  bool _hov = false;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    Future.delayed(const Duration(milliseconds: 900), () {
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
    return FadeTransition(
      opacity: _fade,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Vertical line on top
          Container(
            width: 1,
            height: 80,
            color: KC.textSecondary,
          ),
          const SizedBox(height: 20),
          // Rotated email
          MouseRegion(
            onEnter: (_) => setState(() => _hov = true),
            onExit: (_) => setState(() => _hov = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.translationValues(0, _hov ? -4 : 0, 0),
              child: RotatedBox(
                quarterTurns: 1,
                child: Text(
                  'kaloyalbaniel25@gmail.com',
                  style: TextStyle(
                    color: _hov ? KC.mint : KC.textSecondary,
                    fontSize: 12,
                    fontFamily: 'monospace',
                    letterSpacing: 2,
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
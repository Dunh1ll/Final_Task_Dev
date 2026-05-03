import 'package:flutter/material.dart';
import 'constants.dart';
import 'utilities.dart';
import 'about_page.dart' show SectionHeader;
import 'package:url_launcher/url_launcher.dart';

class KContactPage extends StatelessWidget {
  final bool isWide;
  const KContactPage({required this.isWide});

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
              // Big centered contact section
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    children: [
                      // Overline
                      const Text(
                        '04. What\'s Next?',
                        style: TextStyle(
                          color: KC.mint,
                          fontSize: 14,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Big heading
                      const Text(
                        'Get In Touch',
                        style: TextStyle(
                          color: KC.textPrimary,
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                          height: 1.1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Description
                      const Text(
                        "Although I'm not currently looking for any new opportunities, "
                        "my inbox is always open. Whether you have a question or just "
                        "want to say hi, I'll try my best to get back to you!",
                        style: TextStyle(
                          color: KC.textSecondary,
                          fontSize: 16,
                          height: 1.7,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),

                      // Say Hello button
                      _SayHelloButton(),

                      const SizedBox(height: 80),

                      // Contact info grid
                      _ContactGrid(isWide: isWide),

                      const SizedBox(height: 80),

                      // Footer
                      _Footer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

// ── Say Hello Button ─────────────────────────────────────────────
class _SayHelloButton extends StatefulWidget {
  @override
  State<_SayHelloButton> createState() => _SayHelloButtonState();
}

class _SayHelloButtonState extends State<_SayHelloButton> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: GestureDetector(
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
          decoration: BoxDecoration(
            color: _hov ? KC.mint.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: KC.mint, width: 1),
          ),
          child: const Text(
            'Say Hello',
            style: TextStyle(
              color: KC.mint,
              fontSize: 14,
              fontFamily: 'monospace',
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Contact Info Grid ─────────────────────────────────────────────
class _ContactGrid extends StatelessWidget {
  final bool isWide;
  const _ContactGrid({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final items = [
      _ContactItem(
        icon: Icons.email_outlined,
        label: 'Email',
        value: 'kaloyalbaniel25@gmail.com',
        url: 'mailto:kaloyalbaniel25@gmail.com',
      ),
      _ContactItem(
        icon: Icons.code,
        label: 'GitHub',
        value: 'github.com/yooolak',
        url: 'https://github.com/yooolak',
      ),
      _ContactItem(
        icon: Icons.facebook,
        label: 'Facebook',
        value: 'facebook.com/kaloy456',
        url: 'https://www.facebook.com/kaloy456',
      ),
      _ContactItem(
        icon: Icons.phone_outlined,
        label: 'Phone',
        value: '+63 994 934 2201',
        url: 'tel:+639949342201',
      ),
    ];

    if (isWide) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 3.5,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) => _ContactTile(item: items[i]),
      );
    }

    return Column(
      children: items
          .map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ContactTile(item: item),
              ))
          .toList(),
    );
  }
}

class _ContactItem {
  final IconData icon;
  final String label, value, url;
  const _ContactItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.url,
  });
}

class _ContactTile extends StatefulWidget {
  final _ContactItem item;
  const _ContactTile({required this.item});

  @override
  State<_ContactTile> createState() => _ContactTileState();
}

class _ContactTileState extends State<_ContactTile> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: GestureDetector(
        onTap: () async {
          final uri = Uri.parse(widget.item.url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _hov ? KC.bgCard : KC.bgLight,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _hov ? KC.mint.withOpacity(0.5) : KC.border,
            ),
          ),
          child: Row(
            children: [
              Icon(widget.item.icon, color: KC.mint, size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.item.label,
                      style: const TextStyle(
                        color: KC.textSecondary,
                        fontSize: 11,
                        fontFamily: 'monospace',
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.item.value,
                      style: TextStyle(
                        color: _hov ? KC.mint : KC.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: _hov ? KC.mint : KC.textMuted,
                size: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Footer ────────────────────────────────────────────────────────
class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(height: 1, color: KC.border),
        const SizedBox(height: 24),
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(
              color: KC.textSecondary,
              fontSize: 13,
              fontFamily: 'monospace',
              height: 1.8,
            ),
            children: [
              TextSpan(text: 'Designed & Built by '),
              TextSpan(
                  text: 'Karl Angelo Albaniel',
                  style: TextStyle(color: KC.mint)),
              TextSpan(text: '\nInspired by Brittany Chiang'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '© 2025 · All Rights Reserved',
          style: TextStyle(
            color: KC.textMuted,
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
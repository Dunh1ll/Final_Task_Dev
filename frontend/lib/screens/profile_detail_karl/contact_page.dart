import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'constants.dart';
import 'utilities.dart';
import 'about_page.dart' show SectionHeader;

class KContactPage extends StatelessWidget {
  final bool isWide;
  const KContactPage({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return KReveal(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(number: '04', title: 'Contact'),
          isWide ? _wideLayout() : _narrowLayout(),
          _Footer(),
        ],
      ),
    );
  }

  Widget _wideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LEFT — headline + links (equal half)
        Expanded(
          child: ClipRect(
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(color: KC.borderStr, width: 2),
                ),
              ),
              child: _ContactInfo(),
            ),
          ),
        ),
        // RIGHT — quiet form (equal half)
        Expanded(
          child: ClipRect(
            child: _ContactForm(),
          ),
        ),
      ],
    );
  }

  Widget _narrowLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ContactInfo(),
        Container(height: 2, color: KC.borderStr),
        _ContactForm(),
      ],
    );
  }
}

// ── Contact info panel (the star) ────────────────────────────────
class _ContactInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 48, 40, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KLabel('// Get in touch'),
          const SizedBox(height: 32),

          // ── Headline — natural wrap, no forced breaks ────
          const Text(
            'My inbox is always open.',
            style: TextStyle(
              fontFamily: KC.fontDisplay,
              fontWeight: FontWeight.w900,
              fontSize: 38,
              color: KC.textPrimary,
              letterSpacing: -1.5,
              height: 1.15,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            "Whether you have a question or just want to say hi — I'll get back to you.",
            style: KC.monoMedium.copyWith(
              fontSize: 12,
              color: KC.textMuted,
              height: 1.9,
            ),
          ),

          const SizedBox(height: 32),

          // ── Availability badge ───────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: KC.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PulseDot(),
                const SizedBox(width: 8),
                const Text(
                  'AVAILABLE FOR WORK',
                  style: TextStyle(
                    fontFamily: KC.fontMono,
                    fontSize: 9,
                    letterSpacing: 2.5,
                    color: KC.textMuted,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // ── Strong divider before links ──────────────────
          Container(height: 2, color: KC.borderStr),

          // ── Links — inverted hover rows ──────────────────
          _LinkRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: 'kaloyalbaniel25@gmail.com',
            url: 'mailto:kaloyalbaniel25@gmail.com',
          ),
          _LinkRow(
            icon: Icons.code_rounded,
            label: 'GitHub',
            value: 'github.com/yooolak',
            url: 'https://github.com/yooolak',
          ),
          _LinkRow(
            icon: Icons.facebook_rounded,
            label: 'Facebook',
            value: 'facebook.com/kaloy456',
            url: 'https://www.facebook.com/kaloy456',
          ),
          _LinkRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: '+63 994 934 2201',
            url: 'tel:+639949342201',
          ),

          const SizedBox(height: 40),

          // ── Response time note ───────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: KC.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KLabel('// Response time'),
                const SizedBox(height: 12),
                const Text(
                  'I typically respond within 24 hours. '
                  'For urgent matters, feel free to call directly.',
                  style: TextStyle(
                    fontFamily: KC.fontMono,
                    fontSize: 12,
                    color: KC.textSecondary,
                    height: 1.8,
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

// ── Pulse dot ─────────────────────────────────────────────────────
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
    _o = Tween<double>(begin: 1.0, end: 0.2)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
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
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: KC.textPrimary,
            shape: BoxShape.circle,
          ),
        ),
      );
}

// ── Link row — full-width, inverts on hover ───────────────────────
class _LinkRow extends StatefulWidget {
  final IconData icon;
  final String label, value, url;
  const _LinkRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.url,
  });

  @override
  State<_LinkRow> createState() => _LinkRowState();
}

class _LinkRowState extends State<_LinkRow> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: _hov ? KC.textPrimary : Colors.transparent,
            border: const Border(
              bottom: BorderSide(color: KC.border, width: 1),
            ),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 15,
                color: _hov ? KC.bg : KC.textDim,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label.toUpperCase(),
                      style: TextStyle(
                        fontFamily: KC.fontMono,
                        fontSize: 8,
                        letterSpacing: 2.5,
                        color: _hov ? KC.bg.withOpacity(0.6) : KC.textDim,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.value,
                      style: TextStyle(
                        fontFamily: KC.fontMono,
                        fontSize: 11,
                        color: _hov ? KC.bg : KC.textSecondary,
                        letterSpacing: 0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 10,
                color: _hov ? KC.bg : KC.textDim,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Contact form — quiet, secondary ──────────────────────────────
class _ContactForm extends StatefulWidget {
  @override
  State<_ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<_ContactForm> {
  final _name   = TextEditingController();
  final _email  = TextEditingController();
  final _msg    = TextEditingController();
  bool _sending = false;
  bool _sent    = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _msg.dispose();
    super.dispose();
  }

  void _send() async {
    final name    = _name.text.trim();
    final email   = _email.text.trim();
    final message = _msg.text.trim();

    final emailRx = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (name.isEmpty) {
      _snack('Please enter your name.', error: true); return;
    }
    if (!emailRx.hasMatch(email)) {
      _snack('Please enter a valid email.', error: true); return;
    }
    if (message.isEmpty) {
      _snack('Please enter a message.', error: true); return;
    }

    setState(() => _sending = true);

    try {
      final res = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'service_id':   'service_kuz8evm',
          'template_id':  'template_8irrdl2',
          'user_id':      '5w2kJLQ5Ib5js1BE-',
          'template_params': {
            'from_name':  name,
            'from_email': email,
            'message':    message,
          },
        }),
      );

      if (res.statusCode == 200) {
        _name.clear();
        _email.clear();
        _msg.clear();
        setState(() => _sent = true);
      } else {
        _snack('Something went wrong. Try again.', error: true);
      }
    } catch (_) {
      _snack('Failed to send. Check your connection.', error: true);
    }

    setState(() => _sending = false);
  }

  void _snack(String msg, {required bool error}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            fontFamily: KC.fontMono,
            fontSize: 12,
            color: KC.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: KC.bgCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(
            color: error ? const Color(0xFF666666) : KC.textPrimary,
          ),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: _sent
            ? _SuccessState(onReset: () => setState(() => _sent = false))
            : _FormBody(
                name: _name,
                email: _email,
                msg: _msg,
                sending: _sending,
                onSend: _send,
              ),
      ),
    );
  }
}

// ── Success state — replaces form after send ──────────────────────
class _SuccessState extends StatelessWidget {
  final VoidCallback onReset;
  const _SuccessState({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        const Text(
          '✓',
          style: TextStyle(
            fontFamily: KC.fontDisplay,
            fontWeight: FontWeight.w900,
            fontSize: 64,
            color: KC.textPrimary,
            height: 1,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Message sent.',
          style: TextStyle(
            fontFamily: KC.fontDisplay,
            fontWeight: FontWeight.w900,
            fontSize: 28,
            color: KC.textPrimary,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "I'll get back to you as soon as I can.",
          style: TextStyle(
            fontFamily: KC.fontMono,
            fontSize: 12,
            color: KC.textMuted,
            height: 1.9,
          ),
        ),
        const SizedBox(height: 32),
        _ResetLink(onTap: onReset),
      ],
    );
  }
}

class _ResetLink extends StatefulWidget {
  final VoidCallback onTap;
  const _ResetLink({required this.onTap});

  @override
  State<_ResetLink> createState() => _ResetLinkState();
}

class _ResetLinkState extends State<_ResetLink> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back_rounded,
              size: 12,
              color: _hov ? KC.textPrimary : KC.textDim,
            ),
            const SizedBox(width: 8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 160),
              style: TextStyle(
                fontFamily: KC.fontMono,
                fontSize: 10,
                letterSpacing: 2.5,
                color: _hov ? KC.textPrimary : KC.textDim,
              ),
              child: const Text('SEND ANOTHER'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Form body ─────────────────────────────────────────────────────
class _FormBody extends StatelessWidget {
  final TextEditingController name, email, msg;
  final bool sending;
  final VoidCallback onSend;

  const _FormBody({
    required this.name,
    required this.email,
    required this.msg,
    required this.sending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KLabel('// Drop a message'),
        const SizedBox(height: 28),

        // Name + Email side by side on wide, stacked on narrow
        LayoutBuilder(builder: (context, constraints) {
          final side = constraints.maxWidth > 420;
          if (side) {
            return Row(
              children: [
                Expanded(
                  child: _Field(
                    ctrl: name,
                    label: 'Name',
                    hint: 'Juan dela Cruz',
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _Field(
                    ctrl: email,
                    label: 'Email',
                    hint: 'juan@example.com',
                  ),
                ),
              ],
            );
          }
          return Column(
            children: [
              _Field(ctrl: name, label: 'Name', hint: 'Juan dela Cruz'),
              const SizedBox(height: 14),
              _Field(ctrl: email, label: 'Email', hint: 'juan@example.com'),
            ],
          );
        }),

        const SizedBox(height: 20),

        // Message — taller, more breathing room
        _Field(
          ctrl: msg,
          label: 'Message',
          hint: 'Your message...',
          maxLines: 7,
        ),

        const SizedBox(height: 32),

        // Send row — centered
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _SendBtn(onTap: sending ? null : onSend, sending: sending),
            const SizedBox(width: 20),
            if (!sending)
              const Text(
                '→  I read every message',
                style: TextStyle(
                  fontFamily: KC.fontMono,
                  fontSize: 9,
                  letterSpacing: 1.5,
                  color: KC.textDim,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ── Field — underline only, lighter than before ───────────────────
class _Field extends StatefulWidget {
  final TextEditingController ctrl;
  final String label, hint;
  final int maxLines;
  const _Field({
    required this.ctrl,
    required this.label,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: const TextStyle(
            fontFamily: KC.fontMono,
            fontSize: 8,
            letterSpacing: 3,
            color: KC.textDim,
          ),
        ),
        const SizedBox(height: 6),
        Focus(
          onFocusChange: (v) => setState(() => _focused = v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            decoration: BoxDecoration(
              color: _focused
                  ? KC.textPrimary.withOpacity(0.025)
                  : Colors.transparent,
              border: Border(
                bottom: BorderSide(
                  color: _focused ? KC.textPrimary : KC.border,
                  width: _focused ? 1.5 : 1,
                ),
              ),
            ),
child: TextField(
  controller: widget.ctrl,
  maxLines: widget.maxLines,
  style: KC.monoMedium,  // Changed
  decoration: InputDecoration(
    hintText: widget.hint,
    hintStyle: KC.monoMedium.copyWith(  // Changed
      color: KC.textDim,
    ),
    border: InputBorder.none,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 0,
      vertical: 12,
    ),
  ),
),
          ),
        ),
      ],
    );
  }
}

// ── Send button — compact, not full-width ─────────────────────────
class _SendBtn extends StatefulWidget {
  final VoidCallback? onTap;
  final bool sending;
  const _SendBtn({required this.onTap, required this.sending});

  @override
  State<_SendBtn> createState() => _SendBtnState();
}

class _SendBtnState extends State<_SendBtn> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.onTap != null && !widget.sending;

    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      cursor: active
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: widget.sending
                ? KC.textPrimary.withOpacity(0.5)
                : (_hov ? KC.textPrimary : Colors.transparent),
            border: Border.all(
              color: widget.sending
                  ? KC.textPrimary.withOpacity(0.5)
                  : KC.textPrimary,
              width: 1,
            ),
          ),
          child: widget.sending
              ? const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    color: KC.bg,
                    strokeWidth: 1.5,
                  ),
                )
              : Text(
                  'SEND',
                  style: TextStyle(
                    fontFamily: KC.fontMono,
                    fontSize: 9,
                    letterSpacing: 4,
                    color: _hov ? KC.bg : KC.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

// ── Footer — page-level, outside the form ─────────────────────────
class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: KC.border, width: 1),
        ),
      ),
      child: Row(
        children: const [
          Text(
            'Designed & Built by Karl Angelo Albaniel',
            style: TextStyle(
              fontFamily: KC.fontMono,
              fontSize: 10,
              color: KC.textDim,
              letterSpacing: 1,
            ),
          ),
          Spacer(),
          Text(
            '© 2025',
            style: TextStyle(
              fontFamily: KC.fontMono,
              fontSize: 9,
              color: KC.textDim,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
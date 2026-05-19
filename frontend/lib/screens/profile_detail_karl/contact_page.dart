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
      delay: const Duration(milliseconds: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(number: '04', title: 'Contact'),
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
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: kc.borderStr, width: 2),
                ),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: _ContactInfo(),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(48, 48, 48, 48),
                child: _ContactForm(),
              ),
            ),
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
        _ContactInfo(),
        Container(height: 2, color: kc.borderStr),
        Padding(
          padding: const EdgeInsets.all(24),
          child: _ContactForm(),
        ),
      ],
    );
  }
}

// ── Contact info panel ────────────────────────────────────────────
class _ContactInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final kc = KTheme.colors(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 48, 40, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KLabel('// Get in touch'),
          const SizedBox(height: 32),

          Text(
            'My inbox is always open.',
            style: TextStyle(
              fontFamily: KC.fontDisplay,
              fontWeight: FontWeight.w900,
              fontSize: 44,
              color: kc.textPrimary,
              letterSpacing: -1.5,
              height: 1.15,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            "Whether you have a question or just want to say hi — I'll get back to you.",
            style: TextStyle(
              fontFamily: KC.fontMono,
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: kc.textMuted,
              height: 1.9,
            ),
          ),

          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: kc.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PulseDot(),
                const SizedBox(width: 8),
                Text(
                  'AVAILABLE FOR WORK',
                  style: TextStyle(
                    fontFamily: KC.fontMono,
                    fontSize: 11,
                    letterSpacing: 2.5,
                    color: kc.textMuted,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          Container(height: 2, color: kc.borderStr),

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

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: kc.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KLabel('// Response time'),
                const SizedBox(height: 12),
                Text(
                  'I typically respond within 24 hours. '
                  'For urgent matters, feel free to call directly.',
                  style: TextStyle(
                    fontFamily: KC.fontMono,
                    fontSize: 13,
                    color: kc.textSecondary,
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

// ── Link row ──────────────────────────────────────────────────────
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
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: _hov ? kc.textPrimary : Colors.transparent,
            border: Border(
              bottom: BorderSide(color: kc.border, width: 1),
            ),
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 15,
                  color: _hov ? kc.bg : kc.textDim),
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
                        color: _hov ? kc.bg.withOpacity(0.6) : kc.textDim,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.value,
                      style: TextStyle(
                        fontFamily: KC.fontMono,
                        fontSize: 13,
                        color: _hov ? kc.bg : kc.textSecondary,
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
                color: _hov ? kc.bg : kc.textDim,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Contact form ──────────────────────────────────────────────────
class _ContactForm extends StatefulWidget {
  @override
  State<_ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<_ContactForm> {
  final _name  = TextEditingController();
  final _email = TextEditingController();
  final _msg   = TextEditingController();
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
          'service_id':  'service_kuz8evm',
          'template_id': 'template_8irrdl2',
          'user_id':     '5w2kJLQ5Ib5js1BE-',
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
    final kc = KTheme.colors(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
          style: TextStyle(
            fontFamily: KC.fontMono,
            fontSize: 12,
            color: kc.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: kc.bgCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(
            color: error ? const Color(0xFF666666) : kc.textPrimary,
          ),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _sent
        ? _SuccessState(onReset: () => setState(() => _sent = false))
        : _FormPanel(
            name: _name,
            email: _email,
            msg: _msg,
            sending: _sending,
            onSend: _send,
          );
  }
}

// ── Form panel ────────────────────────────────────────────────────
class _FormPanel extends StatelessWidget {
  final TextEditingController name, email, msg;
  final bool sending;
  final VoidCallback onSend;

  const _FormPanel({
    required this.name,
    required this.email,
    required this.msg,
    required this.sending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final kc = KTheme.colors(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: kc.borderStr, width: 1.5),
        color: kc.textPrimary.withOpacity(0.018),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Form header ───────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 28, vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: kc.borderStr, width: 1.5),
              ),
            ),
            child: Row(
              children: [
                KLabel('// Drop a message'),
                const Spacer(),
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: kc.border, width: 1.5),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: kc.border, width: 1.5),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kc.borderStr,
                  ),
                ),
              ],
            ),
          ),

          // ── Fields ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Field(ctrl: name, label: 'Name', hint: 'Your name'),
                const SizedBox(height: 20),
                _Field(ctrl: email, label: 'Email', hint: 'your@email.com'),
                const SizedBox(height: 20),
                _Field(
                  ctrl: msg,
                  label: 'Message',
                  hint: 'Your message...',
                  maxLines: 6,
                ),
              ],
            ),
          ),

          // ── Footer row ────────────────────────────────────
          Container(
            margin: const EdgeInsets.only(top: 24),
            padding: const EdgeInsets.symmetric(
                horizontal: 28, vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: kc.border, width: 1),
              ),
            ),
            child: Row(
              children: [
                Text(
                  '→  I read every message',
                  style: TextStyle(
                    fontFamily: KC.fontMono,
                    fontSize: 10,
                    letterSpacing: 1.5,
                    color: kc.textDim,
                  ),
                ),
                const Spacer(),
                _SendBtn(
                  onTap: sending ? null : onSend,
                  sending: sending,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Success state ─────────────────────────────────────────────────
class _SuccessState extends StatelessWidget {
  final VoidCallback onReset;
  const _SuccessState({required this.onReset});

  @override
  Widget build(BuildContext context) {
    final kc = KTheme.colors(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        border: Border.all(color: kc.borderStr, width: 1.5),
        color: kc.textPrimary.withOpacity(0.018),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '✓',
            style: TextStyle(
              fontFamily: KC.fontDisplay,
              fontWeight: FontWeight.w900,
              fontSize: 64,
              color: kc.textPrimary,
              height: 1,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Message sent.',
            style: TextStyle(
              fontFamily: KC.fontDisplay,
              fontWeight: FontWeight.w900,
              fontSize: 28,
              color: kc.textPrimary,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "I'll get back to you as soon as I can.",
            style: TextStyle(
              fontFamily: KC.fontMono,
              fontSize: 12,
              color: kc.textMuted,
              height: 1.9,
            ),
          ),
          const SizedBox(height: 32),
          _ResetLink(onTap: onReset),
        ],
      ),
    );
  }
}

// ── Reset link ────────────────────────────────────────────────────
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
    final kc = KTheme.colors(context);
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
              color: _hov ? kc.textPrimary : kc.textDim,
            ),
            const SizedBox(width: 8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 160),
              style: TextStyle(
                fontFamily: KC.fontMono,
                fontSize: 10,
                letterSpacing: 2.5,
                color: _hov ? kc.textPrimary : kc.textDim,
              ),
              child: const Text('SEND ANOTHER'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Field ─────────────────────────────────────────────────────────
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
    final kc = KTheme.colors(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: TextStyle(
            fontFamily: KC.fontMono,
            fontSize: 10,
            letterSpacing: 3,
            color: kc.textDim,
          ),
        ),
        const SizedBox(height: 6),
        Focus(
          onFocusChange: (v) => setState(() => _focused = v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            decoration: BoxDecoration(
              color: _focused
                  ? kc.textPrimary.withOpacity(0.025)
                  : Colors.transparent,
              border: Border(
                bottom: BorderSide(
                  color: _focused ? kc.textPrimary : kc.border,
                  width: _focused ? 1.5 : 1,
                ),
              ),
            ),
            child: TextField(
              controller: widget.ctrl,
              maxLines: widget.maxLines,
              style: TextStyle(
                fontFamily: KC.fontMono,
                fontWeight: FontWeight.w500,
                fontSize: 13,
                letterSpacing: 0.2,
                color: kc.textSecondary,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(
                  fontFamily: KC.fontMono,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  letterSpacing: 0.2,
                  color: kc.textDim,
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

// ── Send button ───────────────────────────────────────────────────
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
    final kc = KTheme.colors(context);
    final active = widget.onTap != null && !widget.sending;

    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      cursor: active ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
          decoration: BoxDecoration(
            color: widget.sending
                ? kc.textPrimary.withOpacity(0.5)
                : (_hov ? kc.textPrimary : Colors.transparent),
            border: Border.all(
              color: widget.sending
                  ? kc.textPrimary.withOpacity(0.5)
                  : kc.textPrimary,
              width: 1,
            ),
          ),
          child: widget.sending
              ? SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    color: kc.bg,
                    strokeWidth: 1.5,
                  ),
                )
              : Text(
                  'SEND MESSAGE',
                  style: TextStyle(
                    fontFamily: KC.fontMono,
                    fontSize: 9,
                    letterSpacing: 4,
                    color: _hov ? kc.bg : kc.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }
      }
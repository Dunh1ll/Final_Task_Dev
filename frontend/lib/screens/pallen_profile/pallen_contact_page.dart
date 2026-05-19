import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'pallen_theme.dart';
import 'pallen_widgets.dart';

// ── ✏️  EMAILJS CREDENTIALS ──────────────────────────────────────────
const _kServiceId = 'service_cu9rr9l';
const _kTemplateId = 'template_c1ino5u';
const _kPublicKey = 'cFsZuR4lxMxyNNJnr';
// ────────────────────────────────────────────────────────────────────

class PallenContactPage extends StatefulWidget {
  final void Function(String) onOpen;
  final Widget footer;

  const PallenContactPage({
    super.key,
    required this.onOpen,
    required this.footer,
  });

  @override
  State<PallenContactPage> createState() => _PallenContactPageState();
}

class _PallenContactPageState extends State<PallenContactPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  bool _sending = false;
  bool _sent = false;
  String? _error;
  int _messageLength = 0;

  // Anchor so "Send a Message" button scrolls to the form
  final _formKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _messageCtrl.addListener(
      () => setState(() => _messageLength = _messageCtrl.text.length),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  // ── Smooth-scroll to form ───────────────────────────────────────────
  void _scrollToForm() {
    final ctx = _formKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    }
  }

  // ── EmailJS send ────────────────────────────────────────────────────
  Future<void> _send() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final subject = _subjectCtrl.text.trim();
    final message = _messageCtrl.text.trim();

    if (name.isEmpty || email.isEmpty || message.isEmpty) {
      setState(() => _error = 'Please fill in your name, email, and message.');
      return;
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      setState(() => _error = 'Please enter a valid email address.');
      return;
    }
    if (message.length < 10) {
      setState(() => _error =
          'Your message is too short — please write at least 10 characters.');
      return;
    }

    setState(() {
      _error = null;
      _sending = true;
    });

    try {
      final response = await html.HttpRequest.request(
        'https://api.emailjs.com/api/v1.0/email/send',
        method: 'POST',
        requestHeaders: {
          'Content-Type': 'application/json',
          'origin': html.window.location.origin,
        },
        sendData: jsonEncode({
          'service_id': _kServiceId,
          'template_id': _kTemplateId,
          'user_id': _kPublicKey,
          'template_params': {
            'from_name': name,
            'from_email': email,
            'subject': subject.isEmpty ? 'Portfolio Inquiry' : subject,
            'message': message,
          },
        }),
      );

      if (response.status == 200) {
        setState(() {
          _sending = false;
          _sent = true;
        });
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) {
            setState(() {
              _sent = false;
              _nameCtrl.clear();
              _emailCtrl.clear();
              _subjectCtrl.clear();
              _messageCtrl.clear();
            });
          }
        });
      } else {
        setState(() {
          _sending = false;
          _error =
              'Send failed (${response.status}). Check your EmailJS credentials.';
        });
      }
    } catch (_) {
      setState(() {
        _sending = false;
        _error = 'Something went wrong. Check your connection and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = PTheme.of(context);

    final contacts = [
      PallenContactData(
          kind: PallenContactKind.facebook,
          platform: 'Facebook',
          handle: 'Dunhill Pallen',
          detail: 'facebook.com/dnhll.plln',
          url: kPallenFacebook),
      PallenContactData(
          kind: PallenContactKind.github,
          platform: 'GitHub',
          handle: 'Dunh1ll',
          detail: 'github.com/Dunh1ll',
          url: kPallenGitHub),
      PallenContactData(
          kind: PallenContactKind.gmail,
          platform: 'Gmail',
          handle: 'cpe.pallen.princedunhill@gmail.com',
          detail: 'cpe.pallen.princedunhill@gmail.com',
          url: kPallenGmail),
      PallenContactData(
          kind: PallenContactKind.linkedin,
          platform: 'LinkedIn',
          handle: 'Prince Dunhill Pallen',
          detail: 'linkedin.com/in/pallen-prince-dunhill',
          url: kPallenLinkedIn),
      PallenContactData(
          kind: PallenContactKind.instagram,
          platform: 'Instagram',
          handle: '@nturdanii',
          detail: 'instagram.com/nturdanii',
          url: kPallenInstagram),
      PallenContactData(
          kind: PallenContactKind.phone,
          platform: 'Mobile',
          handle: '0950 464 7074',
          detail: 'Philippines',
          url: kPallenPhone),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 80),
        Container(
          color: pBg(d),
          padding: const EdgeInsets.fromLTRB(76, 56, 76, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Section header ────────────────────────────────────
              ScrollReveal(child: const PallenEyebrowLabel('03 — CONTACT')),
              ScrollReveal(
                delay: 0.1,
                child: Text(
                  "Let's work together.",
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    color: pHead(d),
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 52),

              // ── Top row ───────────────────────────────────────────
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // LEFT — intro + info cards + CTA
                Expanded(
                  flex: 36,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ScrollReveal(
                        child: Text(
                          'Open to full-time opportunities, freelance projects, '
                          'and interesting collaborations. Whether you have a '
                          'question or just want to say hi — my inbox is open.',
                          style: TextStyle(
                              fontFamily: 'DMSans',
                              color: pBody(d),
                              fontSize: 14,
                              height: 1.8),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Response time
                      ScrollReveal(
                        delay: 0.1,
                        child: PallenHoverCard(
                          slideRight: true,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 14),
                          child: Row(children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: pBg3(d),
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(color: pBorder(d)),
                              ),
                              child: Icon(Icons.timer_outlined,
                                  color: pIcon(d), size: 17),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Response Time',
                                      style: TextStyle(
                                        fontFamily: 'DMSans',
                                        color: pCardText(d),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      )),
                                  const SizedBox(height: 2),
                                  Text('I typically reply within 48 hours.',
                                      style: TextStyle(
                                        fontFamily: 'DMSans',
                                        color: pCardSub(d),
                                        fontSize: 11,
                                      )),
                                ],
                              ),
                            ),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Location
                      ScrollReveal(
                        delay: 0.2,
                        child: PallenHoverCard(
                          slideRight: true,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 14),
                          child: Row(children: [
                            const PallenIconSquare(
                                icon: Icons.location_on_outlined, size: 36),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Location',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      color: pCardText(d),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    )),
                                const SizedBox(height: 2),
                                Text('Alaminos  ·  Laguna',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      color: pCardSub(d),
                                      fontSize: 11,
                                    )),
                              ],
                            ),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── CTA: scrolls to form (no browser open) ────
                      ScrollReveal(
                        delay: 0.3,
                        child: MagneticButton(
                          onTap: _scrollToForm,
                          child: PallenCtaButton(
                            label: 'Send a Message',
                            icon: Icons.edit_outlined,
                            filled: true,
                            onTap: _scrollToForm,
                            magnetic: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 64),

                // RIGHT — social grid
                Expanded(
                  flex: 64,
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 3.2,
                    ),
                    itemCount: contacts.length,
                    itemBuilder: (_, i) => ScrollReveal(
                      delay: 0.05 * i,
                      child: PallenContactCard(
                        data: contacts[i],
                        onTap: () => widget.onOpen(contacts[i].url),
                      ),
                    ),
                  ),
                ),
              ]),

              // ── Divider ───────────────────────────────────────────
              const SizedBox(height: 64),
              ScrollReveal(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.transparent,
                      pLine(d),
                      Colors.transparent,
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 52),

              // ── Form header ───────────────────────────────────────
              ScrollReveal(
                  delay: 0.05,
                  child: const PallenEyebrowLabel('SEND A MESSAGE')),
              const SizedBox(height: 12),
              ScrollReveal(
                delay: 0.1,
                child: Text(
                  'Drop me a message directly.',
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    color: pHead(d),
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    height: 1.15,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ScrollReveal(
                delay: 0.15,
                child: Text(
                  'Fill in the form and hit Send — your message goes straight to my Gmail inbox.',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    color: pBody(d),
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // ── Form ─────────────────────────────────────────────
              // NOTE: NOT wrapped in ScrollReveal — that widget was
              // hiding the form because the visibility threshold was
              // never crossed on shorter viewports. The GlobalKey
              // anchor (_formKey) is enough for the scroll-to behavior.
              _MessageForm(
                key: _formKey,
                d: d,
                nameCtrl: _nameCtrl,
                emailCtrl: _emailCtrl,
                subjectCtrl: _subjectCtrl,
                messageCtrl: _messageCtrl,
                messageLength: _messageLength,
                sending: _sending,
                sent: _sent,
                error: _error,
                onSend: _send,
              ),
            ],
          ),
        ),
        widget.footer,
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// MESSAGE FORM
// ═══════════════════════════════════════════════════════════════════
class _MessageForm extends StatelessWidget {
  final bool d;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController subjectCtrl;
  final TextEditingController messageCtrl;
  final int messageLength;
  final bool sending;
  final bool sent;
  final String? error;
  final VoidCallback onSend;

  const _MessageForm({
    super.key,
    required this.d,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.subjectCtrl,
    required this.messageCtrl,
    required this.messageLength,
    required this.sending,
    required this.sent,
    required this.error,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: pCard(d),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: pCardBorder(d)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + Email
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: _Field(
                d: d,
                label: 'Your Name *',
                hint: 'e.g. Juan Dela Cruz',
                ctrl: nameCtrl,
                icon: Icons.person_outline_rounded,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _Field(
                d: d,
                label: 'Your Email *',
                hint: 'e.g. juan@email.com',
                ctrl: emailCtrl,
                icon: Icons.alternate_email_rounded,
                inputType: TextInputType.emailAddress,
              ),
            ),
          ]),
          const SizedBox(height: 16),

          // Subject
          _Field(
            d: d,
            label: 'Subject',
            hint: 'What is this about? (optional)',
            ctrl: subjectCtrl,
            icon: Icons.subject_rounded,
          ),
          const SizedBox(height: 16),

          // Message
          _MessageSection(
            d: d,
            ctrl: messageCtrl,
            charCount: messageLength,
          ),
          const SizedBox(height: 24),

          // Error
          if (error != null) ...[
            _Banner(
                color: const Color(0xFFEF4444),
                icon: Icons.error_outline_rounded,
                text: error!),
            const SizedBox(height: 16),
          ],

          // Success
          if (sent) ...[
            _Banner(
                color: kPGreen,
                icon: Icons.check_circle_outline_rounded,
                text: "Message sent! It's now in Pallen's Gmail inbox."),
            const SizedBox(height: 16),
          ],

          // Privacy note + send button
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.lock_outline_rounded,
                        size: 11, color: pMuted(d)),
                    const SizedBox(width: 5),
                    Text(
                      'Your info is only used to reply to you.',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        color: pMuted(d),
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              _SendButton(d: d, sending: sending, sent: sent, onSend: onSend),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// MESSAGE SECTION  (label + rich textarea + inner footer bar)
// ═══════════════════════════════════════════════════════════════════
class _MessageSection extends StatefulWidget {
  final bool d;
  final TextEditingController ctrl;
  final int charCount;

  const _MessageSection({
    required this.d,
    required this.ctrl,
    required this.charCount,
  });

  @override
  State<_MessageSection> createState() => _MessageSectionState();
}

class _MessageSectionState extends State<_MessageSection> {
  bool _focused = false;

  static const int _maxChars = 1000;
  static const accent = kPGreen;

  @override
  Widget build(BuildContext context) {
    final d = widget.d;
    final count = widget.charCount;

    final counterColor = count > _maxChars
        ? const Color(0xFFEF4444)
        : count > (_maxChars * 0.85)
            ? const Color(0xFFF59E0B)
            : pMuted(d);

    final tip = count == 0
        ? 'Be as descriptive as possible — it helps me respond better.'
        : count < 10
            ? 'A bit short — tell me more!'
            : count < 50
                ? 'Looking good, keep going…'
                : 'Great detail — this helps a lot!';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label row
        Row(children: [
          Text(
            'Message *',
            style: TextStyle(
              fontFamily: 'DMSans',
              color: pCardSub(d),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accent.withOpacity(0.25)),
            ),
            child: Text(
              'required',
              style: TextStyle(
                fontFamily: 'DMSans',
                color: accent.withOpacity(0.8),
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ]),
        const SizedBox(height: 8),

        // Textarea container
        Focus(
          onFocusChange: (f) => setState(() => _focused = f),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: _focused ? pBg3(d) : pBg2(d),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _focused ? accent.withOpacity(0.6) : pBorder(d),
                width: _focused ? 1.5 : 1.0,
              ),
              boxShadow: _focused
                  ? [
                      BoxShadow(
                          color: accent.withOpacity(0.08),
                          blurRadius: 16,
                          spreadRadius: 1)
                    ]
                  : [],
            ),
            child: Column(
              children: [
                TextField(
                  controller: widget.ctrl,
                  maxLines: 7,
                  maxLength: _maxChars,
                  keyboardType: TextInputType.multiline,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    color: pCardText(d),
                    fontSize: 13,
                    height: 1.6,
                  ),
                  cursorColor: accent,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText:
                        'Write your message here…\n\nFeel free to describe your project, idea, or just say hello!',
                    hintStyle: TextStyle(
                      fontFamily: 'DMSans',
                      color: pMuted(d),
                      fontSize: 13,
                      height: 1.6,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  ),
                ),

                // Inner footer bar
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: _focused
                        ? accent.withOpacity(0.04)
                        : pBg2(d).withOpacity(0.6),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(11),
                      bottomRight: Radius.circular(11),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: _focused
                            ? accent.withOpacity(0.18)
                            : pBorder(d).withOpacity(0.6),
                      ),
                    ),
                  ),
                  child: Row(children: [
                    Icon(Icons.tips_and_updates_outlined,
                        size: 11, color: pMuted(d)),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        tip,
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          color: pMuted(d),
                          fontSize: 10.5,
                          height: 1.3,
                        ),
                      ),
                    ),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 150),
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        color: counterColor,
                        fontSize: 10.5,
                        fontWeight: count > _maxChars
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                      child: Text('$count / $_maxChars'),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// BANNER  (error / success)
// ═══════════════════════════════════════════════════════════════════
class _Banner extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  const _Banner({required this.color, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: TextStyle(
                  fontFamily: 'DMSans',
                  color: color,
                  fontSize: 12,
                  height: 1.4)),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// STYLED TEXT FIELD  (single-line)
// ═══════════════════════════════════════════════════════════════════
class _Field extends StatefulWidget {
  final bool d;
  final String label;
  final String hint;
  final TextEditingController ctrl;
  final IconData icon;
  final int maxLines;
  final TextInputType inputType;

  const _Field({
    required this.d,
    required this.label,
    required this.hint,
    required this.ctrl,
    required this.icon,
    this.maxLines = 1,
    this.inputType = TextInputType.text,
  });

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    const accent = kPGreen;
    final d = widget.d;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: TextStyle(
              fontFamily: 'DMSans',
              color: pCardSub(d),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            )),
        const SizedBox(height: 8),
        Focus(
          onFocusChange: (f) => setState(() => _focused = f),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: _focused ? pBg3(d) : pBg2(d),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _focused ? accent.withOpacity(0.6) : pBorder(d),
                width: _focused ? 1.5 : 1.0,
              ),
              boxShadow: _focused
                  ? [
                      BoxShadow(
                          color: accent.withOpacity(0.08),
                          blurRadius: 16,
                          spreadRadius: 1)
                    ]
                  : [],
            ),
            child: TextField(
              controller: widget.ctrl,
              maxLines: widget.maxLines,
              keyboardType: widget.inputType,
              style: TextStyle(
                fontFamily: 'DMSans',
                color: pCardText(d),
                fontSize: 13,
                height: 1.5,
              ),
              cursorColor: accent,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(
                    fontFamily: 'DMSans', color: pMuted(d), fontSize: 13),
                prefixIcon: widget.maxLines == 1
                    ? Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Icon(widget.icon,
                            color: _focused ? accent : pIcon(d), size: 16),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: widget.maxLines > 1
                    ? const EdgeInsets.all(16)
                    : const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// SEND BUTTON
// ═══════════════════════════════════════════════════════════════════
class _SendButton extends StatefulWidget {
  final bool d;
  final bool sending;
  final bool sent;
  final VoidCallback onSend;
  const _SendButton({
    required this.d,
    required this.sending,
    required this.sent,
    required this.onSend,
  });

  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    const accent = kPGreen;
    final busy = widget.sending || widget.sent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      cursor: busy ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: busy ? null : widget.onSend,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _hov && !busy ? -3 : 0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
          decoration: BoxDecoration(
            color: widget.sent
                ? accent.withOpacity(0.12)
                : (_hov && !widget.sending ? accent : accent.withOpacity(0.88)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.sent ? accent.withOpacity(0.4) : accent,
            ),
            boxShadow: _hov && !busy
                ? [
                    BoxShadow(
                        color: accent.withOpacity(0.28),
                        blurRadius: 22,
                        spreadRadius: 1)
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.sending)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black.withOpacity(0.7),
                  ),
                )
              else
                Icon(
                  widget.sent ? Icons.check_rounded : Icons.send_rounded,
                  size: 15,
                  color: widget.sent ? accent : Colors.black,
                ),
              const SizedBox(width: 9),
              Text(
                widget.sending
                    ? 'Sending…'
                    : widget.sent
                        ? 'Message Sent!'
                        : 'Send Message',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  color: widget.sent ? accent : Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

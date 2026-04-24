// lib/screens/pallen_profile/pallen_contact_page.dart
import 'package:flutter/material.dart';
import 'pallen_theme.dart';
import 'pallen_widgets.dart';

class PallenContactPage extends StatelessWidget {
  final void Function(String) onOpen;
  final Widget footer;

  const PallenContactPage({
    super.key,
    required this.onOpen,
    required this.footer,
  });

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

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(children: [
        const SizedBox(height: 80),
        Container(
          color: pBg(d),
          padding: const EdgeInsets.fromLTRB(76, 56, 76, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PallenEyebrowLabel('03 — CONTACT'),
              Text(
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
              const SizedBox(height: 52),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // LEFT: intro
                Expanded(
                  flex: 36,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Open to full-time opportunities, freelance projects, '
                        'and interesting collaborations. Whether you have a '
                        'question or just want to say hi — my inbox is open.',
                        style: TextStyle(
                            fontFamily: 'DMSans',
                            color: pBody(d),
                            fontSize: 14,
                            height: 1.8),
                      ),
                      const SizedBox(height: 28),
                      PallenHoverCard(
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
                      const SizedBox(height: 12),
                      PallenHoverCard(
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
                              Text('Philippines  ·  Remote & On-site',
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    color: pCardSub(d),
                                    fontSize: 11,
                                  )),
                            ],
                          ),
                        ]),
                      ),
                      const SizedBox(height: 28),
                      PallenCtaButton(
                        label: 'Send an Email',
                        icon: Icons.mail_outline_rounded,
                        filled: true,
                        onTap: () => onOpen(kPallenGmail),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 64),

                // RIGHT: contact grid
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
                    itemBuilder: (_, i) => PallenContactCard(
                      data: contacts[i],
                      onTap: () => onOpen(contacts[i].url),
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
        footer,
      ]),
    );
  }
}

import 'package:flutter/material.dart';
import 'constants.dart';
import 'utilities.dart';
import 'shared.dart';

class KAboutPage extends StatelessWidget {
  final bool isWide;
  const KAboutPage({required this.isWide});

  @override
  Widget build(BuildContext context) => KReveal(child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      KTHead(label: "ABOUT", title: "About Me", color: KC.blue),
      const SizedBox(height: 18),
      Expanded(child: isWide ? _wide() : _narrow()),
    ]),
  ));

  Widget _wide() => Column(children: [
    Expanded(flex: 5, child: Row(children: [
      Expanded(flex: 5, child: KBCard(
        color: KC.blue,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          KLbl("WHO I AM", KC.blue),
          const SizedBox(height: 14),
          Expanded(child: SingleChildScrollView(child: RichText(text: const TextSpan(
            style: TextStyle(color: KC.muted, fontSize: 15, height: 1.85),
            children: [
              TextSpan(text: "I'm a 4th year Information Systems student ",
                  style: TextStyle(color: KC.text, fontWeight: FontWeight.w600)),
              TextSpan(text: "with a genuine passion for building modern digital solutions. "
                  "My focus is mobile app development, UI design, and backend integration.\n\n"
                  "I care about "),
              TextSpan(text: "clean code",
                  style: TextStyle(color: KC.text, fontWeight: FontWeight.w600)),
              TextSpan(text: " and intuitive interfaces — building experiences that actually matter."),
            ],
          )))),
        ]),
      )),
      const SizedBox(width: 10),
      Expanded(flex: 3, child: Column(children: [
        Expanded(child: KBCard(
          color: KC.green,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            KLbl("LOCATION", KC.green),
            const Text("📍", style: TextStyle(fontSize: 32)),
            const Text("Laguna,\nPhilippines", style: TextStyle(
              color: KC.text, fontSize: 18, fontWeight: FontWeight.w700, height: 1.3,
            )),
          ]),
        )),
        const SizedBox(height: 10),
        Expanded(child: KBCard(
          color: KC.amber,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            KLbl("STATUS", KC.amber),
            const Text("✅", style: TextStyle(fontSize: 32)),
            const Text("Open to\nOpportunities", style: TextStyle(
              color: KC.text, fontSize: 16, fontWeight: FontWeight.w700, height: 1.3,
            )),
          ]),
        )),
      ])),
    ])),
    const SizedBox(height: 10),
    Expanded(flex: 4, child: Row(children: [
      Expanded(flex: 4, child: KBCard(
        color: KC.purple,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          KLbl("SKILLS", KC.purple),
          const SizedBox(height: 16),
          Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            KSBar("💙", "Flutter Development", KC.blue,   0.88),
            KSBar("🎨", "UI / UX Design",      KC.rose,   0.75),
            KSBar("⚙️", "Golang Backend",      KC.green,  0.65),
            KSBar("🗄️", "PostgreSQL",          KC.amber,  0.70),
          ])),
        ]),
      )),
      const SizedBox(width: 10),
      Expanded(flex: 5, child: KBCard(
        color: KC.amber,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          KLbl("TECH STACK", KC.amber),
          const SizedBox(height: 4),
          const Text("Technologies I work with",
              style: TextStyle(color: KC.hint, fontSize: 12)),
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8, children: [
            KTC(KC.blue,   "F",  "Flutter"),
            KTC(KC.blue,   "D",  "Dart"),
            KTC(KC.green,  "Go", "Golang"),
            KTC(KC.amber,  "PG", "PostgreSQL"),
            KTC(KC.purple, "VS", "VS Code"),
            KTC(KC.rose,   "GH", "GitHub"),
          ]),
        ]),
      )),
    ])),
  ]);

  Widget _narrow() => SingleChildScrollView(
    physics: const BouncingScrollPhysics(),
    child: Column(children: [
      KBCard(color: KC.blue, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        KLbl("WHO I AM", KC.blue), const SizedBox(height: 12),
        RichText(text: const TextSpan(style: TextStyle(color: KC.muted, fontSize: 15, height: 1.85),
          children: [
            TextSpan(text: "I'm a 4th year Information Systems student ",
                style: TextStyle(color: KC.text, fontWeight: FontWeight.w600)),
            TextSpan(text: "with a genuine passion for building modern digital solutions. "
                "My focus is mobile app development, UI design, and backend integration.\n\n"
                "I care about "),
            TextSpan(text: "clean code",
                style: TextStyle(color: KC.text, fontWeight: FontWeight.w600)),
            TextSpan(text: " and intuitive interfaces — building experiences that matter."),
          ],
        )),
      ])),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: KBCard(color: KC.green, child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          KLbl("LOCATION", KC.green),
          const SizedBox(height: 8),
          const Text("📍", style: TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          const Text("Laguna, PH", style: TextStyle(
            color: KC.text, fontSize: 15, fontWeight: FontWeight.w700,
          )),
        ]))),
        const SizedBox(width: 10),
        Expanded(child: KBCard(color: KC.amber, child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          KLbl("STATUS", KC.amber),
          const SizedBox(height: 8),
          const Text("✅", style: TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          const Text("Open to Work", style: TextStyle(
            color: KC.text, fontSize: 15, fontWeight: FontWeight.w700,
          )),
        ]))),
      ]),
      const SizedBox(height: 10),
      KBCard(color: KC.purple, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        KLbl("SKILLS", KC.purple), const SizedBox(height: 14),
        KSBar("💙", "Flutter Development", KC.blue,  0.88),
        KSBar("🎨", "UI / UX Design",      KC.rose,  0.75),
        KSBar("⚙️", "Golang Backend",      KC.green, 0.65),
        KSBar("🗄️", "PostgreSQL",          KC.amber, 0.70),
      ])),
      const SizedBox(height: 10),
      KBCard(color: KC.amber, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        KLbl("TECH STACK", KC.amber), const SizedBox(height: 4),
        const Text("Technologies I work with",
            style: TextStyle(color: KC.hint, fontSize: 12)),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          KTC(KC.blue,   "F",  "Flutter"),
          KTC(KC.blue,   "D",  "Dart"),
          KTC(KC.green,  "Go", "Golang"),
          KTC(KC.amber,  "PG", "PostgreSQL"),
          KTC(KC.purple, "VS", "VS Code"),
          KTC(KC.rose,   "GH", "GitHub"),
        ]),
      ])),
      const SizedBox(height: 16),
    ]),
  );
}
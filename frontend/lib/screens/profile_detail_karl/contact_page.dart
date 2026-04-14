import 'package:flutter/material.dart';
import 'constants.dart';
import 'utilities.dart';
import 'shared.dart';

class KContactPage extends StatelessWidget {
  final bool isWide;
  const KContactPage({required this.isWide});

  @override
  Widget build(BuildContext context) => KReveal(child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      KTHead(label: "CONTACT", title: "Get in Touch", color: KC.green),
      const SizedBox(height: 6),
      const Text("Feel free to reach out anytime ✌️",
          style: TextStyle(color: KC.amber, fontSize: 15)),
      const SizedBox(height: 20),
      Expanded(child: isWide ? _wide() : _narrow()),
    ]),
  ));

  Widget _wide() => Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Expanded(flex: 5, child: KSCard(child: Column(
      mainAxisAlignment: MainAxisAlignment.center, children: [
      KCTile(Icons.email_outlined,      "EMAIL",    "karl@example.com",    KC.blue),
      const SizedBox(height: 14),
      KCTile(Icons.code_rounded,        "GITHUB",   "github.com/karl",     KC.purple),
      const SizedBox(height: 14),
      KCTile(Icons.location_on_outlined,"LOCATION", "Laguna, Philippines", KC.green),
    ]))),
    const SizedBox(width: 10),
    Expanded(flex: 4, child: KSCard(child: Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text("🎓", style: TextStyle(fontSize: 52)),
      const SizedBox(height: 18),
      const Text("\"Build things\nthat matter.\"",
          textAlign: TextAlign.center,
          style: TextStyle(color: KC.text, fontSize: 28, fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic, letterSpacing: -0.5, height: 1.2)),
      const SizedBox(height: 12),
      const Text("— Karl Angelo Albaniel",
          style: TextStyle(color: KC.hint, fontSize: 15)),
    ])))),
  ]);

  Widget _narrow() => SingleChildScrollView(physics: const BouncingScrollPhysics(),
    child: Column(children: [
      KSCard(child: Column(children: [
        KCTile(Icons.email_outlined,      "EMAIL",    "karl@example.com",    KC.blue),
        const SizedBox(height: 12),
        KCTile(Icons.code_rounded,        "GITHUB",   "github.com/karl",     KC.purple),
        const SizedBox(height: 12),
        KCTile(Icons.location_on_outlined,"LOCATION", "Laguna, Philippines", KC.green),
      ])),
      const SizedBox(height: 10),
      KSCard(child: Center(child: Column(children: [
        const Text("🎓", style: TextStyle(fontSize: 38)),
        const SizedBox(height: 12),
        const Text("\"Build things that matter.\"",
            textAlign: TextAlign.center,
            style: TextStyle(color: KC.text, fontSize: 20,
                fontWeight: FontWeight.w700, fontStyle: FontStyle.italic)),
        const SizedBox(height: 8),
        const Text("— Karl Angelo Albaniel",
            style: TextStyle(color: KC.hint, fontSize: 14)),
      ]))),
      const SizedBox(height: 16),
    ]),
  );
}
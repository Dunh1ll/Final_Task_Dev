import 'package:flutter/material.dart';
import 'constants.dart';
import 'utilities.dart';
import 'shared.dart';

class KProjectsPage extends StatelessWidget {
  final bool isWide;
  const KProjectsPage({required this.isWide});

  @override
  Widget build(BuildContext context) => KReveal(child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      KTHead(label: "PROJECTS", title: "My Work", color: KC.amber),
      const SizedBox(height: 18),
      Expanded(child: isWide ? _wide() : _narrow()),
    ]),
  ));

  Widget _wide() => Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Expanded(flex: 5, child: KSCard(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
      KLbl("FEATURED WORK", KC.amber), const SizedBox(height: 16),
      Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Expanded(child: KPItem("📱", KC.blue, "Final Task Dev App",
            "A multi-user Flutter application with profile management, "
            "authentication, and sub-dashboard systems.",
            const ["Flutter", "Golang", "PostgreSQL"],
            const [KC.blue, KC.green, KC.amber])),
        const SizedBox(height: 10),
        Expanded(child: KPItem("✨", KC.purple, "Portfolio Profile UI",
            "A premium animated developer portfolio with scroll reveals, "
            "grain texture, and bento grid layout.",
            const ["Flutter", "UI/UX", "Dart"],
            const [KC.blue, KC.purple, KC.blue])),
      ])),
    ]))),
    const SizedBox(width: 10),
    Expanded(flex: 4, child: KSCard(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
      KLbl("MY JOURNEY", KC.amber), const SizedBox(height: 4),
      const Text("A timeline of my growth",
          style: TextStyle(color: KC.hint, fontSize: 12)),
      const SizedBox(height: 20),
      Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        KTL("2021", "Started BSIS Degree",
            "Bachelor of Science in Information Systems", false, false),
        KTL("2022", "Started Flutter Development",
            "Built first mobile applications", false, false),
        KTL("2023", "Learned Golang + PostgreSQL",
            "Full-stack project development", false, false),
        KTL("2024", "4th Year — Final Project",
            "Building real-world applications", true, true),
      ])),
    ]))),
  ]);

  Widget _narrow() => SingleChildScrollView(physics: const BouncingScrollPhysics(),
    child: Column(children: [
      KSCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        KLbl("FEATURED WORK", KC.amber), const SizedBox(height: 12),
        KPItem("📱", KC.blue, "Final Task Dev App",
            "A multi-user Flutter app with profile management and authentication.",
            const ["Flutter", "Golang", "PostgreSQL"],
            const [KC.blue, KC.green, KC.amber]),
        const SizedBox(height: 10),
        KPItem("✨", KC.purple, "Portfolio Profile UI",
            "A premium animated portfolio with scroll reveals and grain texture.",
            const ["Flutter", "UI/UX", "Dart"],
            const [KC.blue, KC.purple, KC.blue]),
      ])),
      const SizedBox(height: 10),
      KSCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        KLbl("MY JOURNEY", KC.amber), const SizedBox(height: 4),
        const Text("A timeline of my growth",
            style: TextStyle(color: KC.hint, fontSize: 12)),
        const SizedBox(height: 16),
        KTL("2021", "Started BSIS Degree",
            "Bachelor of Science in Information Systems", false, false),
        KTL("2022", "Started Flutter Development",
            "Built first mobile applications", false, false),
        KTL("2023", "Learned Golang + PostgreSQL",
            "Full-stack project development", false, false),
        KTL("2024", "4th Year — Final Project",
            "Building real-world applications", true, true),
      ])),
      const SizedBox(height: 16),
    ]),
  );
}
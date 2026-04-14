import 'package:flutter/material.dart';
import 'constants.dart';
import 'utilities.dart';
import 'terminal_card.dart';
import 'buttons.dart';

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
  late Animation<double> _f;
  late Animation<Offset> _s;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _f = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _s = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
    _c.forward();
  }

  @override void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _f,
    child: SlideTransition(
      position: _s,
      child: widget.isWide ? _wide() : _narrow(),
    ),
  );

  Widget _wide() => Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Expanded(
        flex: 5,
        child: Padding(
          padding: const EdgeInsets.only(left: 60, right: 60, top: 0, bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: _left(),
          ),
        ),
      ),
      Expanded(
        flex: 5,
        child: Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 20, right: 40, left: 16),
          child: const KTerminalCard(),
        ),
      ),
    ],
  );

  Widget _narrow() => SingleChildScrollView(
    physics: const BouncingScrollPhysics(),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._left(),
          const SizedBox(height: 32),
          SizedBox(height: 420, child: const KTerminalCard()),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );

  List<Widget> _left() => [
    // PROFILE PICTURE
    Container(
      width: 100, height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: KC.amber.withOpacity(0.5), width: 2.5),
        image: const DecorationImage(
          image: AssetImage("assets/images/profile2.png"),
          fit: BoxFit.cover,
        ),
        boxShadow: [BoxShadow(
          color: KC.amber.withOpacity(0.12),
          blurRadius: 24,
          spreadRadius: 4,
        )],
      ),
    ),
    const SizedBox(height: 16),

    // BADGE
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: KC.amber.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: KC.amber.withOpacity(0.28)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Text("🎓", style: TextStyle(fontSize: 12)),
        const SizedBox(width: 6),
        Text("4th Year IS Student", style: TextStyle(
          color: KC.amber.withOpacity(0.9),
          fontSize: 12, fontWeight: FontWeight.w600,
        )),
      ]),
    ),
    const SizedBox(height: 16),

    // NAME
    RichText(
      text: const TextSpan(
        style: TextStyle(fontWeight: FontWeight.w800, height: 1.05, letterSpacing: -1.5),
        children: [
          TextSpan(text: "Karl\n",    style: TextStyle(fontSize: 64, color: KC.text)),
          TextSpan(text: "Angelo\n",  style: TextStyle(fontSize: 64, color: KC.amber)),
          TextSpan(text: "Albaniel", style: TextStyle(fontSize: 64, color: KC.text)),
        ],
      ),
    ),

    // ROLE
    RichText(
      text: TextSpan(children: [
        TextSpan(text: widget.typed, style: const TextStyle(
          color: KC.text, fontSize: 18, fontWeight: FontWeight.w700,
        )),
        WidgetSpan(child: KCursor()),
        const TextSpan(text: "  ·  IS Student  ·  Philippines",
          style: TextStyle(color: KC.muted, fontSize: 15)),
      ]),
    ),
    const SizedBox(height: 18),

    // VALUE STATEMENT
    const Text(
      "I build modern mobile apps with clean UI, scalable backend systems, and real-world impact.",
      style: TextStyle(color: KC.muted, fontSize: 15, height: 1.6),
    ),
    const SizedBox(height: 24),

    // BUTTONS
    Row(children: [
      KInteractiveButton(onTap: widget.onContact),
      const SizedBox(width: 12),
      KSecondaryButton(onTap: widget.onProjects),
    ]),
  ];
}
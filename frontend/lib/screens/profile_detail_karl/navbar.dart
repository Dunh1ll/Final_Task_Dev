import 'package:flutter/material.dart';
import 'constants.dart';

class KNavBar extends StatelessWidget {
  final KTab tab;
  final void Function(KTab) onTab;
  final bool isWide;
  const KNavBar({required this.tab, required this.onTab, required this.isWide});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: KC.surface.withOpacity(0.35),
      border: const Border(bottom: BorderSide(color: KC.border, width: 0)),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
    child: Row(children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: RichText(
          text: const TextSpan(
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            children: [
              TextSpan(text: "< ", style: TextStyle(color: KC.hint)),
              TextSpan(text: "KA", style: TextStyle(color: KC.amber)),
              TextSpan(text: " />", style: TextStyle(color: KC.hint)),
            ],
          ),
        ),
      ),
      const Spacer(),
      if (isWide) ...[
        _KNT("Home",     KTab.home,     tab, onTab),
        _KNT("About",    KTab.about,    tab, onTab),
        _KNT("Projects", KTab.projects, tab, onTab),
        _KNT("Contact",  KTab.contact,  tab, onTab),
      ] else PopupMenuButton<KTab>(
        color: KC.surface,
        icon: const Icon(Icons.more_horiz, color: KC.muted, size: 20),
        onSelected: onTab,
        itemBuilder: (_) => [
          PopupMenuItem(value: KTab.home,     child: Text("Home",     style: _pts)),
          PopupMenuItem(value: KTab.about,    child: Text("About",    style: _pts)),
          PopupMenuItem(value: KTab.projects, child: Text("Projects", style: _pts)),
          PopupMenuItem(value: KTab.contact,  child: Text("Contact",  style: _pts)),
        ],
      ),
    ]),
  );

  static const _pts = TextStyle(color: KC.text, fontSize: 14);
}

class _KNT extends StatelessWidget {
  final String label;
  final KTab tab, cur;
  final void Function(KTab) f;
  const _KNT(this.label, this.tab, this.cur, this.f);
  @override
  Widget build(BuildContext context) {
    final a = tab == cur;
    return GestureDetector(
      onTap: () => f(tab),
      child: Padding(
        padding: const EdgeInsets.only(right: 26),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(label, style: TextStyle(
            color: a ? KC.text : KC.hint,
            fontSize: 15,
            fontWeight: a ? FontWeight.w600 : FontWeight.w400,
          )),
          const SizedBox(height: 3),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: a ? 18 : 0, height: 2,
            decoration: BoxDecoration(
              color: KC.amber,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ]),
      ),
    );
  }
}
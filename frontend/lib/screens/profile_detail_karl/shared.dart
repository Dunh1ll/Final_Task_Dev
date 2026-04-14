import 'package:flutter/material.dart';
import 'constants.dart';

class KTHead extends StatelessWidget {
  final String label, title;
  final Color color;
  const KTHead({required this.label, required this.title, required this.color});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      KLbl(label, color),
      const SizedBox(height: 7),
      Text(title, style: const TextStyle(
        color: KC.text, fontSize: 30,
        fontWeight: FontWeight.w700, letterSpacing: -0.5,
      )),
    ],
  );
}

class KLbl extends StatelessWidget {
  final String label;
  final Color color;
  const KLbl(this.label, this.color);
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 5, height: 5,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 6),
    Text(label, style: TextStyle(
      color: color.withOpacity(0.85),
      fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 2.2,
    )),
  ]);
}

class KBCard extends StatelessWidget {
  final Widget child;
  final Color color;
  const KBCard({required this.child, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.35),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.25)),
      boxShadow: [BoxShadow(
        color: color.withOpacity(0.05),
        blurRadius: 20,
        spreadRadius: 2,
      )],
    ),
    child: child,
  );
}

class KSCard extends StatelessWidget {
  final Widget child;
  const KSCard({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.35),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: KC.border.withOpacity(0.5)),
    ),
    child: child,
  );
}

class KTC extends StatelessWidget {
  final Color color;
  final String code, name;
  const KTC(this.color, this.code, this.name);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: KC.card,
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: KC.border),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 24, height: 24,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Center(child: Text(code, style: TextStyle(
          color: color, fontSize: 9, fontWeight: FontWeight.w700,
        ))),
      ),
      const SizedBox(width: 7),
      Text(name, style: const TextStyle(
        color: KC.muted, fontSize: 13, fontWeight: FontWeight.w500,
      )),
    ]),
  );
}

class KSBar extends StatefulWidget {
  final String emoji, title;
  final Color color;
  final double pct;
  const KSBar(this.emoji, this.title, this.color, this.pct);
  @override
  State<KSBar> createState() => _KSBarState();
}
class _KSBarState extends State<KSBar> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _p;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _p = Tween<double>(begin: 0, end: widget.pct)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    Future.delayed(const Duration(milliseconds: 250), () { if (mounted) _c.forward(); });
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Column(children: [
      Row(children: [
        Text(widget.emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 9),
        Expanded(child: Text(widget.title, style: const TextStyle(
          color: KC.text, fontSize: 14, fontWeight: FontWeight.w500,
        ))),
        AnimatedBuilder(animation: _p, builder: (_, __) =>
          Text("${(_p.value * 100).round()}%", style: TextStyle(
            color: widget.color, fontSize: 13, fontWeight: FontWeight.w700,
          ))),
      ]),
      const SizedBox(height: 8),
      AnimatedBuilder(animation: _p, builder: (_, __) =>
        ClipRRect(borderRadius: BorderRadius.circular(3), child: Stack(children: [
          Container(height: 5, color: KC.border),
          FractionallySizedBox(widthFactor: _p.value,
            child: Container(height: 5, decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                widget.color.withOpacity(0.6), widget.color,
              ]),
              boxShadow: [BoxShadow(
                color: widget.color.withOpacity(0.3), blurRadius: 5,
              )],
            ))),
        ]))),
    ]),
  );
}

class KPItem extends StatelessWidget {
  final String icon, title, desc;
  final Color color;
  final List<String> tags;
  final List<Color> tc;
  const KPItem(this.icon, this.color, this.title, this.desc, this.tags, this.tc);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: KC.card,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: KC.border),
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Center(child: Text(icon, style: const TextStyle(fontSize: 18))),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(title, style: const TextStyle(
            color: KC.text, fontWeight: FontWeight.w600, fontSize: 14,
          ))),
          const Icon(Icons.arrow_outward_rounded, color: KC.hint, size: 13),
        ]),
        const SizedBox(height: 4),
        Text(desc, style: const TextStyle(color: KC.hint, fontSize: 12, height: 1.6)),
        const SizedBox(height: 8),
        Wrap(spacing: 5, runSpacing: 4, children: List.generate(tags.length, (i) =>
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: tc[i].withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: tc[i].withOpacity(0.25)),
            ),
            child: Text(tags[i], style: TextStyle(
              color: tc[i], fontSize: 10, fontWeight: FontWeight.w500,
            )),
          ))),
      ])),
    ]),
  );
}

class KTL extends StatelessWidget {
  final String year, title, sub;
  final bool isLast, isActive;
  const KTL(this.year, this.title, this.sub, this.isLast, this.isActive);
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Column(children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? KC.amber : Colors.transparent,
          border: Border.all(color: isActive ? KC.amber : KC.border, width: 2),
        )),
        if (!isLast) Container(width: 1, height: 44, color: KC.border),
      ]),
      const SizedBox(width: 12),
      Expanded(child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(year, style: const TextStyle(
            color: KC.hint, fontSize: 11,
            fontWeight: FontWeight.w600, letterSpacing: 0.5,
          )),
          const SizedBox(height: 2),
          Text(title, style: TextStyle(
            color: isActive ? KC.amber : KC.text,
            fontSize: 14, fontWeight: FontWeight.w600,
          )),
          Text(sub, style: const TextStyle(
            color: KC.hint, fontSize: 12, height: 1.5,
          )),
        ]),
      )),
    ],
  );
}

class KCTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const KCTile(this.icon, this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: KC.card,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: KC.border),
    ),
    child: Row(children: [
      Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.22)),
        ),
        child: Icon(icon, color: color.withOpacity(0.85), size: 20),
      ),
      const SizedBox(width: 14),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(
          color: KC.hint, fontSize: 11,
          letterSpacing: 1.0, fontWeight: FontWeight.w500,
        )),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(
          color: KC.text, fontSize: 15, fontWeight: FontWeight.w500,
        )),
      ]),
      const Spacer(),
      const Icon(Icons.arrow_forward_ios_rounded, color: KC.hint, size: 13),
    ]),
  );
}
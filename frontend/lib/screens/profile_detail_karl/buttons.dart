import 'package:flutter/material.dart';
import 'constants.dart';

class KInteractiveButton extends StatefulWidget {
  final VoidCallback onTap;
  const KInteractiveButton({required this.onTap});
  @override
  State<KInteractiveButton> createState() => _KInteractiveButtonState();
}
class _KInteractiveButtonState extends State<KInteractiveButton> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
          decoration: BoxDecoration(
            color: KC.amber,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(
              color: KC.amber.withOpacity(_isHovered ? 0.4 : 0.2),
              blurRadius: _isHovered ? 20 : 10,
              offset: const Offset(0, 4),
            )],
          ),
          child: const Text("Get in Touch", style: TextStyle(
            color: Color(0xFF1C1814),
            fontSize: 16, fontWeight: FontWeight.w800,
          )),
        ),
      ),
    );
  }
}

class KSecondaryButton extends StatefulWidget {
  final VoidCallback onTap;
  const KSecondaryButton({required this.onTap});
  @override
  State<KSecondaryButton> createState() => _KSecondaryButtonState();
}
class _KSecondaryButtonState extends State<KSecondaryButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
          decoration: BoxDecoration(
            color: _hover ? KC.card : Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: KC.border),
          ),
          child: const Text("View Projects", style: TextStyle(
            color: KC.text, fontSize: 14, fontWeight: FontWeight.w600,
          )),
        ),
      ),
    );
  }
}
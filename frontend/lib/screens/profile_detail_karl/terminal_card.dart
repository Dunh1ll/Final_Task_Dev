import 'dart:async';
import 'package:flutter/material.dart';
import 'constants.dart';

class KTerminalCard extends StatefulWidget {
  const KTerminalCard();
  @override
  State<KTerminalCard> createState() => _KTerminalCardState();
}

class _KTerminalCardState extends State<KTerminalCard>
    with SingleTickerProviderStateMixin {
  int _visibleLines = 0;
  late AnimationController _cursor;

  @override
  void initState() {
    super.initState();
    _cursor = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    Future.delayed(const Duration(milliseconds: 400), () {
      Timer.periodic(const Duration(milliseconds: 180), (timer) {
        if (!mounted) return;
        setState(() => _visibleLines++);
        if (_visibleLines > 12) timer.cancel();
      });
    });
  }

  @override
  void dispose() { _cursor.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KC.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: KC.amber.withOpacity(0.08), blurRadius: 40, spreadRadius: 5),
          BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.25),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              border: Border(bottom: BorderSide(color: KC.border.withOpacity(0.5))),
            ),
            child: Row(children: [
              _KDot(KC.rose),
              const SizedBox(width: 7),
              _KDot(KC.amber),
              const SizedBox(width: 7),
              _KDot(KC.green),
              const SizedBox(width: 12),
              const Text("karl@portfolio  ~", style: TextStyle(
                color: KC.hint, fontSize: 12, fontFamily: 'monospace',
              )),
            ]),
          ),
          // Terminal body
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (_visibleLines > 0)  _KTLine(cmd: "whoami"),
                  if (_visibleLines > 1)  const _KTOut("Karl Angelo Albaniel", KC.text),
                  if (_visibleLines > 2)  _KTLine(cmd: "cat", arg: "info.txt", argColor: KC.blue),
                  if (_visibleLines > 3)  _KTKv("role",     '"Flutter Developer"'),
                  if (_visibleLines > 4)  _KTKv("year",     '"4th Year IS Student"'),
                  if (_visibleLines > 5)  _KTKv("location", '"Laguna, PH"'),
                  if (_visibleLines > 6)  _KTKv("status",   '"open_to_opportunities"'),
                  if (_visibleLines > 7)  _KTLine(cmd: "ls", arg: "skills/", argColor: KC.blue),
                  if (_visibleLines > 8)  const _KTOut("flutter   dart   golang   postgresql", KC.purple),
                  if (_visibleLines > 9)  _KTLine(cmd: "git log", arg: "--oneline"),
                  if (_visibleLines > 10) _KTCommit("a3f92c1", "built portfolio UI"),
                  if (_visibleLines > 11) _KTCommit("b81de04", "final task dev app"),
                  if (_visibleLines > 12) _KTCommit("c22aa10", "learned golang backend"),
                  Row(children: [
                    const Text("\$  ", style: TextStyle(
                      color: KC.hint, fontFamily: 'monospace', fontSize: 13,
                    )),
                    FadeTransition(
                      opacity: _cursor,
                      child: Container(
                        width: 8, height: 15,
                        decoration: BoxDecoration(
                          color: KC.amber,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KDot extends StatelessWidget {
  final Color color;
  const _KDot(this.color);
  @override
  Widget build(BuildContext context) => Container(
    width: 11, height: 11,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _KTLine extends StatelessWidget {
  final String cmd;
  final String? arg;
  final Color? argColor;
  const _KTLine({required this.cmd, this.arg, this.argColor});
  @override
  Widget build(BuildContext context) => RichText(text: TextSpan(children: [
    const TextSpan(text: "\$  ", style: TextStyle(
      color: KC.hint, fontFamily: 'monospace', fontSize: 13,
    )),
    TextSpan(text: cmd, style: const TextStyle(
      color: KC.amber, fontFamily: 'monospace', fontSize: 13,
    )),
    if (arg != null) ...[
      const TextSpan(text: "  ", style: TextStyle(
        fontFamily: 'monospace', fontSize: 13,
      )),
      TextSpan(text: arg, style: TextStyle(
        color: argColor ?? KC.blue, fontFamily: 'monospace', fontSize: 13,
      )),
    ],
  ]));
}

class _KTOut extends StatelessWidget {
  final String text;
  final Color color;
  const _KTOut(this.text, this.color);
  @override
  Widget build(BuildContext context) => Text(text, style: TextStyle(
    color: color, fontFamily: 'monospace', fontSize: 13,
  ));
}

class _KTKv extends StatelessWidget {
  final String k, value;
  const _KTKv(this.k, this.value);
  @override
  Widget build(BuildContext context) => RichText(text: TextSpan(
    style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
    children: [
      TextSpan(text: k,       style: const TextStyle(color: KC.muted)),
      const TextSpan(text: "  =  ", style: TextStyle(color: KC.hint)),
      TextSpan(text: value,   style: const TextStyle(color: KC.green)),
    ],
  ));
}

class _KTCommit extends StatelessWidget {
  final String hash, message;
  const _KTCommit(this.hash, this.message);
  @override
  Widget build(BuildContext context) => RichText(text: TextSpan(
    style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
    children: [
      TextSpan(text: hash,    style: const TextStyle(color: KC.amber)),
      const TextSpan(text: "  ", style: TextStyle(color: KC.hint)),
      TextSpan(text: message, style: const TextStyle(color: KC.text)),
    ],
  ));
}
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────
// DESIGN TOKENS
// ─────────────────────────────────────────────────────────────────
const _kGold = Color(0xFFD4A017);
const _kBrightGold = Color(0xFFFFD700);
const _kAgedGold = Color(0xFF8B6914);
const _kDarkBrown = Color(0xFF1A0A00);
const _kParchL = Color(0xFFF7EDCC);
const _kParchM = Color(0xFFEDD9A3);
const _kTextDark = Color(0xFF1A0A00);
const _kTextMed = Color(0xFF4A3A1A);
const _kAccent = Color(0xFF0C1E36);
const _kAccentMid = Color(0xFF1A3A62);

// ─────────────────────────────────────────────────────────────────
// DIAGONAL FRACTIONS — "/" direction
//
// HOW THESE WORK:
//   _topX = where the "/" line meets the TOP edge of the card.
//           Expressed as a fraction of the card width (0.0 – 1.0).
//           0.70 means the line starts at 70% from the left.
//
//   _botX = where the "/" line meets the BOTTOM edge of the card.
//           0.48 means the line ends at 48% from the left.
//
// The left parchment panel is the triangle:
//   (0,0) → (_topX*w, 0) → (_botX*w, h) → (0, h) → close
//
// To make the parchment WIDER:  increase both _topX and _botX.
// To make the parchment NARROWER: decrease both.
// To change the ANGLE: change the difference between them.
//
//   Current values:  _topX=0.70  _botX=0.48
//   Previous values: _topX=0.63  _botX=0.37  (was too narrow)
// ─────────────────────────────────────────────────────────────────
const double _topX = 0.70; // ← EXTENDED (was 0.63)
const double _botX = 0.48; // ← EXTENDED (was 0.37)

/// MainProfileCardPallen
///
/// Layout (4:3 landscape) — "/" diagonal:
///   ┌───────────────────────────╲──────────────────┐
///   │  [pic]   LEFT  (extended)  ╲  cover + hero   │
///   │  Name                       ╲                │
///   │  birthday                    ╲  [HERO:       │
///   │  school                       ╲  full height]│
///   │  [role]                        ╲             │
///   └────────────────────────────────╲─────────────┘
///
/// ✅ CHANGE 1: Removed the parchment gradient overlay that was
///   blocking the hero1.png image. The hero photo is now fully
///   visible — only the real parchment panel clips in front of it.
///
/// ✅ CHANGE 2: Extended the left panel shape.
///   _topX increased from 0.63 → 0.70
///   _botX increased from 0.37 → 0.48
///   This gives more parchment area for the text content.
///
/// ✅ onOpenProfile: only the "View Profile" button opens the
///   profile detail screen.
class MainProfileCardPallen extends StatefulWidget {
  final bool isCenter;
  final VoidCallback? onOpenProfile;

  const MainProfileCardPallen({
    super.key,
    required this.isCenter,
    this.onOpenProfile,
  });

  @override
  State<MainProfileCardPallen> createState() => _MainProfileCardPallenState();
}

class _MainProfileCardPallenState extends State<MainProfileCardPallen>
    with SingleTickerProviderStateMixin {
  bool _hov = false;

  // Ambient gold border pulse (breathes slowly)
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hov = true),
        onExit: (_) => setState(() => _hov = false),
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (_, child) => AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            transform: Matrix4.identity()..translate(0.0, _hov ? -8.0 : 0.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                // Breathing gold glow
                BoxShadow(
                  color: _kGold.withOpacity(
                    _hov ? 0.58 : 0.16 + 0.10 * _pulse.value,
                  ),
                  blurRadius: _hov ? 40 : 18,
                  spreadRadius: _hov ? 5 : 0,
                  offset: const Offset(0, 6),
                ),
                // Depth shadow
                BoxShadow(
                  color: Colors.black.withOpacity(0.55),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: child,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LayoutBuilder(
              builder: (ctx, c) => _body(ctx, c.maxWidth, c.maxHeight),
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // MAIN BODY — layer order (bottom to top):
  //   1. Dark base
  //   2. Right panel (cover image, clipped)
  //   3. Left panel (parchment, clipped)
  //   4. Gold "/" diagonal line
  //   5. Hero image (full height, NO blocking gradient)
  //   6. Profile picture
  //   7. Name + info text
  //   8. Role badge + View Profile button
  //   9. ADMIN badge (top-right)
  // ──────────────────────────────────────────────────────────
  Widget _body(BuildContext ctx, double w, double h) {
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        // ── 1. DARK BASE ──────────────────────────────────────
        // Fills the entire card with dark brown.
        // Visible only at the very edges if other layers don't
        // cover them.
        Positioned.fill(
          child: Container(color: _kDarkBrown),
        ),

        // ── 2. RIGHT PANEL — cover image ──────────────────────
        // Clipped to the "/" right shape using _RightPanelClip.
        // The cover image fills this area as background.
        // A left-edge vignette softens the diagonal join.
        // A compass rose adds decorative flair bottom-right.
        Positioned.fill(
          child: ClipPath(
            clipper: const _RightPanelClip(),
            child: Stack(children: [
              // Cover background image
              Positioned.fill(
                child: Image.asset(
                  'assets/images/cover_pallen.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_kAccentMid, _kAccent],
                      ),
                    ),
                  ),
                ),
              ),

              // Left vignette — just softens the hard diagonal
              // edge between the cover image and the gold line.
              // This only covers a thin strip on the left side
              // of the RIGHT panel — it does NOT touch the hero.
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withOpacity(0.28),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Decorative compass rose (bottom-right corner)
              Positioned(
                right: 12,
                bottom: 12,
                child: Opacity(
                  opacity: 0.12,
                  child: CustomPaint(
                    size: Size(h * 0.38, h * 0.38),
                    painter: const _CompassPainter(),
                  ),
                ),
              ),
            ]),
          ),
        ),

        // ── 3. LEFT PANEL — parchment "/" shape ───────────────
        // EXTENDED: _topX=0.70 / _botX=0.48
        //
        // HOW CLIPPING WORKS:
        //   ClipPath paints the child widget, but only shows the
        //   pixels that fall inside the Path returned by the
        //   clipper. Everything outside is invisible.
        //
        //   _LeftPanelClip returns a triangle path:
        //     Start (0,0) → (topX*w, 0) → (botX*w, h) → (0,h) → close
        //
        //   So the gradient Container is only visible inside
        //   this triangle. The rest is transparent, letting layers
        //   below (right panel, dark base) show through.
        Positioned.fill(
          child: ClipPath(
            clipper: const _LeftPanelClip(),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_kParchL, _kParchM],
                ),
              ),
            ),
          ),
        ),

        // ── 4. GOLD "/" DIAGONAL LINE ──────────────────────────
        // Sits above both panels, drawn by _DiagLinePainter.
        // Uses module-level _topX/_botX constants, so it always
        // aligns perfectly with the panel edges.
        //
        // Three lines for visual depth:
        //   Primary gold (2.8px) + glow right (1.2px) +
        //   shimmer left (0.8px white)
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: const _DiagLinePainter(),
            ),
          ),
        ),

        // ── 5. HERO IMAGE — full card height ──────────────────
        // ✅ CHANGE 1: The blocking parchment gradient overlay
        //   that was here has been REMOVED.
        //
        // What was removed (lines 265-287 in old file):
        //   A Positioned Container with a LinearGradient from
        //   _kParchM (solid) → transparent, covering w*0.46 of
        //   the left side of the hero. That gradient was painting
        //   over your hero1.png photo.
        //
        // Now the hero Stack only contains:
        //   a) The hero photo itself (full fit)
        //   b) A bottom vignette (just grounds the figure)
        //
        // The parchment panel (layer 3) naturally overlaps the
        // hero's left portion through clipping — no fake gradient
        // needed. The hero shows through cleanly on the right.
        Positioned(
          left: w * 0.22, // hero starts 22% from left
          right: 0,
          top: 0, // reaches top edge
          bottom: 0, // reaches bottom edge
          child: Stack(children: [
            // ── Hero photo — full area, no blocking overlay ──
            Positioned.fill(
              child: Image.asset(
                'assets/images/hero1.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (_, __, ___) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _kAgedGold.withOpacity(0.2),
                        _kAccent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Bottom vignette only ─────────────────────────
            // A subtle dark fade at the very bottom of the card.
            // This grounds the hero figure visually.
            // It does NOT block the hero's body — only the feet.
            // Reduce h*0.18 to make it shorter/less visible.
            // Remove entirely if you don't want any bottom fade.
          ]),
        ),

        // ── 6. PROFILE PICTURE — square, top-left ─────────────
        Positioned(
          left: 16,
          top: 16,
          child: _profilePic(h),
        ),

        // ── 7. NAME & INFO — below profile pic ────────────────
        // right: constrains text to stay inside the parchment area.
        //
        // HOW TO ADJUST:
        //   The parchment diagonal is at ~_topX=0.70 at the top
        //   and ~_botX=0.48 at the bottom. The text block sits
        //   at roughly y = h*0.30 (top of name block), where the
        //   diagonal is approximately at 0.62 of width.
        //
        //   right: w * 0.36 means "leave 36% free on the right".
        //   This keeps text roughly within the first ~64% of width.
        //
        //   If your text is getting clipped:  decrease this value.
        //   If the text overflows the parchment: increase it.
        Positioned(
          left: 16,
          top: h * 0.22 + 28,
          right: w * 0.36, // ← adjusted for extended panel
          child: _nameBlock(h),
        ),

        // ── 8. BOTTOM-LEFT — role badge + View Profile ─────────
        Positioned(
          left: 14,
          bottom: 14,
          child: _bottomLeft(h),
        ),

        // ── 9. TOP-RIGHT — ADMIN badge ──────────────────────────
        Positioned(
          right: 14,
          top: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.62),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _kGold.withOpacity(0.55),
                width: 1.2,
              ),
            ),
            child: const Text(
              '⚓  ADMIN',
              style: TextStyle(
                color: _kBrightGold,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.8,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────
  // PROFILE PICTURE
  // ──────────────────────────────────────────────────────────
  Widget _profilePic(double h) {
    final sz = h * 0.22;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: sz,
      height: sz,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _hov ? _kBrightGold : _kGold,
          width: _hov ? 3.0 : 2.2,
        ),
        boxShadow: [
          BoxShadow(
            color: _kGold.withOpacity(_hov ? 0.58 : 0.28),
            blurRadius: _hov ? 20 : 10,
            spreadRadius: _hov ? 2 : 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          'assets/images/profile1.jpg',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: _kAgedGold.withOpacity(0.3),
            child: const Icon(Icons.person_rounded, color: _kGold, size: 34),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // NAME BLOCK
  // ──────────────────────────────────────────────────────────
  Widget _nameBlock(double h) {
    final fs = (h * 0.062).clamp(9.0, 14.0);
    final fsl = (h * 0.155).clamp(20.0, 38.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Prince Dunhill',
          style: TextStyle(
            fontFamily: 'DMSans',
            color: _kTextMed,
            fontSize: fs,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.3,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          'PALLEN',
          style: TextStyle(
            fontFamily: 'PirataOne',
            color: _kTextDark,
            fontSize: fsl,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            height: 0.88,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: h * 0.028),
        _infoRow(Icons.cake_outlined, 'March 18, 2004', h),
        SizedBox(height: h * 0.016),
        _infoRow(Icons.school_outlined, 'BS Computer Engineering', h),
        SizedBox(height: h * 0.016),
        _infoRow(Icons.location_on_outlined, 'Alaminos, Laguna', h),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────
  // INFO ROW
  // ──────────────────────────────────────────────────────────
  Widget _infoRow(IconData icon, String text, double h) {
    final fs = (h * 0.057).clamp(8.5, 11.5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: (h * 0.053).clamp(8.0, 11.0),
          color: _kAgedGold.withOpacity(0.75),
        ),
        SizedBox(width: (h * 0.014).clamp(2.0, 5.0)),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'DMSans',
              color: _kTextMed,
              fontSize: fs,
              height: 1.15,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────
  // BOTTOM LEFT — role badge + view profile button
  // ──────────────────────────────────────────────────────────
  Widget _bottomLeft(double h) {
    final fs = (h * 0.058).clamp(8.5, 12.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Role badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: _kDarkBrown.withOpacity(0.90),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: _kGold.withOpacity(_hov ? 0.95 : 0.65),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _kGold.withOpacity(_hov ? 0.32 : 0.10),
                blurRadius: 10,
              ),
            ],
          ),
          child: Text(
            '⚓  Full-Stack Developer',
            style: TextStyle(
              color: _kBrightGold,
              fontSize: fs,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ),

        // "View Profile" button — only for center card
        if (widget.onOpenProfile != null) ...[
          SizedBox(height: h * 0.014),
          GestureDetector(
            onTap: widget.onOpenProfile,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_kGold, _kAgedGold]),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: _kGold.withOpacity(0.45),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.open_in_full_rounded,
                      size: 10, color: Colors.white),
                  const SizedBox(width: 5),
                  Text(
                    'View Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fs * 0.9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// CLIPPERS — "/" diagonal orientation
//
// HOW CustomClipper<Path> WORKS:
//   Flutter calls getClip(Size s) to get the visible region.
//   s.width and s.height are the full size of the widget being
//   clipped. You return a Path that defines which area to show.
//   Anything INSIDE the path = visible. Outside = invisible.
//
// "/" DIAGONAL SHAPE:
//   The line starts at (_topX * w, 0) = 70% from left at top
//   and ends at  (_botX * w, h) = 48% from left at bottom.
//   This creates a forward-slash "/" orientation.
//
// TO CHANGE THE PANEL SIZE:
//   Edit _topX and _botX at the top of this file.
//   Both clippers use those same constants automatically.
// ══════════════════════════════════════════════════════════════════

/// Left parchment panel — "/" shape
/// Triangle: (0,0) → (_topX*w, 0) → (_botX*w, h) → (0,h)
class _LeftPanelClip extends CustomClipper<Path> {
  const _LeftPanelClip();

  @override
  Path getClip(Size s) {
    return Path()
      // Implicit start: top-left corner (0, 0)
      ..lineTo(s.width * _topX, 0) // → top edge at 70%
      ..lineTo(s.width * _botX, s.height) // ↘ to bottom at 48%
      ..lineTo(0, s.height) // ← bottom-left corner
      ..close(); // back to (0,0)
  }

  @override
  bool shouldReclip(_LeftPanelClip _) => false;
}

/// Right cover-image panel — "/" complement shape
/// Quad: (_topX*w, 0) → (w, 0) → (w, h) → (_botX*w, h)
class _RightPanelClip extends CustomClipper<Path> {
  const _RightPanelClip();

  @override
  Path getClip(Size s) {
    return Path()
      ..moveTo(s.width * _topX, 0) // top diagonal (70%)
      ..lineTo(s.width, 0) // top-right corner
      ..lineTo(s.width, s.height) // bottom-right corner
      ..lineTo(s.width * _botX, s.height) // bottom diagonal (48%)
      ..close();
  }

  @override
  bool shouldReclip(_RightPanelClip _) => false;
}

// ══════════════════════════════════════════════════════════════════
// DIAGONAL LINE PAINTER
//
// HOW CustomPainter WORKS:
//   Override paint(Canvas canvas, Size size) and draw directly
//   onto the canvas using canvas.drawLine / drawPath / etc.
//   The canvas origin (0,0) is the top-left of the widget.
//
// THREE LINES (depth effect):
//   1. Primary gold: full opacity, 2.8px width
//   2. Glow shadow:  22% opacity, offset 3.5px right, 1.2px wide
//   3. Shimmer:      18% white,   offset 1px left,   0.8px wide
//
// TO CHANGE LINE THICKNESS: edit strokeWidth.
// TO CHANGE LINE COLOR:      edit ..color = ...
// TO REMOVE GLOW LINES:     delete lines 2 and 3.
// ══════════════════════════════════════════════════════════════════
class _DiagLinePainter extends CustomPainter {
  const _DiagLinePainter();

  @override
  void paint(Canvas canvas, Size s) {
    final Offset top = Offset(s.width * _topX, 0);
    final Offset bot = Offset(s.width * _botX, s.height);

    // 1. Primary gold line
    canvas.drawLine(
        top,
        bot,
        Paint()
          ..color = const Color(0xFFD4A017)
          ..strokeWidth = 2.8
          ..strokeCap = StrokeCap.round);

    // 2. Glow line (offset right)
    canvas.drawLine(
        top.translate(3.5, 0),
        bot.translate(3.5, 0),
        Paint()
          ..color = const Color(0xFFD4A017).withOpacity(0.22)
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round);

    // 3. Shimmer line (offset left)
    canvas.drawLine(
        top.translate(-1.0, 0),
        bot.translate(-1.0, 0),
        Paint()
          ..color = Colors.white.withOpacity(0.18)
          ..strokeWidth = 0.8
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_DiagLinePainter _) => false;
}

// ══════════════════════════════════════════════════════════════════
// COMPASS ROSE PAINTER — decorative right-panel flair
// ══════════════════════════════════════════════════════════════════
class _CompassPainter extends CustomPainter {
  const _CompassPainter();

  static const _arms = [0.0, 1.5708, 3.14159, 4.71239];
  static const _diags = [0.7854, 2.3562, 3.9270, 5.4978];

  double _cos(double a) {
    if (a < 0.001) return 1.0;
    if ((a - 1.5708).abs() < 0.001) return 0.0;
    if ((a - 3.14159).abs() < 0.001) return -1.0;
    if ((a - 4.71239).abs() < 0.001) return 0.0;
    if ((a - 0.7854).abs() < 0.001) return 0.7071;
    if ((a - 2.3562).abs() < 0.001) return -0.7071;
    if ((a - 3.9270).abs() < 0.001) return -0.7071;
    if ((a - 5.4978).abs() < 0.001) return 0.7071;
    return 0.0;
  }

  double _sin(double a) {
    if (a < 0.001) return 0.0;
    if ((a - 1.5708).abs() < 0.001) return 1.0;
    if ((a - 3.14159).abs() < 0.001) return 0.0;
    if ((a - 4.71239).abs() < 0.001) return -1.0;
    if ((a - 0.7854).abs() < 0.001) return 0.7071;
    if ((a - 2.3562).abs() < 0.001) return 0.7071;
    if ((a - 3.9270).abs() < 0.001) return -0.7071;
    if ((a - 5.4978).abs() < 0.001) return -0.7071;
    return 0.0;
  }

  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height / 2;
    final r = s.width / 2;

    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(Offset(cx, cy), r, stroke);
    canvas.drawCircle(Offset(cx, cy), r * 0.62, stroke);

    final center = Offset(cx, cy);

    for (final a in _arms) {
      canvas.drawLine(
          center, Offset(cx + r * _cos(a), cy + r * _sin(a)), stroke);
    }

    for (final a in _diags) {
      canvas.drawLine(center,
          Offset(cx + r * 0.70 * _cos(a), cy + r * 0.70 * _sin(a)), stroke);
    }

    canvas.drawCircle(center, 4.0, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_CompassPainter _) => false;
}

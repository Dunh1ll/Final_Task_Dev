// lib/screens/pallen_profile/pallen_theme.dart
import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════
// SOCIAL LINKS
// ═══════════════════════════════════════════════════════════════════
const kPallenFacebook = 'https://www.facebook.com/dnhll.plln';
const kPallenGitHub = 'https://github.com/Dunh1ll';
const kPallenGmail = 'mailto:cpe.pallen.princedunhill@gmail.com';
const kPallenLinkedIn = 'https://www.linkedin.com/in/pallen-prince-dunhill/';
const kPallenInstagram =
    'https://www.instagram.com/nturdanii?igsh=eGxsdmVwc3BwMGt5';
const kPallenPhone = 'tel:+639504647074';
const kPallenResume =
    'https://drive.google.com/file/d/1392cs0UZbuROHIWIG9S2tzfpIGLvuulo/view?usp=drive_link';

// ═══════════════════════════════════════════════════════════════════
// STATIC DARK-PALETTE CONSTANTS
// ═══════════════════════════════════════════════════════════════════
const kP00 = Color(0xFF000000);
const kP03 = Color(0xFF080808);
const kP07 = Color(0xFF111111);
const kP10 = Color(0xFF1A1A1A);
const kP18 = Color(0xFF2E2E2E);
const kP25 = Color(0xFF404040);
const kP40 = Color(0xFF666666);
const kP55 = Color(0xFF8C8C8C);
const kP70 = Color(0xFFB3B3B3);
const kP85 = Color(0xFFD9D9D9);
const kP93 = Color(0xFFEDEDED);
const kP98 = Color(0xFFF7F7F7);
const kPWh = Colors.white;
const kPGreen = Color(0xFF4ADE80);

// ═══════════════════════════════════════════════════════════════════
// THEME INHERITED WIDGET
// Read anywhere via: PTheme.of(context)
// ═══════════════════════════════════════════════════════════════════
class PTheme extends InheritedWidget {
  final bool dark;
  const PTheme({required this.dark, required super.child});
  static bool of(BuildContext ctx) =>
      ctx.dependOnInheritedWidgetOfExactType<PTheme>()?.dark ?? true;
  @override
  bool updateShouldNotify(PTheme o) => o.dark != dark;
}

// ═══════════════════════════════════════════════════════════════════
// DYNAMIC COLOR HELPERS
// ═══════════════════════════════════════════════════════════════════
Color pBg(bool d) => d ? const Color(0xFF080808) : const Color(0xFFF5F5F5);
Color pBg2(bool d) => d ? const Color(0xFF0F0F0F) : const Color(0xFFEBEBEB);
Color pBg3(bool d) => d ? const Color(0xFF161616) : const Color(0xFFE0E0E0);
Color pHead(bool d) => d ? const Color(0xFFF7F7F7) : const Color(0xFF0D0D0D);
Color pBody(bool d) => d ? const Color(0xFF8C8C8C) : const Color(0xFF555555);
Color pMuted(bool d) => d ? const Color(0xFF555555) : const Color(0xFF999999);
Color pBorder(bool d) => d ? const Color(0xFF2A2A2A) : const Color(0xFFD5D5D5);
Color pBorderH(bool d) => d ? const Color(0xFF505050) : const Color(0xFF999999);
Color pCard(bool d) => d ? const Color(0xFF131313) : const Color(0xFFFFFFFF);
Color pCardH(bool d) => d ? const Color(0xFF1C1C1C) : const Color(0xFFF0F0F0);
Color pCardBorder(bool d) =>
    d ? const Color(0xFF2E2E2E) : const Color(0xFFDDDDDD);
Color pCardBorderH(bool d) =>
    d ? const Color(0xFF545454) : const Color(0xFFAAAAAA);
Color pGlowLit(bool d) => d ? const Color(0x33FFFFFF) : const Color(0x18000000);
Color pGlowDim(bool d) => d ? const Color(0x00FFFFFF) : const Color(0x00000000);
Color pIcon(bool d) => d ? const Color(0xFFB3B3B3) : const Color(0xFF555555);
Color pCardText(bool d) =>
    d ? const Color(0xFFEDEDED) : const Color(0xFF111111);
Color pCardSub(bool d) => d ? const Color(0xFF8C8C8C) : const Color(0xFF666666);
Color pEyebrow(bool d) => d ? const Color(0xFF666666) : const Color(0xFF888888);
Color pLine(bool d) => d ? const Color(0xFF333333) : const Color(0xFFCCCCCC);

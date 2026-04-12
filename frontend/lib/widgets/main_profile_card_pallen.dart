import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/image_helper.dart';

const Color _kGold = Color(0xFFD4A017);
const Color _kDarkGray = Color(0xFF1A0A00);
const Color _kLightGray = Color(0xFFC8A96E);
const Color _kPrimaryBlue = Color(0xFFD4A017);
const Color _kParchment = Color(0xFFF5DEB3);

/// MainProfileCardPallen — 4:3 LANDSCAPE card for Pallen.
///
/// ✅ CHANGED: aspectRatio: 4/3 (landscape, wider than tall).
///   With viewportFraction: 0.88 this fills most of the screen.
///   The card has a modern profile card layout adapted for wide format.
///
/// NOTE: The GestureDetector for tap is NOT here —
/// it is handled by _CarouselCardSlot in dashboard_screen.dart.
/// This widget is purely visual (no onTap).
class MainProfileCardPallen extends StatefulWidget {
  final bool isCenter;

  const MainProfileCardPallen({
    super.key,
    required this.isCenter,
  });

  @override
  State<MainProfileCardPallen> createState() => _MainProfileCardPallenState();
}

class _MainProfileCardPallenState extends State<MainProfileCardPallen> {
  bool _isHovered = false;

  static const String _name = 'Pallen, Prince Dunhill';
  static const String _bio =
      'Computer Science major | Photography enthusiast | Coffee lover ☕';
  static const String _yearLevel = 'Junior';
  static const String _gender = 'Male';
  static const int _age = 21;
  static const String _hometown = 'Manila, Philippines';
  static const String _profilePicture = 'assets/images/profile1.jpg';
  static const String _coverPhoto = 'assets/images/default_cover.jpg';

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = widget.isCenter),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        // ✅ 4:3 LANDSCAPE aspect ratio
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                color: _kParchment,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _isHovered
                        ? _kGold.withOpacity(0.6)
                        : Colors.black.withOpacity(0.4),
                    blurRadius: _isHovered ? 36 : 24,
                    spreadRadius: _isHovered ? 6 : 2,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: _isHovered && widget.isCenter
                    ? Border.all(
                        color: _kGold.withOpacity(0.7),
                        width: 2,
                      )
                    : null,
              ),
              // ── LANDSCAPE LAYOUT ───────────────────
              // Left side: cover photo (full height)
              // Right side: profile picture + info
              child: Row(
                children: [
                  // ── Left: cover photo ───────────────
                  Expanded(
                    flex: 5,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image(
                          image: ImageHelper.buildProvider(
                            _coverPhoto,
                            AssetPaths.defaultCover,
                          ),
                          fit: BoxFit.cover,
                        ),
                        // Right-side gradient overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.15),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Right: profile info ─────────────
                  Expanded(
                    flex: 4,
                    child: Container(
                      color: _kParchment,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Profile picture
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                              image: DecorationImage(
                                image: ImageHelper.buildProvider(
                                  _profilePicture,
                                  AssetPaths.defaultAvatar,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Name
                          Text(
                            _name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _kDarkGray,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 6),

                          // Year level badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: _kPrimaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _kPrimaryBlue.withOpacity(0.3),
                              ),
                            ),
                            child: const Text(
                              _yearLevel,
                              style: TextStyle(
                                fontSize: 10,
                                color: _kPrimaryBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Bio
                          Text(
                            _bio,
                            style: const TextStyle(
                              fontSize: 10,
                              color: _kLightGray,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 10),

                          // Info chips
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 4,
                            runSpacing: 4,
                            children: [
                              _chip('$_age yrs'),
                              _chip(_hometown),
                              _chip(_gender),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: _kPrimaryBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          color: _kPrimaryBlue,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

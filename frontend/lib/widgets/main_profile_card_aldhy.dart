import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/image_helper.dart';

const Color _kGold = Color(0xFFD4A017);
const Color _kDarkGray = Color(0xFF1A0A00);
const Color _kLightGray = Color(0xFFC8A96E);
const Color _kPrimaryBlue = Color(0xFFD4A017);
const Color _kParchment = Color(0xFFF5DEB3);

/// MainProfileCardAldhy — 4:3 LANDSCAPE card for Aldhy.
class MainProfileCardAldhy extends StatefulWidget {
  final bool isCenter;

  const MainProfileCardAldhy({
    super.key,
    required this.isCenter,
  });

  @override
  State<MainProfileCardAldhy> createState() => _MainProfileCardAldhyState();
}

class _MainProfileCardAldhyState extends State<MainProfileCardAldhy> {
  bool _isHovered = false;

  static const String _name = 'Fajardo, Aldhy';
  static const String _bio =
      'Psychology major | Mental health advocate 🧠 | Yoga instructor';
  static const String _yearLevel = 'Sophomore';
  static const String _gender = 'Male';
  static const int _age = 20;
  static const String _hometown = 'Davao, Philippines';
  static const String _profilePicture = 'assets/images/profile3.png';
  static const String _coverPhoto = 'assets/images/default_cover.jpg';

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = widget.isCenter),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: AspectRatio(
          // ✅ 4:3 landscape
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
              child: Row(
                children: [
                  // Left: cover photo
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

                  // Right: profile info
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
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
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

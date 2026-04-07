import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/constants.dart';
import '../utils/image_helper.dart';

/// MainProfileCardAldhy — individual 9:16 card for Fajardo, Aldhy.
/// Separate file so Aldhy's card can be independently designed and updated.
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

  // ── Aldhy's profile data ──────────────────────────────────────
  // Edit these fields to update Aldhy's card on the main dashboard
  static const String _name = 'Fajardo, Aldhy';
  static const String _bio =
      'Psychology major | Mental health advocate 🧠 | Yoga instructor';
  static const String _yearLevel = 'Sophomore';
  static const String _gender = 'Male';
  static const int _age = 20;
  static const String _hometown = 'Davao, Philippines';
  static const String _profilePicture = 'assets/images/profile3.png';
  static const String _coverPhoto = 'assets/images/cover3.jpg';

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => context.push('/profile-aldhy'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.dirtyWhite,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _isHovered
                          ? AppColors.darkGreen.withOpacity(0.6)
                          : Colors.black.withOpacity(0.3),
                      blurRadius: _isHovered ? 30 : 20,
                      spreadRadius: _isHovered ? 6 : 3,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: _isHovered
                      ? Border.all(
                          color: AppColors.darkGreen.withOpacity(0.7),
                          width: 2,
                        )
                      : null,
                ),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        // Cover photo
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.24,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: ImageHelper.buildProvider(
                                  _coverPhoto,
                                  AssetPaths.defaultCover,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.2),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 50),

                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            _name,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGray,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),

                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            _yearLevel,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),

                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            _bio,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.lightGray,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        const Spacer(),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _chip('$_age yrs'),
                              _chip(_hometown),
                              _chip(_gender),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Profile picture
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.24 - 44,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
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
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 10,
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w500)),
    );
  }
}

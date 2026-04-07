import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/constants.dart';
import '../utils/image_helper.dart';

/// ProfileDetailPallen — dedicated profile detail screen for Pallen.
///
/// This is a separate file so Pallen's profile page can have its own
/// unique layout, design, information, and styling independently.
///
/// To edit Pallen's profile info: update the static constants below.
/// To change the design: modify the build method.
class ProfileDetailPallen extends StatelessWidget {
  const ProfileDetailPallen({super.key});

  // ── Pallen's profile data ─────────────────────────────────────
  // Update any of these to change what shows on Pallen's profile page
  static const String _name = 'Pallen, Prince Dunhill';
  static const String _bio =
      'Computer Science major | Photography enthusiast | Coffee lover ☕';
  static const String _yearLevel = 'Junior';
  static const String _age = '21';
  static const String _gender = 'Male';
  static const String _hometown = 'Manila, Philippines';
  static const String _relationship = 'Single';
  static const String _education = 'B.S. Computer Science';
  static const String _work = 'Software Engineering Intern';
  static const String _email = 'pallen@main.com';
  static const String _phone = '+63 912 345 6789';
  static const String _profilePicture = 'assets/images/profile1.jpg';
  static const String _coverPhoto = 'assets/images/default_cover.jpg';
  static const List<String> _interests = [
    'Photography',
    'Hiking',
    'Coding',
    'Reading',
    'Travel',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () => context.pop(),
        ),
        // No edit button — main profiles are hardcoded
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cover photo + profile picture
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                // Cover photo
                Container(
                  height: 260,
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
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                ),

                // Profile picture
                Positioned(
                  bottom: -60,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: Colors.white, width: 5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
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
              ],
            ),

            const SizedBox(height: 70),

            // Name + year level + bio
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Text(
                    _name,
                    style: TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color:
                              AppColors.primaryBlue.withOpacity(0.3)),
                    ),
                    child: const Text(
                      _yearLevel,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _bio,
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Info cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _infoCard(
                      Icons.school, 'Education', _education),
                  _infoCard(Icons.work, 'Work', _work),
                  _infoCard(
                      Icons.location_on, 'Hometown', _hometown),
                  _infoCard(Icons.favorite, 'Relationship Status',
                      _relationship),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Personal details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Details',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _detailRow('Age', _age),
                  _detailRow('Gender', _gender),
                  _detailRow('Year Level', _yearLevel),
                  _detailRow('Email', _email),
                  _detailRow('Phone', _phone),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Interests
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Interests',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _interests
                        .map((interest) => Chip(
                              label: Text(interest),
                              backgroundColor:
                                  AppColors.primaryBlue
                                      .withOpacity(0.1),
                              side: BorderSide.none,
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(
      IconData icon, String title, String content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryBlue),
        title: Text(title,
            style: const TextStyle(
                fontSize: 12, color: Colors.grey)),
        subtitle: Text(content,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: TextStyle(
                    color: Colors.grey[600], fontSize: 14)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
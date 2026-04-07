import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/constants.dart';
import '../utils/image_helper.dart';

/// ProfileDetailAldhy — dedicated profile detail screen for Aldhy.
class ProfileDetailAldhy extends StatelessWidget {
  const ProfileDetailAldhy({super.key});

  static const String _name = 'Fajardo, Aldhy';
  static const String _bio =
      'Psychology major | Mental health advocate 🧠 | Yoga instructor';
  static const String _yearLevel = 'Sophomore';
  static const String _age = '20';
  static const String _gender = 'Male';
  static const String _hometown = 'Davao, Philippines';
  static const String _relationship = 'Single';
  static const String _education = 'B.A. Psychology';
  static const String _work = 'Research Assistant';
  static const String _email = 'aldhy@main.com';
  static const String _phone = '+63 934 567 8901';
  static const String _profilePicture = 'assets/images/profile3.png';
  static const String _coverPhoto = 'assets/images/default_cover.jpg';
  static const List<String> _interests = [
    'Yoga',
    'Meditation',
    'Painting',
    'Volunteering',
    'Dancing',
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
            child:
                const Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
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
                Positioned(
                  bottom: -60,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white, width: 5),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Text(
                    _name,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.primaryBlue
                              .withOpacity(0.3)),
                    ),
                    child: const Text(
                      _yearLevel,
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w500),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _infoCard(Icons.school, 'Education', _education),
                  _infoCard(Icons.work, 'Work', _work),
                  _infoCard(
                      Icons.location_on, 'Hometown', _hometown),
                  _infoCard(Icons.favorite, 'Relationship Status',
                      _relationship),
                ],
              ),
            ),
            const SizedBox(height: 24),
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
                        .map((i) => Chip(
                              label: Text(i),
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

  Widget _infoCard(IconData icon, String title, String content) {
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
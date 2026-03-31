/// DeveloperInfo holds all data for one developer.
/// Update the fields below with your actual developer information.
class DeveloperInfo {
  final String name;
  final String primaryRole;
  final String imagePath;
  final String gmail;
  final String facebook;
  final String phone;

  const DeveloperInfo({
    required this.name,
    required this.primaryRole,
    required this.imagePath,
    required this.gmail,
    required this.facebook,
    required this.phone,
  });
}

/// DeveloperData contains all developer information used on the home page.
///
/// HOW TO UPDATE:
///   1. Replace name, primaryRole, gmail, facebook, phone with real data
///   2. Add developer photos to assets/images/
///   3. Update imagePath to point to the correct file
///   4. Declare the new asset paths in pubspec.yaml
class DeveloperData {
  /// The 3 developers shown on the home page
  static const List<DeveloperInfo> developers = [
    DeveloperInfo(
      name: 'Pallen, Prince Dunhill',
      primaryRole: 'Frontend Developer',
      // ── Update this path to the developer's actual photo ──
      // Add the image file to assets/images/ and declare in pubspec.yaml
      imagePath: 'assets/images/profile1.jpg',
      gmail: 'pallen.prince@gmail.com',
      facebook: 'fb.com/pallen.prince',
      phone: '+63 912 345 6789',
    ),
    DeveloperInfo(
      name: 'Albaniel, Karl Angelo',
      primaryRole: 'Backend Developer',
      imagePath: 'assets/images/profile2.jpg',
      gmail: 'karl.angelo@gmail.com',
      facebook: 'fb.com/karl.angelo',
      phone: '+63 923 456 7890',
    ),
    DeveloperInfo(
      name: 'Fajardo, Aldhy',
      primaryRole: 'Full-Stack Developer',
      imagePath: 'assets/images/profile3.png',
      gmail: 'aldhy.fajardo@gmail.com',
      facebook: 'fb.com/aldhy.fajardo',
      phone: '+63 934 567 8901',
    ),
  ];
}

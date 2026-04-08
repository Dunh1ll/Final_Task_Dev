/// DeveloperInfo holds all data for one developer.
/// Update the fields below with your actual developer information.
class DeveloperInfo {
  final String name;
  final String primaryRole;
  final String secondaryRole; // Added for second role (full stack/web designer)
  final String imagePath;
  final String gmail;
  final String facebook;
  final String phone;

  const DeveloperInfo({
    required this.name,
    required this.primaryRole,
    required this.secondaryRole,
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
      primaryRole: 'Full-Stack Developer', // Main role for Pallen
      secondaryRole: 'Web Designer', // Secondary role
      // ── Update this path to the developer's actual photo ──
      // Add the image file to assets/images/ and declare in pubspec.yaml
      imagePath: 'assets/images/profile1.jpg',
      gmail: 'cpe.pallen.princedunhill@gmail.com',
      facebook: 'Dunhill Pallen',
      phone: '+639504647074',
    ),
    DeveloperInfo(
      name: 'Albaniel, Karl Angelo',
      primaryRole: 'Backend Developer', // Main role for Karl
      secondaryRole: '', // No secondary role
      imagePath: 'assets/images/profile2.png',
      gmail: 'kaloyalbaniel25@gmail.com',
      facebook: 'Karl Angelo Albaniel',
      phone: '+639949342201',
    ),
    DeveloperInfo(
      name: 'Fajardo, Aldhy',
      primaryRole: 'Frontend Developer', // Main role for Aldhy
      secondaryRole: '', // No secondary role
      imagePath: 'assets/images/profile3.png',
      gmail: 'fajardoaldiii@gmail.com',
      facebook: 'Aldhy Sune Fajardo',
      phone: '+639759488949',
    ),
  ];
}

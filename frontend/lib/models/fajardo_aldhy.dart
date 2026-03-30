import 'user_base.dart';

class FajardoAldhy extends UserBase {
  FajardoAldhy()
      : super(
          id: 'profile_3',
          name: 'Fajardo, Aldhy',
          email: 'aldhy.fajardo@university.edu',
          phone: '+63 934 567 8901',
          profilePicture: 'assets/images/profile3.png',
          coverPhoto: 'assets/images/cover3.jpg',
          bio: 'Psychology major | Mental health advocate 🧠 | Yoga instructor',
          age: 20,
          gender: 'Male',
          yearLevel: 'Sophomore',
          birthday: DateTime(2004, 3, 8),
          hometown: 'Davao, Philippines',
          relationshipStatus: 'Single',
          education: 'B.A. Psychology',
          work: 'Research Assistant',
          interests: [
            'Yoga',
            'Meditation',
            'Painting',
            'Volunteering',
            'Dancing'
          ],
          friends: ['profile_1', 'profile_2'],
          isMainProfile: true,
        );
}

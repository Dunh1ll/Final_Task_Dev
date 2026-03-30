import 'user_base.dart';

class AlbanielKarlAngelo extends UserBase {
  AlbanielKarlAngelo()
      : super(
          id: 'profile_2',
          name: 'Albaniel, Karl Angelo',
          email: 'karl.angelo@university.edu',
          phone: '+63 923 456 7890',
          profilePicture: 'assets/images/profile2.jpg',
          coverPhoto: 'assets/images/cover2.jpg',
          bio:
              'Business Administration | Basketball player 🏀 | Aspiring entrepreneur',
          age: 22,
          gender: 'Male',
          yearLevel: 'Senior',
          birthday: DateTime(2002, 8, 22),
          hometown: 'Cebu, Philippines',
          relationshipStatus: 'In a relationship',
          education: 'B.B.A. Finance',
          work: 'Investment Banking Analyst',
          interests: [
            'Basketball',
            'Stock Trading',
            'Golf',
            'Networking',
            'Music'
          ],
          friends: ['profile_1', 'profile_3'],
          isMainProfile: true,
        );
}

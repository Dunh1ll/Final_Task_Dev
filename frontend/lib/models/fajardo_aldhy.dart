import 'user_base.dart';

class FajardoAldhy extends UserBase {
  FajardoAldhy()
      : super(
          id: 'profile_3',
          name: 'Fajardo, Aldhy',
          email: 'aldhy@main.com',
          phone: '+63 9759488949',
          profilePicture: 'assets/images/profile3.jpg',
          coverPhoto: 'assets/images/cover3.jpg',
          bio: 'Flutter| Strategic Thinking | Dart',
          age: 22,
          gender: 'Male',
          yearLevel: '4th',
          birthday: DateTime(2003, 11, 20),
          hometown: 'Laguna, Philippines',
          relationshipStatus: 'Single',
          education: 'BS Information System',
          work: 'Intern',
          interests: [
            'Chess',
            'Basketball',
            'Paper Works',
            'Analyst',
          ],
          friends: ['profile_1', 'profile_2'],
          isMainProfile: true,
        );
}

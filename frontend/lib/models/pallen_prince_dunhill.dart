import 'user_base.dart';

class PallenPrinceDunhill extends UserBase {
  PallenPrinceDunhill()
      : super(
          id: 'profile_1',
          name: 'Pallen, Prince Dunhill',
          email: 'prince.dunhill@university.edu',
          phone: '+63 950 464 7074',
          profilePicture: 'assets/images/profile1.jpg',
          coverPhoto: 'assets/images/cover1.jpg',
          bio:
              'Computer Science major | Photography enthusiast | Coffee lover ☕',
          age: 22,
          gender: 'Male',
          yearLevel: '4th year',
          birthday: DateTime(2004, 3, 18),
          hometown: 'Brgy. Sta. Rosa, Alaminos, Laguna',
          relationshipStatus: 'Single',
          education: 'B.S. Computer Engineering',
          work: 'FDSAP Intern',
          interests: ['Gaming', 'Watching', 'Coding', 'Cooking', 'Sleeping'],
          friends: ['profile_2', 'profile_3'],
          isMainProfile: true,
        );
}

import 'user_base.dart';

class PallenPrinceDunhill extends UserBase {
  PallenPrinceDunhill()
      : super(
          id: 'profile_1',
          name: 'Pallen, Prince Dunhill',
          email: 'prince.dunhill@university.edu',
          phone: '+63 912 345 6789',
          profilePicture: 'assets/images/profile1.jpg',
          coverPhoto: 'assets/images/cover1.jpg',
          bio:
              'Computer Science major | Photography enthusiast | Coffee lover ☕',
          age: 21,
          gender: 'Male',
          yearLevel: 'Junior',
          birthday: DateTime(2003, 5, 15),
          hometown: 'Manila, Philippines',
          relationshipStatus: 'Single',
          education: 'B.S. Computer Science',
          work: 'Software Engineering Intern',
          interests: ['Photography', 'Hiking', 'Coding', 'Reading', 'Travel'],
          friends: ['profile_2', 'profile_3'],
          isMainProfile: true,
        );
}

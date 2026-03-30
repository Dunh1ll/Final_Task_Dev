import 'dart:typed_data';

abstract class UserBase {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? profilePicture;
  final String? coverPhoto;
  final String? bio;
  final int? age;
  final String? gender;
  final String? yearLevel;
  final DateTime? birthday;
  final String? hometown;
  final String? relationshipStatus;
  final String? education;
  final String? work;
  final List<String> interests;
  final List<String> friends;
  final bool? isMainProfile;
  final Uint8List? profilePictureBytes;
  final Uint8List? coverPhotoBytes;

  UserBase({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.profilePicture,
    this.coverPhoto,
    this.bio,
    this.age,
    this.gender,
    this.yearLevel,
    this.birthday,
    this.hometown,
    this.relationshipStatus,
    this.education,
    this.work,
    this.interests = const [],
    this.friends = const [],
    this.isMainProfile,
    this.profilePictureBytes,
    this.coverPhotoBytes,
  });

  // ✅ Create UserBase from backend JSON
  factory UserBase.fromJson(Map<String, dynamic> json) {
    return _UserBaseImpl(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      profilePicture: json['profile_picture_url']?.toString(),
      coverPhoto: json['cover_photo_url']?.toString(),
      bio: json['bio']?.toString(),
      age: json['age'] != null ? int.tryParse(json['age'].toString()) : null,
      gender: json['gender']?.toString(),
      yearLevel: json['year_level']?.toString(),
      birthday: json['birthday'] != null
          ? DateTime.tryParse(json['birthday'].toString())
          : null,
      hometown: json['hometown']?.toString(),
      relationshipStatus: json['relationship_status']?.toString(),
      education: json['education']?.toString(),
      work: json['work']?.toString(),
      interests:
          json['interests'] != null ? List<String>.from(json['interests']) : [],
      friends:
          json['friends'] != null ? List<String>.from(json['friends']) : [],
      isMainProfile: json['is_main_profile'] == true,
      profilePictureBytes: null,
      coverPhotoBytes: null,
    );
  }

  // ✅ Convert to JSON for backend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_picture_url': profilePicture,
      'cover_photo_url': coverPhoto,
      'bio': bio,
      'age': age,
      'gender': gender,
      'year_level': yearLevel,
      'birthday': birthday?.toIso8601String(),
      'hometown': hometown,
      'relationship_status': relationshipStatus,
      'education': education,
      'work': work,
      'interests': interests,
      'is_main_profile': isMainProfile,
    };
  }

  // ✅ copyWith handles all fields including photo bytes
  UserBase copyWith(Map<String, dynamic> updatedData) {
    return _UserBaseImpl(
      id: id,
      name: updatedData['name']?.toString() ?? name,
      email: updatedData['email']?.toString() ?? email,
      phone: updatedData['phone']?.toString() ?? phone,
      profilePicture:
          updatedData['profile_picture_url']?.toString() ?? profilePicture,
      coverPhoto: updatedData['cover_photo_url']?.toString() ?? coverPhoto,
      bio: updatedData['bio']?.toString() ?? bio,
      age: updatedData['age'] != null
          ? int.tryParse(updatedData['age'].toString())
          : age,
      gender: updatedData['gender']?.toString() ?? gender,
      yearLevel: updatedData['year_level']?.toString() ?? yearLevel,
      birthday: updatedData['birthday'] != null
          ? DateTime.tryParse(updatedData['birthday'].toString())
          : birthday,
      hometown: updatedData['hometown']?.toString() ?? hometown,
      relationshipStatus:
          updatedData['relationship_status']?.toString() ?? relationshipStatus,
      education: updatedData['education']?.toString() ?? education,
      work: updatedData['work']?.toString() ?? work,
      interests: updatedData['interests'] != null
          ? List<String>.from(updatedData['interests'])
          : interests,
      friends: friends,
      isMainProfile: isMainProfile,
      // ✅ Carry over photo bytes from edit dialog
      profilePictureBytes: updatedData['profile_picture_bytes'] as Uint8List? ??
          profilePictureBytes,
      coverPhotoBytes:
          updatedData['cover_photo_bytes'] as Uint8List? ?? coverPhotoBytes,
    );
  }
}

// ✅ Private concrete implementation
class _UserBaseImpl extends UserBase {
  _UserBaseImpl({
    required super.id,
    required super.name,
    super.email,
    super.phone,
    super.profilePicture,
    super.coverPhoto,
    super.bio,
    super.age,
    super.gender,
    super.yearLevel,
    super.birthday,
    super.hometown,
    super.relationshipStatus,
    super.education,
    super.work,
    super.interests,
    super.friends,
    super.isMainProfile,
    super.profilePictureBytes,
    super.coverPhotoBytes,
  });
}

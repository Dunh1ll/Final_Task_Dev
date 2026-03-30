import 'dart:typed_data';
import 'user_base.dart';

class SubUser extends UserBase {
  final DateTime createdAt;
  final String? mainProfileId;

  SubUser({
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
    super.isMainProfile = false,
    super.profilePictureBytes,
    super.coverPhotoBytes,
    this.mainProfileId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // ✅ Create from Add Profile form
  factory SubUser.fromForm({
    required String id,
    required String name,
    required int age,
    required String gender,
    required String yearLevel,
    String? email,
    String? phone,
    String? bio,
    String? hometown,
    String? relationshipStatus,
    String? education,
    String? work,
    List<String>? interests,
    DateTime? birthday,
    String? mainProfileId,
    Uint8List? profilePictureBytes,
    Uint8List? coverPhotoBytes,
  }) {
    return SubUser(
      id: id,
      name: name,
      age: age,
      gender: gender,
      yearLevel: yearLevel,
      email: email,
      phone: phone,
      bio: bio,
      birthday: birthday,
      hometown: hometown,
      relationshipStatus: relationshipStatus,
      education: education,
      work: work,
      interests: interests ?? [],
      profilePicture: profilePictureBytes != null
          ? null
          : 'assets/images/default_avatar.png',
      coverPhoto:
          coverPhotoBytes != null ? null : 'assets/images/default_cover.png',
      isMainProfile: false,
      mainProfileId: mainProfileId,
      profilePictureBytes: profilePictureBytes,
      coverPhotoBytes: coverPhotoBytes,
    );
  }

  // ✅ Create from backend JSON response
  factory SubUser.fromJson(Map<String, dynamic> json) {
    return SubUser(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      profilePicture: json['profile_picture_url']?.toString() ??
          'assets/images/default_avatar.png',
      coverPhoto: json['cover_photo_url']?.toString() ??
          'assets/images/default_cover.png',
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
      isMainProfile: false,
      mainProfileId: json['main_profile_id']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      profilePictureBytes: null,
      coverPhotoBytes: null,
    );
  }

  // ✅ Convert to JSON for backend
  @override
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
      'is_main_profile': false,
      'main_profile_id': mainProfileId,
    };
  }

  // ✅ copyWith carries all fields including photo bytes
  @override
  SubUser copyWith(Map<String, dynamic> updatedData) {
    return SubUser(
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
      isMainProfile: false,
      mainProfileId: mainProfileId,
      createdAt: createdAt,
      profilePictureBytes: updatedData['profile_picture_bytes'] as Uint8List? ??
          profilePictureBytes,
      coverPhotoBytes:
          updatedData['cover_photo_bytes'] as Uint8List? ?? coverPhotoBytes,
    );
  }
}

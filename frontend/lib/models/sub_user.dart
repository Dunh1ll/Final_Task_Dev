import 'dart:typed_data';
import 'user_base.dart';

/// SubUser represents a registered sub user profile.
///
/// KEY FIELDS FOR BADGE FIX:
///   ownerUserId — the UUID from the users table (NOT the profile UUID).
///                 Parsed from JSON field 'user_id'.
///                 Used by dashboard badge to find the logged-in user's profile.
///
///   profilePictureBytes — raw bytes of an uploaded photo.
///                         Must survive copyWith() for real-time badge update.
///
/// ✅ FIXED: Removed 'const' from constructor.
///   UserBase super constructor is not const, so SubUser cannot be const.
///
/// ✅ FIXED: Removed @override from props getter.
///   UserBase does not declare an abstract props getter, so the annotation
///   was incorrect and caused a compile error.
class SubUser extends UserBase {
  final String? ownerUserId; // = users.id (the account UUID)
  final String? bio;
  final String? education;
  final String? work;
  final String? hometown;
  final String? relationshipStatus;
  final String? email;
  final String? phone;
  final List<String> interests;
  final DateTime? birthday;

  // ✅ FIXED: No 'const' keyword — UserBase super is not const
  SubUser({
    required super.id,
    required super.name,
    super.profilePicture,
    super.coverPhoto,
    super.age,
    super.gender,
    super.yearLevel,
    super.profilePictureBytes,
    super.coverPhotoBytes,
    this.ownerUserId,
    this.bio,
    this.education,
    this.work,
    this.hometown,
    this.relationshipStatus,
    this.email,
    this.phone,
    this.interests = const [],
    this.birthday,
  });

  /// Parse a SubUser from JSON returned by the backend.
  ///
  /// CRITICAL: 'user_id' in JSON → ownerUserId in Dart.
  /// This is the users table UUID, NOT the profile UUID.
  /// The dashboard badge uses ownerUserId to find the profile.
  factory SubUser.fromJson(Map<String, dynamic> json) {
    List<String> interests = [];
    if (json['interests'] != null) {
      if (json['interests'] is List) {
        interests =
            (json['interests'] as List).map((e) => e.toString()).toList();
      } else if (json['interests'] is String &&
          (json['interests'] as String).isNotEmpty) {
        interests = [json['interests'] as String];
      }
    }

    DateTime? birthday;
    if (json['birthday'] != null) {
      try {
        birthday = DateTime.parse(json['birthday'].toString());
      } catch (_) {}
    }

    return SubUser(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',

      // ✅ CRITICAL: map 'user_id' → ownerUserId
      // This is what the dashboard badge uses to identify
      // the logged-in user's profile in auth.subUsers
      ownerUserId: json['user_id']?.toString(),

      profilePicture: json['profile_picture_url']?.toString() ??
          json['profile_picture']?.toString(),
      coverPhoto: json['cover_photo_url']?.toString() ??
          json['cover_photo']?.toString(),
      age: json['age'] is int
          ? json['age'] as int
          : int.tryParse(json['age']?.toString() ?? ''),
      gender: json['gender']?.toString(),
      yearLevel: json['year_level']?.toString(),
      bio: json['bio']?.toString(),
      education: json['education']?.toString(),
      work: json['work']?.toString(),
      hometown: json['hometown']?.toString(),
      relationshipStatus: json['relationship_status']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      interests: interests,
      birthday: birthday,
    );
  }

  /// copyWith — creates a modified copy of this SubUser.
  ///
  /// ALL fields including ownerUserId and photo bytes must be
  /// explicitly handled here. Missing keys cause silent data loss.
  ///
  /// The map keys match exactly what EditSubUserDialog puts into
  /// the updatedData map passed to onSave().
  @override
  SubUser copyWith(Map<String, dynamic> updates) {
    return SubUser(
      id: updates['id']?.toString() ?? id,
      name: updates['name']?.toString() ?? name,

      // Preserve ownerUserId — needed for badge lookup
      // Accept either 'owner_user_id' or 'user_id' as the key
      ownerUserId: updates.containsKey('owner_user_id')
          ? updates['owner_user_id']?.toString()
          : updates.containsKey('user_id')
              ? updates['user_id']?.toString()
              : ownerUserId,

      profilePicture: updates.containsKey('profile_picture_url')
          ? updates['profile_picture_url']?.toString()
          : updates.containsKey('profile_picture')
              ? updates['profile_picture']?.toString()
              : profilePicture,

      coverPhoto: updates.containsKey('cover_photo_url')
          ? updates['cover_photo_url']?.toString()
          : updates.containsKey('cover_photo')
              ? updates['cover_photo']?.toString()
              : coverPhoto,

      // ✅ Photo bytes survive copyWith
      profilePictureBytes: updates.containsKey('profile_picture_bytes')
          ? updates['profile_picture_bytes'] as Uint8List?
          : profilePictureBytes,

      coverPhotoBytes: updates.containsKey('cover_photo_bytes')
          ? updates['cover_photo_bytes'] as Uint8List?
          : coverPhotoBytes,

      age: updates.containsKey('age')
          ? (updates['age'] is int
              ? updates['age'] as int
              : int.tryParse(updates['age']?.toString() ?? ''))
          : age,

      gender: updates.containsKey('gender')
          ? updates['gender']?.toString()
          : gender,

      yearLevel: updates.containsKey('year_level')
          ? updates['year_level']?.toString()
          : yearLevel,

      bio: updates.containsKey('bio') ? updates['bio']?.toString() : bio,

      education: updates.containsKey('education')
          ? updates['education']?.toString()
          : education,

      work: updates.containsKey('work') ? updates['work']?.toString() : work,

      hometown: updates.containsKey('hometown')
          ? updates['hometown']?.toString()
          : hometown,

      relationshipStatus: updates.containsKey('relationship_status')
          ? updates['relationship_status']?.toString()
          : relationshipStatus,

      email:
          updates.containsKey('email') ? updates['email']?.toString() : email,

      phone:
          updates.containsKey('phone') ? updates['phone']?.toString() : phone,

      interests: updates.containsKey('interests')
          ? (updates['interests'] is List
              ? (updates['interests'] as List).map((e) => e.toString()).toList()
              : interests)
          : interests,

      birthday: updates.containsKey('birthday')
          ? updates['birthday'] as DateTime?
          : birthday,
    );
  }

  // ✅ FIXED: Removed @override — UserBase does not declare
  // an abstract props getter so the annotation was wrong.
  // Kept as a plain getter for Equatable if UserBase extends it.
  List<Object?> get props => [
        id,
        name,
        ownerUserId,
        profilePicture,
        coverPhoto,
        age,
        gender,
        yearLevel,
        bio,
        education,
        work,
        hometown,
        relationshipStatus,
        email,
        phone,
        interests,
        birthday,
      ];
}

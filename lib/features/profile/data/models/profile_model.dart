import '../../domain/entities/profile.dart';

class ProfileModel extends Profile {
  ProfileModel({
    required super.id,
    required super.full_name,
    required super.email,
    required super.gender,
    required super.birthDate,
    required super.profilePictureUrl,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      full_name: json['full_name'],
      email: json['email'],
      gender: json['gender'],
      birthDate: json['birthdate'],
      profilePictureUrl: json['profile_picture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': full_name,
      'gender': gender,
      'birthdate': birthDate,
      'profile_picture': profilePictureUrl,
    };
  }
}

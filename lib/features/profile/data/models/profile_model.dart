import '../../domain/entities/profile.dart';

class ProfileModel extends Profile {
  ProfileModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.gender,
    required super.birthDate,
    required super.profilePictureUrl,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      gender: json['gender'],
      birthDate: json['birthdate'],
      profilePictureUrl: json['profile_picture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'gender': gender,
      'birthdate': birthDate,
      'profile_picture': profilePictureUrl,
    };
  }
}

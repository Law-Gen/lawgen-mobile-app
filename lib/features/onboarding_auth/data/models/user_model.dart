import 'package:lawgen/features/onboarding_auth/domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
    required String birthDate,
    required String gender,
    required String profilePictureUrl,
    required String subscriptionStatus,
    required String role,
    required String? languagePreference,
  }) : super(
         id: id,
         firstName: firstName,
         lastName: lastName,
         email: email,
         birthDate: birthDate,
         gender: gender,
         profilePictureUrl: profilePictureUrl,
         subscriptionStatus: subscriptionStatus,
         role: role,
         languagePreference: languagePreference,
       );
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      birthDate: json['birthDate'],
      gender: json['gender'],
      profilePictureUrl: json['profile_picture_url'],
      subscriptionStatus: json['subscription_status'],
      role: json['role'],
      languagePreference: json['language_preference'],
    );
  }
}

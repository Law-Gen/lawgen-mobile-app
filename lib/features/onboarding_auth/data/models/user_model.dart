import 'package:lawgen/features/onboarding_auth/domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required String id,
    required String full_name,
    required String email,
  }) : super(
         id: id,
         full_name: full_name,
         email: email,
       );
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      full_name: json['full_name'],
      email: json['email'],
    );
  }
}

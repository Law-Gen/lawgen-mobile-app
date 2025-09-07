// features/onboarding_auth/data/models/user_model.dart
import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required String id,
    required String fullName,
    required String email,
  }) : super(id: id, fullName: fullName, email: email);
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // This factory handles the nested 'user' object in the login response
    final userData = json.containsKey('user')
        ? json['user'] as Map<String, dynamic>
        : json;

    return UserModel(
      id: userData['id'] ?? '',
      fullName: userData['full_name'] ?? 'N/A',
      email: userData['email'] ?? 'N/A',
    );
  }
}

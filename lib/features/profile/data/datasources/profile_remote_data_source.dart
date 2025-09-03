// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../../domain/entities/profile.dart';
// import '../models/profile_model.dart';

// abstract class ProfileRemoteDataSource {
//   Future<Profile> getProfile();
//   Future<Profile> updateProfile({required Profile profile});
//   Future<void> changePassword({
//     required String oldPass,
//     required String newPass,
//   });
//   Future<void> logout();
// }

// class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
//   final http.Client client;
//   final String authurl = "url/auth";
//   final String userUrl = "url/users";

//   ProfileRemoteDataSourceImpl({required this.client});

//   @override
//   Future<Profile> getProfile() async {
//     final response = await client.get(Uri.parse('$userUrl/me'));
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final data = json.decode(response.body);
//       return Profile(
//         id: data['id'],
//         firstName: data['firstName'],
//         lastName: data['lastName'],
//         email: data['email'],
//         birthDate: data['birthDate'],
//         gender: data['gender'],
//         profiePictureUrl: data['profilePictureUrl'],
        
//       );
//     } else {
//       throw Exception('Failed to get profile imformation');
//     }
//   }

//   @override
//   Future<Profile> UpdateProfile(Profile profile) async {
//     final response = await client.put(
//       Uri.parse('$userUrl/me'),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({
//         'firstName': firstName,
//         'profilePictureUrl': profiePictureUrl,
//         'gender': gender,
//       }),
//     );
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       return Profile(
//         id: data['id'],
//         firstName: data['firstName'],
//         lastName: data['lastName'],
//         email: data['email'],
//         birthDate: data['birthDate'],
//         gender: data['gender'],
//         profiePictureUrl: data['profilePictureUrl'],
//       );
//     } else {
//       throw Exception("Failed to update profile");
//     }
//   }

//   @override
//   Future<void> ChangePassword(String oldPass, String newPass) async {
//     final response = await client.post(
//       Uri.parse('$authurl/change_password'),
//       body: {"old_password": oldPass, "new_password": newPass},
//     );
//     if (response.statusCode != 200) {
//       throw Exception("Failed to change password");
//     }
//   }
// }

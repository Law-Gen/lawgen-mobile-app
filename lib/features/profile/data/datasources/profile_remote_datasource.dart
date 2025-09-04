import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/profile.dart';

abstract class ProfileRemoteDataSource {
  Future<Profile> getProfile();
  Future<Profile> updateProfile(Profile profile);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final http.Client client;
  final String baseUrl = "url/users"; 

  ProfileRemoteDataSourceImpl({required this.client});

  @override
  Future<Profile> getProfile() async {
    final response = await client.get(
      Uri.parse('$baseUrl/me'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Profile.fromJson(data);
    } else {
      throw Exception("Failed to load profile");
    }
  }

  @override
  Future<Profile> updateProfile(Profile profile) async {
    final response = await client.put(
      Uri.parse('$baseUrl/me'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(profile.toJson()),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Profile.fromJson(data);
    } else {
      throw Exception("Failed to update profile");
    }
  }
}

// features/profile/data/datasources/profile_remote_datasource.dart

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ✅ FIX 1: Import the auth local datasource to get access to the key constants.
import '../../../onboarding_auth/data/datasources/auth_local_datasource.dart';
import '../../domain/entities/profile.dart';

abstract class ProfileRemoteDataSource {
  Future<Profile> getProfile();
  Future<Profile> updateProfile(Profile profile, File? imageFile);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final http.Client client;
  final FlutterSecureStorage storage;
  final String baseUrl = "https://lawgen-backend.onrender.com/users";

  ProfileRemoteDataSourceImpl({required this.client, required this.storage});

  /// Helper to get the token using the centralized key.
  Future<String?> _getToken() async {
    // ✅ FIX 2: Use the static constant from the single source of truth.
    return await storage.read(key: AuthLocalDatasourceImpl.accessTokenKey);
  }

  @override
  Future<Profile> getProfile() async {
    print("--- [Profile DS] Attempting to get profile ---");
    final token = await _getToken(); // Uses the helper
    if (token == null) throw Exception('Authentication Error: No token found.');
    print("--- [Profile DS] Found token, making GET request to /me ---");

    final response = await client.get(
      Uri.parse('$baseUrl/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print("--- [Profile DS] GET /me | Status: ${response.statusCode} ---");
    print("--- [Profile DS] GET /me | Body: ${response.body} ---");

    if (response.statusCode == 200) {
      print("--- [Profile DS] Profile loaded successfully. ---");
      return Profile.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to load profile: ${response.body}");
    }
  }

  @override
  Future<Profile> updateProfile(Profile profile, File? imageFile) async {
    print("--- [Profile DS] Attempting to update profile ---");
    final token = await _getToken(); // Uses the helper
    if (token == null) throw Exception('Authentication Error: No token found.');
    print(
      "--- [Profile DS] Found token, creating Multipart PUT request to /me ---",
    );

    final request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/me'));
    request.headers.addAll({'Authorization': 'Bearer $token'});

    // Add text fields
    request.fields['full_name'] = profile.full_name;
    if (profile.gender != null && profile.gender!.isNotEmpty) {
      request.fields['gender'] = profile.gender!;
    }
    if (profile.birthDate != null && profile.birthDate!.isNotEmpty) {
      request.fields['birth_date'] = profile.birthDate!;
    }
    if (profile.languagePreference != null &&
        profile.languagePreference!.isNotEmpty) {
      request.fields['language_preference'] = profile.languagePreference!;
    }

    // Add image file if it exists
    if (imageFile != null) {
      print("--- [Profile DS] Attaching profile_picture file ---");
      request.files.add(
        await http.MultipartFile.fromPath('profile_picture', imageFile.path),
      );
    }

    print(
      "--- [Profile DS] Sending update request... Fields: ${request.fields} ---",
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print("--- [Profile DS] PUT /me | Status: ${response.statusCode} ---");
    print("--- [Profile DS] PUT /me | Body: ${response.body} ---");

    if (response.statusCode == 200) {
      print("--- [Profile DS] Profile updated successfully. ---");
      return Profile.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to update profile: ${response.body}");
    }
  }
}

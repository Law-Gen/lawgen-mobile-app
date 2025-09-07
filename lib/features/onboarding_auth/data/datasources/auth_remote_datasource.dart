// features/onboarding_auth/data/datasources/auth_remote_datasource.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/user.dart';
import '../../domain/entities/otp.dart';
import '../models/otp_model.dart';
import '../models/user_model.dart';
import 'auth_local_datasource.dart';

// --- ABSTRACT CLASS DEFINITION ---

abstract class AuthRemoteDatasource {
  Future<void> signUp({
    required String full_name,
    required String email,
    required String password,
  });

  Future<UserModel> signIn({required String email, required String password});

  Future<void> logout();

  Future<void> forgetPassword({required String email});

  Future<OtpModel> verifyOTP({required String email, required String otpCode});

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<UserModel> googleSignIn({
    required String authCode,
    required String codeVerifier,
  });

  Future<UserModel> getMe();
}

// --- IMPLEMENTATION ---

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final http.Client client;
  final AuthLocalDatasource localDatasource;
  final String authUrl = "https://lawgen-backend.onrender.com/auth";
  final String userUrl = "https://lawgen-backend.onrender.com/users";

  AuthRemoteDatasourceImpl({
    required this.client,
    required this.localDatasource,
  });

  /// Throws an [Exception] for all error codes.
  Exception _handleError(http.Response response) {
    try {
      final errorData = json.decode(response.body);
      // The backend nests the error message in an 'error' key.
      return Exception(
        errorData['error'] ?? 'An unknown server error occurred.',
      );
    } catch (e) {
      // If parsing fails, return the raw response body.
      return Exception('Failed to parse error response: ${response.body}');
    }
  }

  @override
  Future<void> signUp({
    required String full_name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await client
          .post(
            Uri.parse('$authUrl/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'full_name': full_name,
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 30));

      // The API returns a 201 status code for successful registration.
      if (response.statusCode == 201) {
        // The sign-up response is just a success message, so we return void.
        return;
      } else {
        throw _handleError(response);
      }
    } on SocketException {
      throw Exception('No Internet connection. Please check your network.');
    } on TimeoutException {
      throw Exception('The request timed out. Please try again.');
    }
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client
          .post(
            Uri.parse('$authUrl/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final accessToken = data['access_token'];
        final refreshToken = data['refresh_token'];
        final userData = data['user'];

        if (accessToken == null || refreshToken == null || userData == null) {
          throw Exception(
            'Authentication failed: Invalid response from server.',
          );
        }

        // Cache tokens upon successful login.
        await localDatasource.cacheToken(accessToken, refreshToken);

        // Return the parsed user model.
        return UserModel.fromJson(userData);
      } else {
        throw _handleError(response);
      }
    } on SocketException {
      throw Exception('No Internet connection. Please check your network.');
    } on TimeoutException {
      throw Exception('The request timed out. Please try again.');
    }
  }

  @override
  Future<void> forgetPassword({required String email}) async {
    try {
      final response = await client
          .post(
            Uri.parse('$authUrl/forgot-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: 30));

      // The API returns a 200 status code on success.
      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } on SocketException {
      throw Exception('No Internet connection. Please check your network.');
    } on TimeoutException {
      throw Exception('The request timed out. Please try again.');
    }
  }

  @override
  Future<OtpModel> verifyOTP({
    required String email,
    required String otpCode,
  }) async {
    try {
      final response = await client
          .post(
            Uri.parse('$authUrl/verify-otp'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email, 'otp_code': otpCode}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['password_reset_token'] == null) {
          throw Exception(
            'Verification failed: Missing reset token in response.',
          );
        }
        // The API response only contains the token, so we construct the model with all necessary data.
        return OtpModel(
          email: email,
          otpCode: otpCode,
          resetToken: data['password_reset_token'],
        );
      } else {
        throw _handleError(response);
      }
    } on SocketException {
      throw Exception('No Internet connection. Please check your network.');
    } on TimeoutException {
      throw Exception('The request timed out. Please try again.');
    }
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await client
          .post(
            Uri.parse('$authUrl/reset-password'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'reset_token': token,
              'new_password': newPassword,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } on SocketException {
      throw Exception('No Internet connection. Please check your network.');
    } on TimeoutException {
      throw Exception('The request timed out. Please try again.');
    }
  }

  @override
  Future<void> logout() async {
    // For a stateless API, logout is a client-side operation.
    // We just clear the cached tokens.
    try {
      await localDatasource.clearTokens();
    } catch (e) {
      throw Exception('Failed to clear local session.');
    }
  }

  @override
  Future<UserModel> googleSignIn({
    required String authCode,
    required String codeVerifier,
  }) async {
    // This implementation remains the same as your original, as it correctly handles
    // the expected request and response for Google Sign-In.
    throw UnimplementedError(); // Replace with your actual implementation.
  }

  @override
  Future<UserModel> getMe() async {
    // This implementation remains the same.
    throw UnimplementedError(); // Replace with your actual implementation.
  }
}

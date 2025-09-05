import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/otp.dart';

abstract class AuthRemoteDatasource {
  Future<User> signUp({
    required String full_name,
    required String email,
    required String password,
  });
  Future<User> signIn({required String email, required String password});
  Future<void> logout();
  Future<void> forgetPassword({required String email});
  Future<OTP> verifyOTP({required String email, required String otpCode});
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });
  Future<User> googleSignIn({
    required String authCode,
    required String codeVerifier,
  });
  Future<User> getMe();
  Future<void> verifyPassword({required String password});
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final http.Client client;
  final FlutterSecureStorage storage;
  final String authurl = "https://lawgen-backend.onrender.com/auth";
  final String userUrl = "https://lawgen-backend.onrender.com/users";

  AuthRemoteDatasourceImpl({required this.client, required this.storage});

  @override
  Future<User> signUp({
    required String full_name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await client
          .post(
            Uri.parse('$authurl/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'full_name': full_name,
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final userData = data['user'];
        if (userData == null)
          throw Exception('User data is missing in signup response.');
        return User(
          id: userData['id'] ?? '',
          full_name: userData['full_name'] ?? full_name,
          email: userData['email'] ?? email,
        );
      } else {
        throw _handleError(response);
      }
    } on SocketException {
      throw Exception('No Internet connection.');
    } on TimeoutException {
      throw Exception('The server took too long to respond.');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<User> signIn({required String email, required String password}) async {
    try {
      final response = await client
          .post(
            Uri.parse('$authurl/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final accessToken = data['access_token'];
        if (accessToken != null) {
          await storage.write(key: 'access_token', value: accessToken);
        }
        final userData = data['user'];
        if (userData == null)
          throw Exception('User data is missing in signin response.');
        return User(
          id: userData['id'] ?? '',
          full_name: userData['full_name'] ?? 'No name',
          email: userData['email'] ?? 'No email',
        );
      } else {
        throw _handleError(response);
      }
    } on SocketException {
      throw Exception('No Internet connection.');
    } on TimeoutException {
      throw Exception('The server took too long to respond.');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> logout() async {
    try {
      await storage.delete(key: 'access_token');
    } catch (e) {
      throw Exception('Failed to log out.');
    }
  }

  @override
  Future<void> forgetPassword({required String email}) async {
    try {
      final response = await client
          .post(
            Uri.parse('$authurl/forgot-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: 30));
      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } on SocketException {
      throw Exception('No Internet connection.');
    } on TimeoutException {
      throw Exception('The server took too long to respond.');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<OTP> verifyOTP({
    required String email,
    required String otpCode,
  }) async {
    try {
      final response = await client
          .post(
            Uri.parse('$authurl/verify-otp'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email, 'otp_code': otpCode}),
          )
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['password_reset_token'] == null ||
            data['password_reset_token'].isEmpty) {
          throw Exception('Reset token is missing from server response.');
        }
        return OTP(
          email: email,
          otpCode: otpCode,
          resetToken: data['password_reset_token'],
        );
      } else {
        throw _handleError(response);
      }
    } on SocketException {
      throw Exception('No Internet connection.');
    } on TimeoutException {
      throw Exception('The server took too long to respond.');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
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
            Uri.parse('$authurl/reset-password'),
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
      throw Exception('No Internet connection.');
    } on TimeoutException {
      throw Exception('The server took too long to respond.');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<User> googleSignIn({
    required String authCode,
    required String codeVerifier,
  }) async {
    try {
      final response = await client
          .post(
            Uri.parse('$authurl/google'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'code': authCode,
              'code_verifier': codeVerifier,
            }),
          )
          .timeout(const Duration(seconds: 45));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final accessToken = data['access_token'];
        if (accessToken != null) {
          await storage.write(key: 'access_token', value: accessToken);
        }
        final userData = data['user'];
        if (userData == null)
          throw Exception('User data is missing in response.');
        return User(
          id: userData['id'],
          full_name: userData['full_name'],
          email: userData['email'],
        );
      } else {
        throw _handleError(response);
      }
    } on SocketException {
      throw Exception('No Internet connection.');
    } on TimeoutException {
      throw Exception('The server took too long to respond.');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<User> getMe() async {
    try {
      final token = await storage.read(key: 'access_token');
      if (token == null) throw Exception('Not authenticated.');
      final response = await client
          .get(
            Uri.parse('$userUrl/me'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User(
          id: data['id'],
          full_name: data['full_name'],
          email: data['email'],
        );
      } else {
        throw _handleError(response);
      }
    } on SocketException {
      throw Exception('No Internet connection.');
    } on TimeoutException {
      throw Exception('The server took too long to respond.');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> verifyPassword({required String password}) async {
    try {
      final token = await storage.read(key: 'access_token');
      if (token == null) throw Exception('Not authenticated.');
      final response = await client
          .post(
            Uri.parse('$authurl/verify-password'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode({'password': password}),
          )
          .timeout(const Duration(seconds: 30));
      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } on SocketException {
      throw Exception('No Internet connection.');
    } on TimeoutException {
      throw Exception('The server took too long to respond.');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Exception _handleError(http.Response response) {
    try {
      final errorData = json.decode(response.body);
      return Exception(
        errorData['error'] ?? 'An unknown server error occurred.',
      );
    } catch (e) {
      return Exception(response.body);
    }
  }
}

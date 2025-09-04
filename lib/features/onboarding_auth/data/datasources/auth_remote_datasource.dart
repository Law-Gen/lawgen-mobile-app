import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/user.dart';
import '../../domain/entities/otp.dart';

abstract class AuthRemoteDatasource {
  Future<User> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String birthDate,
    required String gender,
  });

  Future<User> signIn({required String email, required String password});

  Future<void> forgetPassword({required String email});

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<User> getMe();

  Future<void> verifyPassword({required String password});

  Future<OTP> verifyOTP({
    required String email,
    required String otpCode,
    //required String? resetToken,
  });

  Future<void> sendOTP({required String email});
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final http.Client client;
  final String authurl = "url/auth";
  final String userUrl = "url/users";

  AuthRemoteDatasourceImpl({required this.client});

  //signup
  @override
  Future<User> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String birthDate,
    required String gender,
  }) async {
    print(
      "signing up with $firstName, $lastName, $email, $password, $birthDate, $gender",
    );
    final response = await client.post(
      Uri.parse('$authurl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'birthDate': birthDate,
        'gender': gender,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return User(
        id: data['id'],
        firstName: data['firstName'],
        lastName: data['lastName'],
        email: data['email'],
        birthDate: data['birthDate'],
        gender: data['gender'],
        profilePictureUrl: data['profilePictureUrl'],
        subscriptionStatus: data['subscriptionStatus'],
        role: data['role'],
        languagePreference: data['languagePreference'],
      );
    } else {
      throw Exception('Failed to sign up');
    }
  }

  // Sign In
  @override
  Future<User> signIn({required String email, required String password}) async {
    final response = await client.post(
      Uri.parse('$authurl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);
      return User(
        id: data['id'],
        firstName: data['firstName'],
        lastName: data['lastName'],
        email: data['email'],
        birthDate: data['birthDate'],
        gender: data['gender'],
        profilePictureUrl: data['profilePictureUrl'],
        subscriptionStatus: data['subscriptionStatus'],
        role: data['role'],
        languagePreference: data['languagePreference'],
      );
    } else {
      throw Exception('Failed to sign in');
    }
  }

  //Forget Password
  @override
  Future<void> forgetPassword({required String email}) async {
    final response = await client.post(
      Uri.parse('$authurl/forget-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to process forget password request');
    }
  }

  //Get Me
  @override
  Future<User> getMe() async {
    final response = await client.get(
      Uri.parse('$userUrl/me'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return User(
        id: data['id'],
        firstName: data['firstName'],
        lastName: data['lastName'],
        email: data['email'],
        birthDate: data['birthDate'],
        gender: data['gender'],
        profilePictureUrl: data['profilePictureUrl'],
        subscriptionStatus: data['subscriptionStatus'],
        role: data['role'],
        languagePreference: data['languagePreference'],
      );
    } else {
      throw Exception('Failed to get user data');
    }
  }

  // -------------------- Verify Password --------------------
  @override
  Future<void> verifyPassword({required String password}) async {
    final response = await client.post(
      Uri.parse('$authurl/verify-password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'password': password}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to verify password');
    } else {
      print(password);
    }
  }

  // -------------------- Verify OTP --------------------
  @override
  Future<OTP> verifyOTP({
    required String email,
    required String otpCode,
    //required String? resetToken,
  }) async {
    final response = await client.post(
      Uri.parse('$authurl/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'otp_code': otpCode,
        //'reset_token': resetToken,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);
      return OTP(
        email: data['email'],
        otpCode: data['otp_code'],
        resetToken: data['reset_token'],
      );
    } else {
      throw Exception('Failed to verify OTP');
    }
  }

  // -------------------- Send OTP --------------------
  @override
  Future<void> sendOTP({required String email}) async {
    final response = await client.post(
      Uri.parse('$authurl/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send OTP');
    } else {
      print("otp sent");
    }
  }

  // Reset Password 
  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final response = await client.post(
      Uri.parse('$authurl/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'reset_token': token,
        'new_password': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to reset password');
    } else {
      print("password reset");
      print("userUrl/me/password");
    }
  }
}

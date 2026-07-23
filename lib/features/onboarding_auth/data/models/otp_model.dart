// features/onboarding_auth/data/models/otp_model.dart

import '../../domain/entities/otp.dart';

class OtpModel extends OTP {
  const OtpModel({
    required String email,
    required String otpCode,
    required String resetToken,
  }) : super(email: email, otpCode: otpCode, resetToken: resetToken);

  factory OtpModel.fromJson(
    Map<String, dynamic> json, {
    required String email,
    required String otpCode,
  }) {
    return OtpModel(
      email: email, // Passed in since API response doesn't include it
      otpCode: otpCode, // Passed in
      resetToken: json['password_reset_token'] ?? '',
    );
  }
}

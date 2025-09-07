// features/onboarding_auth/domain/entities/otp.dart

class OTP {
  final String email;
  final String otpCode;
  final String resetToken;

  const OTP({
    required this.email,
    required this.otpCode,
    required this.resetToken,
  });
}

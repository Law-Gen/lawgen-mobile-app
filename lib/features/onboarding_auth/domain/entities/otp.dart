class OTP {
  final String email;
  final String otpCode;
  final String? resetToken;

  OTP({
    required this.email,
    required this.otpCode,
    this.resetToken,
  });
}

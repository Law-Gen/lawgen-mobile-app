import 'package:lawgen/features/onboarding_auth/domain/entities/otp.dart';
class OtpModel extends OTP{
  OtpModel({
    required String email,
    required String otpCode,
    required String resetToken,
  }
  ): super(email: email, otpCode: otpCode, resetToken: resetToken);
  factory OtpModel.fromJson(Map<String, dynamic> json){
    return OtpModel(email: json['email'], otpCode: json['otp_code'], resetToken: json['reset_token']);
  }

}
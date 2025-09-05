abstract class AuthEvent {
  const AuthEvent();
}

class AppStarted extends AuthEvent {}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;
  const SignInRequested({required this.email, required this.password});
}

class SignUpRequested extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String birthDate;
  final String gender;
  const SignUpRequested({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.birthDate,
    required this.gender,
  });
}

class LogoutRequested extends AuthEvent {}

class ForgetPasswordRequested extends AuthEvent {
  final String email;
  const ForgetPasswordRequested({required this.email});
}

class ResetPasswordRequested extends AuthEvent {
  final String token;
  final String newPassword;
  const ResetPasswordRequested({
    required this.token,
    required this.newPassword,
  });
}

class VerifyOtpRequested extends AuthEvent {
  final String email;
  final String otpCode;
  const VerifyOtpRequested({required this.email, required this.otpCode});
}

class VerifyPasswordRequested extends AuthEvent {
  final String password;
  const VerifyPasswordRequested({required this.password});
}

class GetMeRequested extends AuthEvent {}

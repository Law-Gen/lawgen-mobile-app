// auth_event.dart
abstract class AuthEvent {}

class AppStarted extends AuthEvent {}

class SignUpRequested extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String birthDate;
  final String gender;

  SignUpRequested({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.birthDate,
    required this.gender,
  });
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  SignInRequested({required this.email, required this.password});
}

class ForgetPasswordRequested extends AuthEvent {
  final String email;
  ForgetPasswordRequested({required this.email});
}

class ResetPasswordRequested extends AuthEvent {
  final String token;
  final String newPassword;

  ResetPasswordRequested({required this.token, required this.newPassword});
}

class VerifyPasswordRequested extends AuthEvent {
  final String password;
  VerifyPasswordRequested({required this.password});
}

class VerifyOtpRequested extends AuthEvent {
  final String email;
  final String otpCode;
  VerifyOtpRequested({required this.email, required this.otpCode});
}

class GetMeRequested extends AuthEvent {}

class LogoutRequested extends AuthEvent {}

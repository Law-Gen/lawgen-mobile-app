import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AuthEvent {}

class SignUpRequested extends AuthEvent {
  final String full_name;
  final String email;
  final String password;

  const SignUpRequested({
    required this.full_name,
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [full_name, email, password];
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class GoogleSignInRequested extends AuthEvent {
  final String authCode;
  final String codeVerifier;

  const GoogleSignInRequested({
    required this.authCode,
    required this.codeVerifier,
  });

  @override
  List<Object> get props => [authCode, codeVerifier];
}

class LogoutRequested extends AuthEvent {}

class ForgetPasswordRequested extends AuthEvent {
  final String email;
  const ForgetPasswordRequested({required this.email});

  @override
  List<Object> get props => [email];
}

class VerifyOtpRequested extends AuthEvent {
  final String email;
  final String otpCode;
  const VerifyOtpRequested({required this.email, required this.otpCode});

  @override
  List<Object> get props => [email, otpCode];
}

class ResetPasswordRequested extends AuthEvent {
  final String token;
  final String newPassword;
  const ResetPasswordRequested({
    required this.token,
    required this.newPassword,
  });

  @override
  List<Object> get props => [token, newPassword];
}

class VerifyPasswordRequested extends AuthEvent {
  final String password;
  const VerifyPasswordRequested({required this.password});

  @override
  List<Object> get props => [password];
}

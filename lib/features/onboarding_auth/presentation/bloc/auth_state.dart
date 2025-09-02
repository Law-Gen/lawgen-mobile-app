import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  const Authenticated();
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class ForgetPasswordSent extends AuthState {
  const ForgetPasswordSent();
}

class PasswordResetSuccess extends AuthState {
  const PasswordResetSuccess();
}

class OTPSent extends AuthState {
  const OTPSent();
}

class OTPVerified extends AuthState {
  final String resetToken;
  const OTPVerified(this.resetToken);
}


class PasswordVerified extends AuthState {
  const PasswordVerified();
}

class UserLoaded extends AuthState {
  final User user;

  const UserLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

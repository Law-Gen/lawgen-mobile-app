abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final bool fromSignIn;
  const Authenticated({this.fromSignIn = true});
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

class ForgetPasswordSent extends AuthState {
  const ForgetPasswordSent();
}

class PasswordResetSuccess extends AuthState {
  const PasswordResetSuccess();
}

class OTPVerified extends AuthState {
  final String resetToken;
  const OTPVerified(this.resetToken);
}

class PasswordVerified extends AuthState {
  const PasswordVerified();
}

class UserLoaded extends AuthState {
  final dynamic user;
  const UserLoaded(this.user);
}

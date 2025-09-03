import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/signin_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../domain/usecases/forget_password_usecase.dart';
import '../../domain/usecases/getme_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/verify_password_usecase.dart';
import '../../domain/usecases/verifyotp_usecase.dart';
import '../../domain/usecases/auth_check.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final ForgetPasswordUseCase forgetPasswordUseCase;
  final GetMeUseCase getMeUseCase;
  final LogoutUseCase logoutUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final VerifyOTPUseCase verifyOTPUseCase;
  final VerifyPasswordUseCase verifyPasswordUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;

  AuthBloc({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.forgetPasswordUseCase,
    required this.getMeUseCase,
    required this.logoutUseCase,
    required this.resetPasswordUseCase,
    required this.verifyOTPUseCase,
    required this.verifyPasswordUseCase,
    required this.checkAuthStatusUseCase,
  }) : super(const AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<SignInRequested>(_onSignInRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<ForgetPasswordRequested>(_onForgetPasswordRequested);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final isLoggedIn = await checkAuthStatusUseCase();
      if (isLoggedIn) {
        emit(const Authenticated(fromSignIn: false));
      } else {
        emit(const Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await signInUseCase(email: event.email, password: event.password);
      emit(const Authenticated(fromSignIn: true));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await logoutUseCase();
      emit(const Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onForgetPasswordRequested(
    ForgetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await forgetPasswordUseCase(email: event.email);
      emit(const ForgetPasswordSent());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}

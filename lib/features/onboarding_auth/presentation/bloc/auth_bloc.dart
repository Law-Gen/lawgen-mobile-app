import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/signIn_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../domain/usecases/forget_password_usecase.dart';
import '../../domain/usecases/getme_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/verify_password_usecase.dart';
import '../../domain/usecases/verifyotp_usecase.dart';
import '../../domain/usecases/auth_check.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignUpUseCase signUpUseCase;
  final SignInUseCase signInUseCase;
  final ForgetPasswordUseCase forgetPasswordUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final VerifyOTPUseCase verifyOTPUseCase;
  final VerifyPasswordUseCase verifyPasswordUseCase;
  final GetMeUseCase getMeUseCase;
  final LogoutUseCase logoutUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;

  AuthBloc({
    required this.signUpUseCase,
    required this.signInUseCase,
    required this.forgetPasswordUseCase,
    required this.getMeUseCase,
    required this.logoutUseCase,
    required this.resetPasswordUseCase,
    required this.verifyOTPUseCase,
    required this.verifyPasswordUseCase,
    required this.checkAuthStatusUseCase,
  }) : super(const AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignInRequested>(_onSignInRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<ForgetPasswordRequested>(_onForgetPasswordRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<VerifyPasswordRequested>(_onVerifyPasswordRequested);
    on<GetMeRequested>(_onGetMeRequested);
  }

  // -------------------- Handlers --------------------
  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final isLoggedIn = await checkAuthStatusUseCase();
      if (isLoggedIn) {
        emit(const Authenticated());
      } else {
        emit(const Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await signUpUseCase(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        password: event.password,
        birthDate: event.birthDate,
        gender: event.gender,
      );
      emit(const Authenticated());
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
      emit(const Authenticated());
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

  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await resetPasswordUseCase(
        token: event.token,
        newPassword: event.newPassword,
      );
      emit(const PasswordResetSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyOtpRequested(
    VerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final result = await verifyOTPUseCase(
        email: event.email,
        otpCode: event.otpCode,
      );

      result.fold(
        (failure) =>
            emit(AuthError(failure.toString())), 
        (otp) =>
            emit(OTPVerified(otp.resetToken!)), 
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyPasswordRequested(
    VerifyPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await verifyPasswordUseCase(password: event.password);
      emit(const PasswordVerified());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onGetMeRequested(
    GetMeRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await getMeUseCase();
      result.fold(
        (failure) => emit(AuthError('Failed to get user')),
        (user) => emit(UserLoaded(user)),
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}

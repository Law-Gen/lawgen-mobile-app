// features/onboarding_auth/domain/repositories/auth_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/otp.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  // --- THIS IS THE FIX ---
  // Changed from Future<Either<Failures, User>> to Future<Either<Failures, void>>
  Future<Either<Failures, void>> signUp({
    required String full_name,
    required String email,
    required String password,
  });

  Future<Either<Failures, User>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failures, User>> googleSignIn({
    required String authCode,
    required String codeVerifier,
  });

  Future<Either<Failures, void>> logout();

  Future<Either<Failures, void>> forgetPassword({required String email});

  Future<Either<Failures, OTP>> verifyOTP({
    required String email,
    required String otpCode,
  });

  Future<Either<Failures, void>> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<Either<Failures, User>> getMe();

  Future<bool> isLoggedIn();
}

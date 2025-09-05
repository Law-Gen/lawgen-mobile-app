import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/otp.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failures, User>> signUp({required String full_name, required String email, required String password});
  Future<Either<Failures, User>> signIn({required String email, required String password});
  Future<Either<Failures, void>> logout();
  Future<Either<Failures, void>> forgetPassword({required String email});
  Future<Either<Failures, OTP>> verifyOTP({required String email, required String otpCode});
  Future<Either<Failures, void>> resetPassword({required String token, required String newPassword});
  Future<Either<Failures, User>> googleSignIn({required String authCode, required String codeVerifier});
  Future<Either<Failures, User>> getMe();
  Future<Either<Failures, void>> verifyPassword({required String password});
  Future<bool> isLoggedIn();
}
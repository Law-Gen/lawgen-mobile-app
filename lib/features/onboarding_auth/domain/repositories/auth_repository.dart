import 'package:dartz/dartz.dart';
import '../entities/otp.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failures, User>> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String birthDate,
    required String gender,
  });
  Future<Either<Failures, User>> signIn({required String email, required String password});
  Future<Either<Failures, void>> forgetPassword({required String email});
  Future<Either<Failures, void>> resetPassword({
   required String token,
   required String newPassword,
  });
  Future<Either<Failures, User>> getMe();
  Future<Either<Failures, void>> verifyPassword({required String password});
  Future<Either<Failures, void>> logout();
  Future<Either<Failures, OTP>> verifyOTP({
    required String email,
    required String otpCode,
    //required String? resetToken,
  });
   Future<bool> isLoggedIn();
  //Future<Either<Failures, void>> resetPasswordWithToken(String resetToken, String newPassword);
}

import 'package:dartz/dartz.dart';
import '../entities/otp.dart';
import '../repositories/auth_repository.dart';
import '../../../../core/errors/failures.dart';

class VerifyOTPUseCase {
  final AuthRepository repository;

  VerifyOTPUseCase(this.repository);

  Future<Either<Failures, OTP>> execute({
    required String email,
    required String otpCode,
    //String? resetToken,
  }) async {
    return await repository.verifyOTP(email: email, otpCode: otpCode);
  }

  Future<Either<Failures, OTP>> call({
    required String email,
    required String otpCode,
    //required String resetToken,
  }) {
    return execute(email: email, otpCode: otpCode);
  }
}

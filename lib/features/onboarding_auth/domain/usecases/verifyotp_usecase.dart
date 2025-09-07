// features/onboarding_auth/domain/usecases/verifyotp_usecase.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/otp.dart';
import '../repositories/auth_repository.dart';

class VerifyOTPUseCase {
  final AuthRepository repository;

  VerifyOTPUseCase(this.repository);

  Future<Either<Failures, OTP>> call({
    required String email,
    required String otpCode,
  }) async {
    return await repository.verifyOTP(email: email, otpCode: otpCode);
  }
}

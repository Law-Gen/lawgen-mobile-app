// features/onboarding_auth/domain/usecases/reset_password_usecase.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<Either<Failures, void>> call({
    required String token,
    required String newPassword,
  }) async {
    return await repository.resetPassword(
      token: token,
      newPassword: newPassword,
    );
  }
}

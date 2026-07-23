// features/onboarding_auth/domain/usecases/forget_password_usecase.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class ForgetPasswordUseCase {
  final AuthRepository repository;

  ForgetPasswordUseCase(this.repository);

  Future<Either<Failures, void>> call({required String email}) async {
    return await repository.forgetPassword(email: email);
  }
}

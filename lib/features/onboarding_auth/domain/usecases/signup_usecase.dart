// features/onboarding_auth/domain/usecases/signup_usecase.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart'; // This import is no longer strictly needed but is fine to keep.
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  // --- THIS IS THE FIX ---
  // Changed the return type from Future<Either<Failures, User>> to Future<Either<Failures, void>>
  Future<Either<Failures, void>> call({
    required String full_name,
    required String email,
    required String password,
  }) async {
    return await repository.signUp(
      full_name: full_name,
      email: email,
      password: password,
    );
  }
}

// features/onboarding_auth/domain/usecases/auth_check.dart

import '../repositories/auth_repository.dart';

class CheckAuthStatusUseCase {
  final AuthRepository repository;

  CheckAuthStatusUseCase(this.repository);

  Future<bool> call() async {
    return await repository.isLoggedIn();
  }
}

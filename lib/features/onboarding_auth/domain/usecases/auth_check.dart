// domain/usecases/check_auth_status_usecase.dart
import '../repositories/auth_repository.dart';

class CheckAuthStatusUseCase {
  final AuthRepository repository;

  CheckAuthStatusUseCase(this.repository);

  Future<bool> call() async {
    return await repository.isLoggedIn();
  }
}
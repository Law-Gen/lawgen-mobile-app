import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<Failures, void>> execute() async {
    return await repository.logout();
  }

  Future<Either<Failures, void>> call() {
    return execute();
  }
}

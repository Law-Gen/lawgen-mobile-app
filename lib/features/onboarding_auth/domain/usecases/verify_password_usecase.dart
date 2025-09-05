import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class VerifyPasswordUseCase {
  final AuthRepository repository;

  VerifyPasswordUseCase(this.repository);

  Future<Either<Failures, void>> execute({required String password}) async {
    return await repository.verifyPassword(password: password);
  }

  Future<Either<Failures, void>> call({required String password}) {
    return execute(password: password);
  }
}

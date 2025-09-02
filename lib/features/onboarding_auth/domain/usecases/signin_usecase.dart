import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import '../../../../core/errors/failures.dart';

class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<Either<Failures, User>> execute({
    required String email,
    required String password,
  }) async {
    return await repository.signIn(email: email, password: password);
  }

  Future<Either<Failures, User>> call({
    required String email,
    required String password,
  }) {
    return execute(email: email, password: password);
  }
}

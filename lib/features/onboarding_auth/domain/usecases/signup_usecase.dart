import 'package:dartz/dartz.dart';
import '../repositories/auth_repository.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';



class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<Either<Failures, User>> execute({
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

  // 👇 Add this
  Future<Either<Failures, User>> call({
    required String full_name,
    required String email,
    required String password,
  }) {
    return execute(
      full_name: full_name,
      email: email,
      password: password,
    );
  }
}

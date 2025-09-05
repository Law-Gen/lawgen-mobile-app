import 'package:dartz/dartz.dart';
import '../repositories/auth_repository.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';



class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<Either<Failures, User>> execute({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String birthDate,
    required String gender,
  }) async {
    return await repository.signUp(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      birthDate: birthDate,
      gender: gender,
    );
  }

  // 👇 Add this
  Future<Either<Failures, User>> call({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String birthDate,
    required String gender,
  }) {
    return execute(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      birthDate: birthDate,
      gender: gender,
    );
  }
}

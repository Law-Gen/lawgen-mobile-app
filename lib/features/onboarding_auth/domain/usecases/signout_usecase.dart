import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  // The 'call' method makes the class callable like a function.
  Future<Either<Failures, void>> call() async {
    return await repository.signOut();
  }
}

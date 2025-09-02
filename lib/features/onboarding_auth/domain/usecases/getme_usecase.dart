import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';
import '../entities/user.dart';

class GetMeUseCase {
  final AuthRepository repository;

  GetMeUseCase(this.repository);

  Future<Either<Failures, User>> execute() async {
    return await repository.getMe();
  }
  Future<Either<Failures, User>> call() {
    return execute();
  }
}

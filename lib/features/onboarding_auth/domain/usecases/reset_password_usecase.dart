import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<Either<Failures, void>> execute({
    required String token,
    required String newPassword,
  }) async {
    return await repository.resetPassword(token:token, newPassword: newPassword);
  }

  Future<Either<Failures, void>> call({
    required String token,
    required String newPassword,
  }) {
    return execute(token: token, newPassword: newPassword);
  }
}

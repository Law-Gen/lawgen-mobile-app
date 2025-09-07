// features/onboarding_auth/domain/usecases/getme_usecase.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetMeUseCase {
  final AuthRepository repository;

  GetMeUseCase(this.repository);

  Future<Either<Failures, User>> call() async {
    return await repository.getMe();
  }
}

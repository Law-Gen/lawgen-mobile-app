// features/onboarding_auth/domain/usecases/googlesignin_usecase.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GoogleSignInUseCase {
  final AuthRepository repository;

  GoogleSignInUseCase(this.repository);

  Future<Either<Failures, User>> call({
    required String authCode,
    required String codeVerifier,
  }) async {
    return await repository.googleSignIn(
      authCode: authCode,
      codeVerifier: codeVerifier,
    );
  }
}

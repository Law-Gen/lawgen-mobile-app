import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/profile_repository.dart';

class ChangePassword {
  final ProfileRepository repository;
  ChangePassword(this.repository);

  Future<Either<Failures, void>> call(String oldPass, String newPass) async {
    return await repository.changePassword(oldPass, newPass);
  }
}
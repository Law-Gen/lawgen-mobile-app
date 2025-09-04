import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../data/models/profile_model.dart';
import '../repositories/profile_repository.dart';

class GetProfile {
  final ProfileRepository repository;
  GetProfile(this.repository);

  Future<Either<Failures, Profile>> call() async {
    return await repository.getProfile();
  }
}
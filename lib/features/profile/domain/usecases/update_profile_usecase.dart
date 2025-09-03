import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/profile_model.dart';
import '../repositories/profile_repository.dart';

class UpdateProfile {
  final ProfileRepository repository;
  UpdateProfile(this.repository);

  Future<Either<Failures, Profile>> call({required Profile profile}) async {
    return await repository.updateProfile(profile);
  }
}
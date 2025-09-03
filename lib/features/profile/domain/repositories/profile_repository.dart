import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/profile_model.dart';

abstract class ProfileRepository {
  Future<Either<Failures, Profile>> getProfile();
  Future<Either<Failures, Profile>> updateProfile(Profile profile);
  Future<Either<Failures, void>> changePassword(String oldPass, String newPass);
  Future<Either<Failures, void>> logout();
}

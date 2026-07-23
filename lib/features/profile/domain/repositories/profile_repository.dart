import 'dart:io';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Either<Failures, Profile>> getProfile();
  Future<Either<Failures, Profile>> updateProfile(Profile profile, File? imageFile);
}
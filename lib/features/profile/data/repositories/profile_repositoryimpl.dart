// import 'dart:io';
// import 'package:dartz/dartz.dart';
// import '../../../../core/errors/failures.dart';
// import '../../domain/entities/profile.dart';
// import '../../domain/repositories/profile_repository.dart';
// import '../datasources/profile_remote_datasource.dart';

// class ProfileRepositoryImpl implements ProfileRepository {
//   final ProfileRemoteDataSource remoteDataSource;

//   ProfileRepositoryImpl({required this.remoteDataSource});

//   @override
//   Future<Either<Failures, Profile>> getProfile() async {
//     try {
//       final profile = await remoteDataSource.getProfile();
//       return Right(profile);
//     } catch (e) {
//       return Left(
//         ServerFailure(message: e.toString().replaceAll('Exception: ', '')),
//       );
//     }
//   }

//   @override
//   Future<Either<Failures, Profile>> updateProfile(
//       Profile profile, File? imageFile) async {
//     try {
//       final updatedProfile =
//           await remoteDataSource.updateProfile(profile, imageFile);
//       return Right(updatedProfile);
//     } catch (e) {
//       return Left(
//         ServerFailure(message: e.toString().replaceAll('Exception: ', '')),
//       );
//     }
//   }
// }
import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});
  @override
  Future<Either<Failures, Profile>> getProfile() async {
    try {
      final profile = await remoteDataSource.getProfile();
      return Right(profile);
    } catch (e) {
      // Convert the exception from the data source into a Failure object
      return Left(ServerFailure(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failures, Profile>> updateProfile(Profile profile, File? imageFile) async {
    try {
      final updatedProfile = await remoteDataSource.updateProfile(profile, imageFile);
      return Right(updatedProfile);
    } catch (e) {
    
      return Left(ServerFailure(message: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
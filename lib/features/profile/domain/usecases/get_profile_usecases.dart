// // get_profile_usecase.dart
// import '../entities/profile.dart';
// import '../repositories/profile_repository.dart';

// class GetProfileUseCase {
//   final ProfileRepository repository;
//   GetProfileUseCase(this.repository);

//   Future<Profile> call() async => await repository.getProfile();
// }

import '../repositories/profile_repository.dart';
import '../entities/profile.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  Future<Profile> call() async {
    return await repository.getProfile();
  }
}

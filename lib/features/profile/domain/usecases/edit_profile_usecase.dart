// import '../entities/profile.dart';
// import '../repositories/profile_repository.dart';

// class UpdateProfileUseCase {
//   final ProfileRepository repository;
//   UpdateProfileUseCase(this.repository);

//   Future<Profile> call(Profile profile) async =>
//       await repository.updateProfile(profile);
// }
import '../repositories/profile_repository.dart';
import '../entities/profile.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Profile> call(Profile profile) async {
    return await repository.updateProfile(profile);
  }
}

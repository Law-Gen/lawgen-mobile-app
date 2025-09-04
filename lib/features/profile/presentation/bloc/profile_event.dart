import '../../domain/entities/profile.dart';

abstract class ProfileEvent {}

class LoadProfile extends ProfileEvent {}

class SaveProfile extends ProfileEvent {
  final Profile profile;
  SaveProfile(this.profile);
}

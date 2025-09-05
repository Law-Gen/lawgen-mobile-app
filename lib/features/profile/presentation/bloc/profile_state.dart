import '../../domain/entities/profile.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Profile profile;

  ProfileLoaded(this.profile);
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}

class ProfileLoggedOut extends ProfileState {}

// New state for successful password changes.
class ProfilePasswordChanged extends ProfileState {}

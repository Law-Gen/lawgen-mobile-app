// features/profile/presentation/bloc/profile_state.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/profile.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Profile profile;
  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

// ✅ NEW STATE: This is emitted after a successful save.
// It also contains the updated profile so the builder can react to it.
class ProfileUpdateSuccess extends ProfileLoaded {
  const ProfileUpdateSuccess(super.profile);
}

// This state is for showing the spinner *during* the update.
class ProfileUpdating extends ProfileLoaded {
  const ProfileUpdating(super.profile);
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

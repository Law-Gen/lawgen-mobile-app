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

// --- THIS IS THE FIX: ADD THIS NEW STATE CLASS ---
// This state also holds the profile data, just like ProfileLoaded,
// but it specifically signals that an update/save operation is in progress.
// The UI will use this to show a loading indicator on the "Save" button
// without losing the currently displayed profile data.
class ProfileUpdating extends ProfileLoaded {
  const ProfileUpdating(super.profile);
}
// --- END OF FIX ---

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

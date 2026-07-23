import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/edit_profile_usecase.dart';
import '../../domain/usecases/get_profile_usecases.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfile;
  final UpdateProfileUseCase updateProfile;

  ProfileBloc({required this.getProfile, required this.updateProfile})
    : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<SaveProfile>(_onSaveProfile);
  }

  /// Handles the initial loading of the user's profile data.
  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    // Emit the loading state for a full-page indicator.
    emit(ProfileLoading());
    final result = await getProfile();

    result.fold(
      (failure) {
        emit(ProfileError(failure.message));
      },
      (profile) {
        emit(ProfileLoaded(profile));
      },
    );
  }

  /// Handles saving the updated profile information.
  Future<void> _onSaveProfile(
    SaveProfile event,
    Emitter<ProfileState> emit,
  ) async {
    // ✅ FIX: Emit the 'ProfileUpdating' state instead of 'ProfileLoading'.
    // This allows the UI to show a loading indicator on the button
    // without hiding the entire form. We pass the current profile data
    // so the UI builder still has access to it.
    emit(ProfileUpdating(event.profile));

    final result = await updateProfile(event.profile, event.imageFile);

    result.fold(
      (failure) {
        // First, emit the error for the listener to show a snackbar.
        emit(ProfileError(failure.message));
        // ✅ FIX: Immediately after an error, emit the 'ProfileLoaded' state
        // with the *original* data. This returns the UI to a stable,
        // non-loading state so the user can try again.
        emit(ProfileLoaded(event.profile));
      },
      (updatedProfile) {
        // ✅ FIX: On success, emit the new specific 'ProfileUpdateSuccess' state.
        // The BlocListener in the UI will catch this to show a success
        // message and exit editing mode. The BlocBuilder will also use
        // the 'updatedProfile' data from this state to refresh the UI fields.
        emit(ProfileUpdateSuccess(updatedProfile));
      },
    );
  }
}

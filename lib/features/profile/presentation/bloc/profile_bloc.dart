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

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
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

  Future<void> _onSaveProfile(
    SaveProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    
    final result = await updateProfile(event.profile, event.imageFile);
    result.fold(
      (failure) {
        emit(ProfileError(failure.message));
      },
      (updatedProfile) {
        emit(ProfileLoaded(updatedProfile));
      },
    );
  }
}
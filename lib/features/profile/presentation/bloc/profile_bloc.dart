// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../domain/entities/profile.dart';
// import '../../domain/usecases/getprofile_usecase.dart';
// import '../../domain/usecases/update_profile_usecase.dart';
// import '../../domain/usecases/change_password_usecase.dart';
// import '../../domain/usecases/logout_usecase.dart';

// part 'profile_event.dart';
// part 'profile_state.dart';

// class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
//   final GetProfile getProfile;
//   final UpdateProfile updateProfile;
//   final ChangePassword changePassword;
//   final Logout logout;

//   ProfileBloc({
//     required this.getProfile,
//     required this.updateProfile,
//     required this.changePassword,
//     required this.logout,
//   }) : super(ProfileInitial()) {
//     on<LoadProfileEvent>((event, emit) async {
//       emit(ProfileLoading());
//       final result = await getProfile();
//       result.fold(
//         (failure) => emit(ProfileError("Failed to load profile")),
//         (profile) => emit(ProfileLoaded(profile)),
//       );
//     });

//     on<UpdateProfileEvent>((event, emit) async {
//       emit(ProfileLoading());
//       final result = await updateProfile(event.profile);
//       result.fold(
//         (failure) => emit(ProfileError("Failed to update profile")),
//         (profile) => emit(ProfileLoaded(profile)),
//       );
//     });

//     on<LogoutEvent>((event, emit) async {
//       await logout();
//       emit(ProfileLoggedOut());
//     });
//   }
// }

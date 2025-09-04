// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../data/models/profile_model.dart';
// import '../../domain/entities/profile.dart';
// import '../../domain/usecases/getprofile_usecase.dart';
// import '../../domain/usecases/update_profile_usecase.dart';
// import '../../domain/usecases/change_password_usecase.dart';
// import '../../domain/usecases/logout_usecase.dart';
// import '../../presentation/bloc/profile_event.dart';
// import '../../presentation/bloc/profile_state.dart';

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
//       final result = await updateProfile.call(profile:event.profile);
//       result.fold(
//         (failure) => emit(ProfileError("Failed to update profile")),
//         (profile) => emit(ProfileLoaded(profile)),
//       );
//     });

//     on<ChangePasswordEvent>((event, emit) async {
//       emit(ProfileLoading());
//       final result = await changePassword(
//         oldPass: event.oldPassword,
//         newPass: event.newPassword,
//       );
//       result.fold(
//         (failure) => emit(ProfileError("Failed to change password")),
//         (_) => emit(ProfilePasswordChanged()),
//       );
//     });

//     on<LogoutEvent>((event, emit) async {
//       final result = await logout();
//       result.fold(
//         (failure) => emit(ProfileError("Failed to logout")),
//         (_) => emit(ProfileLoggedOut()),
//       );
//     });
//   }
// }

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../core/errors/network/network_info.dart';
import '../features/onboarding_auth/data/datasources/auth_local_datasource.dart';
import '../features/onboarding_auth/data/datasources/auth_remote_datasource.dart';
import '../features/onboarding_auth/data/repositories/auth_repository_impl.dart';
import '../features/onboarding_auth/domain/repositories/auth_repository.dart';
import '../features/onboarding_auth/domain/usecases/auth_check.dart';

import '../features/onboarding_auth/domain/usecases/signin_usecase.dart';
import '../features/onboarding_auth/domain/usecases/signout_usecase.dart';
import '../features/onboarding_auth/domain/usecases/signup_usecase.dart';
import '../features/onboarding_auth/domain/usecases/forget_password_usecase.dart';
import '../features/onboarding_auth/domain/usecases/getme_usecase.dart';
import 'package:lawgen/features/onboarding_auth/domain/usecases/googlesignin_usecase.dart';
// import '../features/onboarding_auth/domain/usecases/logout_usecase.dart';
import '../features/onboarding_auth/domain/usecases/reset_password_usecase.dart';
// import '../features/onboarding_auth/domain/usecases/verify_password_usecase.dart';
import '../features/onboarding_auth/domain/usecases/verifyotp_usecase.dart';
import '../features/onboarding_auth/domain/usecases/auth_check.dart';
import '../features/onboarding_auth/presentation/bloc/auth_bloc.dart';
import '../features/profile/data/datasources/profile_remote_datasource.dart';
import '../features/profile/data/repositories/profile_repositoryimpl.dart';
import '../features/profile/domain/repositories/profile_repository.dart';
import '../features/profile/domain/usecases/edit_profile_usecase.dart';
import '../features/profile/domain/usecases/get_profile_usecases.dart';
import '../features/profile/presentation/bloc/profile_bloc.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/profile/presentation/bloc/profile_event.dart';
import '../features/profile/presentation/bloc/profile_state.dart';

// Service Locator instance
final sl = GetIt.instance;

Future<void> init() async {
  if (!sl.isRegistered<http.Client>()) {
    sl.registerLazySingleton(() => http.Client());
  }

  if (!sl.isRegistered<FlutterSecureStorage>()) {
    sl.registerLazySingleton(() => const FlutterSecureStorage());
  }
  if (!sl.isRegistered<NetworkInfo>()) {
    sl.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(connectionChecker: sl()),
    );
  }
  // Core external utilities used across features
  if (!sl.isRegistered<InternetConnectionChecker>()) {
    sl.registerLazySingleton<InternetConnectionChecker>(
      () => InternetConnectionChecker.createInstance(),
    );
  }

  if (!sl.isRegistered<AuthRemoteDatasource>()) {
    sl.registerLazySingleton<AuthRemoteDatasource>(
      () => AuthRemoteDatasourceImpl(
        client: sl(),
        localDatasource: sl(),
      ), // <- FIXED
    );
  }

  if (!sl.isRegistered<AuthLocalDatasource>()) {
    sl.registerLazySingleton<AuthLocalDatasource>(
      () => AuthLocalDatasourceImpl(secureStorage: sl()),
    );
  }

  // Repository
  if (!sl.isRegistered<AuthRepository>()) {
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remoteDatasource: sl(), localDatasource: sl()),
    );
  }

  if (!sl.isRegistered<ProfileRemoteDataSource>()) {
    sl.registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(client: sl(), storage: sl()),
    );
  }

  // Repository
  if (!sl.isRegistered<ProfileRepository>()) {
    sl.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(remoteDataSource: sl()),
    );
  }

  // Use Cases
  if (!sl.isRegistered<ForgetPasswordUseCase>()) {
    sl.registerLazySingleton(() => ForgetPasswordUseCase(sl()));
  }

  if (!sl.isRegistered<SignInUseCase>()) {
    sl.registerLazySingleton(() => SignInUseCase(sl()));
  }

  // if (!sl.isRegistered<LogoutUseCase>()) {
  //   sl.registerLazySingleton(() => LogoutUseCase(sl()));
  // }

  if (!sl.isRegistered<SignUpUseCase>()) {
    sl.registerLazySingleton(() => SignUpUseCase(sl()));
  }

  if (!sl.isRegistered<GetMeUseCase>()) {
    sl.registerLazySingleton(() => GetMeUseCase(sl()));
  }

  if (!sl.isRegistered<ResetPasswordUseCase>()) {
    sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  }

  // if (!sl.isRegistered<VerifyPasswordUseCase>()) {
  //   sl.registerLazySingleton(() => VerifyPasswordUseCase(sl()));
  // }

  if (!sl.isRegistered<VerifyOTPUseCase>()) {
    sl.registerLazySingleton(() => VerifyOTPUseCase(sl()));
  }

  if (!sl.isRegistered<CheckAuthStatusUseCase>()) {
    sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl()));
  }

  if (!sl.isRegistered<GetProfileUseCase>()) {
    sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  }

  if (!sl.isRegistered<UpdateProfileUseCase>()) {
    sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  }
  //google sign in usecase.
  if (!sl.isRegistered<GoogleSignInUseCase>()) {
    sl.registerLazySingleton(() => GoogleSignInUseCase(sl()));
  }
  sl.registerLazySingleton(() => SignOutUseCase(sl()));

  if (!sl.isRegistered<AuthBloc>()) {
    sl.registerFactory(
      () => AuthBloc(
        signInUseCase: sl(),
        // logoutUseCase: sl(),
        signUpUseCase: sl(),
        checkAuthStatusUseCase: sl(),
        forgetPasswordUseCase: sl(),
        resetPasswordUseCase: sl(),
        verifyOTPUseCase: sl(),
        // verifyPasswordUseCase: sl(),
        getMeUseCase: sl(),

        googleSignInUseCase: sl(),
        signOutUseCase: sl(),
      ),
    );
  }

  if (!sl.isRegistered<ProfileBloc>()) {
    sl.registerFactory(
      () => ProfileBloc(getProfile: sl(), updateProfile: sl()),
    );
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../features/onboarding_auth/data/datasources/auth_local_datasource.dart';
import '../features/onboarding_auth/data/datasources/auth_remote_datasource.dart';
import '../features/onboarding_auth/data/repositories/auth_repository_impl.dart';
import '../features/onboarding_auth/domain/repositories/auth_repository.dart';
import '../features/onboarding_auth/domain/usecases/signin_usecase.dart';
import '../features/onboarding_auth/domain/usecases/signup_usecase.dart';
import '../features/onboarding_auth/domain/usecases/forget_password_usecase.dart';
import '../features/onboarding_auth/domain/usecases/getme_usecase.dart';
import '../features/onboarding_auth/domain/usecases/logout_usecase.dart';
import '../features/onboarding_auth/domain/usecases/reset_password_usecase.dart';
import '../features/onboarding_auth/domain/usecases/verify_password_usecase.dart';
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

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(client: sl()),
  );

  sl.registerLazySingleton<AuthLocalDatasource>(
    () => AuthLocalDatasourceImpl(secureStorage: sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDatasource: sl(), localDatasource: sl()),
  );
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(client: sl()),
  );

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => ForgetPasswordUseCase(sl()));
  // Ensure the SignInUseCase is registered
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => GetMeUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => VerifyPasswordUseCase(sl()));
  sl.registerLazySingleton(() => VerifyOTPUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl()));
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));

  sl.registerFactory(
    () => AuthBloc(
      signInUseCase: sl(),
      logoutUseCase: sl(),
      signUpUseCase: sl(),
      checkAuthStatusUseCase: sl(),
      forgetPasswordUseCase: sl(),
      resetPasswordUseCase: sl(),
      verifyOTPUseCase: sl(),
      verifyPasswordUseCase: sl(),
      getMeUseCase: sl(),
    ),
  );
  sl.registerFactory(() => ProfileBloc(
    getProfile: sl(),
    updateProfile: sl(),
  ));
}

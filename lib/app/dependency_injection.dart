import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// --- Feature: Authentication ---
import 'package:lawgen/features/onboarding_auth/data/datasources/auth_local_datasource.dart';
import 'package:lawgen/features/onboarding_auth/data/datasources/auth_remote_datasource.dart';
import 'package:lawgen/features/onboarding_auth/data/repositories/auth_repository_impl.dart';
import 'package:lawgen/features/onboarding_auth/domain/repositories/auth_repository.dart';
import 'package:lawgen/features/onboarding_auth/domain/usecases/auth_check.dart';
import 'package:lawgen/features/onboarding_auth/domain/usecases/forget_password_usecase.dart';
import 'package:lawgen/features/onboarding_auth/domain/usecases/getme_usecase.dart';
import 'package:lawgen/features/onboarding_auth/domain/usecases/googlesignin_usecase.dart';
import 'package:lawgen/features/onboarding_auth/domain/usecases/reset_password_usecase.dart';
import 'package:lawgen/features/onboarding_auth/domain/usecases/signin_usecase.dart';
import 'package:lawgen/features/onboarding_auth/domain/usecases/signup_usecase.dart';
import 'package:lawgen/features/onboarding_auth/domain/usecases/verifyotp_usecase.dart';
import 'package:lawgen/features/onboarding_auth/presentation/bloc/auth_bloc.dart';

// --- Feature: Profile ---
import 'package:lawgen/features/profile/data/datasources/profile_remote_datasource.dart';
// FIX 1: Corrected the typo in the filename from 'profile_repositoryimpl.dart'
import 'package:lawgen/features/profile/data/repositories/profile_repositoryimpl.dart';
import 'package:lawgen/features/profile/domain/repositories/profile_repository.dart';
import 'package:lawgen/features/profile/domain/usecases/edit_profile_usecase.dart';
import 'package:lawgen/features/profile/domain/usecases/get_profile_usecases.dart';
import 'package:lawgen/features/profile/presentation/bloc/profile_bloc.dart';

// Service Locator instance
final sl = GetIt.instance;

Future<void> init() async {
  // --- EXTERNAL DEPENDENCIES ---
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  // =======================================================================
  //                        AUTHENTICATION FEATURE
  // =======================================================================

  // --- DATASOURCES ---
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(client: sl(), storage: sl()),
  );
  sl.registerLazySingleton<AuthLocalDatasource>(
    () => AuthLocalDatasourceImpl(secureStorage: sl()),
  );

  // --- REPOSITORY ---
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDatasource: sl(), localDatasource: sl()),
  );

  // --- USE CASES ---
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => ForgetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => VerifyOTPUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => GetMeUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl()));
  sl.registerLazySingleton(() => GoogleSignInUseCase(sl()));

  // --- BLOC ---
  sl.registerFactory(
    () => AuthBloc(
      signUpUseCase: sl(),
      signInUseCase: sl(),
      forgetPasswordUseCase: sl(),
      verifyOTPUseCase: sl(),
      resetPasswordUseCase: sl(),
      getMeUseCase: sl(),
      checkAuthStatusUseCase: sl(),
      googleSignInUseCase: sl(),
    ),
  );
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(client: sl(), storage: sl()),
  );

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // --- USE CASES ---
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));

  // --- PROFILE BLOC ---
  sl.registerFactory(() => ProfileBloc(getProfile: sl(), updateProfile: sl()));
}

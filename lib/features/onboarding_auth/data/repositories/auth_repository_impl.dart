// features/onboarding_auth/data/repositories/auth_repository_impl.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/otp.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;
  final AuthLocalDatasource localDatasource;

  AuthRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
  });

  @override
  Future<Either<Failures, void>> signUp({
    required String full_name,
    required String email,
    required String password,
  }) async {
    try {
      // The remote datasource now returns Future<void> for signUp.
      await remoteDatasource.signUp(
        full_name: full_name,
        email: email,
        password: password,
      );
      // On success, we return Right with a void value.
      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failures, User>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDatasource.signIn(
        email: email,
        password: password,
      );
      return Right(user);
    } catch (e) {
      return Left(
        ServerFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failures, void>> forgetPassword({required String email}) async {
    try {
      await remoteDatasource.forgetPassword(email: email);
      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failures, OTP>> verifyOTP({
    required String email,
    required String otpCode,
  }) async {
    try {
      final otp = await remoteDatasource.verifyOTP(
        email: email,
        otpCode: otpCode,
      );
      return Right(otp);
    } catch (e) {
      return Left(
        ServerFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failures, void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await remoteDatasource.resetPassword(
        token: token,
        newPassword: newPassword,
      );
      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failures, void>> logout() async {
    try {
      await remoteDatasource.logout();
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final tokens = await localDatasource.getTokens();
      // A user is considered logged in if the access token exists and is not empty.
      return tokens['accessToken']?.isNotEmpty ?? false;
    } catch (e) {
      return false;
    }
  }

  // --- UNIMPLEMENTED METHODS (Keep your original logic here) ---

  @override
  Future<Either<Failures, User>> googleSignIn({
    required String authCode,
    required String codeVerifier,
  }) async {
    try {
      final user = await remoteDatasource.googleSignIn(
        authCode: authCode,
        codeVerifier: codeVerifier,
      );
      return Right(user);
    } catch (e) {
      return Left(
        ServerFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failures, User>> getMe() async {
    try {
      final user = await remoteDatasource.getMe();
      return Right(user);
    } catch (e) {
      return Left(
        ServerFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }
}

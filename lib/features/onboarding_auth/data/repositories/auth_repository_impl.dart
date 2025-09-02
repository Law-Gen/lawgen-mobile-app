import 'package:dartz/dartz.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/otp.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/errors/failures.dart';
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
  Future<Either<Failures, User>> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String birthDate,
    required String gender,
  }) async {
    try {
      final user = await remoteDatasource.signUp(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        birthDate: birthDate,
        gender: gender,
      );
      return Right(user);
    } catch (e) {
      return Left(ServerFailure());
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
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failures, void>> forgetPassword({required String email}) async {
    try {
      await remoteDatasource.forgetPassword(email: email);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
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
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failures, User>> getMe() async {
    try {
      final user = await remoteDatasource.getMe();
      return Right(user);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failures, void>> verifyPassword({
    required String password,
  }) async {
    try {
      await remoteDatasource.verifyPassword(password: password);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failures, void>> logout() async {
    try {
      await localDatasource.clearTokens();
      return Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failures, void>> sendOTP({required String email}) async {
    try {
      await remoteDatasource.sendOTP(email: email);
      return Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failures, OTP>> verifyOTP({
    required String email,
    required String otpCode,
    //required String? resetToken
  }) async {
    try {
      final otp = await remoteDatasource.verifyOTP(
        email: email,
        otpCode: otpCode,
      );
      return Right(otp);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await localDatasource.getTokens();
    // You can add more checks here (e.g. token expiration validation)
    return token != null && token.isNotEmpty;
  }
}

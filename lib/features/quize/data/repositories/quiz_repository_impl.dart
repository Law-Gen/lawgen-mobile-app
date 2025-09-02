import 'package:dartz/dartz.dart';

import '../../../../core/errors/exception.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/quiz_category.dart';
import '../../domain/entities/quize.dart';
import '../../domain/repositories/quize_repository.dart';
import '../datasources/quiz_remote_data_source.dart';

class QuizRepositoryImpl implements QuizRepository {
  final QuizRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  QuizRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<QuizCategory>>> getQuizCategories({
    required int page,
    required int limit,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteCategories = await remoteDataSource.getQuizCategories(
          page: page,
          limit: limit,
        );
        return Right(remoteCategories.map((c) => c.toEntity()).toList());
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<Quiz>>> getQuizzesByCategory({
    required String categoryId,
    required int page,
    required int limit,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteQuizzes = await remoteDataSource.getQuizzesByCategory(
          categoryId: categoryId,
          page: page,
          limit: limit,
        );
        return Right(remoteQuizzes.map((q) => q.toEntity()).toList());
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Quiz>> getQuizById(String quizId) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteQuiz = await remoteDataSource.getQuizById(quizId);
        return Right(remoteQuiz.toEntity());
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<Question>>> getQuestionsByQuizId(
    String quizId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteQuestions = await remoteDataSource.getQuestionsByQuizId(
          quizId,
        );
        return Right(remoteQuestions.map((q) => q.toEntity()).toList());
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}

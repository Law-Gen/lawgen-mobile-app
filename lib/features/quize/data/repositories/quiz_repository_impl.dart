import 'package:dartz/dartz.dart';

import '../../../../core/errors/exception.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/paginated_response.dart';
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
  // 👇 CHANGED: The return type is now a PaginatedResponse of entities
  Future<Either<Failure, PaginatedResponse<QuizCategory>>> getQuizCategories({
    required int page,
    required int limit,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        // remotePaginatedResponse is of type PaginatedResponse<QuizCategoryModel>
        final remotePaginatedResponse = await remoteDataSource
            .getQuizCategories(page: page, limit: limit);

        // ✅ FIXED: Manually convert the PaginatedResponseModel to a PaginatedResponse entity
        final entityResponse = PaginatedResponse<QuizCategory>(
          items: remotePaginatedResponse.items
              .map((model) => model.toEntity())
              .toList(),
          totalItems: remotePaginatedResponse.totalItems,
          totalPages: remotePaginatedResponse.totalPages,
          currentPage: remotePaginatedResponse.currentPage,
        );

        return Right(entityResponse);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  // 👇 CHANGED: The return type is now a PaginatedResponse of entities
  Future<Either<Failure, PaginatedResponse<Quiz>>> getQuizzesByCategory({
    required String categoryId,
    required int page,
    required int limit,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        // remotePaginatedResponse is of type PaginatedResponse<QuizModel>
        final remotePaginatedResponse = await remoteDataSource
            .getQuizzesByCategory(
              categoryId: categoryId,
              page: page,
              limit: limit,
            );

        // ✅ FIXED: Manually convert the PaginatedResponseModel to a PaginatedResponse entity
        final entityResponse = PaginatedResponse<Quiz>(
          items: remotePaginatedResponse.items
              .map((model) => model.toEntity())
              .toList(),
          totalItems: remotePaginatedResponse.totalItems,
          totalPages: remotePaginatedResponse.totalPages,
          currentPage: remotePaginatedResponse.currentPage,
        );

        return Right(entityResponse);
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

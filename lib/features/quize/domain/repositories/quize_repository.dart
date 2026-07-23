import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/paginated_response.dart';
import '../entities/question.dart';
import '../entities/quiz_category.dart';
import '../entities/quize.dart';

/// Contract for the Quiz Repository.
/// This defines the single source of truth for quiz data for the app.
abstract class QuizRepository {
  /// Fetches a paginated list of all quiz categories.
  /// Returns a [PaginatedResponse] containing the list and pagination details.
  // 👇 CHANGED: The return type now reflects the paginated data structure
  Future<Either<Failure, PaginatedResponse<QuizCategory>>> getQuizCategories({
    required int page,
    required int limit,
  });

  /// Fetches a paginated list of quizzes for a specific category.
  /// Returns a [PaginatedResponse] containing the list and pagination details.
  // 👇 CHANGED: The return type now reflects the paginated data structure
  Future<Either<Failure, PaginatedResponse<Quiz>>> getQuizzesByCategory({
    required String categoryId,
    required int page,
    required int limit,
  });

  /// Fetches a single, complete quiz entity by its unique ID.
  Future<Either<Failure, Quiz>> getQuizById(String quizId);

  /// Fetches all questions for a specific quiz.
  Future<Either<Failure, List<Question>>> getQuestionsByQuizId(String quizId);
}

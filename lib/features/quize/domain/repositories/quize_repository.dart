import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/question.dart';
import '../entities/quiz_category.dart';
import '../entities/quize.dart';

/// Contract for Quiz Repository
abstract class QuizRepository {
  /// Get all quiz categories (paginated)
  Future<Either<Failure, List<QuizCategory>>> getQuizCategories({
    required int page,
    required int limit,
  });

  /// Get quizzes under a specific category (paginated)
  Future<Either<Failure, List<Quiz>>> getQuizzesByCategory({
    required String categoryId,
    required int page,
    required int limit,
  });

  /// Get full quiz with its questions
  Future<Either<Failure, Quiz>> getQuizById(String quizId);

  /// Get all questions for a quiz (helper method)
  Future<Either<Failure, List<Question>>> getQuestionsByQuizId(String quizId);
}

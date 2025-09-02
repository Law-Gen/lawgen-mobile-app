part of 'quiz_bloc.dart';

sealed class QuizEvent extends Equatable {
  const QuizEvent();

  @override
  List<Object?> get props => [];
}

// Load all categories with pagination
class LoadQuizCategoriesEvent extends QuizEvent {
  final int page;
  final int limit;

  const LoadQuizCategoriesEvent({this.page = 1, this.limit = 10});

  @override
  List<Object?> get props => [page, limit];
}

class QuizeCategorySelected extends QuizEvent {
  final String categoryId;

  const QuizeCategorySelected({required this.categoryId});

  @override
  List<Object?> get props => [categoryId];
}

// Load quizzes for a specific category
class LoadQuizzesByCategoryEvent extends QuizEvent {
  final String categoryId;
  final int page;
  final int limit;

  const LoadQuizzesByCategoryEvent({
    required this.categoryId,
    this.page = 1,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [categoryId, page, limit];
}

// Get quiz with all details
class GetQuizByIdEvent extends QuizEvent {
  final String quizId;

  const GetQuizByIdEvent({required this.quizId});

  @override
  List<Object?> get props => [quizId];
}

// Get all questions for a quiz
class GetQuestionsByQuizIdEvent extends QuizEvent {
  final String quizId;

  const GetQuestionsByQuizIdEvent({required this.quizId});

  @override
  List<Object?> get props => [quizId];
}

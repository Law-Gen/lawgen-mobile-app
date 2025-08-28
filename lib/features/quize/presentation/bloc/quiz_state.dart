part of 'quiz_bloc.dart';

sealed class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object?> get props => [];
}

// Initial state
final class QuizInitial extends QuizState {}

class QuizCategoriesLoading extends QuizState {} // For initial category loading

class QuizzesByCategoryLoading extends QuizState {} // For loading quizzes

class QuizeQuestionLoading extends QuizState {}

// Loaded quiz categories
final class QuizCategoriesLoaded extends QuizState {
  final List<QuizCategory> categories;

  const QuizCategoriesLoaded({required this.categories});

  @override
  List<Object?> get props => [categories];
}

// Loaded quizzes for a category
final class QuizzesByCategoryLoaded extends QuizState {
  final List<Quiz> quizzes;

  const QuizzesByCategoryLoaded({required this.quizzes});

  @override
  List<Object?> get props => [quizzes];
}

// Loaded quiz with questions
final class QuizLoaded extends QuizState {
  final Quiz quiz;

  const QuizLoaded({required this.quiz});

  @override
  List<Object?> get props => [quiz];
}

// Loaded only questions
final class QuizQuestionsLoaded extends QuizState {
  final List<Question> questions;

  const QuizQuestionsLoaded({required this.questions});

  @override
  List<Object?> get props => [questions];
}

// Error state
final class QuizError extends QuizState {
  final String message;

  const QuizError({required this.message});

  @override
  List<Object?> get props => [message];
}

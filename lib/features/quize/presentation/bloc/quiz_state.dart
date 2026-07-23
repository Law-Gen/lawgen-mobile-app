// lib/features/quiz/presentation/bloc/quiz_state.dart

part of 'quiz_bloc.dart';

sealed class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object?> get props => [];
}

final class QuizInitial extends QuizState {}

class QuizCategoriesLoading extends QuizState {}

class QuizeQuestionLoading extends QuizState {}

/// The primary state for displaying the list of categories and their quizzes.
final class QuizCategoriesLoaded extends QuizState {
  // Category Data
  final List<QuizCategory> categories;
  final int totalCategoryPages;
  final int currentCategoryPage;

  // Quiz Data
  final List<Quiz> quizzes;
  final int totalQuizPages;
  final int currentQuizPage;

  // UI State
  final String? selectedCategoryId;
  final bool isQuizzesLoading; // To show loading indicator for quizzes only

  const QuizCategoriesLoaded({
    required this.categories,
    this.totalCategoryPages = 1,
    this.currentCategoryPage = 1,
    required this.quizzes,
    this.totalQuizPages = 1,
    this.currentQuizPage = 1,
    this.selectedCategoryId,
    this.isQuizzesLoading = false,
  });

  QuizCategoriesLoaded copyWith({
    List<QuizCategory>? categories,
    int? totalCategoryPages,
    int? currentCategoryPage,
    List<Quiz>? quizzes,
    int? totalQuizPages,
    int? currentQuizPage,
    String? selectedCategoryId,
    bool? isQuizzesLoading,
  }) {
    return QuizCategoriesLoaded(
      categories: categories ?? this.categories,
      totalCategoryPages: totalCategoryPages ?? this.totalCategoryPages,
      currentCategoryPage: currentCategoryPage ?? this.currentCategoryPage,
      quizzes: quizzes ?? this.quizzes,
      totalQuizPages: totalQuizPages ?? this.totalQuizPages,
      currentQuizPage: currentQuizPage ?? this.currentQuizPage,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      isQuizzesLoading: isQuizzesLoading ?? this.isQuizzesLoading,
    );
  }

  @override
  List<Object?> get props => [
    categories,
    totalCategoryPages,
    currentCategoryPage,
    quizzes,
    totalQuizPages,
    currentQuizPage,
    selectedCategoryId,
    isQuizzesLoading,
  ];
}

final class QuizLoaded extends QuizState {
  final Quiz quiz;

  const QuizLoaded({required this.quiz});

  @override
  List<Object?> get props => [quiz];
}

final class QuizQuestionsLoaded extends QuizState {
  final List<Question> questions;

  const QuizQuestionsLoaded({required this.questions});

  @override
  List<Object?> get props => [questions];
}

final class QuizError extends QuizState {
  final String message;

  const QuizError({required this.message});

  @override
  List<Object?> get props => [message];
}

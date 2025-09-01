part of 'quiz_bloc.dart';

sealed class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object?> get props => [];
}

final class QuizInitial extends QuizState {}

class QuizCategoriesLoading extends QuizState {}

class QuizeQuestionLoading extends QuizState {}

final class QuizCategoriesLoaded extends QuizState {
  final List<QuizCategory> categories;
  final List<Quiz> quizzes;
  final String? selectedCategoryId;
  final bool isQuizzesLoading; // To show loading indicator for quizzes only

  const QuizCategoriesLoaded({
    required this.categories,
    required this.quizzes,
    this.selectedCategoryId,
    this.isQuizzesLoading = false,
  });

  QuizCategoriesLoaded copyWith({
    List<QuizCategory>? categories,
    List<Quiz>? quizzes,
    String? selectedCategoryId,
    bool? isQuizzesLoading,
  }) {
    return QuizCategoriesLoaded(
      categories: categories ?? this.categories,
      quizzes: quizzes ?? this.quizzes,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      isQuizzesLoading: isQuizzesLoading ?? this.isQuizzesLoading,
    );
  }

  @override
  List<Object?> get props => [
    categories,
    quizzes,
    selectedCategoryId,
    isQuizzesLoading,
  ];
}

// This state can be removed if not used elsewhere, as QuizCategoriesLoaded
// now handles quiz lists. If it's used on other pages, it can be kept.
final class QuizzesByCategoryLoaded extends QuizState {
  final List<Quiz> quizzes;

  const QuizzesByCategoryLoaded({required this.quizzes});

  @override
  List<Object?> get props => [quizzes];
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

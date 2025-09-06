// lib/features/quiz/presentation/bloc/quiz_bloc.dart

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase_params.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/quiz_category.dart';
import '../../domain/entities/quize.dart';
import '../../domain/usecases/get_questions_by_quiz_id_usecase.dart';
import '../../domain/usecases/get_quiz_by_id_usecase.dart';
import '../../domain/usecases/get_quiz_categories_usecase.dart';
import '../../domain/usecases/get_quizzes_by_category_usecase.dart';

part 'quiz_event.dart';
part 'quiz_state.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final GetQuizCategoriesUsecase getQuizCategories;
  final GetQuizzesByCategoryUsecase getQuizzesByCategory;
  final GetQuizByIdUsecase getQuizById;
  final GetQuestionsByQuizIdUsecase getQuestionsByQuizId;

  QuizBloc({
    required this.getQuizCategories,
    required this.getQuizzesByCategory,
    required this.getQuizById,
    required this.getQuestionsByQuizId,
  }) : super(QuizInitial()) {
    on<LoadQuizCategoriesEvent>(_onLoadQuizCategories);
    on<LoadQuizzesByCategoryEvent>(_onLoadQuizzesByCategory);
    on<GetQuizByIdEvent>(_onGetQuizById);
    on<GetQuestionsByQuizIdEvent>(_onGetQuestionsByQuizId);
  }

  Future<void> _onLoadQuizCategories(
    LoadQuizCategoriesEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizCategoriesLoading());
    final result = await getQuizCategories(
      PageParams(page: event.page, limit: event.limit),
    );

    await result.fold(
      (failure) async =>
          emit(QuizError(message: _mapFailureToMessage(failure))),
      // 👇 The success result is now a PaginatedResponse object
      (paginatedCategories) async {
        if (paginatedCategories.items.isEmpty) {
          emit(
            const QuizCategoriesLoaded(
              categories: [],
              quizzes: [],
              selectedCategoryId: null,
            ),
          );
        } else {
          // Auto-load quizzes for the first category
          final firstCategoryId = paginatedCategories.items.first.id;
          final quizzesResult = await getQuizzesByCategory(
            CategoryPageParams(
              categoryId: firstCategoryId,
              page: 1, // Always load the first page of quizzes initially
              limit: event.limit,
            ),
          );

          quizzesResult.fold(
            (failure) =>
                emit(QuizError(message: _mapFailureToMessage(failure))),
            // 👇 This result is also a PaginatedResponse
            (paginatedQuizzes) => emit(
              QuizCategoriesLoaded(
                // ✅ Populate the state with data from the paginated responses
                categories: paginatedCategories.items,
                totalCategoryPages: paginatedCategories.totalPages,
                currentCategoryPage: paginatedCategories.currentPage,
                quizzes: paginatedQuizzes.items,
                totalQuizPages: paginatedQuizzes.totalPages,
                currentQuizPage: paginatedQuizzes.currentPage,
                selectedCategoryId: firstCategoryId,
              ),
            ),
          );
        }
      },
    );
  }

  Future<void> _onLoadQuizzesByCategory(
    LoadQuizzesByCategoryEvent event,
    Emitter<QuizState> emit,
  ) async {
    final currentState = state;
    if (currentState is QuizCategoriesLoaded) {
      emit(
        currentState.copyWith(
          isQuizzesLoading: true,
          selectedCategoryId: event.categoryId,
        ),
      );

      final result = await getQuizzesByCategory(
        CategoryPageParams(
          categoryId: event.categoryId,
          page: event.page,
          limit: event.limit,
        ),
      );

      result.fold(
        (failure) => emit(QuizError(message: _mapFailureToMessage(failure))),
        // 👇 The success result is a PaginatedResponse
        (paginatedQuizzes) => emit(
          currentState.copyWith(
            // ✅ Populate the state with the new quiz data and pagination info
            quizzes: paginatedQuizzes.items,
            totalQuizPages: paginatedQuizzes.totalPages,
            currentQuizPage: paginatedQuizzes.currentPage,
            selectedCategoryId: event.categoryId,
            isQuizzesLoading: false,
          ),
        ),
      );
    }
  }

  Future<void> _onGetQuizById(
    GetQuizByIdEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizeQuestionLoading());
    final result = await getQuizById(IdParams(event.quizId));
    result.fold(
      (failure) => emit(QuizError(message: _mapFailureToMessage(failure))),
      (quiz) => emit(QuizLoaded(quiz: quiz)),
    );
  }

  Future<void> _onGetQuestionsByQuizId(
    GetQuestionsByQuizIdEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizeQuestionLoading());
    final result = await getQuestionsByQuizId(IdParams(event.quizId));
    result.fold(
      (failure) => emit(QuizError(message: _mapFailureToMessage(failure))),
      (questions) => emit(QuizQuestionsLoaded(questions: questions)),
    );
  }
}

// Helper function to map failures to error messages
String _mapFailureToMessage(Failure failure) {
  switch (failure.runtimeType) {
    case ServerFailure:
      return 'Server Failure';
    case NetworkFailure:
      return 'No Internet Connection';
    case CacheFailure:
      return 'Cache Failure';
    default:
      return 'An unexpected error occurred';
  }
}

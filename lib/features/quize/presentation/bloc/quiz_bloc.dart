import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

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
      (categories) async {
        if (categories.isEmpty) {
          emit(
            const QuizCategoriesLoaded(
              categories: [],
              quizzes: [],
              selectedCategoryId: null,
            ),
          );
        } else {
          // Auto-load quizzes for the first category
          final firstCategoryId = categories.first.id;
          final quizzesResult = await getQuizzesByCategory(
            CategoryPageParams(
              categoryId: firstCategoryId,
              page: event.page,
              limit: event.limit,
            ),
          );
          quizzesResult.fold(
            (failure) =>
                emit(QuizError(message: _mapFailureToMessage(failure))),
            (quizzes) => emit(
              QuizCategoriesLoaded(
                categories: categories,
                quizzes: quizzes,
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
      // Emit a state to show the quizzes are loading, but keep the old UI data
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
        (quizzes) => emit(
          currentState.copyWith(
            quizzes: quizzes,
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

// ... (failure mapping code remains the same)
const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String NETWORK_FAILURE_MESSAGE = 'No Internet Connection';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';

String _mapFailureToMessage(Failure failure) {
  switch (failure.runtimeType) {
    case ServerFailure:
      return SERVER_FAILURE_MESSAGE;
    case NetworkFailure:
      return NETWORK_FAILURE_MESSAGE;
    case CacheFailure:
      return CACHE_FAILURE_MESSAGE;
    default:
      return 'Unexpected Error';
  }
}

// ignore_for_file: constant_identifier_names, type_literal_in_constant_pattern

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
    // Load all quiz categories
    on<LoadQuizCategoriesEvent>((event, emit) async {
      emit(QuizCategoriesLoading());
      final result = await getQuizCategories(
        PageParams(page: event.page, limit: event.limit),
      );
      result.fold(
        (failure) => emit(QuizError(message: _mapFailureToMessage(failure))),
        (categories) => emit(QuizCategoriesLoaded(categories: categories)),
      );
    });

    // Load quizzes for a specific category
    on<LoadQuizzesByCategoryEvent>((event, emit) async {
      // Emit the specific loading state
      emit(QuizzesByCategoryLoading());
      final result = await getQuizzesByCategory(
        CategoryPageParams(
          categoryId: event.categoryId,
          page: event.page,
          limit: event.limit,
        ),
      );
      result.fold(
        (failure) => emit(QuizError(message: _mapFailureToMessage(failure))),
        (quizzes) => emit(QuizzesByCategoryLoaded(quizzes: quizzes)),
      );
    });

    // Load a quiz with questions
    on<GetQuizByIdEvent>((event, emit) async {
      emit(QuizeQuestionLoading());
      final result = await getQuizById(IdParams(event.quizId));
      result.fold(
        (failure) => emit(QuizError(message: _mapFailureToMessage(failure))),
        (quiz) => emit(QuizLoaded(quiz: quiz)),
      );
    });

    // Load questions for a quiz (optional, separate event)
    on<GetQuestionsByQuizIdEvent>((event, emit) async {
      emit(QuizeQuestionLoading());
      final result = await getQuestionsByQuizId(IdParams(event.quizId));
      result.fold(
        (failure) => emit(QuizError(message: _mapFailureToMessage(failure))),
        (questions) => emit(QuizQuestionsLoaded(questions: questions)),
      );
    });
  }
}

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

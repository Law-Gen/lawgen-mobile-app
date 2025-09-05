import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import '../../core/network/network_info.dart';
import 'data/datasources/quiz_remote_data_source.dart';
import 'data/repositories/quiz_repository_impl.dart';
import 'domain/repositories/quize_repository.dart';
import 'domain/usecases/get_questions_by_quiz_id_usecase.dart';
import 'domain/usecases/get_quiz_by_id_usecase.dart';
import 'domain/usecases/get_quiz_categories_usecase.dart';
import 'domain/usecases/get_quizzes_by_category_usecase.dart';
import 'presentation/bloc/quiz_bloc.dart';

final quizSl = GetIt.instance;

Future<void> initQuiz() async {
  //! Bloc
  if (!quizSl.isRegistered<QuizBloc>()) {
    quizSl.registerFactory(
      () => QuizBloc(
        getQuizCategories: quizSl(),
        getQuizzesByCategory: quizSl(),
        getQuizById: quizSl(),
        getQuestionsByQuizId: quizSl(),
      ),
    );
  }

  //! Use cases
  if (!quizSl.isRegistered<GetQuizCategoriesUsecase>()) {
    quizSl.registerLazySingleton(() => GetQuizCategoriesUsecase(quizSl()));
  }
  if (!quizSl.isRegistered<GetQuizzesByCategoryUsecase>()) {
    quizSl.registerLazySingleton(() => GetQuizzesByCategoryUsecase(quizSl()));
  }
  if (!quizSl.isRegistered<GetQuizByIdUsecase>()) {
    quizSl.registerLazySingleton(() => GetQuizByIdUsecase(quizSl()));
  }
  if (!quizSl.isRegistered<GetQuestionsByQuizIdUsecase>()) {
    quizSl.registerLazySingleton(() => GetQuestionsByQuizIdUsecase(quizSl()));
  }

  //! Repository
  if (!quizSl.isRegistered<QuizRepository>()) {
    quizSl.registerLazySingleton<QuizRepository>(
      () =>
          QuizRepositoryImpl(remoteDataSource: quizSl(), networkInfo: quizSl()),
    );
  }

  //! Data sources
  if (!quizSl.isRegistered<QuizRemoteDataSource>()) {
    quizSl.registerLazySingleton<QuizRemoteDataSource>(
      () => QuizRemoteDataSourceImpl(),
    );
  }

  //! Core
  if (!quizSl.isRegistered<NetworkInfo>()) {
    quizSl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(quizSl()));
  }

  // InternetConnectionChecker is registered in the app-level DI to avoid duplicates.

  if (!quizSl.isRegistered<http.Client>()) {
    quizSl.registerLazySingleton(() => http.Client());
  }
}

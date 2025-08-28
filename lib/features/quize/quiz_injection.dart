import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';

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
  quizSl.registerFactory(
    () => QuizBloc(
      getQuizCategories: quizSl(),
      getQuizzesByCategory: quizSl(),
      getQuizById: quizSl(),
      getQuestionsByQuizId: quizSl(),
    ),
  );

  //! Use cases
  quizSl.registerLazySingleton(() => GetQuizCategoriesUsecase(quizSl()));
  quizSl.registerLazySingleton(() => GetQuizzesByCategoryUsecase(quizSl()));
  quizSl.registerLazySingleton(() => GetQuizByIdUsecase(quizSl()));
  quizSl.registerLazySingleton(() => GetQuestionsByQuizIdUsecase(quizSl()));

  //! Repository
  quizSl.registerLazySingleton<QuizRepository>(
    () => QuizRepositoryImpl(remoteDataSource: quizSl(), networkInfo: quizSl()),
  );

  //! Data sources
  quizSl.registerLazySingleton<QuizRemoteDataSource>(
    () => QuizRemoteDataSourceImpl(),
  );

  //! Core
  // THIS IS THE FIX: Register NetworkInfo
  quizSl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(quizSl()));

  quizSl.registerLazySingleton<InternetConnectionChecker>(
    () => InternetConnectionChecker.createInstance(),
  );
  quizSl.registerLazySingleton(() => http.Client());
}

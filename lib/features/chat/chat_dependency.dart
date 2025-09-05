import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Core
import '../../../core/utils/internet_connection.dart';

// Data layer
import 'data/datasources/chat_local_data_source.dart';
import 'data/datasources/chat_remote_data_source.dart';
import 'data/datasources/chat_socket_data_source.dart';
import 'data/repository/chat_repository_impl.dart';

// Domain layer
import 'domain/repository/chat_repository.dart';
import 'domain/usecases/ask_question_usecase.dart';
import 'domain/usecases/ask_follow_up_usecase.dart';
import 'domain/usecases/get_chat_history_usecase.dart';
import 'domain/usecases/get_chat_message_usecase.dart';
import 'domain/usecases/ai_response_usecase.dart';
import 'domain/usecases/stop_ask_question_stream.dart';

// Presentation
import 'presentation/bloc/chat_bloc.dart';

final GetIt chatsl = GetIt.instance;

/// Register all dependencies for the Chat (AI) feature.
/// Call this during app startup (after Hive.init & adapter registration).
Future<void> setupChatFeatureDependencies() async {
  // External / shared singletons (only if not already registered elsewhere)
  if (!chatsl.isRegistered<http.Client>()) {
    chatsl.registerLazySingleton<http.Client>(() => http.Client());
  }
  if (!chatsl.isRegistered<FlutterSecureStorage>()) {
    chatsl.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage(),
    );
  }
  // InternetConnectionChecker is registered in the app-level DI to avoid duplicates.
  if (!chatsl.isRegistered<NetworkInfo>()) {
    chatsl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(chatsl()));
  }

  // Data sources
  if (!chatsl.isRegistered<ChatLocalDataSource>()) {
    final local = ChatLocalDataSourceImpl();
    await local.init();
    chatsl.registerLazySingleton<ChatLocalDataSource>(() => local);
  }
  if (!chatsl.isRegistered<ChatRemoteDataSource>()) {
    chatsl.registerLazySingleton<ChatRemoteDataSource>(
      () => ChatRemoteDataSourceImpl(client: chatsl(), secureStorage: chatsl()),
    );
  }
  if (!chatsl.isRegistered<ChatSocketDataSource>()) {
    chatsl.registerLazySingleton<ChatSocketDataSource>(
      () => ChatSocketDataSourceImpl(),
    );
  }

  // Repository
  if (!chatsl.isRegistered<ChatRepository>()) {
    chatsl.registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(
        networkInfo: chatsl(),
        localDataSource: chatsl(),
        remoteDataSource: chatsl(),
        socketDataSource: chatsl(),
      ),
    );
  }

  // Use cases
  if (!chatsl.isRegistered<GetChatHistoryUsecase>()) {
    chatsl.registerLazySingleton(() => GetChatHistoryUsecase(chatsl()));
  }
  if (!chatsl.isRegistered<GetChatMessageUsecase>()) {
    chatsl.registerLazySingleton(() => GetChatMessageUsecase(chatsl()));
  }
  if (!chatsl.isRegistered<AskQuestionUseCase>()) {
    chatsl.registerLazySingleton(() => AskQuestionUseCase(chatsl()));
  }
  if (!chatsl.isRegistered<AskFollowUpUseCase>()) {
    chatsl.registerLazySingleton(() => AskFollowUpUseCase(chatsl()));
  }
  if (!chatsl.isRegistered<AiResponseUsecase>()) {
    chatsl.registerLazySingleton(() => AiResponseUsecase(chatsl()));
  }
  if (!chatsl.isRegistered<StopAskQuestionStreamUseCase>()) {
    chatsl.registerLazySingleton(() => StopAskQuestionStreamUseCase(chatsl()));
  }

  // Bloc
  if (!chatsl.isRegistered<ChatBloc>()) {
    chatsl.registerFactory(
      () => ChatBloc(
        getChatHistoryUsecase: chatsl(),
        getChatMessageUsecase: chatsl(),
        askQuestionUseCase: chatsl(),
        askFollowUpUseCase: chatsl(),
        aiResponseUsecase: chatsl(),
        stopStreamUseCase: chatsl(),
      ),
    );
  }
}

// Convenience providers for MultiRepositoryProvider / MultiBlocProvider usage
List<RepositoryProvider> get chatRepositoryProviders => [
  RepositoryProvider<ChatRepository>(create: (_) => chatsl<ChatRepository>()),
];

List<BlocProvider> get chatBlocProviders => [
  BlocProvider<ChatBloc>(create: (_) => chatsl<ChatBloc>()),
];

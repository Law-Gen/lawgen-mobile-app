import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

// Data layer
import 'data/datasources/chat_remote_data_source.dart';

// Domain layer
import 'data/repository/chat_repository_impl.dart';
import 'domain/repository/chat_repository.dart';
import 'domain/usecases/get_messages_from_session.dart';
import 'domain/usecases/list_user_chat_sessions.dart';
import 'domain/usecases/send_query.dart';
import 'domain/usecases/send_voice_query.dart';

// Presentation
import 'presentation/bloc/chat_bloc.dart';

final GetIt chatsl = GetIt.instance;

/// Register all dependencies for the Chat feature.
/// Assumes core dependencies (like http.Client) are already registered.
Future<void> setupChatFeatureDependencies() async {
  // --- DATA LAYER ---

  // Data Sources
  // CORRECTED: Only the 'client' parameter is provided, matching your implementation.
  chatsl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(client: chatsl()),
  );

  // Repository
  // CORRECTED: Only the 'remoteDataSource' parameter is provided, matching your implementation.
  chatsl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      remoteDataSource: chatsl(),
      networkInfo: chatsl(), // This line was missing
    ),
  );
  // --- DOMAIN LAYER ---

  // Use Cases
  chatsl.registerLazySingleton(() => ListUserChatSessions(chatsl()));
  chatsl.registerLazySingleton(() => GetMessagesFromSession(chatsl()));
  chatsl.registerLazySingleton(() => SendQuery(chatsl()));
  chatsl.registerLazySingleton(() => SendVoiceQuery(chatsl()));

  // --- PRESENTATION LAYER ---

  // Bloc
  chatsl.registerFactory(
    () => ChatBloc(
      listUserChatSessionsUseCase: chatsl(),
      getMessagesFromSessionUseCase: chatsl(),
      sendQueryUseCase: chatsl(),
      sendVoiceQueryUseCase: chatsl(),
    ),
  );
}
  // External / shared singletons (only if not already registered elsewhere)
 
  // InternetConnectionChecker is registered in the app-level DI to avoid duplicates.
  

  


// Convenience providers for MultiRepositoryProvider / MultiBlocProvider usage
List<RepositoryProvider> get chatRepositoryProviders => [
  RepositoryProvider<ChatRepository>(create: (_) => chatsl<ChatRepository>()),
];

List<BlocProvider> get chatBlocProviders => [
  BlocProvider<ChatBloc>(create: (_) => chatsl<ChatBloc>()),
];

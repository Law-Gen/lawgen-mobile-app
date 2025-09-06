import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lawgen/features/onboarding_auth/presentation/bloc/auth_bloc.dart';
import 'package:lawgen/features/onboarding_auth/presentation/bloc/auth_event.dart';

import '../features/LegalAidDirectory/injection_container.dart';
import '../features/catalog/catalog_injection.dart';
import '../features/chat/chat_dependency.dart';
import '../features/chat/data/models/conversation_model.dart';
import '../features/chat/data/models/message_model.dart';
import '../features/quize/quiz_injection.dart';
import 'dependency_injection.dart' as di;
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Hive & register adapters (safe to call only once)
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(ConversationModelAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(MessageSenderAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(MessageModelAdapter());
  }

  // Feature DI setup
  await setupChatFeatureDependencies();
  await di.init();
  await initLegalAid();
  await initQuiz();
  await initCatalog();

  final appRouter = AppRouter();
  runApp(MyApp(router: appRouter.router));
}

class MyApp extends StatelessWidget {
  final GoRouter router;
  const MyApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    final lawgenColorScheme = const ColorScheme.light(
      primary: Color(0xFF7D6E63), // User bubble & Sign Up button
      onPrimary: Colors.white, // Text on user bubble
      surfaceContainerHighest: Color(
        0xFFEDEAE6,
      ), // AI bubble & input field fill
      onSurfaceVariant: Color(0xFF5C534D), // Text on AI bubble
      surface: Color(0xFFF9F6F2), // Main background
      onSurface: Color(0xFF5C534D), // Main text color
      secondary: Color(0xFF5C534D), // Icons and other accents
    );

    return MultiRepositoryProvider(
      providers: [...chatRepositoryProviders],
      child: MultiBlocProvider(
        providers: [
          ...chatBlocProviders,
          BlocProvider<AuthBloc>(
            create: (_) => di.sl<AuthBloc>()..add(AppStarted()),
          ),
        ],
        child: MaterialApp.router(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lawgenColorScheme,
            scaffoldBackgroundColor: lawgenColorScheme.background,
            appBarTheme: AppBarTheme(
              backgroundColor: lawgenColorScheme.background,
              foregroundColor: lawgenColorScheme
                  .onBackground, // For back button, menu icon, etc.
              elevation: 0,
              titleTextStyle: TextStyle(
                color: lawgenColorScheme.onBackground,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            // Style for buttons like 'New Chat'
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: lawgenColorScheme.primary,
                foregroundColor: lawgenColorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          routerConfig: router,
        ),
      ),
    );
  }
}

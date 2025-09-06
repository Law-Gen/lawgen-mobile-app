import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lawgen/features/onboarding_auth/presentation/bloc/auth_bloc.dart';
import 'package:lawgen/features/onboarding_auth/presentation/bloc/auth_event.dart';
import 'package:lawgen/features/onboarding_auth/presentation/bloc/auth_state.dart'; // Import AuthState

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

  // Init Hive & register adapters
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

  // MODIFIED: We need the full AppRouter instance, not just its router object.
  final appRouter = AppRouter();
  runApp(MyApp(appRouter: appRouter));
}

class MyApp extends StatelessWidget {
  // MODIFIED: Changed from GoRouter to the AppRouter class
  final AppRouter appRouter;
  const MyApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    final lawgenColorScheme = const ColorScheme.light(
      primary: Color(0xFF7D6E63),
      onPrimary: Colors.white,
      surfaceContainerHighest: Color(0xFFEDEAE6),
      onSurfaceVariant: Color(0xFF5C534D),
      surface: Color(0xFFF9F6F2),
      onSurface: Color(0xFF5C534D),
      secondary: Color(0xFF5C534D),
    );

    return MultiRepositoryProvider(
      providers: [...chatRepositoryProviders],
      child: MultiBlocProvider(
        providers: [
          ...chatBlocProviders,
          BlocProvider<AuthBloc>(
            // The AppStarted event is dispatched here to check auth status on startup.
            create: (_) => di.sl<AuthBloc>()..add(AppStarted()),
          ),
        ],
        // NEW: This BlocListener is the "bridge" between the AuthBloc and the AppRouter.
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            // When the BLoC's state changes, we update the router's ValueNotifier.
            // This will automatically trigger GoRouter's redirect logic.
            if (state is Authenticated) {
              appRouter.isAuthenticated.value = true;
            } else if (state is Unauthenticated || state is AuthError) {
              // Also treat errors as an unauthenticated state for routing safety.
              appRouter.isAuthenticated.value = false;
            }
          },
          child: MaterialApp.router(
            title: 'Flutter Demo',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: lawgenColorScheme,
              scaffoldBackgroundColor:
                  lawgenColorScheme.surface, // Corrected from .background
              appBarTheme: AppBarTheme(
                backgroundColor:
                    lawgenColorScheme.surface, // Corrected from .background
                foregroundColor:
                    lawgenColorScheme.onSurface, // Corrected from .onBackground
                elevation: 0,
                titleTextStyle: TextStyle(
                  color: lawgenColorScheme
                      .onSurface, // Corrected from .onBackground
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
            // MODIFIED: Get the router config from our AppRouter instance.
            routerConfig: appRouter.router,
          ),
        ),
      ),
    );
  }
}

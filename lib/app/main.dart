import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lawgen/features/onboarding_auth/presentation/bloc/auth_bloc.dart';
import 'package:lawgen/features/onboarding_auth/presentation/bloc/auth_event.dart';
import 'package:lawgen/features/onboarding_auth/presentation/bloc/auth_state.dart';

import '../features/LegalAidDirectory/injection_container.dart';
import '../features/catalog/catalog_injection.dart';
// Updated: Correctly points to the new dependency setup for chat.
import '../features/chat/chat_dependency.dart';
// Removed: Old Hive models are no longer part of the new chat feature.
// import '../features/chat/data/models/conversation_model.dart';
// import '../features/chat/data/models/message_model.dart';
import '../features/quize/quiz_injection.dart';
import 'dependency_injection.dart' as di;
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Hive
  await Hive.initFlutter();

  // Removed: The Hive adapters for ConversationModel and MessageModel are no longer
  // needed as the new chat feature does not use Hive for local storage.
  // Other app features can still register their adapters here.

  // Feature DI setup
  await di.init();
  await setupChatFeatureDependencies(); // This sets up the new chat feature's dependencies.
  await initLegalAid();
  await initQuiz();
  await initCatalog();

  final appRouter = AppRouter();
  runApp(MyApp(appRouter: appRouter));
}

class MyApp extends StatelessWidget {
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
      // The chatRepositoryProviders list is provided from your updated chat_dependency.dart
      providers: [...chatRepositoryProviders],
      child: MultiBlocProvider(
        providers: [
          // The chatBlocProviders list is also from your updated chat_dependency.dart
          ...chatBlocProviders,
          BlocProvider<AuthBloc>(
            create: (_) => di.sl<AuthBloc>()..add(AppStarted()),
          ),
        ],
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              appRouter.isAuthenticated.value = true;
            } else if (state is Unauthenticated || state is AuthError) {
              appRouter.isAuthenticated.value = false;
            }
          },
          child: MaterialApp.router(
            title: 'Flutter Demo',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: lawgenColorScheme,
              scaffoldBackgroundColor: lawgenColorScheme.surface,
              appBarTheme: AppBarTheme(
                backgroundColor: lawgenColorScheme.surface,
                foregroundColor: lawgenColorScheme.onSurface,
                elevation: 0,
                titleTextStyle: TextStyle(
                  color: lawgenColorScheme.onSurface,
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
            routerConfig: appRouter.router,
          ),
        ),
      ),
    );
  }
}

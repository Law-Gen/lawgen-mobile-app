// router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/LegalAidDirectory/presentation/pages/legal_aid_directory_page.dart';
import '../features/chat/presentation/pages/chat_page.dart';
import '../features/catalog/presentation/pages/legal_articles_page.dart';
import '../features/catalog/presentation/pages/legal_categories_page.dart';
import '../features/onboarding_auth/presentation/pages/forget_password_page.dart';
import '../features/onboarding_auth/presentation/pages/onboarding_page.dart';
import '../features/onboarding_auth/presentation/pages/otp_page.dart';
import '../features/onboarding_auth/presentation/pages/reset_password_page.dart';
import '../features/onboarding_auth/presentation/pages/sign_in_page.dart';
import '../features/onboarding_auth/presentation/pages/sign_up_page.dart';
import '../features/onboarding_auth/presentation/pages/success_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/quize/domain/entities/quize.dart';
import '../features/quize/presentation/pages/question_page.dart';
import '../features/quize/presentation/pages/quize_home_page.dart';
import '../features/quize/presentation/pages/quize_result_page.dart';

// --- Placeholder Screens (Keep as is) ---
class PlaceholderScreen extends StatelessWidget {
  final String title;
  final Widget? child;
  const PlaceholderScreen({super.key, required this.title, this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Screen: $title',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}

// --- Main App Shell with Bottom Navigation (Keep as is) ---
class MainAppShell extends StatelessWidget {
  final Widget child;
  const MainAppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(233, 238, 236, 231),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color.fromARGB(255, 155, 113, 87),
        elevation: 20,
        unselectedItemColor: const Color.fromARGB(121, 176, 149, 133),
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bubble_chart_outlined),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.my_library_books_outlined),
            label: 'Catalog',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Quizzes'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/chat')) return 0;
    if (location.startsWith('/topics')) return 1;
    if (location.startsWith('/quiz')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/chat');
        break;
      case 1:
        context.go('/topics');
        break;
      case 2:
        context.go('/quiz');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }
}

// --- GoRouter Configuration ---
class AppRouter {
  final ValueNotifier<bool> isAuthenticated = ValueNotifier(false);
  final ValueNotifier<bool> hasSeenOnboarding = ValueNotifier(false);

  AppRouter() {
    _loadOnboardingStatus();
  }

  Future<void> _loadOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    hasSeenOnboarding.value = prefs.getBool('hasSeenOnboarding') ?? false;
  }

  Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    hasSeenOnboarding.value = true;
  }

  late final GoRouter router = GoRouter(
    initialLocation: hasSeenOnboarding.value ? '/' : '/onboarding',
    refreshListenable: Listenable.merge([isAuthenticated, hasSeenOnboarding]),
    routes: [
      // --- Onboarding ---
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => OnboardingPage(router: this),
      ),

      // --- Authentication Routes ---
      GoRoute(path: '/signin', builder: (context, state) => const SignInPage()),
      GoRoute(path: '/signup', builder: (context, state) => const SignUpPage()),
      GoRoute(
        path: '/forgotpassword',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/otppage',
        builder: (context, state) {
          final email = state.extra as String?;
          return OtpPage(email: email ?? 'Error: No email provided');
        },
      ),
      GoRoute(
        path: '/successreset',
        builder: (context, state) => const SuccessResetPage(),
      ),
      GoRoute(
        path: '/resetpassword/:resetToken',
        builder: (context, state) =>
            ResetPasswordPage(resetToken: state.pathParameters['resetToken']!),
      ),

      // --- Guest/Anonymous Route ---
      GoRoute(
        path: '/',
        builder: (context, state) =>
            ChatPage(), // This is the non-shelled chat page for guests.
      ),

      // --- Logged-In User Routes with Bottom Navigation Shell ---
      ShellRoute(
        builder: (context, state, child) {
          return MainAppShell(child: child);
        },
        routes: [
          GoRoute(path: '/chat', builder: (context, state) => ChatPage()),
          GoRoute(
            path: '/topics',
            builder: (context, state) => LegalCategoriesPage.withBloc(),
            routes: [
              GoRoute(
                path: ':topicId',
                builder: (context, state) {
                  final categoryId = state.pathParameters['topicId']!;
                  final categoryName = state.extra as String;
                  return LegalArticlesPage.withBloc(
                    categoryId: categoryId,
                    categoryName: categoryName,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/quiz',
            builder: (context, state) => QuizHomePage.withBloc(),
            routes: [
              GoRoute(
                path: ':quizId',
                builder: (context, state) =>
                    QuizQuestionPage.withBloc(state.pathParameters['quizId']!),
                routes: [
                  GoRoute(
                    path: 'results',
                    builder: (context, state) {
                      final data = state.extra as Map<String, dynamic>;
                      final quiz = data['quiz'] as Quiz;
                      final userAnswers =
                          data['userAnswers'] as Map<String, String>;
                      return QuizResultPage(
                        quiz: quiz,
                        userAnswers: userAnswers,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),

      // --- Standalone Routes ---
      GoRoute(
        path: '/legal-aid',
        builder: (context, state) => LegalAidDirectoryPage.withBloc(),
      ),
    ],

    // --- Redirect Logic ---
    redirect: (context, state) {
      final bool seenOnboarding = hasSeenOnboarding.value;
      final bool loggedIn = isAuthenticated.value;
      final String location = state.uri.toString();

      final bool isOnboarding = location == '/onboarding';
      final bool isAuthenticating =
          location == '/signin' || location == '/signup';

      // 1. Onboarding Logic
      if (!seenOnboarding && !isOnboarding) {
        return '/onboarding';
      }
      if (seenOnboarding && isOnboarding) {
        // If they have seen onboarding and try to go there, send them to the root.
        return '/';
      }

      // ✅  THIS IS THE FIX
      // If the user is logged in and tries to go to the root guest page,
      // redirect them to the main authenticated page inside the shell.
      if (loggedIn && location == '/') {
        return '/chat';
      }

      // 2. Authentication Logic
      final isProtected =
          location.startsWith('/profile') || location.startsWith('/admin');
      if (!loggedIn && isProtected) {
        return '/signin';
      }

      if (loggedIn && isAuthenticating) {
        return '/chat';
      }

      if (!loggedIn && location == '/chat') {
        return '/signin';
      }

      // No redirect needed
      return null;
    },

    errorBuilder: (context, state) =>
        const PlaceholderScreen(title: '404 - Page Not Found'),
  );
}

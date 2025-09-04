import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/onboarding_auth/presentation/pages/forget_password_page.dart';
import '../features/onboarding_auth/presentation/pages/onboarding_page.dart';
import '../features/onboarding_auth/presentation/pages/otp_page.dart';
import '../features/onboarding_auth/presentation/pages/reset_password_page.dart';
import '../features/onboarding_auth/presentation/pages/sign_in_page.dart';
import '../features/onboarding_auth/presentation/pages/sign_up_page.dart';
import '../features/onboarding_auth/presentation/pages/success_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Placeholder Screens ---
// In your actual app, you would import your real screen widgets here.
// These are placeholders to make the router code runnable.
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

class MainAppShell extends StatelessWidget {
  final Widget child;
  const MainAppShell({super.key, required this.child});
  // In a real app, this would be your Scaffold with a BottomNavigationBar
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
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
  // Mock authentication state. In a real app, you would get this from your auth provider/state manager.
  final ValueNotifier<bool> isAuthenticated = ValueNotifier(false);
  // Change to `true` to test logged-in routes
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
  // Change to `true` to skip onboarding

  late final GoRouter router = GoRouter(
    initialLocation: '/onboarding',
    refreshListenable: hasSeenOnboarding,
    routes: [
      // --- Onboarding ---
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => OnboardingPage(router: this),
      ),

      // --- Authentication Routes ---
      GoRoute(path: '/signin', builder: (context, state) => SignInPage()),
      GoRoute(path: '/signup', builder: (context, state) => SignUpPage()),
      GoRoute(
        path: '/forgotpassword',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/otppage',
        builder: (context, state) => const OtpPage(email: 'email'),
      ),
      GoRoute(
        path: '/successreset',
        builder: (context, state) => const SuccessResetPage(),
      ),
      GoRoute(
        // Correcting the path to accept a parameter for the reset token
        path: '/resetpassword/:resetToken',
        builder: (context, state) =>
            ResetPasswordPage(resetToken: state.pathParameters['resetToken']!),
      ),

      // --- Guest/Anonymous Routes ---
      GoRoute(
        path: '/',
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Chat (Guest Mode)'),
      ),

      // --- Logged-In User Routes with Bottom Navigation Shell ---
      ShellRoute(
        builder: (context, state, child) {
          return MainAppShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/chat',
            builder: (context, state) =>
                const PlaceholderScreen(title: 'Chat (Logged-In)'),
          ),
          GoRoute(
            path: '/topics',
            builder: (context, state) =>
                const PlaceholderScreen(title: 'Legal Topics'),
            routes: [
              // Nested route for topic details
              GoRoute(
                path: ':topicId', // e.g., /topics/family-law
                builder: (context, state) => PlaceholderScreen(
                  title: 'Topic Detail: ${state.pathParameters['topicId']}',
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/quiz',
            builder: (context, state) =>
                const PlaceholderScreen(title: 'Quiz Home'),
            routes: [
              // Nested route for a specific quiz
              GoRoute(
                path: ':quizId', // e.g., /quiz/employment-law-quiz
                builder: (context, state) => PlaceholderScreen(
                  title: 'Quiz Questions: ${state.pathParameters['quizId']}',
                ),
                routes: [
                  // Nested route for quiz results
                  GoRoute(
                    path: 'results', // e.g., /quiz/employment-law-quiz/results
                    builder: (context, state) => PlaceholderScreen(
                      title: 'Quiz Results: ${state.pathParameters['quizId']}',
                    ),
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

      // --- Standalone Routes (Without Bottom Navigation) ---
      GoRoute(
        path: '/legal-aid',
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Legal Aid Directory'),
      ),
      GoRoute(
        path: '/subscriptions',
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Subscription Plans'),
      ),

      // --- Admin Panel Routes (Could have its own ShellRoute) ---
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Admin Dashboard'),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Admin User Management'),
      ),
      GoRoute(
        path: '/admin/quizzes',
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Admin Quizzes'),
      ),
      GoRoute(
        path: '/admin/content',
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Admin Content Management'),
      ),
    ],

    // --- Redirect Logic ---
    redirect: (context, state) {
      final bool isLoggingIn =
          state.uri.toString() == '/signin' ||
          state.uri.toString() == '/signup';
      //final bool isOnboarding = state.uri.toString() == '/onboarding';

      // If the user hasn't seen onboarding, redirect them there first.
      final isOnboarding = state.uri.toString() == '/onboarding';
      if (!hasSeenOnboarding.value && !isOnboarding) {
        return '/onboarding';
      }
      if (hasSeenOnboarding.value && isOnboarding) {
        return isAuthenticated.value ? '/chat' : '/';
      }

      // If the user is not authenticated and is trying to access a protected route,
      // redirect them to the sign-in page.
      final isProtected =
          state.uri.toString().startsWith('/chat') ||
          state.uri.toString().startsWith('/profile') ||
          state.uri.toString().startsWith('/admin');

      // if (!isAuthenticated && isProtected) {
      //   return '/signin';
      // }

      // // If the user is already authenticated and tries to go to the sign-in/sign-up page,
      // // redirect them to the logged-in chat screen.
      // if (isAuthenticated && isLoggingIn) {
      //   return '/chat';
      // }

      // No redirect needed.
      return null;
    },

    // --- Error Handling ---
    errorBuilder: (context, state) =>
        const PlaceholderScreen(title: '404 - Page Not Found'),
  );
}

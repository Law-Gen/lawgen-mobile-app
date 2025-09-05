import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/chat/presentation/pages/chat_page.dart';

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
        backgroundColor: Color.fromARGB(233, 238, 236, 231),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color.fromARGB(255, 155, 113, 87),
        elevation: 20,
        unselectedItemColor: Color.fromARGB(121, 176, 149, 133),
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
  // Mock authentication state. In a real app, you would get this from your auth provider/state manager.
  final bool isAuthenticated =
      true; // Change to `true` to test logged-in routes
  final bool hasSeenOnboarding = true; // Change to `true` to skip onboarding

  late final GoRouter router = GoRouter(
    initialLocation: '/onboarding',
    routes: [
      // --- Onboarding ---
      GoRoute(
        path: '/onboarding',
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Onboarding & Consent'),
      ),

      // --- Authentication Routes ---
      GoRoute(
        path: '/signin',
        builder: (context, state) => const PlaceholderScreen(title: 'Sign In'),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const PlaceholderScreen(title: 'Sign Up'),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Forgot Password'),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Reset Password'),
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
          GoRoute(path: '/chat', builder: (context, state) => ChatPage()),
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
            builder: (context, state) =>
                const PlaceholderScreen(title: 'Profile'),
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
    redirect: (BuildContext context, GoRouterState state) {
      final bool isLoggingIn =
          state.uri.toString() == '/signin' ||
          state.uri.toString() == '/signup';
      final bool isOnboarding = state.uri.toString() == '/onboarding';

      // If the user hasn't seen onboarding, redirect them there first.
      if (!hasSeenOnboarding && !isOnboarding) {
        return '/onboarding';
      }

      // If the user is on the onboarding screen but has already seen it, send them to the right home page.
      if (hasSeenOnboarding && isOnboarding) {
        return isAuthenticated ? '/chat' : '/';
      }

      // If the user is not authenticated and is trying to access a protected route,
      // redirect them to the sign-in page.
      final isProtected =
          state.uri.toString().startsWith('/chat') ||
          state.uri.toString().startsWith('/profile') ||
          state.uri.toString().startsWith('/admin');

      if (!isAuthenticated && isProtected) {
        return '/signin';
      }

      // If the user is already authenticated and tries to go to the sign-in/sign-up page,
      // redirect them to the logged-in chat screen.
      if (isAuthenticated && isLoggingIn) {
        return '/chat';
      }

      // No redirect needed.
      return null;
    },

    // --- Error Handling ---
    errorBuilder: (context, state) =>
        const PlaceholderScreen(title: '404 - Page Not Found'),
  );
}

// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../features/onboarding_auth/presentation/pages/forget_password_page.dart';
// import '../features/onboarding_auth/presentation/pages/onboarding_page.dart';
// import '../features/onboarding_auth/presentation/pages/otp_page.dart';
// import '../features/onboarding_auth/presentation/pages/reset_password_page.dart';
// import '../features/onboarding_auth/presentation/pages/sign_in_page.dart';
// import '../features/onboarding_auth/presentation/pages/sign_up_page.dart';
// import '../features/onboarding_auth/presentation/pages/success_page.dart';

// class PlaceholderScreen extends StatelessWidget {
//   final String title;
//   final Widget? child;
//   const PlaceholderScreen({super.key, required this.title, this.child});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(title)),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Screen: $title',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//             if (child != null) child!,
//           ],
//         ),
//       ),
//     );
//   }
// }

// class MainAppShell extends StatelessWidget {
//   final Widget child;
//   const MainAppShell({super.key, required this.child});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: child,
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _calculateSelectedIndex(context),
//         onTap: (index) => _onItemTapped(index, context),
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.category),
//             label: 'Categories',
//           ),
//           BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Quizzes'),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
//         ],
//       ),
//     );
//   }

//   int _calculateSelectedIndex(BuildContext context) {
//     final String location = GoRouterState.of(context).uri.toString();
//     if (location.startsWith('/chat')) return 0;
//     if (location.startsWith('/topics')) return 1;
//     if (location.startsWith('/quiz')) return 2;
//     if (location.startsWith('/profile')) return 3;
//     return 0;
//   }

//   void _onItemTapped(int index, BuildContext context) {
//     switch (index) {
//       case 0:
//         context.go('/chat');
//         break;
//       case 1:
//         context.go('/topics');
//         break;
//       case 2:
//         context.go('/quiz');
//         break;
//       case 3:
//         context.go('/profile');
//         break;
//     }
//   }
// }

// // --- Router with SharedPreferences for onboarding ---
// class AppRouter {
//   final ValueNotifier<bool> isAuthenticated = ValueNotifier(false);
//   final ValueNotifier<bool> hasSeenOnboarding = ValueNotifier(false);

//   AppRouter() {
//     _loadOnboardingStatus();
//   }

//   Future<void> _loadOnboardingStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//     hasSeenOnboarding.value = prefs.getBool('hasSeenOnboarding') ?? false;
//   }

//   Future<void> setOnboardingSeen() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('hasSeenOnboarding', true);
//     hasSeenOnboarding.value = true;
//   }

//   late final GoRouter router = GoRouter(
//     initialLocation: '/onboarding',
//     refreshListenable: hasSeenOnboarding,
//     routes: [
//       GoRoute(
//         path: '/onboarding',
//         builder: (context, state) => OnboardingPage(router: this),
//       ),
//       GoRoute(path: '/signin', builder: (context, state) => SignInPage()),
//       GoRoute(path: '/signup', builder: (context, state) => SignUpPage()),
//       GoRoute(
//         path: '/forgotpassword',
//         builder: (context, state) => const ForgotPasswordPage(),
//       ),
//       GoRoute(
//         path: '/otppage',
//         builder: (context, state) => const OtpPage(email: 'email'),
//       ),
//       GoRoute(
//         path: '/successreset',
//         builder: (context, state) => const SuccessResetPage(),
//       ),
//       GoRoute(
//         path: '/resetpassword/:resetToken',
//         builder: (context, state) =>
//             ResetPasswordPage(resetToken: state.pathParameters['resetToken']!),
//       ),
//       GoRoute(
//         path: '/',
//         builder: (context, state) =>
//             const PlaceholderScreen(title: 'Chat (Guest Mode)'),
//       ),
//       ShellRoute(
//         builder: (context, state, child) => MainAppShell(child: child),
//         routes: [
//           GoRoute(
//             path: '/chat',
//             builder: (context, state) =>
//                 const PlaceholderScreen(title: 'Chat (Logged-In)'),
//           ),
//           GoRoute(
//             path: '/topics',
//             builder: (context, state) =>
//                 const PlaceholderScreen(title: 'Legal Topics'),
//             routes: [
//               GoRoute(
//                 path: ':topicId',
//                 builder: (context, state) => PlaceholderScreen(
//                   title: 'Topic Detail: ${state.pathParameters['topicId']}',
//                 ),
//               ),
//             ],
//           ),
//           GoRoute(
//             path: '/quiz',
//             builder: (context, state) =>
//                 const PlaceholderScreen(title: 'Quiz Home'),
//             routes: [
//               GoRoute(
//                 path: ':quizId',
//                 builder: (context, state) => PlaceholderScreen(
//                   title: 'Quiz Questions: ${state.pathParameters['quizId']}',
//                 ),
//                 routes: [
//                   GoRoute(
//                     path: 'results',
//                     builder: (context, state) => PlaceholderScreen(
//                       title: 'Quiz Results: ${state.pathParameters['quizId']}',
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           GoRoute(
//             path: '/profile',
//             builder: (context, state) =>
//                 const PlaceholderScreen(title: 'Profile'),
//           ),
//         ],
//       ),
//     ],
//     redirect: (context, state) {
//       final isOnboarding = state.uri.toString() == '/onboarding';
//       if (!hasSeenOnboarding.value && !isOnboarding) {
//         return '/onboarding';
//       }
//       if (hasSeenOnboarding.value && isOnboarding) {
//         return isAuthenticated.value ? '/chat' : '/';
//       }
//       return null;
//     },
//     errorBuilder: (context, state) =>
//         const PlaceholderScreen(title: '404 - Page Not Found'),
//   );
// }


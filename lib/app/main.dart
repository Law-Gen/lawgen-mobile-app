import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/quize/quiz_injection.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initQuiz(); // Initialize your quiz dependencies
  final approuter = AppRouter();

  runApp(MyApp(router: approuter.router));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.router});
  final GoRouter router;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return (MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: router,
      // routeInformationParser: router.routeInformationParser,
    ));
  }
}

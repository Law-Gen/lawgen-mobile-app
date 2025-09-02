// lib/main.dart
import 'package:flutter/material.dart';
import 'dependency_injection.dart' as di; // Import the dependency injector
import 'features/profile_and_premium/presentation/pages/plans_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  di.init(); // Initialize all the dependencies
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Subscription App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // We start the app at the PlansPage for this feature
      home: const PlansPage(),
    );
  }
}

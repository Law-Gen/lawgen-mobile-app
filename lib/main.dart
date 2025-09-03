import 'core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'dependency_injection.dart' as di;
import 'features/profile_and_premium/presentation/pages/plans_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LawGen',
      theme: AppTheme.lightTheme, // <-- Apply your custom theme here
      home: const PlansPage(),
    );
  }
}

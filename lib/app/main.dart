import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'router.dart';
import 'dependency_injection.dart' as di;
import 'package:lawgen/features/onboarding_auth/presentation/bloc/auth_bloc.dart';
import 'package:lawgen/features/onboarding_auth/presentation/bloc/auth_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AppRouter appRouter = AppRouter();

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>()..add(AppStarted()),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'LawGen',
        theme: ThemeData(primarySwatch: Colors.blue),
        routerConfig: appRouter.router,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'router.dart';

void main() {
  final approuter = AppRouter();

  runApp( MyApp(router:approuter.router));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.router});
  final GoRouter router;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return (MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: router,
      // routeInformationParser: router.routeInformationParser,
    ));
  }
}



import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:luminarawebsite/routes.dart';
import 'controllers/login_controller/loginController.dart';
import 'controllers/session_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginController()),

        // Add more controllers if needed
      ],
      child: MaterialApp.router(
        title: 'Luminara Mental Health App',
        routerConfig: router,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

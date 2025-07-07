import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luminarawebsite/utils/constants/colors.dart';
import 'package:provider/provider.dart';
import 'package:luminarawebsite/routes.dart';
import 'controllers/login_controller/loginController.dart';
import 'controllers/session_controller.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        routerDelegate: router.routerDelegate,
        routeInformationParser: router.routeInformationParser,
        routeInformationProvider: router.routeInformationProvider,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: MyColors.color1),
          textTheme: GoogleFonts.merriweatherTextTheme(),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

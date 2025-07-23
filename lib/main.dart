import 'package:dynamic_path_url_strategy/dynamic_path_url_strategy.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luminarawebsite/providers/userProvider.dart';
import 'package:luminarawebsite/utils/constants/colors.dart';
import 'package:provider/provider.dart';
import 'package:luminarawebsite/routes.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'controllers/login_controller/loginController.dart';
import 'controllers/session_controller.dart';
import 'firebase_options.dart';



void main() async {
  setPathUrlStrategy();


  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await GetStorage.init(); // <-- Required
  // Keep screen awake
  await WakelockPlus.enable();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginController()),
        ChangeNotifierProvider(create: (_) => UserProvider()..loadUserData()),

        // Add more controllers if needed
      ],
      child: MaterialApp.router(
        title: 'Luminara Mental Health App',
        routerDelegate: router.routerDelegate,
        routeInformationParser: router.routeInformationParser,
        routeInformationProvider: router.routeInformationProvider,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: MyColors.color2),
          textTheme: GoogleFonts.merriweatherTextTheme(),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

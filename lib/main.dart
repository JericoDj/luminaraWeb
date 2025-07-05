import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:luminarawebsite/screens/homePage.dart';

import 'controllers/login_controller/loginController.dart';
import 'controllers/session_controller.dart';

void main() {

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Get.lazyPut(()=>SessionController());
    Get.lazyPut(()=>LoginController());
    return GetMaterialApp(

      title: 'Luminara Mental Health App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),

      ),
      debugShowCheckedModeBanner: false,
      home: Homepage(),
    );
  }
}

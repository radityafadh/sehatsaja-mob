import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/pages/splash_page.dart';
import 'package:frontend/pages/sign_in_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SehatSaja Health Application',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const SplashPage()),
        GetPage(name: '/sign-in', page: () => SignInPage()),
      ],
    );
  }
}

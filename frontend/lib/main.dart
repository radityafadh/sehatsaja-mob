import 'package:flutter/material.dart';
import 'package:frontend/pages/medicine_pick_page.dart';
import 'package:get/get.dart';
import 'package:frontend/pages/splash_page.dart';
import 'package:frontend/pages/sign_in_page.dart';
import 'package:frontend/pages/sign_up_page.dart';
import 'package:frontend/pages/home_page.dart';
import 'package:frontend/pages/medicine_detail_page.dart';
import 'package:frontend/pages/news_detail_page.dart';
import 'package:frontend/pages/medicine_add_page.dart';
import 'package:frontend/pages/pick_doctor_page.dart';
import 'package:frontend/pages/detail_doctor_page.dart';
import 'package:frontend/pages/setting_page.dart';

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
        GetPage(name: '/sign-up', page: () => SignUpPage()),
        GetPage(name: '/home', page: () => HomePage()),
        GetPage(name: '/detail-medicine', page: () => MedicineDetailPage()),
        GetPage(name: '/pick-medicine', page: () => MedicinePickPage()),
        GetPage(name: '/add-medicine', page: () => MedicineAddPage()),
        GetPage(name: '/detail-news', page: () => NewsDetailPage()),
        GetPage(name: '/pick-doctor', page: () => PickDoctorPage()),
        GetPage(name: '/detail-doctor', page: () => DetailDoctorPage()),
        GetPage(name: '/setting', page: () => SettingPage()),
      ],
    );
  }
}

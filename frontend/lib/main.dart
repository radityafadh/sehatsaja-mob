import 'package:flutter/material.dart';
import 'package:frontend/pages/User/medicine_pick_page.dart';
import 'package:get/get.dart';
import 'package:frontend/pages/pages.dart';

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
        GetPage(name: '/article-history', page: () => ArticleHistoryPage()),
        GetPage(
          name: '/transaction-history',
          page: () => TransactionHistoryPage(),
        ),
        GetPage(name: '/detail-transaction', page: () => DetailPaymentPage()),
        GetPage(name: '/payment-method', page: () => PaymentMethodPage()),
        GetPage(name: '/forget-password', page: () => ForgetPasswordPage()),
        GetPage(name: '/rename-password', page: () => RenamePasswordPage()),
        GetPage(
          name: '/detail-transaction-2',
          page: () => DetailPaymentPage2(),
        ),
        GetPage(name: '/profile', page: () => ProfilePage()),
        GetPage(name: '/medical-article', page: () => MedicalArticlePage()),
        GetPage(name: '/chat', page: () => ChatPage()),
        GetPage(name: '/chatroom', page: () => ChatRoomPage()),
        GetPage(name: '/map-screen', page: () => MapScreen()),
        GetPage(name: '/home-hoctor', page: () => HomePageDoctor()),
        GetPage(name: '/E-money', page: () => EMoneyPage()),
        GetPage(name: '/nomor-rekening', page: () => EmoneyRekening()),
        GetPage(
          name: '/payment-method-emoney',
          page: () => PaymentMethodEmoneyPage(),
        ),
        GetPage(name: '/chat-doctor', page: () => ChatPageDoctor()),
        GetPage(
          name: '/pick-medicine-doctor',
          page: () => MedicinePickPageDoctor(),
        ),
        GetPage(name: '/chatroom-doctor', page: () => ChatRoomPageDoctor()),
        GetPage(
          name: '/detail-doctor-doctor',
          page: () => ChatRoomPageDoctor(),
        ),
      ],
    );
  }
}

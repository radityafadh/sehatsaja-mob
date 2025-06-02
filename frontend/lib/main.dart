import 'package:flutter/material.dart';
import 'package:frontend/pages/User/medicine_pick_page.dart';
import 'package:get/get.dart';
import 'package:frontend/pages/pages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:intl/intl.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }

  AppointmentStatusWatcher.initialize();

  runApp(MyApp());
}

class AppointmentStatusWatcher {
  static Timer? _timer;

  static void initialize() {
    // Cancel any existing timer
    _timer?.cancel();

    // Create a new periodic timer that runs every 2 minutes
    _timer = Timer.periodic(Duration(minutes: 2), (_) {
      _checkAppointments();
    });

    // Also run immediately on app start
    _checkAppointments();
  }

  static Future<void> _checkAppointments() async {
    print('[Watcher] Checking appointments...');

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('[Watcher] No user logged in. Skipping check.');
        return;
      }

      final now = DateTime.now();
      final todayString = DateFormat('yyyy-MM-dd').format(now);
      final currentTime = now;

      print('[Watcher] Current time: $currentTime');
      print('[Watcher] Today (String): $todayString');

      final patientQuery =
          FirebaseFirestore.instance
              .collection('appointments')
              .where('patientId', isEqualTo: user.uid)
              .where('status', whereIn: ['confirmed', 'waiting'])
              .where('appointmentDate', isLessThanOrEqualTo: todayString)
              .get();

      final doctorQuery =
          FirebaseFirestore.instance
              .collection('appointments')
              .where('doctorId', isEqualTo: user.uid)
              .where('status', whereIn: ['confirmed', 'waiting'])
              .where('appointmentDate', isLessThanOrEqualTo: todayString)
              .get();

      final results = await Future.wait([patientQuery, doctorQuery]);
      final allDocs = [...results[0].docs, ...results[1].docs];

      print('[Watcher] Found ${allDocs.length} total appointments.');

      final batch = FirebaseFirestore.instance.batch();
      bool hasUpdates = false;

      for (final doc in allDocs) {
        final data = doc.data();
        print('\n[Watcher] Checking appointment ${doc.id}...');
        print('[Watcher] Appointment data: $data');

        final appointmentDate = data['appointmentDate'];
        final timeRange = data['appointmentTime'] as String? ?? '';

        if (appointmentDate != todayString) {
          print('[Watcher] Appointment is not today. Skipping.');
          continue;
        }

        DateTime? endDateTime;

        try {
          if (timeRange.contains('-')) {
            final times = timeRange.split('-');
            if (times.length != 2) {
              print('[Watcher] Invalid time range format. Skipping.');
              continue;
            }

            final endTimeStr = times[1].trim();
            final endTime = DateFormat('HH:mm').parse(endTimeStr);
            endDateTime = DateTime(
              currentTime.year,
              currentTime.month,
              currentTime.day,
              endTime.hour,
              endTime.minute,
            );
          } else {
            // Fallback: assume it's a single start time, add 30 mins
            final startTime = DateFormat('HH:mm').parse(timeRange.trim());
            endDateTime = DateTime(
              currentTime.year,
              currentTime.month,
              currentTime.day,
              startTime.hour,
              startTime.minute,
            ).add(Duration(minutes: 30));
          }

          final endDateTimePlus30 = endDateTime.add(Duration(minutes: 30));
          print('[Watcher] Calculated end time: $endDateTimePlus30');

          if (currentTime.isAfter(endDateTimePlus30)) {
            final newStatus =
                data['status'] == 'confirmed' ? 'completed' : 'cancelled';
            print(
              '[Watcher] Appointment ${doc.id} is overdue. Updating status to $newStatus.',
            );

            batch.update(doc.reference, {
              'status': newStatus,
              'updatedAt': FieldValue.serverTimestamp(),
            });
            hasUpdates = true;
          } else {
            print('[Watcher] Appointment ${doc.id} is not overdue. Skipping.');
          }
        } catch (e) {
          print('[Watcher] Error parsing time for appointment ${doc.id}: $e');
          continue;
        }
      }

      if (hasUpdates) {
        await batch.commit();
        print('[Watcher] Batch update committed.');
      } else {
        print('[Watcher] No updates to commit.');
      }
    } catch (e) {
      print('[Watcher] Error during appointment check: $e');
    }
  }
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
        GetPage(
          name: '/detail-medicine',
          page: () => MedicineDetailPage(uid: '', docId: ''),
        ),
        GetPage(name: '/pick-medicine', page: () => MedicinePickPage()),
        GetPage(name: '/add-medicine', page: () => MedicineAddPage()),
        GetPage(name: '/detail-news', page: () => NewsDetailPage(newsId: '')),
        GetPage(name: '/pick-doctor', page: () => PickDoctorPage()),
        GetPage(name: '/detail-doctor', page: () => DetailDoctorPage(uid: '')),
        GetPage(name: '/setting', page: () => SettingPage()),
        GetPage(
          name: '/transaction-history',
          page: () => TransactionHistoryPage(),
        ),
        GetPage(
          name: '/detail-transaction',
          page: () => DetailPaymentPage(appointmentId: ''),
        ),
        GetPage(name: '/forget-password', page: () => ForgetPasswordPage()),
        GetPage(name: '/rename-password', page: () => RenamePasswordPage()),
        GetPage(
          name: '/detail-transaction-2',
          page: () => DetailPaymentPage2(appointmentId: ''),
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
        GetPage(name: '/chatroom-doctor', page: () => ChatRoomPageDoctor()),
        GetPage(
          name: '/detail-doctor-doctor',
          page: () => ChatRoomPageDoctor(),
        ),
      ],
    );
  }
}

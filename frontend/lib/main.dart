import 'package:flutter/material.dart';
import 'package:frontend/pages/User/medicine_pick_page.dart';
import 'package:get/get.dart';
import 'package:frontend/pages/pages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/shared/notification_service.dart';
import 'firebase_options.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:workmanager/workmanager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('[MAIN] App starting');

  try {
    // 1. Initialize Firebase
    debugPrint('[FIREBASE] Initializing...');
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('[FIREBASE] ✅ Success');
    } catch (e) {
      if (!e.toString().contains('already exists')) rethrow;
      debugPrint('[FIREBASE] Already initialized');
    }

    // 2. Initialize NotificationService
    debugPrint('[NOTIFICATION_SERVICE] Initializing...');
    final notificationService = await Get.putAsync(
      () => NotificationService().initialize(),
    );
    debugPrint('[NOTIFICATION_SERVICE] ✅ Success');

    // 3. Request permissions if needed
    if (!await notificationService.hasPermission()) {
      debugPrint('[PERMISSION] Requesting notification permission...');
      await notificationService.requestPermissions();
    }

    // 4. Initialize ReminderSystem first
    debugPrint('[REMINDER_SYSTEM] Initializing...');
    Get.put(ReminderSystem());
    debugPrint('[REMINDER_SYSTEM] ✅ Success');

    // 5. Initialize Workmanager
    debugPrint('[WORKMANAGER] Initializing...');
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
    debugPrint('[WORKMANAGER] ✅ Success');

    // 6. Initialize other services
    debugPrint('[APPOINTMENT_WATCHER] Initializing...');
    AppointmentStatusWatcher.initialize();
    debugPrint('[APPOINTMENT_WATCHER] ✅ Success');

    // 7. Initialize background service last
    debugPrint('[BACKGROUND_SERVICE] Initializing...');
    await initializeBackgroundService();
    WidgetsBinding.instance.addObserver(AppLifecycleObserver());
    debugPrint('[BACKGROUND_SERVICE] ✅ Success');

    debugPrint('[MAIN] ✅ All services initialized');
    runApp(const MyApp());
  } catch (e, stack) {
    debugPrint('[MAIN] ❌ FATAL ERROR: $e');
    debugPrint(stack.toString());
    // Consider showing an error UI or retry mechanism
  }
}

Future<void> _showPermissionDialog(NotificationService service) async {
  bool? result = await Get.dialog<bool>(
    AlertDialog(
      title: Text('Izin Notifikasi'),
      content: Text('Aktifkan notifikasi untuk mendapatkan pengingat penting.'),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text('Nanti'),
        ),
        TextButton(
          onPressed: () => Get.back(result: true),
          child: Text('Izinkan'),
        ),
      ],
    ),
  );

  if (result == true) {
    await service.requestPermissions();
  }
}

class AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _verifyBackgroundService();
    }
  }

  Future<void> _verifyBackgroundService() async {
    // Perbaikan: Gunakan service instance dengan benar
    final service = FlutterBackgroundService();
    final isRunning = await service.isRunning();
  }
}

class AppointmentStatusWatcher {
  static Timer? _timer;

  static void initialize() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 2), (_) {
      _checkAppointments();
    });
    _checkAppointments();
  }

  static void dispose() {
    _timer?.cancel();
    _timer = null;
  }

  static Future<void> _checkAppointments() async {
    debugPrint('\n[Watcher] ========== START checking appointments ==========');

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('[Watcher] No user logged in. Skipping check.');
        return;
      }

      final now = DateTime.now();
      final todayString = DateFormat('yyyy-MM-dd').format(now);

      debugPrint('[Watcher] Current time: $now');
      debugPrint('[Watcher] Today (String): $todayString');

      final patientQuery =
          FirebaseFirestore.instance
              .collection('appointments')
              .where('patientId', isEqualTo: user.uid)
              .where('status', whereIn: ['confirmed', 'waiting'])
              .get();

      final doctorQuery =
          FirebaseFirestore.instance
              .collection('appointments')
              .where('doctorId', isEqualTo: user.uid)
              .where('status', whereIn: ['confirmed', 'waiting'])
              .get();

      final results = await Future.wait([patientQuery, doctorQuery]);
      final allDocs = [...results[0].docs, ...results[1].docs];

      debugPrint('[Watcher] Found ${allDocs.length} total appointments.');

      final batch = FirebaseFirestore.instance.batch();
      bool hasUpdates = false;

      for (final doc in allDocs) {
        final data = doc.data();
        debugPrint('\n[Watcher] ---- Checking appointment ${doc.id} ----');
        debugPrint('[Watcher] Data: $data');

        final appointmentDateStr = data['appointmentDate'] as String?;
        final appointmentTimeStr = data['appointmentTime'] as String?;

        if (appointmentDateStr == null) {
          debugPrint('[Watcher] Missing appointment date. Skipping.');
          continue;
        }

        try {
          final appointmentDate = DateFormat(
            'yyyy-MM-dd',
          ).parse(appointmentDateStr);
          final isBeforeToday = appointmentDate.isBefore(
            DateTime(now.year, now.month, now.day),
          );

          if (isBeforeToday) {
            final newStatus =
                data['status'] == 'confirmed' ? 'completed' : 'cancelled';

            debugPrint('[Watcher] Appointment date is BEFORE today.');
            debugPrint('[Watcher] Updating status to "$newStatus".');

            batch.update(doc.reference, {
              'status': newStatus,
              'updatedAt': FieldValue.serverTimestamp(),
            });
            hasUpdates = true;
            continue;
          }

          // Only process today's appointment with time
          if (appointmentDateStr == todayString && appointmentTimeStr != null) {
            final startTime = DateFormat(
              'HH:mm',
            ).parse(appointmentTimeStr.trim());

            final startDateTime = DateTime(
              now.year,
              now.month,
              now.day,
              startTime.hour,
              startTime.minute,
            );

            final endDateTime = startDateTime.add(const Duration(minutes: 30));

            debugPrint('[Watcher] Start time: $startDateTime');
            debugPrint('[Watcher] End time (+30 min): $endDateTime');

            if (now.isAfter(endDateTime)) {
              final newStatus =
                  data['status'] == 'confirmed' ? 'completed' : 'cancelled';
              debugPrint(
                '[Watcher] Current time is AFTER end time. Updating status to "$newStatus".',
              );

              batch.update(doc.reference, {
                'status': newStatus,
                'updatedAt': FieldValue.serverTimestamp(),
              });
              hasUpdates = true;
            } else {
              debugPrint('[Watcher] Appointment still active.');
            }
          } else {
            debugPrint(
              '[Watcher] Not today or missing time. Skipping time check.',
            );
          }
        } catch (e) {
          debugPrint('[Watcher] Error parsing date/time: $e');
        }
      }

      if (hasUpdates) {
        await batch.commit();
        debugPrint('[Watcher] ✅ Batch update committed.');
      } else {
        debugPrint('[Watcher] ❌ No updates to commit.');
      }
    } catch (e) {
      debugPrint('[Watcher] ❗ Error during appointment check: $e');
    }

    debugPrint('[Watcher] ========== END checking appointments ==========\n');
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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:workmanager/workmanager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // Add this import

class NotificationService extends GetxService {
  static NotificationService get to => Get.find<NotificationService>();
  late FlutterLocalNotificationsPlugin _notifications;
  bool _isInitialized = false;

  Future<NotificationService> initialize() async {
    if (_isInitialized) return this;
    WidgetsFlutterBinding.ensureInitialized();
    _notifications = FlutterLocalNotificationsPlugin();

    try {
      tz.initializeTimeZones();
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      throw e;
    }

    try {
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      await _notifications.initialize(
        InitializationSettings(android: androidSettings, iOS: iosSettings),
      );

      _isInitialized = true;
    } catch (e) {
      throw e;
    }

    await _createNotificationChannels();
    return this;
  }

  Future<bool> hasPermission() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final status = await Permission.notification.status;
        return status.isGranted;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _createNotificationChannels() async {
    try {
      const channel = AndroidNotificationChannel(
        'reminder_channel',
        'Reminders',
        importance: Importance.high,
        description: 'Channel untuk pengingat',
      );

      await _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    } catch (e) {
      throw e;
    }
  }

  Future<void> showCleanNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_isInitialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      importance: Importance.high,
      priority: Priority.defaultPriority,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.show(id, title, body, platformDetails);
    } catch (e) {
      throw e;
    }
  }

  Future<bool> requestPermissions() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        var status = await Permission.notification.status;
        if (status.isPermanentlyDenied) {
          try {
            await openAppSettings();
          } catch (e) {
            return false;
          }
          return false;
        }
        status = await Permission.notification.request();
        return status.isGranted;
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}

class ReminderSystem extends GetxService {
  static ReminderSystem get to => Get.find<ReminderSystem>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initializeForUser(String userId) async {
    try {
      final hasPermission = await NotificationService.to.hasPermission();
      if (!hasPermission) {
        throw 'Notification permission not granted';
      }

      await initializeBackgroundService();
      await _cleanupOldSchedules(userId);
      await _syncReminders(userId);

      await Workmanager().registerPeriodicTask(
        'reminderSync_$userId',
        'reminderSyncTask',
        frequency: Duration(minutes: 15),
        constraints: Constraints(networkType: NetworkType.connected),
        inputData: {'userId': userId},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> manualSync(String userId) async {
    try {
      await _syncReminders(userId);
    } catch (e, stack) {
      rethrow;
    }
  }

  Future<void> _syncReminders(String userId) async {
    try {
      await _deleteAllScheduledReminders(userId);
      await _syncAppointments(userId);
      await _syncMedicines(userId);
    } catch (e, stack) {
      rethrow;
    }
  }

  Future<void> _deleteAllScheduledReminders(String userId) async {
    try {
      final reminders =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('scheduledReminders')
              .get();

      final batch = _firestore.batch();
      for (var doc in reminders.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      await Workmanager().cancelByTag('exactReminder_$userId');
    } catch (e) {
      throw e;
    }
  }

  Future<void> _cleanupOldSchedules(String userId) async {
    try {
      final now = DateTime.now();
      final oldReminders =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('scheduledReminders')
              .where('triggerTime', isLessThan: now)
              .get();

      final batch = _firestore.batch();
      for (var doc in oldReminders.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e, stack) {
      throw e;
    }
  }

  Future<void> _syncAppointments(String userId) async {
    try {
      final now = DateTime.now();

      final patientQuery =
          await _firestore
              .collection('appointments')
              .where('status', isEqualTo: 'confirmed')
              .where('patientId', isEqualTo: userId)
              .get();

      final doctorQuery =
          await _firestore
              .collection('appointments')
              .where('status', isEqualTo: 'confirmed')
              .where('doctorId', isEqualTo: userId)
              .get();

      final allAppointments = [...patientQuery.docs, ...doctorQuery.docs];

      for (var doc in allAppointments) {
        final data = doc.data();
        final appointmentTime = _parseAppointmentTime(
          data['appointmentDate'],
          data['appointmentTime'],
        );

        if (appointmentTime.isAfter(now)) {
          await _scheduleExactReminder(
            userId: userId,
            reminderId: 'appt_${doc.id}',
            triggerTime: appointmentTime,
            description: data['complaint'] ?? 'Appointment reminder',
            type: 'appointment',
            additionalData: {
              'doctorName': data['doctorName'],
              'patientName': data['patientName'],
              'specialization': data['doctorSpecialization'],
            },
          );
        }
      }
    } catch (e, stack) {
      rethrow;
    }
  }

  Future<void> _syncMedicines(String userId) async {
    try {
      final medicines =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('medicines')
              .get();

      final now = DateTime.now();

      for (var doc in medicines.docs) {
        final data = doc.data();
        final startDateStr = data['startDate'] as String?;
        final endDateStr = data['endDate'] as String?;
        final schedules = data['schedule'] as List<dynamic>?;
        final description =
            data['description'] as String? ?? 'Medicine Reminder';

        if (startDateStr == null || endDateStr == null || schedules == null) {
          continue;
        }

        final startDate = DateTime.parse(startDateStr);
        final endDate = DateTime.parse(endDateStr);

        if (endDate.isBefore(now)) {
          continue;
        }

        for (var schedule in schedules.cast<Map<String, dynamic>>()) {
          final hour = schedule['hour'] as int?;
          final minute = schedule['minute'] as int?;

          if (hour == null || minute == null) continue;

          var currentDate = startDate;
          while (currentDate.isBefore(endDate) ||
              currentDate.isAtSameMomentAs(endDate)) {
            final triggerTime = DateTime(
              currentDate.year,
              currentDate.month,
              currentDate.day,
              hour,
              minute,
            );

            if (triggerTime.isAfter(now)) {
              await _scheduleExactReminder(
                userId: userId,
                reminderId:
                    'med_${doc.id}_${currentDate.toIso8601String()}_$hour:$minute',
                triggerTime: triggerTime,
                description:
                    '$description at ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
                type: 'medicine',
              );
            }

            currentDate = currentDate.add(const Duration(days: 1));
          }
        }
      }
    } catch (e, stack) {
      rethrow;
    }
  }

  Future<void> _scheduleExactReminder({
    required String userId,
    required String reminderId,
    required DateTime triggerTime,
    required String description,
    required String type,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final workName =
          'exactReminder_${userId}_${reminderId}_${triggerTime.millisecondsSinceEpoch}';

      final reminderData = {
        'userId': userId,
        'originalReminderId': reminderId,
        'triggerTime': triggerTime,
        'description': _getCleanDescription(type, description, additionalData),
        'type': type,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'scheduled',
        'notificationId': _generateNotificationId(reminderId, triggerTime),
        if (additionalData != null) ...additionalData,
      };

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('scheduledReminders')
          .doc(workName)
          .set(reminderData);

      await Workmanager().registerOneOffTask(
        workName,
        'exactReminderTask',
        initialDelay: triggerTime.difference(DateTime.now()),
        constraints: Constraints(networkType: NetworkType.not_required),
        inputData: {
          'userId': userId,
          'reminderId': reminderId,
          'description': _getCleanDescription(
            type,
            description,
            additionalData,
          ),
          'type': type,
          'triggerTime': triggerTime.toIso8601String(),
          if (additionalData != null) ...additionalData,
        },
      );
    } catch (e, stack) {
      throw e;
    }
  }

  String _getCleanDescription(
    String type,
    String description,
    Map<String, dynamic>? additionalData,
  ) {
    if (type == 'appointment') {
      return 'Appointment with ${additionalData?['doctorName']} (${additionalData?['specialization']})';
    }
    return description;
  }

  DateTime _parseAppointmentTime(String dateStr, String timeStr) {
    try {
      final date = DateFormat('yyyy-MM-dd').parse(dateStr);
      final timeParts = timeStr.split(':');
      return date.add(
        Duration(
          hours: int.parse(timeParts[0]),
          minutes: int.parse(timeParts[1]),
        ),
      );
    } catch (e, stack) {
      return DateTime.now();
    }
  }

  DateTime _parseDateTime(String dateStr, String timeStr) {
    try {
      final date = DateFormat('yyyy-MM-dd').parse(dateStr);
      final timeParts = timeStr.split(':');
      return date.add(
        Duration(
          hours: int.parse(timeParts[0]),
          minutes: int.parse(timeParts[1]),
        ),
      );
    } catch (e) {
      return DateTime.now().add(Duration(minutes: 1));
    }
  }

  int _generateNotificationId(String reminderId, DateTime time) {
    return (reminderId.hashCode + time.millisecondsSinceEpoch).hashCode;
  }

  Future<void> logout() async {
    try {
      await Workmanager().cancelAll();
    } catch (e, stack) {
      rethrow;
    }
  }
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  try {
    await Firebase.initializeApp();

    try {
      await Get.putAsync(() => NotificationService().initialize());
    } catch (e) {
      throw e;
    }

    if (service is AndroidServiceInstance) {
      service.on('stopService').listen((_) {
        service.stopSelf();
      });
    }

    await checkReminders();
    Timer.periodic(const Duration(minutes: 1), (_) async {
      await checkReminders();
    });
  } catch (e) {
    if (service is AndroidServiceInstance) {
      await Future.delayed(const Duration(seconds: 5));
      service.stopSelf();
    }
  }
}

Future<void> checkReminders() async {
  try {
    final auth = FirebaseAuth.instance;
    final currentUser = auth.currentUser;

    if (currentUser == null) {
      return;
    }

    await ReminderSystem.to.manualSync(currentUser.uid);
  } catch (e, stack) {
    throw e;
  }
}

Future<void> initializeBackgroundService() async {
  try {
    await Firebase.initializeApp();
    final service = FlutterBackgroundService();

    if (await service.isRunning()) {
      return;
    }

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: false,
        autoStart: true,
        autoStartOnBoot: true,
      ),
      iosConfiguration: IosConfiguration(
        onForeground: onStart,
        onBackground: (_) => true,
        autoStart: true,
      ),
    );

    await service.startService();
  } catch (e) {
    rethrow;
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      await Firebase.initializeApp();

      if (taskName == 'exactReminderTask') {
        final userId = inputData?['userId'] as String?;
        final reminderId = inputData?['reminderId'] as String?;
        final description = inputData?['description'] as String? ?? 'Reminder';
        final type = inputData?['type'] as String? ?? 'reminder';
        final triggerTime = DateTime.parse(inputData?['triggerTime'] as String);

        if (userId == null || reminderId == null) return false;

        final notificationId = _generateNotificationId(reminderId, triggerTime);

        final reminders = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('scheduledReminders');

        final query =
            await reminders
                .where('originalReminderId', isEqualTo: reminderId)
                .where('triggerTime', isEqualTo: triggerTime)
                .limit(1)
                .get();

        if (query.docs.isNotEmpty) {
          await query.docs.first.reference.update({
            'status': 'triggered',
            'triggeredAt': FieldValue.serverTimestamp(),
          });
        }

        final notificationService = await Get.putAsync(
          () => NotificationService().initialize(),
        );

        await notificationService.showCleanNotification(
          id: notificationId,
          title:
              type == 'medicine' ? 'Medicine Reminder' : 'Appointment Reminder',
          body: description,
        );

        return true;
      } else if (taskName == 'reminderSyncTask') {
        final userId = inputData?['userId'] as String?;
        if (userId != null) {
          await ReminderSystem.to.manualSync(userId);
          return true;
        }
      }

      return true;
    } catch (e, stack) {
      return false;
    }
  });
}

int _generateNotificationId(String reminderId, DateTime time) {
  return (reminderId.hashCode + time.millisecondsSinceEpoch).hashCode;
}

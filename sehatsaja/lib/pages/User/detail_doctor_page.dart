import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:sehatsaja/shared/theme.dart';
import 'package:sehatsaja/widgets/containerdetail.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:sehatsaja/pages/User/detail_payment_page.dart';
import 'package:sehatsaja/shared/notification_service.dart';

class DetailDoctorController extends GetxController {
  final String uid;
  final RxString _currentState = 'Schedule'.obs;
  final RxString selectedTime = ''.obs;
  final RxString doctorName = ''.obs;
  final RxInt doctorPrice = 0.obs;
  final RxMap<String, dynamic> dailySchedules = <String, dynamic>{}.obs;
  final RxString selectedDate =
      DateFormat('yyyy-MM-dd').format(DateTime.now()).obs;
  final RxList<Map<String, dynamic>> appointments =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final specialization = ''.obs;
  final TextEditingController specializationController =
      TextEditingController();
  final RxString photoUrl = ''.obs;
  final RxBool isBooking = false.obs;
  final RxString appointmentId = ''.obs;
  final RxString description = ''.obs;
  final RxString licenseNumber = ''.obs;
  final RxInt patientCount = 0.obs;
  final RxDouble averageRating = 0.0.obs;
  final RxInt ratingCount = 0.obs;

  DetailDoctorController({required this.uid});

  String get currentState => _currentState.value;

  @override
  void onInit() {
    super.onInit();
    _loadDoctorData();
    _loadAppointments();
  }

  Future<void> _loadDoctorData() async {
    try {
      isLoading.value = true;
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists) {
        updateDoctorData(doc.data()!);
      } else {
        throw Exception('Doctor document does not exist');
      }
    } catch (e) {
      debugPrint('Error loading doctor data: $e');
      Get.snackbar('Error', 'Failed to load doctor data');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadAppointments() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('appointments')
              .where('doctorId', isEqualTo: uid)
              .get();

      // Process appointments to remove duplicates
      final uniqueAppointments = _removeDuplicates(snapshot.docs);

      appointments.assignAll(
        uniqueAppointments.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList(),
      );

      // Count completed/confirmed appointments
      final completedAppointments =
          appointments
              .where(
                (appt) => ['confirmed', 'completed'].contains(appt['status']),
              )
              .toList();

      patientCount.value = completedAppointments.length;

      // Calculate average rating
      final ratings =
          completedAppointments
              .where((appt) => appt['rating'] != null)
              .map((appt) => (appt['rating'] as num).toDouble())
              .toList();

      ratingCount.value = ratings.length;
      if (ratings.isNotEmpty) {
        averageRating.value = ratings.reduce((a, b) => a + b) / ratings.length;
      } else {
        averageRating.value = 0.0;
      }
    } catch (e) {
      debugPrint('Error loading appointments: $e');
      Get.snackbar('Error', 'Failed to load appointments');
    }
  }

  List<DocumentSnapshot> _removeDuplicates(
    List<DocumentSnapshot> appointments,
  ) {
    final Map<String, DocumentSnapshot> uniqueMap = {};

    for (var appointment in appointments) {
      final data = appointment.data() as Map<String, dynamic>?;
      if (data == null) continue;

      final date = data['appointmentDate']?.toString() ?? '';
      final time = data['appointmentTime']?.toString() ?? '';

      if (date.isNotEmpty && time.isNotEmpty) {
        final key = '$date-$time';

        // Keep the latest appointment if duplicates exist
        if (!uniqueMap.containsKey(key)) {
          uniqueMap[key] = appointment;
        } else {
          // Compare timestamps to keep the latest one
          final existingTimestamp = uniqueMap[key]!['createdAt'] as Timestamp?;
          final currentTimestamp = data['createdAt'] as Timestamp?;

          if (currentTimestamp != null &&
              (existingTimestamp == null ||
                  currentTimestamp.millisecondsSinceEpoch >
                      existingTimestamp.millisecondsSinceEpoch)) {
            uniqueMap[key] = appointment;
          }
        }
      }
    }

    return uniqueMap.values.toList();
  }

  void changeState(String state) {
    if (_currentState.value != state) {
      _currentState.value = state;
    }
  }

  void updateDoctorData(Map<String, dynamic> data) {
    doctorName.value = data['name']?.toString() ?? 'No Name';
    doctorPrice.value = (data['price'] as num?)?.toInt() ?? 0;
    specialization.value = data['specialization']?.toString() ?? '';
    specializationController.text = specialization.value;
    photoUrl.value = data['photoUrl']?.toString() ?? '';
    description.value =
        data['description']?.toString() ?? 'No description available';
    licenseNumber.value =
        data['licenseNumber']?.toString() ?? 'No license number';

    dailySchedules.clear();
    if (data['dailySchedules'] is Map) {
      dailySchedules.assignAll(
        Map<String, dynamic>.from(data['dailySchedules']),
      );
    }
  }

  List<String> getAvailableDates() {
    final now = DateTime.now();
    final currentDate = DateFormat('yyyy-MM-dd').format(now);

    return dailySchedules.keys.where((date) {
        // Filter out past dates
        final dateTime = DateTime.parse(date);
        if (dateTime.isBefore(DateTime(now.year, now.month, now.day))) {
          return false;
        }

        // Check if the date has any available time slots
        final timeRanges = getAvailableTimeRanges(date);
        return timeRanges.isNotEmpty;
      }).toList()
      ..sort();
  }

  List<Map<String, String>> getAvailableTimeRanges(String date) {
    if (!dailySchedules.containsKey(date)) return [];

    final scheduleData = dailySchedules[date];
    if (scheduleData is! List) return [];

    final now = DateTime.now();
    final isToday = date == DateFormat('yyyy-MM-dd').format(now);

    // Get all booked slots for this date
    final bookedSlots =
        appointments
            .where(
              (appt) =>
                  appt['appointmentDate'] == date &&
                  (appt['status'] == 'waiting' ||
                      appt['status'] == 'confirmed' ||
                      appt['status'] == 'completed'),
            )
            .map((appt) => appt['appointmentTime'] as String)
            .toList();

    return (scheduleData as List)
        .whereType<String>()
        .where((timeString) {
          // Check if time is already booked
          if (bookedSlots.contains(timeString)) return false;

          // For today's date, check if time has passed
          if (isToday) {
            final timeParts = timeString.split(':');
            final slotTime = DateTime(
              now.year,
              now.month,
              now.day,
              int.parse(timeParts[0]),
              int.parse(timeParts[1]),
            );
            return slotTime.isAfter(now);
          }
          return true;
        })
        .map((timeString) {
          // Format display as "14:20-14:50" but store original "14:20"
          final startTime = timeString;
          final start = DateTime.parse('2000-01-01 $startTime:00');
          final end = start.add(const Duration(minutes: 30));
          final endTime = DateFormat('HH:mm').format(end);

          return {
            'start': startTime,
            'end': endTime,
            'display': '$startTime-$endTime',
          };
        })
        .toList();
  }

  void selectTimeRange(String range) {
    selectedTime.value = range;
  }

  Future<String> bookAppointment({
    required String date,
    required String time,
    required String complaint,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      if (complaint.isEmpty) {
        throw Exception('Complaint cannot be empty');
      }

      final appointmentData = {
        'complaint': complaint,
        'createdAt': FieldValue.serverTimestamp(),
        'appointmentDate': date,
        'doctorId': uid,
        'doctorName': doctorName.value,
        'patientId': user.uid,
        'patientName': user.displayName ?? 'Guest',
        'paymentMethod': '',
        'patientPhone': user.phoneNumber,
        'patientEmail': user.email,
        'price': doctorPrice.value,
        'priceDisplay': 'Rp ${NumberFormat('#,###').format(doctorPrice.value)}',
        'doctorSpecialization': specializationController.text,
        'status': 'waiting',
        'appointmentTime': time,
        'updatedAt': FieldValue.serverTimestamp(),
        'rating': null,
      };

      final docRef = await FirebaseFirestore.instance
          .collection('appointments')
          .add(appointmentData);

      await _loadAppointments();
      appointmentId.value = docRef.id;

      Get.snackbar('Success', 'Appointment booked successfully!');
      return docRef.id;
    } catch (e) {
      debugPrint('Error booking appointment: $e');
      Get.snackbar(
        'Error',
        'Failed to book appointment: ${e.toString().replaceAll('Exception: ', '')}',
      );
      rethrow;
    }
  }
}

class DetailDoctorPage extends GetView<DetailDoctorController> {
  DetailDoctorPage({Key? key, required String uid}) : super(key: key) {
    Get.put(DetailDoctorController(uid: uid));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGreyColor,
      appBar: AppBar(
        backgroundColor: lightGreyColor,
        elevation: 0,
        title: Text('', style: GoogleFonts.poppins(color: blackColor)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    _buildProfileHeader(controller),
                    _buildStateButtons(controller),
                    _buildContentSection(controller, context),
                    _buildBookButton(controller, context),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildProfileHeader(DetailDoctorController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                final photoUrl = controller.photoUrl.value;
                final isBase64 = photoUrl.contains('base64,');
                final imageData = isBase64 ? photoUrl.split(',')[1] : photoUrl;

                return ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child:
                      isBase64 && imageData.isNotEmpty
                          ? Image.memory(
                            base64Decode(imageData),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                          )
                          : imageData.isNotEmpty
                          ? Image.network(
                            imageData,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                          )
                          : _buildDefaultAvatar(),
                );
              }),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => Text(
                        controller.doctorName.value,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(
                      () => Text(
                        controller.specialization.value,
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Obx(
                () => ContainerDetail(
                  icon: PhosphorIconsBold.person,
                  name: '${controller.patientCount.value}+',
                  detail: 'Patients',
                ),
              ),
              Obx(
                () => ContainerDetail(
                  icon: PhosphorIconsBold.star,
                  name: controller.averageRating.value.toStringAsFixed(1),
                  detail: 'Rating',
                ),
              ),
              ContainerDetail(
                icon: PhosphorIconsBold.identificationCard,
                name: 'License',
                detail: 'Verified',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(
            () => Text(
              "Rp ${NumberFormat('#,###').format(controller.doctorPrice.value)}",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: bold,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 100,
      height: 100,
      color: Colors.grey[200],
      child: Icon(PhosphorIconsBold.user, size: 40, color: Colors.grey[400]),
    );
  }

  Widget _buildStateButtons(DetailDoctorController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:
            ['Schedule', 'Details'].map((state) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Obx(
                  () => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          controller.currentState == state
                              ? primaryColor
                              : whiteColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => controller.changeState(state),
                    child: Text(
                      state,
                      style: GoogleFonts.poppins(
                        color:
                            controller.currentState == state
                                ? whiteColor
                                : Colors.black87,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildContentSection(
    DetailDoctorController controller,
    BuildContext context,
  ) {
    return Obx(() {
      if (controller.currentState == 'Details') {
        return _buildDetailsContent(controller);
      } else {
        return _buildScheduleContent(controller, context);
      }
    });
  }

  Widget _buildDetailsContent(DetailDoctorController controller) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        PhosphorIconsBold.fileText,
                        size: 20,
                        color: primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Description',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => Text(
                      controller.description.value,
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        PhosphorIconsBold.identificationCard,
                        size: 20,
                        color: primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'License Number',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => Text(
                      controller.licenseNumber.value,
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        PhosphorIconsBold.star,
                        size: 20,
                        color: primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Rating Summary',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Average Rating: ${controller.averageRating.value.toStringAsFixed(1)}',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Based on ${controller.ratingCount.value} reviews',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleContent(
    DetailDoctorController controller,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Available Dates',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 60,
          child: Obx(() {
            final availableDates = controller.getAvailableDates();
            if (availableDates.isEmpty) {
              return Center(
                child: Text(
                  'No available dates',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: availableDates.length,
              itemBuilder: (context, index) {
                final date = availableDates[index];
                return Obx(
                  () => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(
                        DateFormat('MMM dd').format(DateTime.parse(date)),
                        style: GoogleFonts.poppins(
                          color:
                              controller.selectedDate.value == date
                                  ? whiteColor
                                  : Colors.black87,
                        ),
                      ),
                      selected: controller.selectedDate.value == date,
                      onSelected: (selected) {
                        if (selected) {
                          controller.selectedDate.value = date;
                          controller.selectedTime.value = '';
                        }
                      },
                      selectedColor: primaryColor,
                      backgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Available Time Slots',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final timeRanges = controller.getAvailableTimeRanges(
            controller.selectedDate.value,
          );

          if (timeRanges.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No available time slots for selected date',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  timeRanges.map((range) {
                    return ChoiceChip(
                      label: Text(range['display']!),
                      selected: controller.selectedTime.value == range['start'],
                      onSelected: (selected) {
                        if (selected) {
                          controller.selectTimeRange(range['start']!);
                        }
                      },
                    );
                  }).toList(),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBookButton(
    DetailDoctorController controller,
    BuildContext context,
  ) {
    return Obx(() {
      if (controller.currentState == 'Schedule' &&
          controller.selectedTime.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () => _showBookingDialog(controller, context),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Book Now",
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: whiteColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
      return const SizedBox();
    });
  }

  void _showBookingDialog(
    DetailDoctorController controller,
    BuildContext context,
  ) {
    final complaintController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        title: Text(
          'Confirm Appointment',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Doctor: ${controller.doctorName.value}',
                  style: GoogleFonts.poppins(),
                ),
                const SizedBox(height: 8),
                Text(
                  'Date: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(controller.selectedDate.value))}',
                  style: GoogleFonts.poppins(),
                ),
                const SizedBox(height: 8),
                Text(
                  'Time: ${controller.selectedTime.value} - ${DateFormat('HH:mm').format(DateTime.parse('2000-01-01 ${controller.selectedTime.value}:00').add(const Duration(minutes: 30)))}',
                  style: GoogleFonts.poppins(),
                ),
                const SizedBox(height: 8),
                Text(
                  'Price: Rp ${NumberFormat('#,###').format(controller.doctorPrice.value)}',
                  style: GoogleFonts.poppins(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: complaintController,
                  decoration: InputDecoration(
                    labelText: 'Complaint/Reason',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  maxLines: 3,
                  validator:
                      (value) =>
                          value?.isEmpty ?? true
                              ? 'Please describe your complaint'
                              : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          Obx(
            () =>
                controller.isBooking.value
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                      ),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          controller.isBooking.value = true;
                          try {
                            // Get the current user ID
                            final userId =
                                FirebaseAuth.instance.currentUser?.uid;

                            // Book appointment
                            final appointmentId = await controller
                                .bookAppointment(
                                  date: controller.selectedDate.value,
                                  time: controller.selectedTime.value,
                                  complaint: complaintController.text,
                                );

                            if (userId != null) {
                              await ReminderSystem.to.manualSync(userId);
                            }

                            // Navigate to payment page
                            Get.back(); // Close the dialog
                            Get.to(
                              () => DetailPaymentPage(
                                appointmentId: appointmentId,
                              ),
                            );
                          } finally {
                            controller.isBooking.value = false;
                          }
                        }
                      },
                      child: Text(
                        'Confirm Booking',
                        style: GoogleFonts.poppins(color: whiteColor),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}

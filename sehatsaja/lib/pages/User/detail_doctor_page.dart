import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:sehatsaja/shared/theme.dart';
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

      final uniqueAppointments = _removeDuplicates(snapshot.docs);

      appointments.assignAll(
        uniqueAppointments.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList(),
      );

      final completedAppointments =
          appointments
              .where(
                (appt) => ['confirmed', 'completed'].contains(appt['status']),
              )
              .toList();

      patientCount.value = completedAppointments.length;

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

        if (!uniqueMap.containsKey(key)) {
          uniqueMap[key] = appointment;
        } else {
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
        final dateTime = DateTime.parse(date);
        if (dateTime.isBefore(DateTime(now.year, now.month, now.day))) {
          return false;
        }

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
          if (bookedSlots.contains(timeString)) return false;

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Doctor Details',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildProfileHeader(controller),
                    _buildStateButtons(controller),
                    _buildContentSection(controller, context),
                  ],
                ),
              ),
            ),
            _buildBookButton(controller, context),
          ],
        );
      }),
    );
  }

  Widget _buildProfileHeader(DetailDoctorController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                final photoUrl = controller.photoUrl.value;
                final isBase64 = photoUrl.contains('base64,');
                final imageData = isBase64 ? photoUrl.split(',')[1] : photoUrl;

                return Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image:
                        isBase64 && imageData.isNotEmpty
                            ? DecorationImage(
                              image: MemoryImage(base64Decode(imageData)),
                              fit: BoxFit.cover,
                            )
                            : imageData.isNotEmpty
                            ? DecorationImage(
                              image: NetworkImage(imageData),
                              fit: BoxFit.cover,
                            )
                            : null,
                    color: imageData.isEmpty ? Colors.grey[200] : null,
                  ),
                  child:
                      imageData.isEmpty
                          ? Icon(
                            PhosphorIconsBold.user,
                            size: 40,
                            color: Colors.grey[400],
                          )
                          : null,
                );
              }),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => Text(
                        controller.doctorName.value,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(
                      () => Text(
                        controller.specialization.value,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          PhosphorIconsBold.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Obx(
                          () => Text(
                            '${controller.averageRating.value.toStringAsFixed(1)} (${controller.ratingCount.value})',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(
                icon: PhosphorIconsBold.user,
                title: 'Patients',
                value: '${controller.patientCount.value}+',
              ),
              _buildInfoItem(
                icon: PhosphorIconsBold.identificationCard,
                title: 'License',
                value: controller.licenseNumber.value,
              ),
              _buildInfoItem(
                icon: PhosphorIconsBold.currencyDollar,
                title: 'Price',
                value:
                    'Rp ${NumberFormat('#,###').format(controller.doctorPrice.value)}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: primaryColor),
        const SizedBox(height: 4),
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildStateButtons(DetailDoctorController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(
              () => _buildStateButton(
                'Schedule',
                controller.currentState == 'Schedule',
                () => controller.changeState('Schedule'),
              ),
            ),
          ),
          Expanded(
            child: Obx(
              () => _buildStateButton(
                'Details',
                controller.currentState == 'Details',
                () => controller.changeState('Details'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateButton(String text, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: isActive ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
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
          Text(
            'About Doctor',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            controller.description.value,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(height: 24),
          Text(
            'License Information',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  PhosphorIconsBold.identificationCard,
                  size: 24,
                  color: primaryColor,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'License Number',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.licenseNumber.value,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Date',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
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
                itemCount: availableDates.length,
                itemBuilder: (context, index) {
                  final date = availableDates[index];
                  return Obx(
                    () => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () {
                          controller.selectedDate.value = date;
                          controller.selectedTime.value = '';
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color:
                                controller.selectedDate.value == date
                                    ? primaryColor
                                    : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                DateFormat('EEE').format(DateTime.parse(date)),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color:
                                      controller.selectedDate.value == date
                                          ? Colors.white
                                          : Colors.grey[600],
                                ),
                              ),
                              Text(
                                DateFormat('dd').format(DateTime.parse(date)),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      controller.selectedDate.value == date
                                          ? Colors.white
                                          : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          const SizedBox(height: 24),
          Text(
            'Available Time Slots',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            final timeRanges = controller.getAvailableTimeRanges(
              controller.selectedDate.value,
            );

            if (timeRanges.isEmpty) {
              return Center(
                child: Text(
                  'No available time slots for selected date',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              );
            }

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  timeRanges.map((range) {
                    return Obx(
                      () => InkWell(
                        onTap: () {
                          controller.selectTimeRange(range['start']!);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color:
                                controller.selectedTime.value == range['start']
                                    ? primaryColor
                                    : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  controller.selectedTime.value ==
                                          range['start']
                                      ? primaryColor
                                      : Colors.grey[300]!,
                            ),
                          ),
                          child: Text(
                            range['display']!,
                            style: GoogleFonts.poppins(
                              color:
                                  controller.selectedTime.value ==
                                          range['start']
                                      ? Colors.white
                                      : Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBookButton(
    DetailDoctorController controller,
    BuildContext context,
  ) {
    return Obx(() {
      if (controller.currentState == 'Schedule' &&
          controller.selectedTime.isNotEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () => _showBookingDialog(controller, context),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              "Book Appointment",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white,
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
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Confirm Appointment',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildBookingDetailItem('Doctor', controller.doctorName.value),
              _buildBookingDetailItem(
                'Date',
                DateFormat(
                  'MMM dd, yyyy',
                ).format(DateTime.parse(controller.selectedDate.value)),
              ),
              _buildBookingDetailItem(
                'Time',
                '${controller.selectedTime.value} - ${DateFormat('HH:mm').format(DateTime.parse('2000-01-01 ${controller.selectedTime.value}:00').add(const Duration(minutes: 30)))}',
              ),
              _buildBookingDetailItem(
                'Price',
                'Rp ${NumberFormat('#,###').format(controller.doctorPrice.value)}',
              ),
              const SizedBox(height: 16),
              Form(
                key: formKey,
                child: TextFormField(
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
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(color: Colors.grey[700]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(
                      () =>
                          controller.isBooking.value
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    controller.isBooking.value = true;
                                    try {
                                      final appointmentId = await controller
                                          .bookAppointment(
                                            date: controller.selectedDate.value,
                                            time: controller.selectedTime.value,
                                            complaint: complaintController.text,
                                          );

                                      final userId =
                                          FirebaseAuth
                                              .instance
                                              .currentUser
                                              ?.uid;
                                      if (userId != null) {
                                        await ReminderSystem.to.manualSync(
                                          userId,
                                        );
                                      }

                                      Get.back();
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
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'Confirm',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingDetailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          Text(value, style: GoogleFonts.poppins()),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:sehatsaja/shared/theme.dart';
import 'package:sehatsaja/widgets/containerdetail.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class DetailDoctorPageDoctorController extends GetxController {
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
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  final RxString photoUrl = ''.obs;
  final RxString description = 'No description available'.obs;
  final RxString licenseNumber = ''.obs;
  final RxBool isEditing = false.obs;
  final RxBool isUpdating = false.obs;
  final RxBool isManagingSlots = false.obs;
  final TextEditingController newDateController = TextEditingController();
  final RxString selectedSlotDate = ''.obs;
  final RxList<String> selectedDateSlots = <String>[].obs;
  final RxInt patientCount = 0.obs;
  final RxDouble averageRating = 0.0.obs;
  final RxInt ratingCount = 0.obs;

  // New time slot management variables
  final RxString selectedStartTime = '08:00'.obs;
  final RxString selectedEndTime = '17:00'.obs;

  DetailDoctorPageDoctorController({required this.uid});

  String get currentState => _currentState.value;
  bool get hasLicense => licenseNumber.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _loadDoctorData().then((_) {
      _loadAppointments().then((_) {
        _loadPatientCountAndRatings();
      });
    });
  }

  Future<void> _loadPatientCountAndRatings() async {
    try {
      final confirmedAppointments =
          appointments
              .where(
                (appt) => ['confirmed', 'completed'].contains(appt['status']),
              )
              .toList();

      patientCount.value = confirmedAppointments.length;

      final ratings =
          confirmedAppointments
              .where((appt) => appt['rating'] != null)
              .map((appt) => (appt['rating'] as num).toDouble())
              .toList();

      ratingCount.value = ratings.length;
      averageRating.value =
          ratings.isNotEmpty
              ? ratings.reduce((a, b) => a + b) / ratings.length
              : 0.0;
    } catch (e) {
      debugPrint('Error loading patient count and ratings: $e');
      patientCount.value = 0;
      ratingCount.value = 0;
      averageRating.value = 0.0;
    }
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

      appointments.assignAll(
        snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList(),
      );
    } catch (e) {
      debugPrint('Error loading appointments: $e');
    }
  }

  void changeState(String state) {
    if (_currentState.value != state) {
      _currentState.value = state;
    }
  }

  void updateDoctorData(Map<String, dynamic> data) {
    doctorName.value = data['name']?.toString() ?? 'No Name';
    nameController.text = doctorName.value;

    doctorPrice.value = (data['price'] as num?)?.toInt() ?? 0;
    priceController.text = doctorPrice.value.toString();

    specialization.value = data['specialization']?.toString() ?? '';
    specializationController.text = specialization.value;

    photoUrl.value = data['photoUrl']?.toString() ?? '';

    description.value =
        data['description']?.toString() ?? 'No description available';
    descriptionController.text = description.value;

    licenseNumber.value = data['licenseNumber']?.toString() ?? '';
    licenseController.text = licenseNumber.value;

    dailySchedules.clear();
    if (data['dailySchedules'] is Map) {
      dailySchedules.assignAll(
        Map<String, dynamic>.from(data['dailySchedules']),
      );
    }
  }

  Future<void> updateDoctorProfile() async {
    try {
      isUpdating.value = true;

      final updateData = <String, dynamic>{};
      if (nameController.text != doctorName.value) {
        updateData['name'] = nameController.text;
      }

      final newPrice = int.tryParse(priceController.text) ?? 0;
      if (newPrice != doctorPrice.value) {
        updateData['price'] = newPrice;
      }

      if (specializationController.text != specialization.value) {
        updateData['specialization'] = specializationController.text;
      }

      if (descriptionController.text != description.value) {
        updateData['description'] = descriptionController.text;
      }

      if (licenseController.text != licenseNumber.value) {
        updateData['licenseNumber'] = licenseController.text;
      }

      if (updateData.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .update(updateData);
        await _loadDoctorData();
        Get.snackbar('Success', 'Profile updated successfully');
      }

      isEditing.value = false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: ${e.toString()}');
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> addAvailableDate() async {
    if (newDateController.text.isEmpty) return;

    try {
      final date = newDateController.text;
      if (!dailySchedules.containsKey(date)) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'dailySchedules.$date': FieldValue.arrayUnion([]),
        });
        dailySchedules[date] = [];
        newDateController.clear();
        Get.snackbar('Success', 'Date added successfully');
      } else {
        Get.snackbar('Info', 'Date already exists');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to add date: ${e.toString()}');
    }
  }

  Future<void> removeAvailableDate(String date) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'dailySchedules.$date': FieldValue.delete(),
      });
      dailySchedules.remove(date);
      Get.snackbar('Success', 'Date removed successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove date: ${e.toString()}');
    }
  }

  Future<void> addTimeSlot(String time) async {
    if (selectedSlotDate.value.isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'dailySchedules.${selectedSlotDate.value}': FieldValue.arrayUnion([
          time,
        ]),
      });

      if (dailySchedules[selectedSlotDate.value] == null) {
        dailySchedules[selectedSlotDate.value] = [time];
      } else {
        dailySchedules[selectedSlotDate.value].add(time);
      }

      loadSlotsForDate(selectedSlotDate.value);
      Get.snackbar('Success', 'Time slot added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add time slot: ${e.toString()}');
    }
  }

  Future<void> addMultipleTimeSlots(List<String> times) async {
    if (selectedSlotDate.value.isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'dailySchedules.${selectedSlotDate.value}': FieldValue.arrayUnion(
          times,
        ),
      });

      if (dailySchedules[selectedSlotDate.value] == null) {
        dailySchedules[selectedSlotDate.value] = times;
      } else {
        dailySchedules[selectedSlotDate.value].addAll(times);
      }

      loadSlotsForDate(selectedSlotDate.value);
      Get.snackbar('Success', '${times.length} time slots added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add time slots: ${e.toString()}');
    }
  }

  Future<void> removeTimeSlot(String time) async {
    if (selectedSlotDate.value.isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'dailySchedules.${selectedSlotDate.value}': FieldValue.arrayRemove([
          time,
        ]),
      });

      dailySchedules[selectedSlotDate.value].remove(time);
      loadSlotsForDate(selectedSlotDate.value);
      Get.snackbar('Success', 'Time slot removed successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove time slot: ${e.toString()}');
    }
  }

  Future<void> clearAllTimeSlots() async {
    if (selectedSlotDate.value.isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'dailySchedules.${selectedSlotDate.value}': FieldValue.delete(),
      });

      dailySchedules.remove(selectedSlotDate.value);
      selectedDateSlots.clear();
      Get.snackbar('Success', 'All time slots cleared');
    } catch (e) {
      Get.snackbar('Error', 'Failed to clear time slots: ${e.toString()}');
    }
  }

  void loadSlotsForDate(String date) {
    selectedSlotDate.value = date;
    selectedDateSlots.assignAll(
      (dailySchedules[date] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  List<String> getAvailableDates() {
    return dailySchedules.keys.toList()..sort();
  }

  List<Map<String, String>> getAvailableTimeRanges(String date) {
    if (!dailySchedules.containsKey(date)) return [];

    final scheduleData = dailySchedules[date];
    if (scheduleData is! List) return [];

    final bookedSlots =
        appointments
            .where((appt) => appt['appointmentDate'] == date)
            .map((appt) => appt['appointmentTime'] as String)
            .toList();

    return (scheduleData as List)
        .whereType<String>()
        .where((timeString) => !bookedSlots.contains(timeString))
        .map((timeString) {
          final startTime = timeString;
          final endTime = _calculateEndTime(startTime);
          return {'start': startTime, 'end': endTime, 'original': timeString};
        })
        .toList();
  }

  String _calculateEndTime(String startTime) {
    try {
      final parts = startTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final endTime = DateTime(
        0,
        0,
        0,
        hour,
        minute,
      ).add(const Duration(minutes: 30));
      return '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '${startTime.split(':')[0]}:30';
    }
  }

  void selectTime(String range) {
    selectedTime.value = range;
  }
}

class DetailDoctorPageDoctor extends GetView<DetailDoctorPageDoctorController> {
  DetailDoctorPageDoctor({Key? key, required String uid}) : super(key: key) {
    Get.put(DetailDoctorPageDoctorController(uid: uid));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGreyColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Doctor Profile',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() {
            if (controller.isManagingSlots.value) {
              return IconButton(
                icon: Icon(Icons.close, color: primaryColor),
                onPressed: () {
                  controller.isManagingSlots.value = false;
                  controller.isEditing.value = false;
                },
              );
            } else if (controller.isEditing.value) {
              return IconButton(
                icon: Icon(Icons.close, color: primaryColor),
                onPressed: () => controller.isEditing.value = false,
              );
            }
            return Container();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.isManagingSlots.value) {
          return _buildManageSlotsView(controller);
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHeader(controller),
              _buildActionButtons(controller),
              _buildStateButtons(controller),
              _buildContentSection(controller, context),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildActionButtons(DetailDoctorPageDoctorController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.edit, size: 18),
              label: Text(
                'Edit Profile',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: primaryColor.withOpacity(0.3)),
                ),
              ),
              onPressed:
                  controller.isEditing.value
                      ? null
                      : () => controller.isEditing.value = true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.schedule, size: 18),
              label: Text(
                'Manage Slots',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => controller.isManagingSlots.value = true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManageSlotsView(DetailDoctorPageDoctorController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manage Time Slots',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 20),

          // Date Selection Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Date',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.newDateController,
                          decoration: InputDecoration(
                            hintText: 'YYYY-MM-DD',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              controller.loadSlotsForDate(value);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        onPressed: () {
                          if (controller.newDateController.text.isNotEmpty) {
                            controller.loadSlotsForDate(
                              controller.newDateController.text,
                            );
                          }
                        },
                        child: Text(
                          'Load',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    final dates = controller.getAvailableDates();
                    if (dates.isEmpty) {
                      return Text(
                        'No available dates added yet',
                        style: GoogleFonts.poppins(color: Colors.grey),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Dates:',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children:
                                dates.map((date) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Chip(
                                      label: Text(date),
                                      backgroundColor:
                                          controller.selectedSlotDate.value ==
                                                  date
                                              ? primaryColor.withOpacity(0.2)
                                              : Colors.grey[200],
                                      onDeleted:
                                          () => controller.removeAvailableDate(
                                            date,
                                          ),
                                      deleteIconColor: primaryColor,
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Quick Add Time Slots Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Add Time Slots',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Select a time range to automatically generate 30-minute slots:',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                  const SizedBox(height: 16),

                  // Time Range Selection
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start Time',
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Obx(
                              () => DropdownButtonFormField<String>(
                                items: List.generate(24, (index) {
                                  final hour = index.toString().padLeft(2, '0');
                                  return DropdownMenuItem(
                                    value: '$hour:00',
                                    child: Text('$hour:00'),
                                  );
                                }),
                                onChanged: (value) {
                                  controller.selectedStartTime.value =
                                      value ?? '08:00';
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                value: controller.selectedStartTime.value,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'End Time',
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Obx(
                              () => DropdownButtonFormField<String>(
                                items: List.generate(24, (index) {
                                  final hour = (index + 1).toString().padLeft(
                                    2,
                                    '0',
                                  );
                                  return DropdownMenuItem(
                                    value: '$hour:00',
                                    child: Text('$hour:00'),
                                  );
                                }),
                                onChanged: (value) {
                                  controller.selectedEndTime.value =
                                      value ?? '17:00';
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                value: controller.selectedEndTime.value,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Generate Slots Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      if (controller.selectedSlotDate.value.isEmpty) {
                        Get.snackbar('Error', 'Please select a date first');
                        return;
                      }

                      final startParts = controller.selectedStartTime.value
                          .split(':');
                      final endParts = controller.selectedEndTime.value.split(
                        ':',
                      );

                      final startHour = int.parse(startParts[0]);
                      final startMinute = int.parse(startParts[1]);
                      final endHour = int.parse(endParts[0]);
                      final endMinute = int.parse(endParts[1]);

                      final startTime = DateTime(
                        0,
                        0,
                        0,
                        startHour,
                        startMinute,
                      );
                      final endTime = DateTime(0, 0, 0, endHour, endMinute);

                      if (endTime.isBefore(startTime)) {
                        Get.snackbar(
                          'Error',
                          'End time must be after start time',
                        );
                        return;
                      }

                      final newSlots = <String>[];
                      var currentTime = startTime;

                      while (currentTime.isBefore(endTime)) {
                        final timeStr =
                            '${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}';
                        newSlots.add(timeStr);
                        currentTime = currentTime.add(
                          const Duration(minutes: 30),
                        );
                      }

                      if (newSlots.isNotEmpty) {
                        controller.addMultipleTimeSlots(newSlots);
                      }
                    },
                    child: Text(
                      'Generate Time Slots',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Current Time Slots Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.selectedSlotDate.value.isNotEmpty
                        ? 'Time Slots for ${DateFormat('MMM dd, yyyy').format(DateTime.parse(controller.selectedSlotDate.value))}'
                        : 'Time Slots',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    final slots = controller.selectedDateSlots;
                    if (slots.isEmpty) {
                      return Text(
                        'No time slots for selected date',
                        style: GoogleFonts.poppins(color: Colors.grey),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              slots.map((time) {
                                return Chip(
                                  label: Text(time),
                                  backgroundColor: Colors.blue[50],
                                  labelStyle: GoogleFonts.poppins(
                                    color: primaryColor,
                                  ),
                                  deleteIconColor: primaryColor,
                                  onDeleted:
                                      () => controller.removeTimeSlot(time),
                                );
                              }).toList(),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[50],
                            foregroundColor: Colors.red,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            if (controller.selectedSlotDate.value.isEmpty)
                              return;
                            Get.defaultDialog(
                              title: 'Clear All Slots',
                              middleText:
                                  'Are you sure you want to remove all time slots for this date?',
                              textConfirm: 'Yes',
                              textCancel: 'No',
                              confirmTextColor: Colors.white,
                              onConfirm: () {
                                controller.clearAllTimeSlots();
                                Get.back();
                              },
                            );
                          },
                          child: Text(
                            'Clear All Slots',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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

  Widget _buildProfileHeader(DetailDoctorPageDoctorController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[200],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        isBase64 && imageData.isNotEmpty
                            ? Image.memory(
                              base64Decode(imageData),
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => _buildDefaultAvatar(),
                            )
                            : imageData.isNotEmpty
                            ? Image.network(
                              imageData,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => _buildDefaultAvatar(),
                            )
                            : _buildDefaultAvatar(),
                  ),
                );
              }),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () =>
                          controller.isEditing.value
                              ? TextFormField(
                                controller: controller.nameController,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                              )
                              : Text(
                                controller.doctorName.value,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                    const SizedBox(height: 4),
                    Obx(
                      () =>
                          controller.isEditing.value
                              ? TextFormField(
                                controller: controller.specializationController,
                                style: GoogleFonts.poppins(fontSize: 12),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                              )
                              : Text(
                                controller.specialization.value,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
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
              ContainerDetail(
                icon: PhosphorIconsBold.person,
                name: '${controller.patientCount.value}+',
                detail: 'Patients',
              ),
              ContainerDetail(
                icon: PhosphorIconsBold.star,
                name: controller.averageRating.value.toStringAsFixed(1),
                detail: 'Rating',
              ),
              if (controller.hasLicense)
                ContainerDetail(
                  icon: PhosphorIconsBold.identificationCard,
                  name: 'License',
                  detail: 'Verified',
                ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(
            () =>
                controller.isEditing.value
                    ? TextFormField(
                      controller: controller.priceController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        prefixText: 'Rp ',
                        prefixStyle: GoogleFonts.poppins(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                    : Text(
                      "Rp ${NumberFormat('#,###').format(controller.doctorPrice.value)}",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
          ),
          if (controller.isEditing.value) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: controller.updateDoctorProfile,
              child: Obx(
                () =>
                    controller.isUpdating.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                          'Save Changes',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Center(
      child: Icon(PhosphorIconsBold.user, size: 40, color: Colors.grey[400]),
    );
  }

  Widget _buildStateButtons(DetailDoctorPageDoctorController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
              ['Schedule', 'Details'].map((state) {
                return Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor:
                          controller.currentState == state
                              ? primaryColor.withOpacity(0.1)
                              : Colors.transparent,
                    ),
                    onPressed: () => controller.changeState(state),
                    child: Text(
                      state,
                      style: GoogleFonts.poppins(
                        color:
                            controller.currentState == state
                                ? primaryColor
                                : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildContentSection(
    DetailDoctorPageDoctorController controller,
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

  Widget _buildDetailsContent(DetailDoctorPageDoctorController controller) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
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
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () =>
                        controller.isEditing.value
                            ? TextFormField(
                              controller: controller.descriptionController,
                              maxLines: 3,
                              style: GoogleFonts.poppins(fontSize: 14),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.all(12),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                            )
                            : Text(
                              controller.description.value,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
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
              borderRadius: BorderRadius.circular(12),
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
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () =>
                        controller.isEditing.value
                            ? TextFormField(
                              controller: controller.licenseController,
                              style: GoogleFonts.poppins(fontSize: 14),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.all(12),
                                filled: true,
                                fillColor: Colors.grey[50],
                                hintText: 'Enter license number',
                              ),
                            )
                            : Text(
                              controller.licenseNumber.value.isNotEmpty
                                  ? controller.licenseNumber.value
                                  : 'No license number',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
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
              borderRadius: BorderRadius.circular(12),
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
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Average Rating: ${controller.averageRating.value.toStringAsFixed(1)}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Based on ${controller.ratingCount.value} reviews',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
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
    DetailDoctorPageDoctorController controller,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Dates',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: blackColor,
            ),
          ),
          const SizedBox(height: 12),
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
                padding: const EdgeInsets.symmetric(horizontal: 4),
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
                                    ? Colors.white
                                    : primaryColor,
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
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: primaryColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          const SizedBox(height: 20),
          Text(
            'Available Time Slots',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: blackColor,
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            final timeRanges = controller.getAvailableTimeRanges(
              controller.selectedDate.value,
            );

            if (timeRanges.isEmpty) {
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No available time slots for selected date',
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                ),
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: timeRanges.length,
              itemBuilder: (context, index) {
                final range = timeRanges[index];
                final displayRange = '${range['start']} - ${range['end']}';
                return Obx(
                  () => Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    color:
                        controller.selectedTime.value == displayRange
                            ? primaryColor.withOpacity(0.1)
                            : Colors.white,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        controller.selectTime(displayRange);
                      },
                      child: Center(
                        child: Text(
                          displayRange,
                          style: GoogleFonts.poppins(
                            color:
                                controller.selectedTime.value == displayRange
                                    ? primaryColor
                                    : Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

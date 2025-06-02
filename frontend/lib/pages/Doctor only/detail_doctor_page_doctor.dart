import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:frontend/shared/theme.dart';
import 'package:frontend/widgets/containerdetail.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final TextEditingController newTimeController = TextEditingController();
  final RxString selectedSlotDate = ''.obs;
  final RxList<String> selectedDateSlots = <String>[].obs;

  DetailDoctorPageDoctorController({required this.uid});

  String get currentState => _currentState.value;
  bool get hasLicense => licenseNumber.value.isNotEmpty;

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

      appointments.assignAll(
        snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList(),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to load appointments');
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

      // Create update map with only changed fields
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

      // Only update if something actually changed
      if (updateData.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .update(updateData);
        await _loadDoctorData();
        Get.snackbar('Success', 'Profile updated successfully');
      } else {
        Get.snackbar('Info', 'No changes detected');
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

  Future<void> addTimeSlot() async {
    if (selectedSlotDate.value.isEmpty || newTimeController.text.isEmpty)
      return;

    try {
      final time = newTimeController.text;
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

      newTimeController.clear();
      loadSlotsForDate(selectedSlotDate.value);
      Get.snackbar('Success', 'Time slot added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add time slot: ${e.toString()}');
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
            .where((appt) => appt['date'] == date)
            .map((appt) => appt['time'] as String)
            .toList();

    return (scheduleData as List)
        .whereType<String>()
        .where((timeString) => !bookedSlots.contains(timeString))
        .map((timeString) {
          final startTime = timeString;
          // Parse the time and add 30 minutes for display
          final timeFormat = DateFormat('HH:mm');
          final startDateTime = timeFormat.parse(startTime);
          final endDateTime = startDateTime.add(Duration(minutes: 30));
          final endTime = timeFormat.format(endDateTime);

          return {
            'start': startTime,
            'end': endTime,
            'original': timeString, // Keep original for backend
          };
        })
        .toList();
  }

  void selectTimeRange(String range) {
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
        backgroundColor: lightGreyColor,
        elevation: 0,
        title: Text('', style: GoogleFonts.poppins(color: blackColor)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() {
            if (controller.isManagingSlots.value) {
              return IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () {
                  controller.isManagingSlots.value = false;
                  controller.isEditing.value = false;
                },
              );
            } else if (controller.isEditing.value) {
              return IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () => controller.isEditing.value = false,
              );
            } else {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.black),
                onSelected: (value) {
                  if (value == 'edit') {
                    controller.isEditing.value = true;
                  } else if (value == 'manage_slots') {
                    controller.isManagingSlots.value = true;
                  }
                },
                itemBuilder:
                    (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('Edit Profile'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'manage_slots',
                        child: Text('Manage Time Slots'),
                      ),
                    ],
              );
            }
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
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildManageSlotsView(DetailDoctorPageDoctorController controller) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manage Available Slots',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Add New Date',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.newDateController,
                  decoration: InputDecoration(
                    hintText: 'YYYY-MM-DD',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: controller.addAvailableDate,
                child: Text('Add Date'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Available Dates',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() {
            final dates = controller.getAvailableDates();
            if (dates.isEmpty) {
              return Text('No available dates', style: GoogleFonts.poppins());
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  dates.map((date) {
                    return Chip(
                      label: Text(date),
                      onDeleted: () => controller.removeAvailableDate(date),
                    );
                  }).toList(),
            );
          }),
          const SizedBox(height: 20),
          Text(
            'Time Slots for Selected Date',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() {
            final dates = controller.getAvailableDates();
            return DropdownButtonFormField<String>(
              value:
                  controller.selectedSlotDate.value.isEmpty && dates.isNotEmpty
                      ? dates.first
                      : controller.selectedSlotDate.value,
              items:
                  dates.map((date) {
                    return DropdownMenuItem<String>(
                      value: date,
                      child: Text(date),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.loadSlotsForDate(value);
                }
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Select Date',
              ),
            );
          }),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.newTimeController,
                  decoration: InputDecoration(
                    hintText: 'HH:MM (e.g., 14:00)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: controller.addTimeSlot,
                child: Text('Add Slot'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            final slots = controller.selectedDateSlots;
            if (slots.isEmpty) {
              return Text(
                'No time slots for selected date',
                style: GoogleFonts.poppins(),
              );
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  slots.map((time) {
                    return Chip(
                      label: Text(time),
                      onDeleted: () => controller.removeTimeSlot(time),
                    );
                  }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(DetailDoctorPageDoctorController controller) {
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
                      () =>
                          controller.isEditing.value
                              ? TextFormField(
                                controller: controller.nameController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                ),
                              )
                              : Text(
                                controller.doctorName.value,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: bold,
                                ),
                              ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: primaryColor, size: 16.0),
                        const SizedBox(width: 4),
                        Text(
                          '4.8 (120 reviews)',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Obx(
                      () =>
                          controller.isEditing.value
                              ? TextFormField(
                                controller: controller.specializationController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                ),
                              )
                              : Text(
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
              ContainerDetail(
                icon: PhosphorIconsBold.person,
                name: '320+',
                detail: 'Patients',
              ),
              if (controller.hasLicense)
                ContainerDetail(
                  icon: PhosphorIconsBold.identificationCard,
                  name: 'License',
                  detail: 'Verified',
                ),
              ContainerDetail(
                icon: PhosphorIconsBold.star,
                name: '4.8',
                detail: 'Rating',
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
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        prefixText: 'Rp ',
                      ),
                    )
                    : Text(
                      "Rp ${NumberFormat('#,###').format(controller.doctorPrice.value)}",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: bold,
                        color: primaryColor,
                      ),
                    ),
          ),
          if (controller.isEditing.value) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.updateDoctorProfile,
              child: Obx(
                () =>
                    controller.isUpdating.value
                        ? CircularProgressIndicator(color: whiteColor)
                        : Text('Save Changes'),
              ),
            ),
          ],
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

  Widget _buildStateButtons(DetailDoctorPageDoctorController controller) {
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
                    () =>
                        controller.isEditing.value
                            ? TextFormField(
                              controller: controller.descriptionController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.all(8),
                              ),
                            )
                            : Text(
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
                    () =>
                        controller.isEditing.value
                            ? TextFormField(
                              controller: controller.licenseController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.all(8),
                                hintText: 'Enter license number',
                              ),
                            )
                            : Text(
                              controller.licenseNumber.value.isNotEmpty
                                  ? controller.licenseNumber.value
                                  : 'No license number',
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                  ),
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
                    // Display as "14:20 - 14:50" but store original "14:20" for backend
                    final displayRange = '${range['start']}-${range['end']}';
                    return ChoiceChip(
                      label: Text('${range['start']} - ${range['end']}'),
                      selected: controller.selectedTime.value == displayRange,
                      onSelected: (selected) {
                        if (selected) {
                          controller.selectTimeRange(displayRange);
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
}

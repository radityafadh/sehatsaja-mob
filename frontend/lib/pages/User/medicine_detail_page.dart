import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/shared/theme.dart';

class MedicineDetailPage extends StatefulWidget {
  final String uid;
  final String docId;

  const MedicineDetailPage({super.key, required this.uid, required this.docId});

  @override
  State<MedicineDetailPage> createState() => _MedicineDetailPageState();
}

class _MedicineDetailPageState extends State<MedicineDetailPage> {
  Map<String, dynamic>? medicineData;
  bool isLoading = true;
  bool isEditing = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  List<TimeOfDay> scheduleTimes = [];

  @override
  void initState() {
    super.initState();
    fetchMedicineData();
  }

  Future<void> fetchMedicineData() async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.uid)
              .collection('medicines')
              .doc(widget.docId)
              .get();

      if (doc.exists) {
        final data = doc.data();
        setState(() {
          medicineData = data;
          nameController.text = data?['name'] ?? '';
          descriptionController.text = data?['description'] ?? '';
          startDate =
              DateTime.tryParse(data?['startDate'] ?? '') ?? DateTime.now();
          endDate = DateTime.tryParse(data?['endDate'] ?? '') ?? DateTime.now();
          scheduleTimes =
              (data?['schedule'] as List<dynamic>? ?? []).map<TimeOfDay>((
                time,
              ) {
                return TimeOfDay(hour: time['hour'], minute: time['minute']);
              }).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error fetching medicine: $e');
    }
  }

  Future<void> deleteMedicine() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('medicines')
        .doc(widget.docId)
        .delete();
    if (mounted) Navigator.pop(context);
  }

  Future<void> saveChanges() async {
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Start and End date cannot be empty')),
      );
      return;
    }

    if (endDate!.isBefore(startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date cannot be before Start date')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .collection('medicines')
          .doc(widget.docId)
          .update({
            'name': nameController.text,
            'description': descriptionController.text,
            'startDate': startDate!.toIso8601String(),
            'endDate': endDate!.toIso8601String(),
            'schedule':
                scheduleTimes
                    .map((t) => {'hour': t.hour, 'minute': t.minute})
                    .toList(),
          });

      setState(() {
        isEditing = false;
        medicineData?['name'] = nameController.text;
        medicineData?['description'] = descriptionController.text;
        medicineData?['startDate'] = startDate!.toIso8601String();
        medicineData?['endDate'] = endDate!.toIso8601String();
        medicineData?['schedule'] =
            scheduleTimes
                .map((t) => {'hour': t.hour, 'minute': t.minute})
                .toList();
      });
    } catch (e) {
      print('❌ Error saving changes: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to save changes')));
    }
  }

  Future<void> selectDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (startDate ?? now) : (endDate ?? now),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  Future<void> selectTime(int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: scheduleTimes[index],
    );
    if (picked != null) {
      setState(() {
        scheduleTimes[index] = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || medicineData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final String name = medicineData?['name'] ?? '-';
    final String description = medicineData?['description'] ?? '-';
    final String shape = medicineData?['shape'] ?? '';
    final int colorValue = medicineData?['color'] ?? Colors.grey.value;
    final Color shapeColor = Color(colorValue);
    final dateFormat = DateFormat('yyyy-MM-dd');

    String formattedSchedule = scheduleTimes
        .map(
          (t) =>
              '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
        )
        .join(', ');

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        title: const Text(''),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () => setState(() => isEditing = !isEditing),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                shape.isNotEmpty
                    ? ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        shapeColor,
                        BlendMode.modulate,
                      ),
                      child: SizedBox(
                        width: 160,
                        height: 160,
                        child: Image.asset(shape, fit: BoxFit.contain),
                      ),
                    )
                    : Icon(Icons.medication, color: shapeColor, size: 100),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Medicine Name',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: regular,
                          color: blackColor,
                        ),
                      ),
                      isEditing
                          ? TextField(
                            controller: nameController,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: semiBold,
                              color: primaryColor,
                            ),
                          )
                          : Text(
                            name,
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: semiBold,
                              color: primaryColor,
                            ),
                          ),
                      const SizedBox(height: 10),
                      Text(
                        'Description',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: regular,
                          color: blackColor,
                        ),
                      ),
                      isEditing
                          ? TextField(
                            controller: descriptionController,
                            maxLines: 3,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: regular,
                              color: primaryColor,
                            ),
                          )
                          : Text(
                            description,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: regular,
                              color: primaryColor,
                            ),
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          ),
                      const SizedBox(height: 10),
                      Text(
                        'Next Dose',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: regular,
                          color: blackColor,
                        ),
                      ),
                      Text(
                        scheduleTimes.isNotEmpty
                            ? scheduleTimes[0].format(context)
                            : '-',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: semiBold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Dose',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: regular,
                color: blackColor,
              ),
            ),
            isEditing
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < scheduleTimes.length; i++)
                      Row(
                        children: [
                          Text(
                            'Time ${i + 1}: ',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: blackColor,
                            ),
                          ),
                          TextButton(
                            onPressed: () => selectTime(i),
                            child: Text(
                              scheduleTimes[i].format(context),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              scheduleTimes.add(TimeOfDay.now());
                            });
                          },
                          child: const Text('Add Time'),
                        ),
                        const SizedBox(width: 10),
                        if (scheduleTimes.length > 1)
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                scheduleTimes.removeLast();
                              });
                            },
                            child: const Text('Remove Last'),
                          ),
                      ],
                    ),
                  ],
                )
                : Text(
                  '${scheduleTimes.length} Times  |  $formattedSchedule',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: regular,
                    color: greyColor,
                  ),
                ),
            const SizedBox(height: 20),
            Text(
              'Program',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: medium,
                color: blackColor,
              ),
            ),
            isEditing
                ? Row(
                  children: [
                    TextButton(
                      onPressed: () => selectDate(isStart: true),
                      child: Text(
                        'Start: ${dateFormat.format(startDate ?? DateTime.now())}',
                      ),
                    ),
                    TextButton(
                      onPressed: () => selectDate(isStart: false),
                      child: Text(
                        'End: ${dateFormat.format(endDate ?? DateTime.now())}',
                      ),
                    ),
                  ],
                )
                : ((startDate != null && endDate != null)
                    ? Text(
                      'Total ${(endDate!.difference(startDate!).inDays / 7).ceil()} Weeks  |  ${(endDate!.difference(DateTime.now()).inDays / 7).ceil()} Weeks left',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: regular,
                        color: greyColor,
                      ),
                    )
                    : Text(
                      'Program schedule not available',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: greyColor,
                      ),
                    )),
            if (isEditing)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: ElevatedButton(
                  onPressed: saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                  child: Text(
                    'Save Changes',
                    style: GoogleFonts.poppins(color: whiteColor),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

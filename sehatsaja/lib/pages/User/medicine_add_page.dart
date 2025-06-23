import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sehatsaja/shared/theme.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:get/get.dart';
import 'package:sehatsaja/pages/User/medicine_pick_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatsaja/shared/notification_service.dart';

class MedicineAddPage extends StatefulWidget {
  const MedicineAddPage({super.key});

  @override
  _MedicineAddPageState createState() => _MedicineAddPageState();
}

class _MedicineAddPageState extends State<MedicineAddPage> {
  int selectedShapeIndex = -1;
  int selectedColorIndex = -1;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  TimeOfDay _selectedTime = TimeOfDay.now();
  List<TimeOfDay> _scheduleList = [];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  final List<String> shapeAssets = [
    'assets/shape/Vector_11.png',
    'assets/shape/Vector_12.png',
    'assets/shape/Vector_13.png',
    'assets/shape/Vector_14.png',
    'assets/shape/Vector_15.png',
  ];

  final List<Color> colorOptions = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.brown,
  ];

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && !_scheduleList.contains(picked)) {
      setState(() {
        _scheduleList.add(picked);
        _scheduleList.sort((a, b) {
          final aMinutes = a.hour * 60 + a.minute;
          final bMinutes = b.hour * 60 + b.minute;
          return aMinutes.compareTo(bMinutes);
        });
      });
    }
  }

  Future<void> _saveMedicineToFirebase() async {
    if (nameController.text.isEmpty ||
        selectedShapeIndex == -1 ||
        selectedColorIndex == -1 ||
        _scheduleList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all required fields')),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('User not logged in')));
        return;
      }

      final uid = user.uid;

      final shapeAssetName = shapeAssets[selectedShapeIndex];
      final shapeCode =
          'assets/shape/shape_${shapeAssetName.split('_').last.split('.').first}.png';

      final medicineData = {
        'name': nameController.text,
        'description': descController.text,
        'shape': shapeCode,
        'color': colorOptions[selectedColorIndex].value,
        'startDate': _startDate.toIso8601String(),
        'endDate': _endDate.toIso8601String(),
        'schedule':
            _scheduleList
                .map((t) => {'hour': t.hour, 'minute': t.minute})
                .toList(),
        'createdAt': FieldValue.serverTimestamp(),
        'uid': uid, // Menambahkan UID pengguna
      };

      final docRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('medicines')
          .add(medicineData);

      medicineData['id'] = docRef.id; // Menambahkan ID dokumen Firebase

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Medicine saved successfully!')));

      Get.to(() => MedicinePickPage());
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGreyColor,
      appBar: AppBar(title: Text(''), backgroundColor: lightGreyColor),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Name",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: regular,
                    color: blackColor,
                  ),
                ),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your Medicine Name',
                    hintStyle: TextStyle(color: greyColor),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: lightGreyColor),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Description",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: regular,
                    color: blackColor,
                  ),
                ),
                TextFormField(
                  controller: descController,
                  decoration: InputDecoration(
                    hintText: 'Enter your Description',
                    hintStyle: TextStyle(color: greyColor),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: lightGreyColor),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Shape",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: regular,
                    color: blackColor,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: shapeAssets.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedShapeIndex = index;
                          });
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color:
                                selectedShapeIndex == index
                                    ? primaryColor
                                    : whiteColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                selectedShapeIndex == index
                                    ? whiteColor
                                    : primaryColor,
                                BlendMode.srcIn,
                              ),
                              child: Image.asset(
                                shapeAssets[index],
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Color",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: regular,
                    color: blackColor,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: colorOptions.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColorIndex = index;
                          });
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorOptions[index],
                            border: Border.all(
                              color:
                                  selectedColorIndex == index
                                      ? Colors.black
                                      : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Dose Start",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: regular,
                    color: blackColor,
                  ),
                ),
                TableCalendar(
                  firstDay: DateTime(2000),
                  lastDay: DateTime(2050),
                  focusedDay: _startDate,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_startDate, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _startDate = selectedDay;
                      if (_endDate.isBefore(_startDate)) {
                        _endDate = _startDate;
                      }
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Dose End",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: regular,
                    color: blackColor,
                  ),
                ),
                TableCalendar(
                  firstDay: DateTime(2000),
                  lastDay: DateTime(2050),
                  focusedDay: _endDate,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_endDate, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    if (selectedDay.isBefore(_startDate)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('End date must be after start date'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    setState(() {
                      _endDate = selectedDay;
                    });
                  },
                  enabledDayPredicate: (day) => !day.isBefore(_startDate),
                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Schedule",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: regular,
                    color: blackColor,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  children:
                      _scheduleList.map((time) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Chip(
                            label: Text(
                              '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                            ),
                            backgroundColor: primaryColor,
                          ),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _selectTime(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: whiteColor),
                  child: Text('Select Time'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await _saveMedicineToFirebase();
                    final userId = FirebaseAuth.instance.currentUser?.uid;
                    if (userId != null) {
                      await ReminderSystem.to.manualSync(userId);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: whiteColor),
                  child: Text('Save Medicine'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

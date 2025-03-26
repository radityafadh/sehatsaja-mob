import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/shared/theme.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:get/get.dart';
import 'package:frontend/pages/medicine_pick_page.dart';

class MedicineAddPage extends StatefulWidget {
  const MedicineAddPage({super.key});

  @override
  _MedicineAddPageState createState() => _MedicineAddPageState();
}

class _MedicineAddPageState extends State<MedicineAddPage> {
  int selectedShapeIndex = -1;
  int selectedColorIndex = -1;
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  TimeOfDay _selectedTime = TimeOfDay.now();
  List<TimeOfDay> _scheduleList = [];

  final List<String> shapeAssets = [
    'assets/shape/Vector_11.png',
    'assets/shape/Vector_12.png',
    'assets/shape/Vector_13.png',
    'assets/shape/Vector_14.png',
    'assets/shape/Vector_15.png',
    'assets/shape/Vector_16.png',
    'assets/shape/Vector_17.png',
  ];

  final List<Color> boxColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
  ];

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && !_scheduleList.contains(picked)) {
      setState(() {
        _scheduleList.add(picked);
        // Sort the list of times
        _scheduleList.sort((a, b) {
          final aMinutes = a.hour * 60 + a.minute;
          final bMinutes = b.hour * 60 + b.minute;
          return aMinutes.compareTo(bMinutes);
        });
      });
    }
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
                                BlendMode
                                    .srcIn, // Changes the color of the image
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
                  "Shape",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: regular,
                    color: blackColor,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 30,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: boxColors.length,
                    itemBuilder: (context, index) {
                      bool isSelected = selectedColorIndex == index;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColorIndex = index;
                          });
                        },
                        child: Container(
                          width: 60,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: boxColors[index], // Background color
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              width: isSelected ? 3 : 1,
                              color: isSelected ? blackColor : whiteColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Dose",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: regular,
                    color: blackColor,
                  ),
                ),
                TableCalendar(
                  firstDay: DateTime(2000),
                  lastDay: DateTime(2050),
                  focusedDay: _selectedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
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
                  "Time",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: regular,
                    color: blackColor,
                  ),
                ),
                const SizedBox(height: 10),
                ..._scheduleList.map(
                  (time) => ListTile(
                    title: Text("${time.format(context)}"),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: primaryColor),
                      onPressed: () {
                        setState(() {
                          _scheduleList.remove(time);
                        });
                      },
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: whiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    minimumSize: const Size(double.infinity, 20),
                  ),
                  onPressed: () => _selectTime(context),
                  child: Text(
                    'Select Time',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: regular,
                      color: blackColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    minimumSize: const Size(double.infinity, 20),
                  ),
                  onPressed: () {
                    Get.to(() => MedicinePickPage());
                  },
                  child: Text(
                    'Add',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: regular,
                      color: whiteColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/shared/theme.dart';
import 'package:frontend/widgets/navbar.dart';
import 'package:frontend/widgets/cardobat.dart';
import 'package:frontend/widgets/dropdown.dart';
import 'package:get/get.dart';
import 'package:frontend/pages/User/medicine_add_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MedicinePickPage extends StatefulWidget {
  const MedicinePickPage({Key? key}) : super(key: key);

  @override
  _MedicinePickState createState() => _MedicinePickState();
}

class _MedicinePickState extends State<MedicinePickPage> {
  int selectedIndexpages = 1;
  int? selectedIndex;
  int selectedMonthIndex = DateTime.now().month - 1;
  late List<DateTime> daysInMonth;
  late ScrollController _scrollController;

  final List<String> months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void generateDaysInMonth(int year, int month) {
    final lastDay = DateTime(year, month + 1, 0).day;
    daysInMonth = List.generate(
      lastDay,
      (index) => DateTime(year, month, index + 1),
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    final now = DateTime.now();
    generateDaysInMonth(now.year, now.month);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final todayIndex = now.day - 1;
      _scrollController.animateTo(
        todayIndex * 70.0,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      setState(() {
        selectedIndex = todayIndex;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final selectedDate =
        (selectedIndex != null && selectedIndex! < daysInMonth.length)
            ? daysInMonth[selectedIndex!]
            : DateTime.now();

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: Text('', style: GoogleFonts.poppins(color: whiteColor)),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: whiteColor),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Medicine Reminder',
                  style: GoogleFonts.poppins(
                    fontSize: 25,
                    fontWeight: semiBold,
                    color: whiteColor,
                  ),
                ),
                const SizedBox(height: 10),
                CustomDropdown(
                  items: months,
                  value: months[selectedMonthIndex],
                  onChanged: (value) {
                    final index = months.indexOf(value);
                    setState(() {
                      selectedMonthIndex = index;
                      generateDaysInMonth(DateTime.now().year, index + 1);
                      selectedIndex = 0;
                      _scrollController.jumpTo(0);
                    });
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: whiteColor,
              border: Border.all(color: primaryColor, width: 2),
            ),
            child: SizedBox(
              height: 70,
              width: double.infinity,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: daysInMonth.length,
                itemBuilder: (context, index) {
                  final date = daysInMonth[index];
                  final isSelected = selectedIndex == index;

                  return GestureDetector(
                    onTap: () => onItemTapped(index),
                    child: Container(
                      width: 60,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : whiteColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryColor),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat.E().format(date),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? whiteColor : primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            date.day.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: bold,
                              color: isSelected ? whiteColor : primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: lightGreyColor),
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser?.uid)
                        .collection('medicines')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Terjadi kesalahan'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final docs =
                      snapshot.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final startDate =
                            DateTime.parse(data['startDate']).toLocal();
                        final endDate =
                            DateTime.parse(data['endDate']).toLocal();

                        return selectedDate.isAfter(
                              startDate.subtract(Duration(days: 1)),
                            ) &&
                            selectedDate.isBefore(
                              endDate.add(Duration(days: 1)),
                            );
                      }).toList();

                  if (docs.isEmpty) {
                    return Center(
                      child: Text(
                        'Tidak ada obat untuk tanggal ini',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 20,
                    ),
                    itemCount: docs.length, // Filtered list of medicines
                    itemBuilder: (context, index) {
                      final doc = docs[index]; // Use filtered docs
                      final currentUser = FirebaseAuth.instance.currentUser;
                      final data = doc.data() as Map<String, dynamic>;
                      data['id'] = doc.id; // Add docId to the data map

                      if (currentUser != null) {
                        data['uid'] =
                            currentUser.uid; // Add uid to the data map
                      } else {
                        print('⚠️ User belum login!');
                      }

                      return Column(
                        children: [
                          Cardobat(medicineData: data),
                          const SizedBox(height: 10),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => MedicineAddPage());
        },
        child: Icon(Icons.add, size: 50),
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        onItemTapped: (index) {
          setState(() {
            selectedIndexpages = index;
          });
        },
        currentIndex: selectedIndexpages,
        uid: FirebaseAuth.instance.currentUser!.uid,
      ),
    );
  }
}

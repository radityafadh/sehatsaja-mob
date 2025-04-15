import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/shared/theme.dart';
import 'package:frontend/widgets/navbar.dart';
import 'package:frontend/widgets/cardobat.dart';
import 'package:frontend/widgets/dropdown.dart';
import 'package:get/get.dart';
import 'package:frontend/pages/User/medicine_add_page.dart';

class MedicinePickPage extends StatefulWidget {
  const MedicinePickPage({Key? key}) : super(key: key);

  @override
  _MedicinePickState createState() => _MedicinePickState();
}

class _MedicinePickState extends State<MedicinePickPage> {
  int selectedIndexpages = 1;
  int? selectedIndex;

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

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

  final List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  @override
  Widget build(BuildContext context) {
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
                CustomDropdown(items: months),
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
              height: 60,
              width: double.infinity,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: days.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => onItemTapped(index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            days[index],
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: bold,
                              color:
                                  selectedIndex == index
                                      ? primaryColor
                                      : blackColor,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${index + 1}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: bold,
                              color:
                                  selectedIndex == index
                                      ? primaryColor
                                      : blackColor,
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 20,
                ),
                child: Column(
                  children: const [
                    Cardobat(
                      image: 'assets/pill_red.png',
                      name: 'Fluoxetine',
                      shape: 'Mixture',
                      dose: '2 times a day',
                      detailPageRoute: '/detail-medicine',
                    ),
                    SizedBox(height: 20),
                    Cardobat(
                      image: 'assets/medicine_bottle.png',
                      name: 'Fluoxetine',
                      shape: 'Mixture',
                      dose: '2 times a day',
                      detailPageRoute: '/detail-medicine',
                    ),
                  ],
                ),
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
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:frontend/pages/news_detail_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:frontend/shared/theme.dart';
import 'package:frontend/widgets/cardobat.dart';
import 'package:frontend/widgets/navbar.dart';
import 'package:frontend/widgets/cardnews.dart';
import 'package:get/get.dart';
import 'package:frontend/pages/medicine_pick_page.dart';
import 'package:frontend/pages/setting_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndexpages = 0;
  int? selectedIndex;

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGreyColor,
      body: ListView(
        padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0),
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello,',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: bold,
                      color: blackColor,
                    ),
                  ),
                  Text(
                    'John Doe',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(25.0),
                ),
                height: 60.0,
                child: GestureDetector(
                  onTap: () {
                    Get.to(SettingPage());
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Stack(
                        children: [
                          PhosphorIcon(
                            PhosphorIconsBold.bell,
                            color: blackColor,
                            size: 25.0,
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16.0),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.asset(
                          'assets/profile.png',
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            decoration: InputDecoration(
              filled: true,
              fillColor: whiteColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Icon(Icons.search, color: secondaryColor),
              hintText: 'Search Doctor',
              hintStyle: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: regular,
                color: secondaryColor,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                'Upcoming Appointment',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: bold,
                  color: blackColor,
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward, size: 30, color: primaryColor),
                onPressed: () {},
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.asset(
                        'assets/doctor.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 20.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dr. Mulyadi Akbar',
                          style: TextStyle(
                            color: whiteColor,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Dentist',
                          style: TextStyle(color: whiteColor, fontSize: 16.0),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7.0),
                      decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: PhosphorIcon(
                              PhosphorIconsBold.calendarDots,
                              color: whiteColor,
                              size: 25.0,
                            ),
                          ),
                          const SizedBox(width: 5.0),
                          Text(
                            'Monday, 8:00 AM',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: medium,
                              color: whiteColor,
                            ),
                          ),
                          const SizedBox(width: 20.0),
                          Container(
                            padding: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: PhosphorIcon(
                              PhosphorIconsBold.clock,
                              color: whiteColor,
                              size: 25.0,
                            ),
                          ),
                          const SizedBox(width: 5.0),
                          Text(
                            'Monday, 8:00 AM',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: medium,
                              color: whiteColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                "Today's Medicine",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: bold,
                  color: blackColor,
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward, size: 30, color: primaryColor),
                onPressed: () {
                  Get.to(() => MedicinePickPage());
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: whiteColor,
              border: Border.all(color: primaryColor, width: 2),
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => onItemTapped(index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            days[index],
                            style: GoogleFonts.poppins(
                              fontSize: 16,
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
                              fontSize: 16,
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
          const SizedBox(height: 20),
          Cardobat(
            image: 'assets/pill_red.png',
            name: 'Fluoxetine',
            shape: 'Mixture',
            dose: '2 times a day',
            detailPageRoute: '/detail-medicine',
          ),
          const SizedBox(height: 20),
          Cardobat(
            image: 'assets/medicine_bottle.png',
            name: 'Fluoxetine',
            shape: 'Mixture',
            dose: '2 times a day',
            detailPageRoute: '/detail-medicine',
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                "Medical Article",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: bold,
                  color: blackColor,
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward, size: 30, color: primaryColor),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: CardNews(
                    image: 'assets/news1.png',
                    subtitle: 'lorem ipsum dolor sit amet perci pesidasius',
                    onTap: () {
                      Get.to(() => NewsDetailPage());
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                "Find Nearby Hospital!",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: bold,
                  color: blackColor,
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward, size: 30, color: primaryColor),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        onItemTapped: (index) {
          setState(() {
            selectedIndexpages = index;
          });
        },
        currentIndex: 0,
      ),
    );
  }
}

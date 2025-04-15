import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/shared/theme.dart';
import 'package:get/get.dart';
import 'package:frontend/widgets/chatbox.dart';
import 'package:frontend/widgets/navbar_doctor.dart';
import 'package:frontend/pages/Doctor only/detail_doctor_page_doctor.dart';

class ChatPageDoctor extends StatefulWidget {
  const ChatPageDoctor({Key? key}) : super(key: key);

  @override
  _ChatPagesDoctortate createState() => _ChatPagesDoctortate();
}

class _ChatPagesDoctortate extends State<ChatPageDoctor> {
  int selectedIndexpages = 2;
  int? selectedIndex;

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: bold,
            color: blackColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: lightGreyColor,
      ),
      backgroundColor: lightGreyColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          children: [
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: whiteColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search, color: secondaryColor),
                hintText: 'Search Chat',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: regular,
                  color: secondaryColor,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.to(() => DetailDoctorPageDoctor());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: whiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: BorderSide(color: primaryColor, width: 2.0),
                ),
                child: Text(
                  'Profile Detail',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: semiBold,
                    color: blackColor,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.separated(
                itemCount: 3,
                separatorBuilder: (context, index) => SizedBox(height: 5),
                itemBuilder: (context, index) {
                  return Chatbox(
                    image: 'assets/profile.png',
                    name: 'Dr. John Doe',
                    snippets: 'lorem ipsum dolor',
                    day: 'Today',
                    time: '09:00',
                    onPressed: () {
                      Navigator.pushNamed(context, '/chatroom-doctor');
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar_Doctor(
        onItemTapped: (index) {
          setState(() {
            selectedIndexpages = index;
          });
        },
        currentIndex: 2,
      ),
    );
  }
}

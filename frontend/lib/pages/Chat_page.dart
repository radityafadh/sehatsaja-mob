import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/shared/theme.dart';
import 'package:frontend/pages/pick_doctor_page.dart';
import 'package:get/get.dart';
import 'package:frontend/widgets/chatbox.dart';
import 'package:frontend/widgets/navbar.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPagestate createState() => _ChatPagestate();
}

class _ChatPagestate extends State<ChatPage> {
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
                  Get.to(() => PickDoctorPage());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: whiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: BorderSide(color: primaryColor, width: 2.0),
                ),
                child: Text(
                  'Book Appointment',
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
                    image: 'assets/doctor.png',
                    name: 'Dr. John Doe',
                    snippets: 'lorem ipsum dolor',
                    day: 'Today',
                    time: '09:00',
                    onPressed: () {
                      Navigator.pushNamed(context, '/chatroom');
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
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

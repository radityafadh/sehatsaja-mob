import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:get/get.dart';
import 'package:sehatsaja/shared/theme.dart';
import 'package:sehatsaja/pages/User/medicine_pick_page.dart';
import 'package:sehatsaja/pages/User/home_page.dart';
import 'package:sehatsaja/pages/User/chat_page.dart';
import 'package:sehatsaja/pages/User/map_screen_page.dart';
import 'package:sehatsaja/pages/Doctor only/home_page_doctor.dart';
import 'package:sehatsaja/pages/Doctor only/chat_page_doctor.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onItemTapped;
  final String uid;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onItemTapped,
    required this.uid,
  }) : super(key: key);

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  String role = 'user'; // Default role

  @override
  void initState() {
    super.initState();
    fetchUserRole();
  }

  Future<void> fetchUserRole() async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.uid)
              .get();

      if (userDoc.exists) {
        setState(() {
          role = userDoc['role'] ?? 'user';
        });
      }
    } catch (e) {
      print('Error fetching user role: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: whiteColor,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () {
              widget.onItemTapped(0);
              if (role == 'doctor') {
                Get.offAll(() => HomePageDoctor());
              } else {
                Get.offAll(() => HomePage());
              }
            },
            icon: SvgPicture.asset(
              'assets/home_navbar.svg',
              height: 30,
              width: 30,
              color: widget.currentIndex == 0 ? primaryColor : blackColor,
            ),
          ),
          IconButton(
            onPressed: () {
              widget.onItemTapped(1);
              Get.to(() => MedicinePickPage());
            },
            icon: SvgPicture.asset(
              'assets/pill_navbar.svg',
              height: 30,
              width: 30,
              color: widget.currentIndex == 1 ? primaryColor : blackColor,
            ),
          ),
          IconButton(
            onPressed: () {
              widget.onItemTapped(2);
              if (role == 'doctor') {
                Get.to(() => ChatPageDoctor());
              } else {
                Get.to(() => ChatPage());
              }
            },
            icon: PhosphorIcon(
              PhosphorIconsRegular.stethoscope,
              size: 35.0,
              color: widget.currentIndex == 2 ? primaryColor : blackColor,
            ),
          ),
          IconButton(
            onPressed: () {
              widget.onItemTapped(3);
              Get.to(() => MapScreen());
            },
            icon: SvgPicture.asset(
              'assets/location_navbar.svg',
              height: 30,
              width: 30,
              color: widget.currentIndex == 3 ? primaryColor : blackColor,
            ),
          ),
        ],
      ),
    );
  }
}

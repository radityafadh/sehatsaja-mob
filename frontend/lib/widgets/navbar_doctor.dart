import 'package:flutter/material.dart';
import 'package:frontend/shared/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:get/get.dart';
import 'package:frontend/pages/User/medicine_pick_page.dart';
import 'package:frontend/pages/Doctor only/home_page_doctor.dart';
import 'package:frontend/pages/Doctor only/chat_page_doctor.dart';
import 'package:frontend/pages/Doctor only/medicine_pick_page_doctor.dart';
import 'package:frontend/pages/User/map_screen_page.dart';

class CustomBottomNavigationBar_Doctor extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavigationBar_Doctor({
    Key? key,
    required this.onItemTapped,
    required this.currentIndex,
  }) : super(key: key);

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
              onItemTapped(0);
              Get.to(() => HomePageDoctor());
            },
            icon: SvgPicture.asset(
              'assets/home_navbar.svg',
              height: 30,
              width: 30,
              color: currentIndex == 0 ? primaryColor : blackColor,
            ),
          ),
          IconButton(
            onPressed: () {
              onItemTapped(1);
              Get.to(() => MedicinePickPageDoctor());
            },
            icon: SvgPicture.asset(
              'assets/pill_navbar.svg',
              height: 30,
              width: 30,
              color: currentIndex == 1 ? primaryColor : blackColor,
            ),
          ),
          IconButton(
            onPressed: () {
              onItemTapped(2);
              Get.to(() => ChatPageDoctor());
            },
            icon: PhosphorIcon(
              PhosphorIconsRegular.stethoscope,
              size: 35.0,
              color: currentIndex == 2 ? primaryColor : blackColor,
            ),
          ),
          IconButton(
            onPressed: () {
              onItemTapped(3);
              Get.to(() => MapScreen());
            },
            icon: SvgPicture.asset(
              'assets/location_navbar.svg',
              height: 30,
              width: 30,
              color: currentIndex == 3 ? primaryColor : blackColor,
            ),
          ),
        ],
      ),
    );
  }
}

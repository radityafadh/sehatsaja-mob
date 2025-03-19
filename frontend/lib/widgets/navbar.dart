import 'package:flutter/material.dart';
import 'package:frontend/shared/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavigationBar({
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
            onPressed: () => onItemTapped(0),
            icon: SvgPicture.asset(
              'assets/home_navbar.svg',
              height: 30,
              width: 30,
              color: currentIndex == 0 ? primaryColor : blackColor,
            ),
          ),
          IconButton(
            onPressed: () => onItemTapped(1),
            icon: SvgPicture.asset(
              'assets/pill_navbar.svg',
              height: 30,
              width: 30,
              color: currentIndex == 1 ? primaryColor : blackColor,
            ),
          ),
          IconButton(
            onPressed: () => onItemTapped(2),
            icon: PhosphorIcon(
              PhosphorIconsRegular.stethoscope,
              size: 35.0,
              color: currentIndex == 2 ? primaryColor : blackColor,
            ),
          ),
          IconButton(
            onPressed: () => onItemTapped(3),
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

import 'package:flutter/material.dart';
import 'package:frontend/shared/theme.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Carddoctor extends StatelessWidget {
  final String image;
  final String name;
  final String role;
  final String detailPageRoute;

  const Carddoctor({
    Key? key,
    required this.image,
    required this.name,
    required this.role,
    required this.detailPageRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.4,
      height: screenHeight * 0.25,
      padding: EdgeInsets.all(screenWidth * 0.02),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(screenWidth * 0.08),
        border: Border.all(color: primaryColor, width: 2.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: screenHeight * 0.015),
          ClipRRect(
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
            child: Image.asset(
              image,
              width: screenWidth * 0.15,
              height: screenWidth * 0.15,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: screenWidth * 0.05,
              fontWeight: bold,
              color: blackColor,
            ),
          ),
          Text(
            role,
            style: GoogleFonts.poppins(
              fontSize: screenWidth * 0.035,
              fontWeight: regular,
              color: blackColor,
            ),
          ),
          SizedBox(height: screenHeight * 0.015),
          ElevatedButton(
            onPressed: () {
              Get.toNamed(detailPageRoute);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.08),
              ),
            ),
            child: Text(
              'Detail',
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.03,
                fontWeight: FontWeight.bold,
                color: whiteColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:frontend/shared/theme.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ExperienceCard extends StatelessWidget {
  final String role;
  final String place;
  final String time;
  final String detail;

  const ExperienceCard({
    Key? key,
    required this.role,
    required this.place,
    required this.time,
    required this.detail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color borderColor = primaryColor;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(color: whiteColor),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      role,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: extraBold,
                        color: blackColor,
                      ),
                    ),
                    SizedBox(width: 10.0),
                    Text(
                      place,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: extraBold,
                        color: blackColor,
                      ),
                    ),
                  ],
                ),
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: bold,
                    color: blackColor,
                  ),
                ),
                SizedBox(height: 5.0),
                Text(
                  detail,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: regular,
                    color: blackColor,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

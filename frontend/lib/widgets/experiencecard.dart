import 'package:flutter/material.dart';
import 'package:frontend/shared/theme.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ExperienceCard extends StatelessWidget {
  final String experienceString;

  const ExperienceCard({Key? key, required this.experienceString})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Asumsikan format string: "role - place - time - detail"
    final parts = experienceString.split(' - ');

    final role = parts.length > 0 ? parts[0] : 'Role';
    final place = parts.length > 1 ? parts[1] : 'Place';
    final time = parts.length > 2 ? parts[2] : 'Time';
    final detail = parts.length > 3 ? parts[3] : 'Detail';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
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
                    const SizedBox(width: 10.0),
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
                const SizedBox(height: 5.0),
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/shared/theme.dart';

class MedicineDetailPage extends StatelessWidget {
  const MedicineDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(title: Text(''), backgroundColor: whiteColor),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/pill_red.png',
                  width: 160,
                  height: 160,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Medicine Name',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: regular,
                        color: blackColor,
                      ),
                    ),
                    Text(
                      'Fluoxetine',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: semiBold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Description',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: regular,
                        color: blackColor,
                      ),
                    ),
                    Text(
                      '20 mg',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: semiBold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Next Dose',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: regular,
                        color: blackColor,
                      ),
                    ),
                    Text(
                      '06.00 PM',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: semiBold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Dose',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: regular,
                color: blackColor,
              ),
            ),
            Text(
              '3 Times  |  06.00 AM, 06.00 PM',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: regular,
                color: greyColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Program',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: medium,
                color: blackColor,
              ),
            ),
            Text(
              'Total 4 Weeks  |  2 Weeks left',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: regular,
                color: greyColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

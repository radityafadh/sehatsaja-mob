import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/shared/theme.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:frontend/pages/article_history_page.dart';
import 'package:get/get.dart';
import 'package:frontend/pages/transaction_history_page.dart';
import 'package:frontend/pages/profile_page.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGreyColor,
      appBar: AppBar(
        title: Text(
          '',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: bold,
            color: lightGreyColor,
          ),
        ),
        backgroundColor: lightGreyColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: GoogleFonts.poppins(
                fontSize: 40,
                fontWeight: semiBold,
                color: blackColor,
              ),
            ),
            const SizedBox(height: 40.0),
            Text(
              'Account',
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: medium,
                color: blackColor,
              ),
            ),
            const SizedBox(height: 20.0),
            GestureDetector(
              onTap: () {
                Get.to(ProfilePage());
              },
              child: Row(
                children: [
                  PhosphorIcon(
                    PhosphorIconsBold.user,
                    color: blackColor,
                    size: 25.0,
                  ),
                  const SizedBox(width: 10.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'John Doe',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: medium,
                          color: blackColor,
                        ),
                      ),
                      Text(
                        'Personal Information',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: regular,
                          color: blackColor,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  PhosphorIcon(
                    PhosphorIconsBold.arrowRight,
                    color: primaryColor,
                    size: 25.0,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            GestureDetector(
              onTap: () {
                Get.to(ArticleHistoryPage());
              },
              child: Row(
                children: [
                  PhosphorIcon(
                    PhosphorIconsBold.clock,
                    color: blackColor,
                    size: 25.0,
                  ),
                  const SizedBox(width: 10.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'History',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: medium,
                          color: blackColor,
                        ),
                      ),
                      Text(
                        'Article Read',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: regular,
                          color: blackColor,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  PhosphorIcon(
                    PhosphorIconsBold.arrowRight,
                    color: primaryColor,
                    size: 25.0,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            GestureDetector(
              onTap: () {
                Get.to(TransactionHistoryPage());
              },
              child: Row(
                children: [
                  PhosphorIcon(
                    PhosphorIconsBold.money,
                    color: blackColor,
                    size: 25.0,
                  ),
                  const SizedBox(width: 10.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'History',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: medium,
                          color: blackColor,
                        ),
                      ),
                      Text(
                        'Transaction',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: regular,
                          color: blackColor,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  PhosphorIcon(
                    PhosphorIconsBold.arrowRight,
                    color: primaryColor,
                    size: 25.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

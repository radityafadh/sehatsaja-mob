import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sehatsaja/shared/theme.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:get/get.dart';
import 'package:sehatsaja/pages/User/transaction_history_page.dart';
import 'package:sehatsaja/pages/User/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatsaja/pages/User/home_page.dart';
import 'package:sehatsaja/pages/User/rating_history_page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String name = 'Guest';
  String email = '';
  bool isDoctor = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final doc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (doc.exists) {
          setState(() {
            name = doc['name'] ?? 'Guest';
            email = user.email ?? '';
            isDoctor = email.toLowerCase().contains('dokter');
          });
        } else {
          setState(() {
            name = 'Unknown';
            email = user.email ?? '';
            isDoctor = email.toLowerCase().contains('dokter');
          });
        }
      } catch (e) {
        print('Error fetching user data: $e');
        setState(() {
          name = 'Guest';
          email = user.email ?? '';
          isDoctor = email.toLowerCase().contains('dokter');
        });
      }
    } else {
      setState(() {
        name = 'Guest';
        email = '';
        isDoctor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: blackColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: lightGreyColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: blackColor),
          onPressed: () {
            Get.to(HomePage());
          },
        ),
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
                        name,
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
            if (!isDoctor) const SizedBox(height: 20.0),
            if (!isDoctor)
              GestureDetector(
                onTap: () {
                  Get.to(RatingHistoryPage());
                },
                child: Row(
                  children: [
                    PhosphorIcon(
                      PhosphorIconsBold.star,
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
                          'Rating',
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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/shared/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:frontend/pages/sign_in_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      Get.to(() => SignInPage());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 148,
              height: 144,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/logo_pill.png'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'SehatSaja',
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: bold,
                color: whiteColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

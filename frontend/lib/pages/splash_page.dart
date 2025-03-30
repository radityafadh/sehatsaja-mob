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
      Get.to(() => const SignInPage());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double imageSize = constraints.maxWidth * 0.4;
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: imageSize,
                  height: imageSize * 0.97,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/logo_pill.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: constraints.maxHeight * 0.02),
                Text(
                  'SehatSaja',
                  style: GoogleFonts.poppins(
                    fontSize: constraints.maxWidth * 0.08,
                    fontWeight: bold,
                    color: whiteColor,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

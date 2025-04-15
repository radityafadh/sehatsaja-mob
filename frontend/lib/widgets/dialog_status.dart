import 'package:flutter/material.dart';
import 'package:frontend/shared/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:frontend/pages/User/sign_in_page.dart';

class StatusDialog extends StatelessWidget {
  final bool isSuccess;
  final String message;

  const StatusDialog({Key? key, required this.isSuccess, required this.message})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: whiteColor,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10),
          Image.asset(
            isSuccess ? 'assets/checkmark.png' : 'assets/crossmark.png',
          ),
          SizedBox(height: 10),
          Text(
            isSuccess ? 'Success' : 'Failure',
            style: GoogleFonts.poppins(
              fontSize: 30,
              fontWeight: bold,
              color: isSuccess ? primaryColor : blackColor,
            ),
          ),
          SizedBox(height: 5),
          Text(message, textAlign: TextAlign.center),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (isSuccess) {
                Get.to(() => SignInPage());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isSuccess ? primaryColor : blackColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Continue',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: regular,
                color: whiteColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

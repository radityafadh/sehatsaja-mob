import 'package:flutter/material.dart';
import 'package:frontend/shared/theme.dart';
import 'package:get/get.dart';
import 'package:frontend/pages/User/sign_in_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/shared/notification_service.dart';

class SignoutDialog extends StatelessWidget {
  const SignoutDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: whiteColor,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Apakah kamu ingin keluar?",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: blackColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // "Tidak" Button
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: greyColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Tidak",
                  style: TextStyle(fontSize: 16, color: whiteColor),
                ),
              ),
              // "Ya" Button
              ElevatedButton(
                onPressed: () async {
                  await ReminderSystem.to.logout();
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pop();
                  Get.offAll(() => SignInPage());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Ya",
                  style: TextStyle(fontSize: 16, color: whiteColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

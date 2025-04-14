import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/shared/theme.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'forget_password_page.dart';
import 'package:frontend/widgets/dialog_signout.dart';
import 'package:frontend/pages/edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: bold,
            color: blackColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(40.0),
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: lightGreyColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                  bottomLeft: Radius.zero,
                  bottomRight: Radius.zero,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      'First name',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: bold,
                        color: greyColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Text(
                        'John',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: bold,
                          color: blackColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Last name',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: bold,
                        color: greyColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Text(
                        'Doe',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: bold,
                          color: blackColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Email',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: bold,
                        color: greyColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Text(
                        'JohnDoe@gmail.com',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: bold,
                          color: blackColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Birth',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: bold,
                        color: greyColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Text(
                        '12 January 2002',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: bold,
                          color: blackColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Gender',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: bold,
                        color: greyColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Text(
                        'Male',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: bold,
                          color: blackColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Get.to(EditProfilePage());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'Edit Profile',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: semiBold,
                              color: whiteColor,
                            ),
                          ),
                        ),
                        Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            Get.to(ForgetPasswordPage());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'Change Password',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: semiBold,
                              color: whiteColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => SignoutDialog(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: whiteColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          side: BorderSide(color: primaryColor, width: 2.0),
                        ),
                        child: Text(
                          'Log Out',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: semiBold,
                            color: blackColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * -0.001,
            left: MediaQuery.of(context).size.width * 0.4,
            child: ClipRRect(
              child: Image.asset(
                'assets/profile.png',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

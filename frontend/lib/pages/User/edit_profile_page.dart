import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/shared/theme.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'forget_password_page.dart';
import 'package:frontend/pages/User/profile_page.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

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
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    buildLabel('First name'),
                    buildTextField('John'),
                    const SizedBox(height: 10),
                    buildLabel('Last name'),
                    buildTextField('Doe'),
                    const SizedBox(height: 10),
                    buildLabel('Email'),
                    buildTextField('JohnDoe@gmail.com'),
                    const SizedBox(height: 10),
                    buildLabel('Birth'),
                    buildTextField('12 January 2002'),
                    const SizedBox(height: 10),
                    buildLabel('Gender'),
                    buildTextField('Male'),
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.to(ProfilePage());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: whiteColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          side: BorderSide(color: primaryColor, width: 2.0),
                        ),
                        child: Text(
                          'Save Changes',
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

  Widget buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: bold,
        color: greyColor,
      ),
    );
  }

  Widget buildTextField(String initialValue) {
    return TextFormField(
      initialValue: initialValue,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: bold,
        color: blackColor,
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(10.0),
        filled: true,
        fillColor: whiteColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

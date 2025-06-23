import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sehatsaja/shared/theme.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatsaja/pages/User/rename_password_page.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Masukkan email anda';
    }

    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Masukkan email yang benar';
    }
    return null;
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGreyColor,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 120),
              Text(
                'Forget Password',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: extraBold,
                  color: blackColor,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'Enter your Email to reset password',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: regular,
                  color: blackColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              Image.asset('assets/logo_pill.png', height: 200),
              const SizedBox(height: 100),
              Align(
                alignment: Alignment.centerLeft,
                child: TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: whiteColor,
                    hintText: 'E-mail',
                    hintStyle: TextStyle(color: secondaryColor),
                    prefixIcon: PhosphorIcon(
                      PhosphorIconsBold.envelopeSimple,
                      color: secondaryColor,
                      size: 25.0,
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(40.0)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: validateEmail,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final currentUser = FirebaseAuth.instance.currentUser;

                      if (currentUser != null) {
                        final enteredEmail = emailController.text.trim();
                        final currentEmail = currentUser.email;

                        if (enteredEmail == currentEmail) {
                          Get.to(RenamePasswordPage());
                        } else {
                          Get.snackbar(
                            'Email Tidak Cocok',
                            'Silakan masukkan email yang sama dengan akun yang sedang login.',
                            backgroundColor: Colors.red.shade100,
                            colorText: Colors.red.shade900,
                            snackPosition: SnackPosition.TOP,
                          );
                        }
                      } else {
                        Get.snackbar(
                          'Tidak Ada Pengguna',
                          'Tidak ada pengguna yang sedang login.',
                          backgroundColor: Colors.orange.shade100,
                          colorText: Colors.orange.shade900,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                  child: Text(
                    'Next',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: whiteColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: whiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      side: BorderSide(color: primaryColor),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: extraBold,
                      color: blackColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sehatsaja/shared/theme.dart';
import 'package:sehatsaja/pages/User/sign_up_page.dart';
import 'package:sehatsaja/pages/User/home_page.dart';
import 'package:sehatsaja/pages/Doctor only/home_page_doctor.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:sehatsaja/pages/User/forget_password_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatsaja/shared/notification_service.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class SignInController extends GetxController {
  var obscureText = true.obs;

  void togglePasswordVisibility() {
    obscureText.value = !obscureText.value;
  }
}

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final SignInController controller = Get.put(SignInController());
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Masukkan password anda';
    }
    return null;
  }

  void handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;

      // Initialize reminder system for the user
      await ReminderSystem.to.initializeForUser(uid);

      // Ambil data user dari 'users' collection
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        // Update lastLogin dan updatedAt
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });

        // Ambil seluruh data user sebagai Map
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        // Ambil role
        String role = userData['role'] ?? 'user';

        // Navigasi berdasarkan role
        if (role == 'doctor') {
          Get.offAll(() => HomePageDoctor());
        } else {
          Get.offAll(() => HomePage());
        }
        return;
      } else {
        Get.snackbar(
          'Login Gagal',
          'Data pengguna tidak ditemukan di sistem.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Pengguna tidak ditemukan.';
          break;
        case 'wrong-password':
          errorMessage = 'Password salah.';
          break;
        case 'invalid-email':
          errorMessage = 'Email tidak valid.';
          break;
        default:
          errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      }

      Get.snackbar(
        'Login Gagal',
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 80),
                Text(
                  'Hello!',
                  style: GoogleFonts.poppins(
                    fontSize: 50,
                    fontWeight: medium,
                    color: whiteColor,
                  ),
                ),
                Text(
                  'Welcome to SehatSaja',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: medium,
                    color: whiteColor,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(40.0),
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: lightGreyColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Login',
                        style: GoogleFonts.poppins(
                          fontSize: 40,
                          fontWeight: bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
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
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: validateEmail,
                      ),
                      const SizedBox(height: 20),
                      Obx(
                        () => TextFormField(
                          obscureText: controller.obscureText.value,
                          controller: passwordController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: whiteColor,
                            hintText: 'Password',
                            hintStyle: TextStyle(color: secondaryColor),
                            prefixIcon: PhosphorIcon(
                              PhosphorIconsBold.lockSimple,
                              color: secondaryColor,
                              size: 25.0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40.0),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.obscureText.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: secondaryColor,
                              ),
                              onPressed: controller.togglePasswordVisibility,
                            ),
                          ),
                          validator: validatePassword,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              handleLogin();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'Login',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: bold,
                              color: whiteColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an Account? ",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: medium,
                              color: secondaryColor,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.to(() => SignUpPage());
                            },
                            child: Text(
                              "Sign Up",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: extraBold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.08,
            left: MediaQuery.of(context).size.width * 0.60,
            child: ClipRRect(
              child: Image.asset(
                'assets/pill_red.png',
                width: 250,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

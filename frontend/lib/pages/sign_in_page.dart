import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/shared/theme.dart';

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

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Masukkan email anda';
    }

    // Basic email regex pattern
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
    if (value.length < 8) {
      return 'Password anda harus minimal 8 karakter';
    }
    if (value.length > 20) {
      return 'Password anda harus kurang dari 20 karakter';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    fontWeight: FontWeight.w500,
                    color: whiteColor,
                  ),
                ),
                Text(
                  'Welcome to SehatSaja',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                  bottomLeft: Radius.zero,
                  bottomRight: Radius.zero,
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
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: whiteColor,
                          hintText: 'Enter Your E-mail',
                          hintStyle: TextStyle(color: secondaryColor),
                          prefixIcon: Icon(Icons.email, color: primaryColor),
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
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: whiteColor,
                            hintText: 'Enter Your password',
                            hintStyle: TextStyle(color: secondaryColor),
                            prefixIcon: Icon(Icons.lock, color: primaryColor),
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
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: bold,
                              color: primaryColor,
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
                            if (_formKey.currentState!.validate()) {}
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
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: secondaryColor, // Customize the color
                              thickness: 1, // Adjust the thickness of the line
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "Or login with",
                              style: TextStyle(
                                color:
                                    secondaryColor, // Match the text color with the line
                                fontSize: 16, // Adjust the font size
                                fontWeight: medium, // Make it semi-bold
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color:
                                  secondaryColor, // Same color as the other side
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: SizedBox(
                              width: 60,
                              height: 60,
                              child: Image.asset('assets/logo_google.png'),
                            ),
                            onPressed: () {},
                          ),
                          const SizedBox(width: 40),
                          IconButton(
                            icon: SizedBox(
                              width: 60,
                              height: 60,
                              child: Image.asset('assets/logo_facebook.png'),
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
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
                            onPressed: () {},
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
            top: MediaQuery.of(context).size.height * 0.13,
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

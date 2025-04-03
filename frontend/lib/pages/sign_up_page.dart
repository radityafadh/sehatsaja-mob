import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/shared/theme.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SignUpController extends GetxController {
  var obscureText1 = true.obs;
  var obscureText2 = true.obs;

  void togglePasswordVisibility1() {
    obscureText1.value = !obscureText1.value;
  }

  void togglePasswordVisibility2() {
    obscureText2.value = !obscureText2.value;
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final SignUpController controller = Get.put(SignUpController());
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String? selectedGender;

  // Validators
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Masukkan email anda';
    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(value) ? null : 'Masukkan email yang benar';
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Masukkan password anda';
    if (value.length < 8) return 'Password minimal 8 karakter';
    if (value.length > 20) return 'Password maksimal 20 karakter';
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Masukkan ulang password';
    if (value != passwordController.text) return 'Password tidak sama';
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Masukkan nomor telepon anda';
    final RegExp phoneRegex = RegExp(r'^\+?628\d{9,}$'); // Supports +628 or 628
    return phoneRegex.hasMatch(value)
        ? null
        : 'Masukkan nomor telepon yang benar';
  }

  String? validateGender() {
    if (selectedGender == null) {
      return "Pilih jenis kelamin anda";
    }
    return null;
  }

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      print("Email: ${emailController.text}");
      print("Password: ${passwordController.text}");
      print("Phone: ${phoneController.text}");
      print("Gender: $selectedGender");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          Positioned(
            top: 20,
            left: 270,
            child: Image.asset(
              'assets/pill_red.png',
              width: 250,
              height: 250,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: -140,
            left: -100,
            child: Image.asset(
              'assets/medicine_green.png',
              width: 250,
              height: 250,
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.only(
                top: 20,
                left: 40,
                right: 40,
                bottom: 20,
              ),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              size: 26,
                              color: primaryColor,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Text(
                            'Back to login',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: semiBold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Sign Up',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 40,
                          fontWeight: extraBold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 40),
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
                          controller: passwordController,
                          obscureText: controller.obscureText1.value,
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
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.obscureText1.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: secondaryColor,
                              ),
                              onPressed: controller.togglePasswordVisibility1,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: validatePassword,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Obx(
                        () => TextFormField(
                          controller: confirmPasswordController,
                          obscureText: controller.obscureText2.value,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: whiteColor,
                            hintText: 'Confirm Password',
                            hintStyle: TextStyle(color: secondaryColor),
                            prefixIcon: PhosphorIcon(
                              PhosphorIconsBold.lockSimple,
                              color: secondaryColor,
                              size: 25.0,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.obscureText2.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: secondaryColor,
                              ),
                              onPressed: controller.togglePasswordVisibility2,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: validateConfirmPassword,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: whiteColor,
                          hintText: 'Phone Number',
                          hintStyle: TextStyle(color: secondaryColor),
                          prefixIcon: PhosphorIcon(
                            PhosphorIconsBold.phone,
                            color: secondaryColor,
                            size: 25.0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: validatePhone,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 150,
                            child: ElevatedButton(
                              onPressed:
                                  () => setState(() => selectedGender = "Male"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    selectedGender == "Male"
                                        ? primaryColor
                                        : whiteColor,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  PhosphorIcon(
                                    PhosphorIconsBold.genderMale,
                                    size: 26.0,
                                    color:
                                        selectedGender == "Male"
                                            ? whiteColor
                                            : primaryColor,
                                  ),
                                  Text(
                                    "   Male",
                                    style: TextStyle(
                                      color:
                                          selectedGender == "Male"
                                              ? whiteColor
                                              : primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          SizedBox(
                            width: 150,
                            child: ElevatedButton(
                              onPressed:
                                  () =>
                                      setState(() => selectedGender = "Female"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    selectedGender == "Female"
                                        ? femaleColor
                                        : whiteColor,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  PhosphorIcon(
                                    PhosphorIconsBold.genderFemale,
                                    size: 26.0,
                                    color:
                                        selectedGender == "Male"
                                            ? femaleColor
                                            : whiteColor,
                                  ),
                                  Text(
                                    "   Female",
                                    style: TextStyle(
                                      color:
                                          selectedGender == "Female"
                                              ? whiteColor
                                              : femaleColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (validateGender() != null)
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            validateGender()!,
                            style: TextStyle(color: Color(0xFFBA433B)),
                          ),
                        ),
                      const SizedBox(height: 70),
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 300,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40.0),
                              ),
                              backgroundColor: primaryColor,
                              textStyle: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: semiBold,
                                color: whiteColor,
                              ),
                            ),
                            onPressed: submitForm,
                            child: Text(
                              "Sign up",
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: semiBold,
                                color: whiteColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

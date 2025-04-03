import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/shared/theme.dart';
import 'package:frontend/widgets/dialog_status.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class RenamePasswordPageController extends GetxController {
  var obscureText1 = true.obs;
  var obscureText2 = true.obs;

  void togglePasswordVisibility1() {
    obscureText1.value = !obscureText1.value;
  }

  void togglePasswordVisibility2() {
    obscureText2.value = !obscureText2.value;
  }
}

class RenamePasswordPage extends StatefulWidget {
  RenamePasswordPage({Key? key}) : super(key: key);

  @override
  State<RenamePasswordPage> createState() => _RenamePasswordPageState();
}

class _RenamePasswordPageState extends State<RenamePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final RenamePasswordPageController controller = Get.put(
    RenamePasswordPageController(),
  );

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'masukkan password anda';
    }
    if (value.length < 8) {
      return 'Password anda harus minimal 8 karakter';
    }
    if (value.length > 20) {
      return 'Password anda harus kurang dari 20 karakter';
    }
    return null;
  }

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Masukkan ulang password';
    if (value != passwordController.text) return 'Password tidak sama';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGreyColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 120),
              Text(
                'Reset Your Password',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: extraBold,
                  color: blackColor,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'Enter you new Password',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: regular,
                  color: blackColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 100),
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
              const SizedBox(height: 120),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return StatusDialog(
                            isSuccess: true,
                            message: 'Your password is succesfully created',
                          );
                        },
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return StatusDialog(
                            isSuccess: false,
                            message: 'Please input the correct password',
                          );
                        },
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Next',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: bold,
                      color: whiteColor,
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

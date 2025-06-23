import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sehatsaja/shared/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'profile_page.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  DateTime? selectedBirthDate;

  String name = '';
  String email = '';
  String birthDate = '';
  String phone = '';
  String? profileImageBase64;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      name = data['name'] ?? '';
      email = data['email'] ?? '';
      birthDate = data['birthDate'] ?? '';
      phone = data['phone'] ?? '';
      profileImageBase64 = data['photoUrl'];

      nameController.text = name;
      emailController.text = FirebaseAuth.instance.currentUser!.email ?? '';
      phoneController.text = phone;

      if (data['birthDate'] != null &&
          data['birthDate'].toString().trim().isNotEmpty) {
        try {
          selectedBirthDate = DateFormat(
            'dd MMMM yyyy',
          ).parse(data['birthDate']);
        } catch (e) {
          print('Failed to parse birthDate: ${data['birthDate']}');
        }
      }
      setState(() {});
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();

      // Tentukan MIME type berdasarkan ekstensi file
      String mimeType;
      if (pickedFile.path.endsWith('.png')) {
        mimeType = 'image/png';
      } else {
        mimeType = 'image/jpeg'; // default fallback
      }

      setState(() {
        profileImageBase64 = 'data:$mimeType;base64,${base64Encode(bytes)}';
      });
    }
  }

  Future<void> saveChanges() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final name = nameController.text.trim();

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'name': name,
      'email': emailController.text.trim(),
      'phone': phoneController.text.trim(),
      'birthDate':
          selectedBirthDate != null
              ? DateFormat('dd MMMM yyyy').format(selectedBirthDate!)
              : '',
      'photoUrl': profileImageBase64 ?? '',
    });

    Get.off(() => const ProfilePage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: blackColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: blackColor),
          onPressed: () {
            Get.to(ProfilePage());
          },
        ),
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.only(top: 5, left: 40, right: 40.0),
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
                    Center(
                      child: Text(
                        'Edit Profile',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: blackColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Center(
                      child: Text(
                        'Update your profile information',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: blackColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: pickImage,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child:
                              profileImageBase64 != null &&
                                      profileImageBase64!.isNotEmpty
                                  ? Image.memory(
                                    base64Decode(
                                      profileImageBase64!.contains(',')
                                          ? profileImageBase64!.split(',').last
                                          : profileImageBase64!,
                                    ),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                  : Image.asset(
                                    'assets/profile.png',
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    buildLabel('Name'),
                    buildTextField(nameController),
                    const SizedBox(height: 10),
                    buildLabel('Email'),
                    buildTextField(emailController),
                    const SizedBox(height: 10),
                    buildLabel('Birth Date'),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedBirthDate ?? DateTime(2000),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedBirthDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          selectedBirthDate != null
                              ? DateFormat(
                                'dd MMMM yyyy',
                              ).format(selectedBirthDate!)
                              : 'Pick your birth date',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color:
                                selectedBirthDate != null
                                    ? blackColor
                                    : greyColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    buildLabel('Phone Number'),
                    buildTextField(
                      phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: saveChanges,
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
                            fontWeight: FontWeight.w600,
                            color: blackColor,
                          ),
                        ),
                      ),
                    ),
                    // Add other buttons here if needed
                  ],
                ),
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
        fontWeight: FontWeight.bold,
        color: greyColor,
      ),
    );
  }

  Widget buildTextField(
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
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

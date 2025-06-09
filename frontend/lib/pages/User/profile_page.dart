import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/shared/theme.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'forget_password_page.dart';
import 'package:frontend/widgets/dialog_signout.dart';
import 'package:frontend/pages/User/edit_profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/pages/User/setting_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = '';
  String email = '';
  String birthDate = '';
  String phoneNumber = '';
  String photoUrl = '';
  Uint8List? photoBytes;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        name = data['name'] ?? '';
        email = data['email'] ?? '';
        birthDate = data['birthDate'] ?? '';
        phoneNumber = (data['phone'] ?? '').toString();
        photoUrl = data['photoUrl'] ?? '';

        photoBytes = null;
        if (photoUrl.isNotEmpty) {
          try {
            // Handle base64 with data URL prefix
            if (photoUrl.startsWith('data:image')) {
              final base64Str = photoUrl.split(',').last;
              photoBytes = base64Decode(base64Str);
            } else {
              // Try to decode directly (for raw base64)
              photoBytes = base64Decode(photoUrl);
            }
          } catch (e) {
            photoBytes = null; // Fallback to network or asset
          }
        }
      });
    }
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
            Get.to(SettingPage());
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
                    _buildProfileField('Name', name),
                    const SizedBox(height: 10),
                    _buildProfileField('Email', email),
                    const SizedBox(height: 10),
                    _buildProfileField('Birth', birthDate),
                    const SizedBox(height: 10),
                    _buildProfileField('Phone Number', phoneNumber),
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
                        const Spacer(),
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
                    const SizedBox(height: 20),
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
              borderRadius: BorderRadius.circular(50),
              child: Builder(
                builder: (context) {
                  if (photoBytes != null) {
                    // tampilkan base64 decode image
                    return Image.memory(
                      photoBytes!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    );
                  } else if (photoUrl.isNotEmpty) {
                    // tampilkan url image
                    return Image.network(
                      photoUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // fallback ke asset kalau gagal load url
                        return Image.asset(
                          'assets/profile.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        );
                      },
                    );
                  } else {
                    // fallback default asset
                    return Image.asset(
                      'assets/profile.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
            value.isNotEmpty ? value : '...',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: bold,
              color: blackColor,
            ),
          ),
        ),
      ],
    );
  }
}

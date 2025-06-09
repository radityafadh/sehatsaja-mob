import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/shared/theme.dart';
import 'package:frontend/pages/User/detail_doctor_page.dart';

class Carddoctor extends StatefulWidget {
  final String uid;

  const Carddoctor({Key? key, required this.uid}) : super(key: key);

  @override
  State<Carddoctor> createState() => _CarddoctorState();
}

class _CarddoctorState extends State<Carddoctor> {
  String name = '';
  String role = '';
  String specialization = '';
  String photoUrl = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDoctorData();
  }

  Future<void> fetchDoctorData() async {
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.uid)
              .get();

      if (doc.exists) {
        setState(() {
          name = doc['name'] ?? '';
          role = doc['role'] ?? '';
          specialization = doc['specialization'] ?? '';
          photoUrl = doc['photoUrl'] ?? '';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching doctor data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.4,
      height: screenHeight * 0.25,
      padding: EdgeInsets.all(screenWidth * 0.02),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(screenWidth * 0.08),
        border: Border.all(color: primaryColor, width: 2.0),
      ),
      child:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Doctor Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    child:
                        photoUrl.startsWith('data:image')
                            ? Image.memory(
                              Uri.parse(photoUrl).data!.contentAsBytes(),
                              width: screenWidth * 0.15,
                              height: screenWidth * 0.15,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/default_user.png',
                                  width: screenWidth * 0.15,
                                  height: screenWidth * 0.15,
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                            : Image.asset(
                              'assets/default_user.png',
                              width: screenWidth * 0.15,
                              height: screenWidth * 0.15,
                              fit: BoxFit.cover,
                            ),
                  ),

                  // Doctor Name with overflow handling
                  SizedBox(
                    width: screenWidth * 0.35,
                    child: Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.04, // Slightly reduced
                        fontWeight: bold,
                        color: blackColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Specialization/Role with overflow handling
                  SizedBox(
                    width: screenWidth * 0.35,
                    child: Text(
                      specialization.isNotEmpty ? specialization : role,
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.032, // Slightly reduced
                        fontWeight: regular,
                        color: blackColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Detail Button
                  ElevatedButton(
                    onPressed: () {
                      Get.to(() => DetailDoctorPage(uid: widget.uid));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.08),
                      ),
                      minimumSize: Size(screenWidth * 0.3, screenHeight * 0.04),
                    ),
                    child: Text(
                      'Detail',
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.bold,
                        color: whiteColor,
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}

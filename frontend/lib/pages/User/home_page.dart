import 'package:flutter/material.dart';
import 'package:frontend/pages/User/news_detail_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:frontend/shared/theme.dart';
import 'package:frontend/widgets/cardobat.dart';
import 'package:frontend/widgets/navbar.dart';
import 'package:frontend/widgets/cardnews.dart';
import 'package:get/get.dart';
import 'package:frontend/pages/User/medicine_pick_page.dart';
import 'package:frontend/pages/User/setting_page.dart';
import 'package:frontend/pages/User/medical_article_page.dart';
import 'package:frontend/pages/User/chat_page.dart';
import 'package:frontend/widgets/map_widget.dart';
import 'package:frontend/pages/User/map_screen_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:typed_data';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndexpages = 0;
  String name = 'Loading...';
  Uint8List? profilePhotoBytes;
  String profilePhotoUrl = '';
  Map<String, dynamic>? upcomingAppointment;
  bool isLoadingAppointment = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchUpcomingAppointment();
  }

  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => name = 'Guest');
      return;
    }

    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (doc.exists) {
        setState(() {
          name = doc['name'] ?? 'Guest';
          profilePhotoUrl = doc['photoUrl'] ?? '';
          profilePhotoBytes = null;

          if (profilePhotoUrl.isNotEmpty) {
            try {
              // If the string starts with a base64 data URI, remove the prefix
              final base64PrefixRegex = RegExp(r'data:image/[^;]+;base64,');
              final cleanedBase64 = profilePhotoUrl.replaceFirst(
                base64PrefixRegex,
                '',
              );

              profilePhotoBytes = base64Decode(cleanedBase64);
            } catch (e) {
              print('Failed to decode base64 image: $e');
              profilePhotoBytes = null;
            }
          }
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() => name = 'Guest');
    }
  }

  Future<void> fetchUpcomingAppointment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('Debug: No user logged in');
      setState(() {
        isLoadingAppointment = false;
        upcomingAppointment = null;
      });
      return;
    }

    try {
      final now = DateTime.now();
      final todayString = DateFormat('yyyy-MM-dd').format(now);
      final currentTime = DateFormat('HH:mm').format(now);

      print('Debug: Fetching appointments for patient ${user.uid}');
      print('Debug: Current date: $todayString, time: $currentTime');

      // Query for today's confirmed appointments that haven't passed yet
      final todayQuery = FirebaseFirestore.instance
          .collection('appointments')
          .where('patientId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'confirmed')
          .where('appointmentDate', isEqualTo: todayString)
          .where('appointmentTime', isGreaterThanOrEqualTo: currentTime)
          .orderBy('appointmentTime')
          .limit(1);

      // Query for future confirmed appointments
      final futureQuery = FirebaseFirestore.instance
          .collection('appointments')
          .where('patientId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'confirmed')
          .where('appointmentDate', isGreaterThan: todayString)
          .orderBy('appointmentDate')
          .orderBy('appointmentTime')
          .limit(1);

      print('Debug: Executing todayQuery...');
      final todaySnapshot = await todayQuery.get();
      print('Debug: todayQuery returned ${todaySnapshot.docs.length} results');

      print('Debug: Executing futureQuery...');
      final futureSnapshot = await futureQuery.get();
      print(
        'Debug: futureQuery returned ${futureSnapshot.docs.length} results',
      );

      DocumentSnapshot? upcomingDoc;

      if (todaySnapshot.docs.isNotEmpty) {
        upcomingDoc = todaySnapshot.docs.first;
      } else if (futureSnapshot.docs.isNotEmpty) {
        upcomingDoc = futureSnapshot.docs.first;
      }

      if (upcomingDoc != null) {
        final appointment = upcomingDoc.data() as Map<String, dynamic>;
        print('Debug: Found upcoming appointment: ${appointment.toString()}');
        setState(() {
          isLoadingAppointment = false;
          upcomingAppointment = appointment;
        });
      } else {
        print('Debug: No upcoming appointments found');
        setState(() {
          isLoadingAppointment = false;
          upcomingAppointment = null;
        });
      }
    } catch (e) {
      print('Error fetching appointment: $e');
      setState(() {
        isLoadingAppointment = false;
        upcomingAppointment = null;
      });
    }
  }

  Widget _buildUpcomingAppointment() {
    if (isLoadingAppointment) {
      return Center(child: CircularProgressIndicator());
    }

    if (upcomingAppointment == null) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: Center(
          child: Text(
            'No upcoming appointments',
            style: GoogleFonts.poppins(fontSize: 16, color: blackColor),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Removed the profile image widget here
              const SizedBox(width: 20.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      upcomingAppointment!['doctorName'] ?? 'Doctor',
                      style: TextStyle(
                        color: whiteColor,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      upcomingAppointment!['specialization'] ??
                          'Specialization',
                      style: TextStyle(color: whiteColor, fontSize: 16.0),
                    ),
                    if (upcomingAppointment!['complaint'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Complaint: ${upcomingAppointment!['complaint']}',
                          style: TextStyle(color: whiteColor, fontSize: 14.0),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15.0),
          Container(
            padding: const EdgeInsets.all(7.0),
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: PhosphorIcon(
                    PhosphorIconsBold.calendarDots,
                    color: whiteColor,
                    size: 25.0,
                  ),
                ),
                const SizedBox(width: 5.0),
                Text(
                  '${upcomingAppointment!['date']} • ${upcomingAppointment!['time']}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: medium,
                    color: whiteColor,
                  ),
                ),
                const SizedBox(width: 10.0),
                Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: PhosphorIcon(
                    PhosphorIconsBold.currencyDollar,
                    color: whiteColor,
                    size: 25.0,
                  ),
                ),
                const SizedBox(width: 5.0),
                Text(
                  upcomingAppointment!['priceDisplay'] ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: medium,
                    color: whiteColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGreyColor,
      body: ListView(
        padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0),
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello,',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: bold,
                      color: blackColor,
                    ),
                  ),
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(25.0),
                ),
                height: 60.0,
                child: GestureDetector(
                  onTap: () => Get.to(SettingPage()),
                  child: Row(
                    children: [
                      PhosphorIcon(
                        PhosphorIconsBold.bell,
                        color: blackColor,
                        size: 25.0,
                      ),
                      const SizedBox(width: 16.0),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child:
                            profilePhotoBytes != null
                                ? Image.memory(
                                  profilePhotoBytes!,
                                  width: 36,
                                  height: 36,
                                  fit: BoxFit.cover,
                                )
                                : Image.asset(
                                  'assets/profile.png',
                                  width: 36,
                                  height: 36,
                                  fit: BoxFit.cover,
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                'Upcoming Appointment',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: bold,
                  color: blackColor,
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward, size: 30, color: primaryColor),
                onPressed: () => Get.to(ChatPage()),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildUpcomingAppointment(),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                "Today's Medicine",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: bold,
                  color: blackColor,
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward, size: 30, color: primaryColor),
                onPressed: () {
                  Get.to(() => MedicinePickPage());
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          FutureBuilder<QuerySnapshot>(
            future:
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('medicines')
                    .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Text(
                  'No medicine scheduled for today.',
                  style: GoogleFonts.poppins(color: blackColor),
                );
              }

              DateTime today = DateTime.now();
              final currentUser = FirebaseAuth.instance.currentUser;

              List<DocumentSnapshot> todayMedicines =
                  snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    DateTime? startDate = DateTime.tryParse(
                      data['startDate'] ?? '',
                    );
                    DateTime? endDate = DateTime.tryParse(
                      data['endDate'] ?? '',
                    );

                    if (startDate == null || endDate == null) return false;

                    return !today.isBefore(startDate) &&
                        !today.isAfter(endDate);
                  }).toList();

              if (todayMedicines.isEmpty) {
                return Text(
                  'No medicine scheduled for today.',
                  style: GoogleFonts.poppins(color: blackColor),
                );
              }

              return Column(
                children:
                    todayMedicines.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      data['id'] = doc.id;
                      if (currentUser != null) {
                        data['uid'] = currentUser.uid;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Cardobat(medicineData: data),
                      );
                    }).toList(),
              );
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                "Medical Article",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: bold,
                  color: blackColor,
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward, size: 30, color: primaryColor),
                onPressed: () {
                  Get.to(() => MedicalArticlePage());
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 250,
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('news')
                      .orderBy('date', descending: true)
                      .limit(5)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No recent articles found.'));
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot document = snapshot.data!.docs[index];
                    String articleId = document.id;

                    return Padding(
                      padding: EdgeInsets.only(
                        right:
                            index == snapshot.data!.docs.length - 1 ? 0 : 10.0,
                      ),
                      child: CardNews(id: articleId),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                "Find Nearby Hospital!",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: bold,
                  color: blackColor,
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward, size: 30, color: primaryColor),
                onPressed: () {
                  Get.to(() => MapScreen());
                },
              ),
            ],
          ),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primaryColor, width: 4),
            ),
            child: const ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              child: MapWidget(),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        onItemTapped: (index) {
          setState(() => selectedIndexpages = index);
        },
        currentIndex: 0,
        uid: FirebaseAuth.instance.currentUser?.uid ?? '',
      ),
    );
  }
}

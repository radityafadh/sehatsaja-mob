import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:sehatsaja/shared/theme.dart';
import 'package:sehatsaja/widgets/cardobat.dart';
import 'package:sehatsaja/widgets/cardnews.dart';
import 'package:get/get.dart';
import 'package:sehatsaja/pages/User/medicine_pick_page.dart';
import 'package:sehatsaja/pages/User/setting_page.dart';
import 'package:sehatsaja/pages/User/medical_article_page.dart';
import 'package:sehatsaja/pages/Doctor only/chat_page_doctor.dart';
import 'package:sehatsaja/widgets/map_widget.dart';
import 'package:sehatsaja/pages/User/map_screen_page.dart';
import 'package:sehatsaja/pages/Doctor only/E-money.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatsaja/widgets/navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:typed_data';

class HomePageDoctor extends StatefulWidget {
  const HomePageDoctor({Key? key}) : super(key: key);

  @override
  _HomePageDoctorState createState() => _HomePageDoctorState();
}

class _HomePageDoctorState extends State<HomePageDoctor> {
  int selectedIndexpages = 0;
  String name = 'Loading...';
  Uint8List? profilePhotoBytes;
  String profilePhotoUrl = '';
  Map<String, dynamic>? upcomingAppointment;
  bool isLoadingAppointment = true;
  double totalBalance = 0.0;
  bool isLoadingBalance = true;
  List<Map<String, dynamic>> doctorAppointments = [];

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchUpcomingAppointment();
    fetchDoctorBalanceAndAppointments();
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

  Future<void> fetchDoctorBalanceAndAppointments() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('🔥 [DEBUG] No user logged in - aborting balance fetch');
      setState(() {
        isLoadingBalance = false;
        totalBalance = 0.0;
        doctorAppointments = [];
      });
      return;
    }

    debugPrint('🔄 [DEBUG] Starting balance fetch for doctor ${user.uid}');

    try {
      // 1. Get all completed payments for this doctor
      debugPrint('🔍 [DEBUG] Querying completed payments');
      final paymentsQuery =
          await FirebaseFirestore.instance
              .collection('payments')
              .where('status', isEqualTo: 'completed')
              .get();

      // 2. Fetch appointments for each payment
      List<Map<String, dynamic>> fetchedAppointments = [];
      double totalPayments = 0.0;

      for (var paymentDoc in paymentsQuery.docs) {
        final paymentData = paymentDoc.data();
        final appointmentId = paymentData['appointmentId'] as String?;

        if (appointmentId == null) {
          debugPrint(
            '⚠️ [DEBUG] Payment ${paymentDoc.id} has no appointmentId',
          );
          continue;
        }

        try {
          final appointmentDoc =
              await FirebaseFirestore.instance
                  .collection('appointments')
                  .doc(appointmentId)
                  .get();

          if (appointmentDoc.exists) {
            final appointmentData = appointmentDoc.data()!;
            final appointmentPrice = (appointmentData['price'] ?? 0) as num;
            totalPayments += appointmentPrice.toDouble();

            fetchedAppointments.add({
              'payment': paymentData,
              'appointment': appointmentData,
            });
          }
        } catch (e) {
          debugPrint('❌ [DEBUG] Error fetching appointment $appointmentId: $e');
        }
      }

      // 3. Get withdrawals for this doctor - IMPROVED QUERY
      debugPrint('🔍 [DEBUG] Querying withdrawals for doctor ${user.uid}');
      final withdrawalsQuery =
          await FirebaseFirestore.instance
              .collection('payments')
              .where('type', isEqualTo: 'withdrawal')
              .where('status', isEqualTo: 'confirmed')
              .where('doctorId', isEqualTo: user.uid)
              .get();

      // Debug print withdrawals
      debugPrint(
        'ℹ️ [DEBUG] Found ${withdrawalsQuery.docs.length} withdrawals',
      );
      for (var doc in withdrawalsQuery.docs) {
        debugPrint('ℹ️ [DEBUG] Withdrawal doc ID: ${doc.id}');
        debugPrint('ℹ️ [DEBUG] Withdrawal data: ${doc.data()}');
      }

      // Calculate total withdrawals
      double totalWithdrawals = withdrawalsQuery.docs.fold(0.0, (sum, doc) {
        final amount = (doc.data()['amount'] ?? 0) as num;
        debugPrint('ℹ️ [DEBUG] Adding withdrawal amount: $amount');
        return sum + amount.toDouble();
      });

      // Calculate final balance (payments minus withdrawals)
      final calculatedBalance = totalPayments - totalWithdrawals;

      debugPrint('💰 [DEBUG] Balance Calculation:');
      debugPrint('💰 [DEBUG] Total Payments: $totalPayments');
      debugPrint('💰 [DEBUG] Total Withdrawals: $totalWithdrawals');
      debugPrint('💰 [DEBUG] Final Balance: $calculatedBalance');

      setState(() {
        isLoadingBalance = false;
        totalBalance = calculatedBalance;
        doctorAppointments = fetchedAppointments;
      });
    } catch (e, stackTrace) {
      debugPrint('❌ [DEBUG] Error: $e\n$stackTrace');
      setState(() {
        isLoadingBalance = false;
        doctorAppointments = [];
      });

      // Temporary test query for debugging
      try {
        debugPrint('🛠️ [DEBUG] Running test query...');
        const testDocId = 'KNOWN_DOCUMENT_ID'; // Replace with actual ID
        final testQuery =
            await FirebaseFirestore.instance
                .collection('transactions')
                .doc(testDocId)
                .get();

        if (testQuery.exists) {
          debugPrint('ℹ️ [DEBUG] Test doc exists: ${testQuery.data()}');
        } else {
          debugPrint('⚠️ [DEBUG] Test doc does not exist!');
        }
      } catch (testError) {
        debugPrint('❌ [DEBUG] Test query error: $testError');
      }
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

      // Query for today's confirmed appointments
      final todayQuery = FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'confirmed')
          .where('appointmentDate', isEqualTo: todayString)
          .orderBy('appointmentTime');

      print('Debug: Executing todayQuery...');
      final todaySnapshot = await todayQuery.get();
      print('Debug: todayQuery returned ${todaySnapshot.docs.length} results');

      DocumentSnapshot? upcomingDoc;

      // First, check if there's an ongoing appointment (started but not finished)
      for (var doc in todaySnapshot.docs) {
        final appointment = doc.data() as Map<String, dynamic>;
        final apptTime = appointment['appointmentTime'] as String;
        final duration =
            appointment['duration'] as int? ?? 30; // default 30 minutes

        // Parse time to DateTime for comparison
        final apptDateTime = DateFormat(
          'yyyy-MM-dd HH:mm',
        ).parse('$todayString $apptTime');
        final endTime = apptDateTime.add(Duration(minutes: duration));

        if (now.isAfter(apptDateTime)) {
          if (now.isBefore(endTime)) {
            // This is an ongoing appointment
            print('Debug: Found ongoing appointment');
            upcomingDoc = doc;
            break;
          }
        }
      }

      // If no ongoing appointment, find the next upcoming appointment today
      if (upcomingDoc == null) {
        for (var doc in todaySnapshot.docs) {
          final appointment = doc.data() as Map<String, dynamic>;
          final apptTime = appointment['appointmentTime'] as String;

          if (apptTime.compareTo(currentTime) >= 0) {
            // This is an upcoming appointment today
            print('Debug: Found upcoming appointment today');
            upcomingDoc = doc;
            break;
          }
        }
      }

      // If no appointments today, look for future appointments
      if (upcomingDoc == null) {
        print('Debug: Looking for future appointments');
        final futureQuery = FirebaseFirestore.instance
            .collection('appointments')
            .where('patientId', isEqualTo: user.uid)
            .where('status', isEqualTo: 'confirmed')
            .where('appointmentDate', isGreaterThan: todayString)
            .orderBy('appointmentDate')
            .orderBy('appointmentTime')
            .limit(1);

        print('Debug: Executing futureQuery...');
        final futureSnapshot = await futureQuery.get();
        print(
          'Debug: futureQuery returned ${futureSnapshot.docs.length} results',
        );

        if (futureSnapshot.docs.isNotEmpty) {
          upcomingDoc = futureSnapshot.docs.first;
        }
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
              const SizedBox(width: 20.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      upcomingAppointment!['patientName'] ?? 'Patient',
                      style: TextStyle(
                        color: whiteColor,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Patient',
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
                  '${upcomingAppointment!['appointmentDate']} • ${upcomingAppointment!['appointmentTime']}',
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
                                  'assets/doctor.png',
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
          Text(
            "Saldo Tersedia",
            style: GoogleFonts.poppins(
              fontSize: 30,
              fontWeight: bold,
              color: blackColor,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isLoadingBalance)
                      CircularProgressIndicator(color: whiteColor)
                    else
                      Text(
                        'Rp. ${NumberFormat("#,###").format(totalBalance)}',
                        style: GoogleFonts.poppins(
                          fontSize: 40,
                          fontWeight: regular,
                          color: whiteColor,
                        ),
                      ),
                    Text(
                      'Total Saldo',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: regular,
                        color: whiteColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Get.to(EMoneyPage());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: whiteColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Transfer bank',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
                onPressed: () => Get.to(ChatPageDoctor()),
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

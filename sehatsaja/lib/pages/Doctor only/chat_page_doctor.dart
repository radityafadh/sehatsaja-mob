import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sehatsaja/widgets/navbar.dart';
import 'package:sehatsaja/pages/Doctor%20only/detail_doctor_page_doctor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:sehatsaja/shared/theme.dart';
import 'package:sehatsaja/widgets/chatbox.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPageDoctor extends StatefulWidget {
  const ChatPageDoctor({Key? key}) : super(key: key);

  @override
  _ChatPageDoctorState createState() => _ChatPageDoctorState();
}

class _ChatPageDoctorState extends State<ChatPageDoctor> {
  int selectedIndexpages = 2;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
  }

  bool _isAppointmentActive(Map<String, dynamic> appointmentData) {
    try {
      final dateStr = appointmentData['appointmentDate'] as String?;
      final timeStr = appointmentData['appointmentTime'] as String?;

      if (dateStr == null || timeStr == null) return false;

      // Parse date (assuming format is 'yyyy-MM-dd')
      final dateParts = dateStr.split('-');
      if (dateParts.length != 3) return false;

      // Parse start time (assuming format is 'HH:mm-HH:mm')
      final startTime = timeStr.split('-').first.split(':');
      if (startTime.length != 2) return false;

      // Create DateTime for appointment start
      final appointmentStart = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        int.parse(startTime[0]),
        int.parse(startTime[1]),
      );

      // Consider appointment active if current time is within 30 minutes before start time
      return DateTime.now().isAfter(
        appointmentStart.subtract(Duration(minutes: 30)),
      );
    } catch (e) {
      print('Error parsing appointment time: $e');
      return false;
    }
  }

  bool _isAppointmentInFuture(Map<String, dynamic> appointmentData) {
    try {
      final dateStr = appointmentData['appointmentDate'] as String?;
      final timeStr = appointmentData['appointmentTime'] as String?;

      if (dateStr == null || timeStr == null) return false;

      final dateParts = dateStr.split('-');
      if (dateParts.length != 3) return false;

      final startTime = timeStr.split('-').first.split(':');
      if (startTime.length != 2) return false;

      final appointmentDateTime = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        int.parse(startTime[0]),
        int.parse(startTime[1]),
      );

      // Check if appointment is in the future (including buffer time)
      return DateTime.now().isBefore(
        appointmentDateTime.add(Duration(hours: 1)),
      );
    } catch (e) {
      print('Error checking future appointment: $e');
      return false;
    }
  }

  Widget _buildPatientImage(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) {
      return Image.asset(
        'assets/profile.png',
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      );
    }

    try {
      if (photoUrl.startsWith('data:image')) {
        final base64String = photoUrl.split(',').last;
        final bytes = base64Decode(base64String);
        return Image.memory(bytes, width: 50, height: 50, fit: BoxFit.cover);
      } else {
        return Image.network(
          photoUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/profile.png',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            );
          },
        );
      }
    } catch (e) {
      return Image.asset(
        'assets/profile.png',
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Prevent keyboard from pushing content up
      appBar: AppBar(
        title: Text(
          'Chat',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: bold,
            color: blackColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: lightGreyColor,
        elevation: 0,
      ),
      backgroundColor: lightGreyColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          children: [
            const SizedBox(height: 16.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.to(
                    () => DetailDoctorPageDoctor(uid: currentUserId ?? ''),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: whiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: BorderSide(color: primaryColor, width: 2.0),
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                ),
                child: Text(
                  'Profile Detail',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: semiBold,
                    color: blackColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('appointments')
                        .where('doctorId', isEqualTo: currentUserId)
                        .where('status', isEqualTo: 'confirmed')
                        .snapshots(),
                builder: (context, appointmentSnapshot) {
                  if (appointmentSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!appointmentSnapshot.hasData ||
                      appointmentSnapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No confirmed appointments',
                        style: GoogleFonts.poppins(color: blackColor),
                      ),
                    );
                  }

                  // Filter out past appointments
                  final validAppointments =
                      appointmentSnapshot.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return _isAppointmentInFuture(data) ||
                            _isAppointmentActive(data);
                      }).toList();

                  if (validAppointments.isEmpty) {
                    return Center(
                      child: Text(
                        'No upcoming appointments',
                        style: GoogleFonts.poppins(color: blackColor),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: validAppointments.length,
                    separatorBuilder: (context, index) => SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final appointment = validAppointments[index];
                      final appointmentData =
                          appointment.data() as Map<String, dynamic>;
                      final patientId = appointmentData['patientId'];
                      final isActive = _isAppointmentActive(appointmentData);

                      return StreamBuilder<DocumentSnapshot>(
                        stream:
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(patientId)
                                .snapshots(),
                        builder: (context, patientSnapshot) {
                          if (!patientSnapshot.hasData) {
                            return Opacity(
                              opacity: isActive ? 1.0 : 0.6,
                              child: Chatbox(
                                image: 'assets/profile.png',
                                name: 'Loading...',
                                snippets:
                                    'Appointment on ${appointmentData['appointmentDate']} at ${appointmentData['appointmentTime']?.split('-').first ?? ''}',
                                day: isActive ? 'Active Now' : 'Upcoming',
                                time:
                                    appointmentData['time']?.split('-').first ??
                                    '',
                                onPressed: () {
                                  if (!isActive) {
                                    Get.snackbar(
                                      'Appointment Not Started',
                                      'This chat will be available 30 minutes before your appointment time',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.orange,
                                    );
                                    return;
                                  }
                                  Get.toNamed(
                                    '/chatroom-doctor',
                                    parameters: {
                                      'appointmentId': appointment.id,
                                      'doctorId': currentUserId ?? '',
                                      'patientId': patientId,
                                    },
                                  );
                                },
                              ),
                            );
                          }

                          final patientData =
                              patientSnapshot.data!.data()
                                  as Map<String, dynamic>?;
                          final patientName = patientData?['name'] ?? 'Patient';
                          final photoUrl = patientData?['photoUrl'];

                          return Opacity(
                            opacity: isActive ? 1.0 : 0.6,
                            child: Chatbox(
                              imageWidget: _buildPatientImage(photoUrl),
                              name: patientName,
                              snippets:
                                  'Appointment on ${appointmentData['date']} at ${appointmentData['time']?.split('-').first ?? ''}',
                              day: isActive ? 'Active Now' : 'Upcoming',
                              time:
                                  appointmentData['time']?.split('-').first ??
                                  '',
                              onPressed: () {
                                if (!isActive) {
                                  Get.snackbar(
                                    'Appointment Not Started',
                                    'This chat will be available 30 minutes before your appointment time',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.orange,
                                  );
                                  return;
                                }
                                Get.toNamed(
                                  '/chatroom-doctor',
                                  parameters: {
                                    'appointmentId': appointment.id,
                                    'doctorId': currentUserId ?? '',
                                    'patientId': patientId,
                                  },
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        onItemTapped: (index) {
          setState(() {
            selectedIndexpages = index;
          });
        },
        currentIndex: 2,
        uid: currentUserId ?? '',
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/shared/theme.dart';
import 'package:frontend/pages/User/pick_doctor_page.dart';
import 'package:get/get.dart';
import 'package:frontend/widgets/chatbox.dart';
import 'package:frontend/widgets/navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

class ChatRoomController extends GetxController {
  final messages = <Map<String, dynamic>>[].obs;
  final messageController = TextEditingController();
  final isTyping = false.obs;
  final isLoading = true.obs;
  final doctorData = <String, dynamic>{}.obs;

  late String appointmentId;
  late String doctorId;
  late String patientId;
  late User? currentUser;
  late StreamSubscription<QuerySnapshot> _messagesSubscription;
  late StreamSubscription<DocumentSnapshot> _appointmentSubscription;

  @override
  void onInit() {
    super.onInit();
    currentUser = FirebaseAuth.instance.currentUser;
    appointmentId = Get.parameters['appointmentId'] ?? '';
    doctorId = Get.parameters['doctorId'] ?? '';
    patientId = Get.parameters['patientId'] ?? '';
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      // Load doctor data
      final doctorDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(doctorId)
              .get();
      doctorData.value = doctorDoc.data() ?? {};

      // Setup real-time listeners
      _setupMessageListener();
      _setupAppointmentListener();

      // Mark messages as read when opening chat
      await _markMessagesAsRead();

      isLoading.value = false;
    } catch (e) {
      print('Error initializing chat: $e');
      isLoading.value = false;
    }
  }

  void _setupMessageListener() {
    _messagesSubscription = FirebaseFirestore.instance
        .collection('appointments')
        .doc(appointmentId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((snapshot) {
          messages.assignAll(
            snapshot.docs.map((doc) {
              return {...doc.data(), 'id': doc.id};
            }),
          );
        });
  }

  void _setupAppointmentListener() {
    _appointmentSubscription = FirebaseFirestore.instance
        .collection('appointments')
        .doc(appointmentId)
        .snapshots()
        .listen((snapshot) {
          // Update typing indicators or other appointment status
          if (currentUser?.uid == patientId) {
            isTyping.value = snapshot.data()?['doctorTyping'] == true;
          } else {
            isTyping.value = snapshot.data()?['patientTyping'] == true;
          }
        });
  }

  Future<void> _markMessagesAsRead() async {
    if (currentUser == null) return;

    final unreadMessages = messages.where(
      (msg) => msg['senderId'] != currentUser?.uid && !(msg['read'] ?? false),
    );

    if (unreadMessages.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    for (final msg in unreadMessages) {
      final docRef = FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .collection('messages')
          .doc(msg['id']);
      batch.update(docRef, {'read': true});
    }

    await batch.commit();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || currentUser == null) return;

    final isDoctor = currentUser!.uid == doctorId;
    final newMessage = {
      'text': text.trim(),
      'senderId': currentUser!.uid,
      'isDoctor': isDoctor,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    };

    try {
      // Add to messages subcollection
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .collection('messages')
          .add(newMessage);

      // Update last message in appointment document
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .update({
            'lastMessage': text.trim(),
            'lastMessageTime': FieldValue.serverTimestamp(),
            if (isDoctor) 'doctorTyping': false,
            if (!isDoctor) 'patientTyping': false,
          });

      messageController.clear();
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  void setTyping(bool typing) {
    if (currentUser == null) return;

    final field =
        currentUser!.uid == doctorId ? 'doctorTyping' : 'patientTyping';

    FirebaseFirestore.instance
        .collection('appointments')
        .doc(appointmentId)
        .update({field: typing});
  }

  @override
  void onClose() {
    _messagesSubscription.cancel();
    _appointmentSubscription.cancel();
    messageController.dispose();
    setTyping(false);
    super.onClose();
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  int selectedIndexpages = 2;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
  }

  Widget _buildDoctorImage(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) {
      return Image.asset(
        'assets/doctor.png',
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      );
    }

    try {
      // Check if photoUrl is base64 encoded
      if (photoUrl.startsWith('data:image')) {
        final base64String = photoUrl.split(',').last;
        final bytes = base64Decode(base64String);
        return Image.memory(bytes, width: 50, height: 50, fit: BoxFit.cover);
      } else {
        // Handle regular URL
        return Image.network(
          photoUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/doctor.png',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            );
          },
        );
      }
    } catch (e) {
      return Image.asset(
        'assets/doctor.png',
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      );
    }
  }

  bool _isAppointmentInFuture(Map<String, dynamic> appointmentData) {
    try {
      final dateStr = appointmentData['appointmentDate'] as String?;
      final timeStr = appointmentData['appointmentTime'] as String?;

      if (dateStr == null || timeStr == null) return false;

      // Parse the date (assuming format is 'yyyy-MM-dd')
      final dateParts = dateStr.split('-');
      if (dateParts.length != 3) return false;

      // Parse the time (assuming format is 'HH:mm-HH:mm')
      final timeParts = timeStr.split('-').first.split(':');
      if (timeParts.length != 2) return false;

      final appointmentDateTime = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      return appointmentDateTime.isAfter(DateTime.now());
    } catch (e) {
      print('Error parsing appointment date/time: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      ),
      backgroundColor: lightGreyColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          children: [
            SizedBox(height: 16.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.to(() => PickDoctorPage()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: whiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: BorderSide(color: primaryColor, width: 2.0),
                ),
                child: Text(
                  'Book Appointment',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: semiBold,
                    color: blackColor,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('appointments')
                        .where('patientId', isEqualTo: currentUserId)
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

                  return ListView.separated(
                    itemCount: appointmentSnapshot.data!.docs.length,
                    separatorBuilder: (context, index) => SizedBox(height: 5),
                    itemBuilder: (context, index) {
                      final appointment = appointmentSnapshot.data!.docs[index];
                      final appointmentData =
                          appointment.data() as Map<String, dynamic>;
                      final doctorId = appointmentData['doctorId'];
                      final isFutureAppointment = _isAppointmentInFuture(
                        appointmentData,
                      );

                      return StreamBuilder<DocumentSnapshot>(
                        stream:
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(doctorId)
                                .snapshots(),
                        builder: (context, doctorSnapshot) {
                          if (!doctorSnapshot.hasData) {
                            return Opacity(
                              opacity: isFutureAppointment ? 0.6 : 1.0,
                              child: Chatbox(
                                image: 'assets/doctor.png',
                                name: 'Loading...',
                                snippets:
                                    'Appointment confirmed for ${appointmentData['date']}',
                                day: 'Appointment',
                                time:
                                    appointmentData['time']?.split('-').first ??
                                    '',
                                onPressed: () {
                                  if (isFutureAppointment) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'This appointment is not active yet',
                                          style: GoogleFonts.poppins(),
                                        ),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  } else {
                                    Navigator.pushNamed(
                                      context,
                                      '/chatroom',
                                      arguments: {
                                        'appointmentId': appointment.id,
                                      },
                                    );
                                  }
                                },
                              ),
                            );
                          }

                          final doctorData =
                              doctorSnapshot.data!.data()
                                  as Map<String, dynamic>?;
                          final doctorName = doctorData?['name'] ?? 'Doctor';
                          final photoUrl = doctorData?['photoUrl'];

                          return Opacity(
                            opacity: isFutureAppointment ? 0.6 : 1.0,
                            child: Chatbox(
                              imageWidget: _buildDoctorImage(photoUrl),
                              name: doctorName,
                              snippets:
                                  'Appointment confirmed for ${appointmentData['date']}',
                              day: 'Appointment',
                              time:
                                  appointmentData['time']?.split('-').first ??
                                  '',
                              onPressed: () {
                                print('Navigating to ChatRoom with:');
                                print('  appointmentId: ${appointment.id}');
                                print('  doctorId: $doctorId');
                                print('  patientId: $currentUserId');

                                if (isFutureAppointment) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Chat will be available when the appointment time starts',
                                        style: GoogleFonts.poppins(),
                                      ),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                } else {
                                  Get.toNamed(
                                    '/chatroom',
                                    parameters: {
                                      'appointmentId': appointment.id,
                                      'doctorId': doctorId,
                                      'patientId': currentUserId ?? '',
                                    },
                                  );
                                }
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

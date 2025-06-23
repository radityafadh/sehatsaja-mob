import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sehatsaja/shared/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:sehatsaja/widgets/ratingdialog.dart';

class RatingHistoryPage extends StatefulWidget {
  const RatingHistoryPage({Key? key}) : super(key: key);

  @override
  _RatingHistoryPageState createState() => _RatingHistoryPageState();
}

class _RatingHistoryPageState extends State<RatingHistoryPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> _appointmentsStream;

  @override
  void initState() {
    super.initState();
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      _appointmentsStream =
          _firestore
              .collection('appointments')
              .where('patientId', isEqualTo: currentUser.uid)
              .where('status', isEqualTo: 'completed')
              .where('rating', isNull: true)
              .snapshots();
    } else {
      _appointmentsStream = const Stream.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Rating History',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: lightGreyColor,
      ),
      backgroundColor: lightGreyColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _appointmentsStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading appointments',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.red),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'No rating history found',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final appointment = snapshot.data!.docs[index];
                final data = appointment.data() as Map<String, dynamic>;

                return _buildAppointmentCard(data, appointment.id);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(
    Map<String, dynamic> data,
    String appointmentId,
  ) {
    final date = data['appointmentDate'] ?? '';
    final time = data['appointmentTime'] ?? '';
    final doctorName = data['doctorName'] ?? 'Unknown Doctor';
    final specialization =
        data['doctorSpecialization'] ?? 'General Practitioner';
    final complaint = data['complaint'] ?? 'No complaint specified';
    final price = data['price'] ?? 0;
    final formattedPrice = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(price);

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => RatingDialog(appointmentId: appointmentId),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$date at $time',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  formattedPrice,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              doctorName,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              specialization,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Complaint: $complaint',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Tap to Rate',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

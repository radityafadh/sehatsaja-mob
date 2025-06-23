import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sehatsaja/shared/theme.dart';
import 'package:sehatsaja/pages/User/detail_payment_page_2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class DetailPaymentPage extends StatefulWidget {
  final String appointmentId;

  const DetailPaymentPage({Key? key, required this.appointmentId})
    : super(key: key);

  @override
  _DetailPaymentPageState createState() => _DetailPaymentPageState();
}

class _DetailPaymentPageState extends State<DetailPaymentPage> {
  String? selectedPaymentMethod;
  bool isLoading = false;
  bool isProcessingPayment = false;

  final List<String> paymentMethods = ['bca', 'mandiri', 'bni'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Pembayaran',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: bold,
            color: blackColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: lightGreyColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: blackColor),
          onPressed: () => Get.back(),
        ),
      ),
      backgroundColor: lightGreyColor,
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance
                .collection('appointments')
                .doc(widget.appointmentId)
                .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                'Appointment not found',
                style: GoogleFonts.poppins(),
              ),
            );
          }

          final appointment = snapshot.data!.data() as Map<String, dynamic>;
          final doctorId = appointment['doctorId'] as String;

          return FutureBuilder<DocumentSnapshot>(
            future:
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(doctorId)
                    .get(),
            builder: (context, doctorSnapshot) {
              if (doctorSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!doctorSnapshot.hasData || !doctorSnapshot.data!.exists) {
                return Center(
                  child: Text(
                    'Doctor information not available',
                    style: GoogleFonts.poppins(),
                  ),
                );
              }

              final doctor =
                  doctorSnapshot.data!.data() as Map<String, dynamic>;

              return _buildContent(appointment: appointment, doctor: doctor);
            },
          );
        },
      ),
    );
  }

  Widget _buildContent({
    required Map<String, dynamic> appointment,
    required Map<String, dynamic> doctor,
  }) {
    final price =
        appointment['price'] is int
            ? appointment['price'] as int
            : (appointment['price'] as num).toInt();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Doctor info section
          _buildSectionContainer(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Consultation session with:',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: bold,
                    color: blackColor,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildDoctorImage(doctor['photoUrl']?.toString() ?? ''),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor['name']?.toString() ?? 'No Name',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: bold,
                              color: blackColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '1x Session',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            appointment['time']?.toString() ?? 'No Time',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Transaction details section
          _buildSectionContainer(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transaction Details',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: bold,
                    color: blackColor,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDetailRow('Transaction number:', widget.appointmentId),
                _buildDetailRow(
                  'Transaction date:',
                  DateFormat('dd MMMM yyyy HH:mm').format(
                        (appointment['createdAt'] as Timestamp).toDate(),
                      ) +
                      ' WIB',
                ),
                const SizedBox(height: 16),
                Text(
                  'Consultation Details',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: bold,
                    color: blackColor,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  'Doctor:',
                  doctor['name']?.toString() ?? 'No Name',
                ),
                _buildDetailRow('Session:', '1x Session'),
                _buildDetailRow(
                  'Time:',
                  appointment['time']?.toString() ?? 'No Time',
                ),
                _buildDetailRow(
                  'Complaint:',
                  appointment['complaint']?.toString() ?? '-',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Payment method section
          Text(
            'Payment Method',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: bold,
              color: blackColor,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButton<String>(
              value: selectedPaymentMethod,
              hint: Text('Select Payment Method', style: GoogleFonts.poppins()),
              isExpanded: true,
              underline: const SizedBox(),
              items:
                  paymentMethods.map((String method) {
                    return DropdownMenuItem<String>(
                      value: method,
                      child: Text(method, style: GoogleFonts.poppins()),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedPaymentMethod = newValue;
                });
              },
            ),
          ),
          const SizedBox(height: 20),

          // Total payment section
          _buildTotalPaymentSection(price),
          const SizedBox(height: 20),

          // Pay now button
          _buildPayNowButton(appointment),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionContainer(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: medium,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: regular,
                color: blackColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalPaymentSection(int price) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Payment:',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: medium,
              color: blackColor,
            ),
          ),
          Text(
            'Rp ${NumberFormat('#,###').format(price)}',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: extraBold,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayNowButton(Map<String, dynamic> appointment) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            selectedPaymentMethod == null || isProcessingPayment
                ? null
                : () async {
                  setState(() => isProcessingPayment = true);
                  try {
                    await FirebaseFirestore.instance
                        .collection('appointments')
                        .doc(widget.appointmentId)
                        .update({
                          'paymentMethod': selectedPaymentMethod,
                          'updatedAt': FieldValue.serverTimestamp(),
                          'status': 'pending',
                        });

                    Get.to(
                      () => DetailPaymentPage2(
                        appointmentId: widget.appointmentId,
                      ),
                    );
                  } catch (e) {
                    Get.snackbar(
                      'Error',
                      'Failed to process payment: ${e.toString()}',
                      backgroundColor: Colors.red,
                      colorText: whiteColor,
                    );
                  } finally {
                    setState(() => isProcessingPayment = false);
                  }
                },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              selectedPaymentMethod == null ? Colors.grey[300] : primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
        ),
        child:
            isProcessingPayment
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Color(0xFF4993FA),
                    strokeWidth: 2,
                  ),
                )
                : Text(
                  'Pay Now',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color:
                        selectedPaymentMethod == null
                            ? Colors.grey[600]
                            : whiteColor,
                  ),
                ),
      ),
    );
  }

  Widget _buildDoctorImage(String photoUrl) {
    if (photoUrl.isEmpty) return _buildDefaultAvatar();

    try {
      final isBase64 = photoUrl.contains('base64,');
      final imageData = isBase64 ? photoUrl.split(',')[1] : photoUrl;

      return ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child:
            isBase64
                ? Image.memory(
                  base64Decode(imageData),
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                )
                : Image.network(
                  imageData,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                ),
      );
    } catch (e) {
      return _buildDefaultAvatar();
    }
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.person, size: 40, color: Colors.grey[400]),
    );
  }
}

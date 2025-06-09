import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/shared/theme.dart';
import 'package:frontend/pages/User/home_page.dart';

class DetailPaymentPage2 extends StatelessWidget {
  final String appointmentId;

  const DetailPaymentPage2({Key? key, required this.appointmentId})
    : super(key: key);

  Future<Map<String, dynamic>> _fetchAppointmentData() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(appointmentId)
            .get();
    if (!doc.exists) throw Exception("Appointment not found");
    return doc.data()!;
  }

  void _confirmPayment(
    BuildContext context,
    Map<String, dynamic> appointmentData,
  ) async {
    if (appointmentData['status'] == 'confirmed') {
      Get.snackbar("Warning", "This appointment has already been paid.");
      return;
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    final paymentData = {
      'appointmentId': appointmentId,
      'patientId': appointmentData['patientId'] ?? '',
      'patientName': appointmentData['patientName'] ?? '',
      'description':
          'appointment with ${appointmentData['doctorName']}, ${appointmentData['doctorSpecialization']}}',
      'paymentDate':
          DateTime.tryParse(appointmentData['date'] ?? '') ?? DateTime.now(),
      'paymentMethod': appointmentData['paymentMethod'] ?? 'unknown',
      'amount': appointmentData['price'] ?? 0,
      'paymentDate': DateTime.now(),
      'createdAt': Timestamp.now(),
      'status': 'completed',
    };

    try {
      await FirebaseFirestore.instance.collection('payments').add(paymentData);
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .update({'status': 'confirmed'});

      Get.back(); // close loading dialog
      Get.snackbar("Success", "Payment saved successfully");

      Future.delayed(const Duration(milliseconds: 500), () {
        Get.offAll(() => const HomePage());
      });
    } catch (e) {
      Get.back(); // close loading
      Get.snackbar("Error", "Failed to save payment: $e");
    }
  }

  String _getPaymentInstructions(String method) {
    switch (method.toLowerCase()) {
      case 'bca':
        return '''
1. Log in to BCA Mobile App.
2. Select m-BCA > BCA Virtual Account.
3. Enter code 80777 + phone number.
4. Confirm details, enter PIN.
5. Save payment proof.''';
      case 'mandiri':
        return '''
1. Open Mandiri Online.
2. Choose Bayar > Multi Payment.
3. Enter virtual account.
4. Confirm and complete with MPIN.''';
      case 'bni':
        return '''
1. Log in to BNI Mobile Banking.
2. Go to Transfer > VA Billing.
3. Input VA number.
4. Confirm and enter PIN.''';
      default:
        return 'No instructions available for this payment method.';
    }
  }

  String _getVirtualAccountNumber(String method) {
    switch (method.toLowerCase()) {
      case 'bca':
        return '8077799999999999';
      case 'mandiri':
        return '8877799999999999';
      case 'bni':
        return '8878899999999999';
      default:
        return '0000000000000000';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchAppointmentData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final data = snapshot.data!;
        final date = DateTime.tryParse(data['date'] ?? '') ?? DateTime.now();
        final paymentMethod = data['paymentMethod'] ?? 'unknown';
        final vaNumber = _getVirtualAccountNumber(paymentMethod);
        final instruction = _getPaymentInstructions(paymentMethod);
        final amount = data['price'] ?? 0;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Payment',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: bold,
                color: blackColor,
              ),
            ),
            centerTitle: true,
            backgroundColor: lightGreyColor,
          ),
          backgroundColor: lightGreyColor,
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 30.0,
              vertical: 20.0,
            ),
            child: ListView(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Column(
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
                      Text(
                        'Transaction number: $appointmentId',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: blackColor,
                        ),
                      ),
                      Text(
                        'Transaction date: ${date.toLocal()}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: blackColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Consultation Details',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: bold,
                          color: blackColor,
                        ),
                      ),
                      Text(
                        data['complaint'] ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: blackColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Method',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: bold,
                          color: blackColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        paymentMethod,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: regular,
                          color: blackColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Virtual Account Number:',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: bold,
                          color: blackColor,
                        ),
                      ),
                      Text(
                        vaNumber,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: regular,
                          color: blackColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Steps to Complete Payment:',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: bold,
                          color: blackColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        instruction,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: blackColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Total Payment: ',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: regular,
                        color: blackColor,
                      ),
                    ),
                    Text(
                      'Rp $amount',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: extraBold,
                        color: blackColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _confirmPayment(context, data),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Confirm Payment',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: bold,
                        color: whiteColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/shared/theme.dart';
import 'package:frontend/pages/Doctor only/home_page_doctor.dart';
import 'package:intl/intl.dart';

class EMoneyPage extends StatefulWidget {
  const EMoneyPage({Key? key}) : super(key: key);

  @override
  State<EMoneyPage> createState() => _EMoneyPageState();
}

class _EMoneyPageState extends State<EMoneyPage> {
  double totalBalance = 0.0;
  bool isLoading = false;
  bool isLoadingBalance = true;
  String selectedBank = 'mandiri';
  final List<String> banks = ['mandiri', 'bca', 'bni'];
  final amountController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    fetchDoctorBalance();
  }

  Future<void> fetchDoctorBalance() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('DEBUG: No user logged in');
      setState(() {
        isLoadingBalance = false;
        totalBalance = 0.0;
      });
      return;
    }

    print('DEBUG: Fetching balance for doctor ${user.uid}');

    try {
      // 1. Get all completed payments for THIS DOCTOR ONLY
      final paymentsQuery =
          await FirebaseFirestore.instance
              .collection('payments')
              .where('status', isEqualTo: 'completed')
              .get();

      print('DEBUG: Found ${paymentsQuery.docs.length} completed payments');

      double balance = 0.0;
      int validPayments = 0;
      int skippedPayments = 0;
      final validStatuses = {'completed', 'confirmed'}; // Accepted statuses

      // 2. Process each payment
      for (var payment in paymentsQuery.docs) {
        final paymentData = payment.data();
        print(
          'DEBUG: Processing payment ${payment.id} with amount: ${paymentData['amount']}',
        );

        // Skip if no amount or appointmentId
        if (paymentData['amount'] == null) {
          print('DEBUG: Skipping payment ${payment.id} - no amount');
          skippedPayments++;
          continue;
        }

        if (paymentData['appointmentId'] == null) {
          print('DEBUG: Skipping payment ${payment.id} - no appointmentId');
          skippedPayments++;
          continue;
        }

        // 3. Get the corresponding appointment
        print('DEBUG: Fetching appointment ${paymentData['appointmentId']}');
        final appointmentDoc =
            await FirebaseFirestore.instance
                .collection('appointments')
                .doc(paymentData['appointmentId'] as String)
                .get();

        // 4. Validate appointment
        if (!appointmentDoc.exists) {
          print('DEBUG: Skipping - appointment not found');
          skippedPayments++;
          continue;
        }

        final appointmentData = appointmentDoc.data();
        final appointmentStatus =
            appointmentData?['status']?.toString().toLowerCase();

        // Check if status is valid
        if (appointmentStatus == null ||
            !validStatuses.contains(appointmentStatus)) {
          print(
            'DEBUG: Skipping - invalid appointment status: $appointmentStatus',
          );
          skippedPayments++;
          continue;
        }

        if (appointmentData?['doctorId'] != user.uid) {
          print('DEBUG: Skipping - appointment belongs to different doctor');
          skippedPayments++;
          continue;
        }

        // Valid payment found!
        final amount = (paymentData['amount'] as num).toDouble();
        print('''
      DEBUG: Valid payment-appointment pair found:
      - Payment ID: ${payment.id}
      - Appointment ID: ${paymentData['appointmentId']}
      - Status: $appointmentStatus
      - Amount: $amount
      ''');

        balance += amount;
        validPayments++;
      }

      print('''
    DEBUG: Balance calculation complete:
    - Total payments processed: ${paymentsQuery.docs.length}
    - Valid payments counted: $validPayments
    - Skipped payments: $skippedPayments
    - Final balance: $balance
    ''');

      setState(() {
        isLoadingBalance = false;
        totalBalance = balance;
      });
    } catch (e, stackTrace) {
      print('''
    ERROR fetching balance:
    Error: $e
    Stack Trace: $stackTrace
    ''');
      setState(() {
        isLoadingBalance = false;
        totalBalance = 0.0;
      });
    }
  }

  Future<void> processWithdrawal() async {
    if (amountController.text.isEmpty) {
      Get.snackbar('Error', 'Masukkan jumlah penarikan');
      return;
    }

    final amount = double.tryParse(amountController.text) ?? 0;
    if (amount <= 0) {
      Get.snackbar('Error', 'Jumlah harus lebih dari 0');
      return;
    }

    if (totalBalance < amount) {
      Get.snackbar('Error', 'Saldo tidak mencukupi');
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User tidak login');

      // Record withdrawal payments with negative amount
      await _firestore.collection('payments').add({
        'type': 'withdrawal',
        'amount': -amount,
        'bank': selectedBank,
        'doctorId': user.uid,
        'status': 'confirmed',
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Sukses',
        'Permintaan penarikan berhasil dikirim',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Refresh balance after withdrawal
      await fetchDoctorBalance();

      // Navigate back only if still mounted
      if (mounted) {
        Get.off(() => HomePageDoctor());
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memproses penarikan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Penarikan Saldo',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: blackColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: lightGreyColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.off(() => HomePageDoctor()),
        ),
      ),
      backgroundColor: lightGreyColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saldo Sekarang
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(7),
              ),
              child:
                  isLoadingBalance
                      ? Center(child: CircularProgressIndicator())
                      : Column(
                        children: [
                          Text(
                            'Saldo Saat Ini',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            _currencyFormat.format(totalBalance),
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: blackColor,
                            ),
                          ),
                        ],
                      ),
            ),
            SizedBox(height: 20),

            // Input Jumlah
            TextFormField(
              controller: amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Jumlah Penarikan',
                border: OutlineInputBorder(),
                prefixText: 'Rp ',
              ),
            ),
            SizedBox(height: 20),

            // Pilih Bank
            DropdownButtonFormField<String>(
              value: selectedBank,
              items:
                  banks.map((bank) {
                    return DropdownMenuItem(
                      value: bank,
                      child: Text(
                        bank.toUpperCase(),
                        style: GoogleFonts.poppins(),
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() => selectedBank = value!);
              },
              decoration: InputDecoration(
                labelText: 'Pilih Bank',
                border: OutlineInputBorder(),
              ),
            ),
            Spacer(),

            // Tombol Submit
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    isLoading || isLoadingBalance ? null : processWithdrawal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child:
                    isLoading
                        ? CircularProgressIndicator(color: whiteColor)
                        : Text(
                          'Tarik Sekarang',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: whiteColor,
                          ),
                        ),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sehatsaja/shared/theme.dart';
import 'package:sehatsaja/pages/Doctor only/home_page_doctor.dart';
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
  List<Map<String, dynamic>> doctorAppointments = [];

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
    fetchDoctorBalanceAndAppointments();
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

      await _firestore.collection('payments').add({
        'type': 'withdrawal',
        'amount': amount,
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
      await fetchDoctorBalanceAndAppointments();

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

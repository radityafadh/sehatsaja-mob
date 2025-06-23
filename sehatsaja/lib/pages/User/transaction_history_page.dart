import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sehatsaja/shared/theme.dart';
import 'package:sehatsaja/widgets/cardbankdetail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({Key? key}) : super(key: key);

  @override
  _TransactionHistoryPageState createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String _currentUserId;
  late bool _isDoctor;
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _currentUserId = _auth.currentUser?.uid ?? '';
    _isDoctor = _auth.currentUser?.email?.startsWith('dokter') ?? false;
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      if (_isDoctor) {
        await _loadDoctorTransactions();
      } else {
        await _loadPatientTransactions();
      }
    } catch (e) {
      print('Error loading transactions: $e');
    }
  }

  Future<void> _loadPatientTransactions() async {
    List<Map<String, dynamic>> transactions = [];

    final paymentsQuery =
        await _firestore
            .collection('payments')
            .where('patientId', isEqualTo: _currentUserId)
            .get();

    for (var doc in paymentsQuery.docs) {
      final paymentData = doc.data();
      final appointmentId = paymentData['appointmentId'] as String?;

      Map<String, dynamic>? appointmentData;
      if (appointmentId != null && appointmentId.isNotEmpty) {
        final appointmentDoc =
            await _firestore
                .collection('appointments')
                .doc(appointmentId)
                .get();
        if (appointmentDoc.exists) {
          appointmentData = appointmentDoc.data();
        }
      }

      transactions.add({
        'type': 'payment',
        'data': paymentData,
        'appointment': appointmentData,
        'timestamp': paymentData['createdAt'] ?? paymentData['paymentDate'],
      });
    }

    final withdrawalsQuery =
        await _firestore
            .collection('payments')
            .where('doctorId', isEqualTo: _currentUserId)
            .where('type', isEqualTo: 'withdrawal')
            .get();

    for (var doc in withdrawalsQuery.docs) {
      final withdrawalData = doc.data();
      transactions.add({
        'type': 'withdrawal',
        'data': withdrawalData,
        'timestamp': withdrawalData['createdAt'],
      });
    }

    transactions.sort((a, b) {
      final aTimestamp = a['timestamp'] as Timestamp?;
      final bTimestamp = b['timestamp'] as Timestamp?;
      return (bTimestamp ?? Timestamp.now()).compareTo(
        aTimestamp ?? Timestamp.now(),
      );
    });

    setState(() {
      _transactions = transactions;
    });
  }

  Future<void> _loadDoctorTransactions() async {
    List<Map<String, dynamic>> transactions = [];

    final appointmentsQuery =
        await _firestore
            .collection('appointments')
            .where('doctorId', isEqualTo: _currentUserId)
            .where('status', whereIn: ['completed', 'confirmed'])
            .get();

    for (var doc in appointmentsQuery.docs) {
      final appointmentData = doc.data();

      final paymentQuery =
          await _firestore
              .collection('payments')
              .where('appointmentId', isEqualTo: doc.id)
              .limit(1)
              .get();

      Map<String, dynamic>? paymentData;
      if (paymentQuery.docs.isNotEmpty) {
        paymentData = paymentQuery.docs.first.data();
      }

      transactions.add({
        'type': 'appointment',
        'data': appointmentData,
        'payment': paymentData,
        'timestamp':
            appointmentData['updatedAt'] ?? appointmentData['createdAt'],
      });
    }

    final withdrawalsQuery =
        await _firestore
            .collection('payments')
            .where('doctorId', isEqualTo: _currentUserId)
            .where('type', isEqualTo: 'withdrawal')
            .get();

    for (var doc in withdrawalsQuery.docs) {
      final withdrawalData = doc.data();
      transactions.add({
        'type': 'withdrawal',
        'data': withdrawalData,
        'timestamp': withdrawalData['createdAt'],
      });
    }

    transactions.sort((a, b) {
      final aTimestamp = a['timestamp'] as Timestamp?;
      final bTimestamp = b['timestamp'] as Timestamp?;
      return (bTimestamp ?? Timestamp.now()).compareTo(
        aTimestamp ?? Timestamp.now(),
      );
    });

    setState(() {
      _transactions = transactions;
    });
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'No date';
    final date = timestamp.toDate();
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'No date';
    try {
      final date = DateFormat('yyyy-MM-dd').parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transaction History',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[200],
      ),
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child:
            _transactions.isEmpty
                ? Center(
                  child: Text(
                    'No transactions found',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                )
                : ListView.separated(
                  itemCount: _transactions.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 5),
                  itemBuilder: (context, index) {
                    final transaction = _transactions[index];
                    final type = transaction['type'] as String;

                    if (type == 'payment' || type == 'appointment') {
                      return _buildPaymentCard(transaction, type);
                    } else if (type == 'withdrawal') {
                      return _buildWithdrawalCard(transaction);
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> transaction, String type) {
    final isPayment = type == 'payment';
    final data = isPayment ? transaction['data'] : transaction['data'];
    final appointment =
        isPayment ? transaction['appointment'] : transaction['data'];

    final amount =
        isPayment
            ? (data['amount'] as num?)?.toInt() ?? 0
            : (appointment['price'] as num?)?.toInt() ?? 0;
    final doctorName =
        isPayment
            ? data['description']?.toString().split('(').first.trim() ??
                'Unknown Doctor'
            : appointment['doctorName'] as String? ?? 'Unknown Doctor';
    final status =
        isPayment
            ? data['status'] as String? ?? 'pending'
            : appointment['status'] as String? ?? 'unknown';
    final timestamp =
        isPayment
            ? _formatTimestamp(data['createdAt'] as Timestamp?)
            : '${_formatDate(appointment['appointmentDate'] as String?)} at ${appointment['appointmentTime']}';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              doctorName,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              timestamp,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '1x session',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  'Rp. ${NumberFormat('#,###').format(amount)}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      status == 'success' || status == 'completed'
                          ? Colors.green[100]
                          : status == 'pending'
                          ? Colors.orange[100]
                          : Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color:
                        status == 'success' || status == 'completed'
                            ? Colors.green
                            : status == 'pending'
                            ? Colors.orange
                            : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWithdrawalCard(Map<String, dynamic> transaction) {
    final data = transaction['data'];
    final amount = (data['amount'] as num?)?.toInt() ?? 0;
    final bank = data['bank'] as String? ?? 'unknown';
    final status = data['status'] as String? ?? 'pending';
    final timestamp = _formatTimestamp(data['createdAt'] as Timestamp?);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Withdrawal',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Rp. ${NumberFormat('#,###').format(amount)}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              'Bank: ${bank.toUpperCase()}',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  timestamp,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        status == 'confirmed'
                            ? Colors.green[100]
                            : Colors.orange[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color:
                          status == 'confirmed' ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

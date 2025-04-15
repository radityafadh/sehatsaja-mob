import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/shared/theme.dart';
import 'package:frontend/widgets/cardbanksimple.dart';
import 'package:frontend/pages/User/payment_method.dart';

class DetailPaymentPage2 extends StatefulWidget {
  const DetailPaymentPage2({Key? key}) : super(key: key);

  @override
  State<DetailPaymentPage2> createState() => _DetailPaymentPage2State();
}

class _DetailPaymentPage2State extends State<DetailPaymentPage2> {
  Duration _duration = const Duration(minutes: 15);
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_duration.inSeconds == 0) {
        timer.cancel();
      } else {
        setState(() {
          _duration = _duration - const Duration(seconds: 1);
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String minutes = duration.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    String seconds = duration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
        child: ListView(
          children: [
            Container(
              width: double.infinity,
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
                    'Transaction number: 0000000001',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: regular,
                      color: blackColor,
                    ),
                  ),
                  Text(
                    'Transaction date: 06 February 2025 09:00 WIB',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: regular,
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
                    'Doctor: Dr. Mulyadi Akbar',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: regular,
                      color: blackColor,
                    ),
                  ),
                  Text(
                    'Session: 1x Session',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: regular,
                      color: blackColor,
                    ),
                  ),
                  Text(
                    'Time: 8.00 AM',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: regular,
                      color: blackColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
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
                  CardBankSimple(image: 'bank_bca', type: 'Virtual Account'),
                  const SizedBox(height: 10),
                  Text(
                    'Virtual Account Number:',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: bold,
                      color: blackColor,
                    ),
                  ),
                  Text(
                    '807779999999999999999',
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
                    '1. Log in to BCA Mobile App.\n'
                    '2. Select m-BCA and enter your access code.\n'
                    '3. Choose m-Transfer > BCA Virtual Account.\n'
                    '4. Enter the company code (80777) and your registered phone number.\n'
                    '5. Confirm details and enter PIN.\n'
                    '6. Payment is complete. Save the notification as proof of payment.',
                    style: GoogleFonts.poppins(fontSize: 12, color: blackColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Text(
                    'Time Remaining for Payment',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: bold,
                      color: blackColor,
                    ),
                  ),
                  Text(
                    _formatDuration(_duration),
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: extraBold,
                      color: Colors.red,
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
                  'Rp 10.000',
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
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: whiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: primaryColor, width: 2.0),
                  ),
                ),
                child: Text(
                  'Awaiting Payment',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: bold,
                    color: blackColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

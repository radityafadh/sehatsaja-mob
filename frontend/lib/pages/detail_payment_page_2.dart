import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/shared/theme.dart';
import 'package:frontend/widgets/cardbanksimple.dart';
import 'package:frontend/pages/payment_method.dart';

class DetailPaymentPage2 extends StatelessWidget {
  const DetailPaymentPage2({Key? key}) : super(key: key);

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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

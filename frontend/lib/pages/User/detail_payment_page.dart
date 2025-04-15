import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/shared/theme.dart';
import 'package:frontend/widgets/cardbanksimple.dart';
import 'package:frontend/pages/User/payment_method.dart';
import 'package:frontend/pages/User/detail_payment_page_2.dart';

class DetailPaymentPage extends StatelessWidget {
  const DetailPaymentPage({Key? key}) : super(key: key);

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
      ),
      backgroundColor: lightGreyColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Consultation session with :',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: bold,
                      color: blackColor,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          'assets/doctor.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dr Mulyadi Akbar',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: bold,
                              color: blackColor,
                            ),
                          ),
                          Text(
                            '1x Session',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: regular,
                              color: blackColor,
                            ),
                          ),
                          Text(
                            '8.00 Am',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: regular,
                              color: blackColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
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
                    'Transaction number : 0000000001',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: regular,
                      color: blackColor,
                    ),
                  ),
                  Text(
                    'Transaction date : 06 February 2025 09:00 WIB',
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
                    'TDoctor                       : Dr. Mulyadi Akbar',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: regular,
                      color: blackColor,
                    ),
                  ),
                  Text(
                    'Session                       : 1x Session',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: regular,
                      color: blackColor,
                    ),
                  ),
                  Text(
                    'Time                            : 8.00 Am',
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
            Row(
              children: [
                Text(
                  'Payment Method',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: bold,
                    color: blackColor,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.arrow_forward,
                    size: 30,
                    color: primaryColor,
                  ),
                  onPressed: () {
                    Get.to(() => PaymentMethodPage());
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            CardBankSimple(image: 'bank_mandiri', type: 'Virtual Account'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Total Payment : ',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: regular,
                    color: blackColor,
                  ),
                ),
                Text(
                  'Rp 10.0000',
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
              width: double.infinity, // Membuat tombol selebar layar
              child: ElevatedButton(
                onPressed: () {
                  Get.to(() => DetailPaymentPage2());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Pay Now',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold, // Perbaiki `bold`
                    color: whiteColor,
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

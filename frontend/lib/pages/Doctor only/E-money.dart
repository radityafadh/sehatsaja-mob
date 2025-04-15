import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/shared/theme.dart';
import 'package:frontend/widgets/cardbanksimple.dart';
import 'package:frontend/pages/Doctor only/payment_method_emoney.dart';
import 'package:frontend/pages/Doctor only/nomor_rekening.dart';
import 'package:frontend/pages/Doctor only/home_page_doctor.dart';

class EMoneyPage extends StatelessWidget {
  const EMoneyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'E-money',
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          'assets/doctor.png',
                          width: 80,
                          height: 80,
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
                            'Rp. 30.000,00',
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
                    Get.to(() => PaymentMethodEmoneyPage());
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            CardBankSimple(image: 'bank_mandiri', type: 'Virtual Account'),
            Spacer(),
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
            SizedBox(
              width: double.infinity, // Membuat tombol selebar layar
              child: ElevatedButton(
                onPressed: () {
                  Get.to(() => HomePageDoctor());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Transfer now',
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

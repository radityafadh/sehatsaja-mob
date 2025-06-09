import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/shared/theme.dart';
import 'package:frontend/widgets/cardbanksimple.dart';
import 'package:frontend/pages/Doctor only/nomor_rekening.dart';
import 'package:get/get.dart';

class PaymentMethodEmoneyPage extends StatelessWidget {
  const PaymentMethodEmoneyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pick Payment Method',
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
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
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
          CardBankSimple(image: 'bank_mandiri', type: 'Virtual Account'),
          CardBankSimple(image: 'bank_bri', type: 'Virtual Account'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Get.to(() => EmoneyRekening());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'Add Payment Method',
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
    );
  }
}

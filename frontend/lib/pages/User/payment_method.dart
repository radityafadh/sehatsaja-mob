import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/shared/theme.dart';
import 'package:frontend/widgets/cardbanksimple.dart';
import 'package:frontend/pages/User/detail_payment_page.dart';
import 'package:get/get.dart';

class PaymentMethodPage extends StatelessWidget {
  const PaymentMethodPage({Key? key}) : super(key: key);

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
          CardBankSimple(image: 'bank_bni', type: 'Virtual Account'),
          CardBankSimple(image: 'bank_mandiri', type: 'Virtual Account'),
          CardBankSimple(image: 'bank_bri', type: 'Virtual Account'),
          const SizedBox(height: 20),
          Text(
            'ATM Bank',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: bold,
              color: blackColor,
            ),
          ),
          CardBankSimple(image: 'bank_bca', type: 'ATM Bank'),
          CardBankSimple(image: 'bank_bni', type: 'ATM Bank'),
          CardBankSimple(image: 'bank_mandiri', type: 'ATM Bank'),
          CardBankSimple(image: 'bank_bri', type: 'ATM Bank'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Get.to(DetailPaymentPage());
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

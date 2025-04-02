import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/shared/theme.dart';
import 'package:frontend/widgets/cardbanksimple.dart';

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
        ],
      ),
    );
  }
}

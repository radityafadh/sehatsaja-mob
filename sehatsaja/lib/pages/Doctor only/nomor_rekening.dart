import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sehatsaja/shared/theme.dart';
import 'package:sehatsaja/pages/Doctor only/E-money.dart';
import 'package:get/get.dart';

class EmoneyRekening extends StatelessWidget {
  const EmoneyRekening({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Masukkan nomor rekening',
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
            'No Rekening',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: bold,
              color: blackColor,
            ),
          ),
          TextFormField(
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: regular,
              color: blackColor,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(10.0),
              filled: true,
              fillColor: whiteColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Nominal',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: bold,
              color: blackColor,
            ),
          ),
          TextFormField(
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: regular,
              color: blackColor,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(10.0),
              filled: true,
              fillColor: whiteColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 50.0),
          ElevatedButton(
            onPressed: () {
              Get.to(() => EMoneyPage());
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
                'Lanjutkan',
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

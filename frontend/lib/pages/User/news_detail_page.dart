import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/shared/theme.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class NewsDetailPage extends StatelessWidget {
  const NewsDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: whiteColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: PhosphorIcon(
              PhosphorIconsRegular.shareNetwork,
              size: 30.0,
              color: blackColor,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: PhosphorIcon(
              PhosphorIconsRegular.slidersHorizontal,
              size: 30.0,
              color: blackColor,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Text(
              'January, 14 2025 - 19.20',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: regular,
                color: blackColor,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'The Proper Use of Medication: The Role of Nurses in Ensuring Patient Safety',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: bold,
              color: blackColor,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            child: Image.asset(
              'assets/news1.png',
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Nurses play a crucial role in ensuring the proper use of medication for patients. As frontline healthcare professionals, they are responsible for administering medication according to the prescribed dosage, schedule, and method recommended by doctors. Medication errors, such as incorrect dosages or overlooked drug interactions, can have fatal consequences for patients. Therefore, nurses must have a strong understanding of pharmacology, side effects, and safe medication administration procedures.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: medium,
              color: blackColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'In addition, nurses are also responsible for educating patients on how to take their medication independently, especially those undergoing long-term treatment. Effective communication between nurses, doctors, and patients is essential to prevent errors and ensure patient adherence to medication regimens. Through discipline, accuracy, and a strong understanding of medication management, nurses play a vital role in enhancing patient safety and the effectiveness of drug therapy.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: medium,
              color: blackColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Furthermore, nurses play a key role in monitoring patients for any adverse reactions or unexpected side effects after medication administration. Their ability to promptly recognize and respond to these issues can prevent complications and improve patient outcomes. By regularly assessing a patient’s condition and documenting any changes, nurses contribute valuable information that helps physicians make necessary adjustments to the treatment plan. This continuous monitoring ensures that medications remain both safe and effective throughout the course of therapy.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: medium,
              color: blackColor,
            ),
          ),
        ],
      ),
    );
  }
}

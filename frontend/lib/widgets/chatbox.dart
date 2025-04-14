import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:frontend/shared/theme.dart';
import 'package:google_fonts/google_fonts.dart';

class Chatbox extends StatelessWidget {
  final String image;
  final String name;
  final String snippets;
  final String day;
  final String time;
  final VoidCallback onPressed;

  const Chatbox({
    Key? key,
    required this.image,
    required this.name,
    required this.snippets,
    required this.day,
    required this.time,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero, // Supaya nggak nambah padding default
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
      ),
      child: Container(
        padding: const EdgeInsets.all(10.0),
        margin: const EdgeInsets.only(bottom: 10.0),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(7.0),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50.0),
              child: Image.asset(
                image,
                width: 50.0,
                height: 50.0,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: bold,
                    color: blackColor,
                  ),
                ),
                const SizedBox(height: 5.0),
                Text(
                  snippets,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: regular,
                    color: blackColor,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Column(
              children: [
                Text(
                  day,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: regular,
                    color: blackColor,
                  ),
                ),
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: regular,
                    color: blackColor,
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

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:sehatsaja/shared/theme.dart';
import 'package:google_fonts/google_fonts.dart';

class Chatbox extends StatelessWidget {
  final Widget? imageWidget;
  final String? image;
  final String name;
  final String snippets;
  final String day;
  final String time;
  final VoidCallback onPressed;

  const Chatbox({
    Key? key,
    this.imageWidget,
    this.image,
    required this.name,
    required this.snippets,
    required this.day,
    required this.time,
    required this.onPressed,
  }) : assert(
         imageWidget != null || image != null,
         'Either imageWidget or image must be provided',
       ),
       super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
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
              child:
                  imageWidget ??
                  Image.asset(
                    image!,
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,
                  ),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: bold,
                      color: blackColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    snippets,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: regular,
                      color: blackColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10.0),
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

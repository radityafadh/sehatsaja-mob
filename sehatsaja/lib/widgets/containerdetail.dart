import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:sehatsaja/shared/theme.dart';
import 'package:google_fonts/google_fonts.dart';

class ContainerDetail extends StatelessWidget {
  final PhosphorIconData icon;
  final String name;
  final String detail;

  const ContainerDetail({
    Key? key,
    required this.icon,
    required this.name,
    required this.detail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: const BorderRadius.all(Radius.circular(7.0)),
      ),
      child: Column(
        children: [
          PhosphorIcon(icon, color: primaryColor, size: 50.0),
          Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: bold,
              color: blackColor,
            ),
          ),
          Text(
            detail,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: regular,
              color: blackColor,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:frontend/shared/theme.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDropdown extends StatelessWidget {
  final List<String> items;
  final String value;
  final Function(String) onChanged;

  const CustomDropdown({
    Key? key,
    required this.items,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: blackColor),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onChanged(newValue); // Notify parent
            }
          },
          items:
              items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: regular,
                      color: blackColor,
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}

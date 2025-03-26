import 'package:flutter/material.dart';
import 'package:frontend/shared/theme.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDropdown extends StatefulWidget {
  final List<String> items;

  const CustomDropdown({Key? key, required this.items}) : super(key: key);

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  late String selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.items.first;
  }

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
          value: selectedValue,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: blackColor),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() => selectedValue = newValue);
            }
          },
          items:
              widget.items.map((item) {
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

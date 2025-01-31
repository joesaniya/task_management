import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String labelText;

  const CustomDropdown({
    Key? key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.labelText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        helperStyle: GoogleFonts.metrophobic(
          textStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.normal,
            letterSpacing: .5,
          ),
        ),
        labelStyle: GoogleFonts.metrophobic(
          textStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.normal,
            letterSpacing: .5,
          ),
        ),
        hintStyle: GoogleFonts.metrophobic(
          textStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.normal,
            letterSpacing: .5,
          ),
        ),
        border: OutlineInputBorder(),
      ),
    );
  }
}

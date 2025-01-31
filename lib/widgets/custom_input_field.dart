import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomInputField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final TextInputType inputType;
  final IconData? suffixIcon;
  final bool isDatePicker;
  final Function(String)? onDateSelected;
  final Color? backgroundColor;
  final int? maxLines;

  CustomInputField({
    required this.label,
    required this.hintText,
    required this.controller,
    this.validator,
    this.inputType = TextInputType.text,
    this.suffixIcon,
    this.isDatePicker = false,
    this.onDateSelected,
    this.backgroundColor = Colors.grey,
    this.maxLines = 1,
  });

  @override
  _CustomInputFieldState createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool isAnimated = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        isAnimated = true;
      });
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      final String formattedDate = "${selectedDate.toLocal()}"
          .split(' ')[0]; // Formatting the date as YYYY-MM-DD
      widget.onDateSelected?.call(
          formattedDate); // Call the callback to update the date in controller
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedOpacity(
            opacity: isAnimated ? 1.0 : 0.0,
            duration: Duration(seconds: 1),
            child: Text(
              widget.label,
              style: GoogleFonts.metrophobic(
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: .5,
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
          AnimatedOpacity(
            opacity: isAnimated ? 1.0 : 0.0,
            duration: Duration(seconds: 1),
            child: TextFormField(
              controller: widget.controller,
              keyboardType: widget.inputType,
              validator: widget.validator,
              maxLines: widget.maxLines,
              decoration: InputDecoration(
                errorStyle: GoogleFonts.metrophobic(
                  textStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                    letterSpacing: .5,
                  ),
                ),
                hintText: widget.hintText,
                suffixIcon: widget.isDatePicker
                    ? IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context),
                      )
                    : (widget.suffixIcon != null
                        ? Icon(widget.suffixIcon)
                        : null),
                fillColor: widget.backgroundColor,
                filled: true,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

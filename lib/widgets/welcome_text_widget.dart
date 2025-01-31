import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeTextWidget extends StatelessWidget {
  const WelcomeTextWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
        ),
        RichText(
          textAlign: TextAlign.start,
          text: TextSpan(
            text: "Hello, ",
            style: GoogleFonts.josefinSans(
              textStyle: TextStyle(
                color: Colors.black,
                fontSize: 25,
                fontWeight: FontWeight.w500,
                letterSpacing: .5,
              ),
            ),
            children: [
              TextSpan(
                text: "Shinchan",
                style: GoogleFonts.josefinSans(
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    letterSpacing: .5,
                  ),
                ),
              ),
            ],
          ),
        ),
        Text(
          'Have a nice day!!,',
          style: GoogleFonts.josefinSans(
            textStyle: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                letterSpacing: .5),
          ),
          textAlign: TextAlign.left,
        ),
      ],
    );
  }
}

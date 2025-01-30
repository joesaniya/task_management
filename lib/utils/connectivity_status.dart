import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConnectivityStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(children: [
      Image.asset(
        'assets/images/no_internet.png',
        height: MediaQuery.of(context).size.height * 0.25,
        width: MediaQuery.of(context).size.width * 0.65,
      ),
      Text(
        'Whoops!!',
        style: GoogleFonts.josefinSans(
          textStyle: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: .5),
        ),
      ),
      Text(
        'No Internet Connection was Found. Check\nyour connection or try again.',
        style: GoogleFonts.josefinSans(
          textStyle: TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w400,
              letterSpacing: .5),
        ),
      ),
    ]));
  }
}

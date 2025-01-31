import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:task1/provider/task_provider.dart';
import 'package:task1/sreens/add_task_screen.dart';

class WelcomeTextWidget extends StatelessWidget {
  const WelcomeTextWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddTaskScreen(),
              ),
            );
          },
          child: Container(
            height: 40,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.add,
                  color: Colors.deepPurple,
                ),
                Text(
                  'Add Task',
                  style: GoogleFonts.metrophobic(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                      letterSpacing: .5,
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}

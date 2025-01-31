import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wave/wave.dart';
import 'package:wave/config.dart';

class WaveContainer extends StatelessWidget {
  final String title;
  final double waveHeightPercentage;
  final double completedTasksPercentage;
  final List<Color> colors;
  final double percentage;

  WaveContainer(
      {required this.title,
      required this.waveHeightPercentage,
      required this.completedTasksPercentage,
      required this.colors,
      required this.percentage});

  @override
  Widget build(BuildContext context) {
    // log('completed:$completedTasksPercentage');
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          WaveWidget(
            config: CustomConfig(
              gradients: [
                [colors[0], colors[1]],
                [colors[1].withOpacity(0.3), colors[1].withOpacity(0.7)],
              ],
              durations: [3500, 4000],
              heightPercentages: [
                waveHeightPercentage.isNaN ? 0.0 : waveHeightPercentage,
                0.3,
              ],
            ),
            size: Size(double.infinity, double.infinity),
            waveAmplitude: 15,
          ),
          Positioned(
            bottom: 10,
            child: Text('$title - ${percentage.toStringAsFixed(2)}%',
                style: GoogleFonts.metrophobic(
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: .5,
                  ),
                )),
          ),
        ],
      ),
    );
  }
}

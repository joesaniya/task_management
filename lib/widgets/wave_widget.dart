import 'package:flutter/material.dart';
import 'package:wave/config.dart';


class WaveWidget extends StatelessWidget {
  final CustomConfig config;
  final double waveAmplitude;
  final Size size;

  WaveWidget({required this.config, required this.waveAmplitude, required this.size});

  @override
  Widget build(BuildContext context) {
    return WaveWidget(
      config: config,
      waveAmplitude: waveAmplitude,
      size: size,
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kiv_mbkz_weather_app/physics/rain_model.dart';
import 'package:kiv_mbkz_weather_app/physics/snow_model.dart';
import 'package:kiv_mbkz_weather_app/widgets/painters/rain_painter.dart';
import 'package:kiv_mbkz_weather_app/widgets/painters/snow_painter.dart';
import 'package:simple_animations/simple_animations/rendering.dart';

class Rain extends StatefulWidget {
  final int numberOfParticles;

  Rain(this.numberOfParticles);

  @override
  _RainState createState() => _RainState();
}

class _RainState extends State<Rain> {
  final Random random = Random();

  final List<RainModel> particles = [];

  @override
  void initState() {
    List.generate(widget.numberOfParticles, (index) {
//
      particles.add(RainModel(random));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Rendering(
      startTime: Duration(seconds: 100),
      startTimeSimulationTicks: 10000,
      onTick: _simulateParticles,
      builder: (context, time) {
        return CustomPaint(
          painter: RainPainter(particles, time),
        );
      },
    );
  }

  _simulateParticles(Duration time) {
    particles.forEach((particle) => particle.maintainRestart(time));
  }
}


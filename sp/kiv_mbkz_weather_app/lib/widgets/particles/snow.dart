import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kiv_mbkz_weather_app/physics/snow_model.dart';
import 'package:kiv_mbkz_weather_app/widgets/painters/snow_painter.dart';
import 'package:simple_animations/simple_animations/rendering.dart';

class Snow extends StatefulWidget {
  final int numberOfParticles;

  Snow(this.numberOfParticles);

  @override
  _SnowState createState() => _SnowState();
}

class _SnowState extends State<Snow> {
  final Random random = Random();

  final List<SnowModel> particles = [];

  @override
  void initState() {
    List.generate(widget.numberOfParticles, (index) {
      particles.add(SnowModel(random));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Rendering(
      startTime: Duration(seconds: 30),
      onTick: _simulateParticles,
      builder: (context, time) {
        return CustomPaint(
          painter: SnowPainter(particles, time),
        );
      },
    );
  }

  _simulateParticles(Duration time) {
    particles.forEach((particle) => particle.maintainRestart(time));
  }
}


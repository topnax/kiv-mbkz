import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kiv_mbkz_weather_app/physics/cloud_model.dart';
import 'package:kiv_mbkz_weather_app/widgets/painters/clouds_painter.dart';
import 'package:simple_animations/simple_animations/rendering.dart';

class Clouds extends StatefulWidget {
  final int numberOfParticles;
  final bool thunder;

  Clouds(this.numberOfParticles, {this.thunder = false});

  @override
  _CloudsState createState() => _CloudsState(thunder: this.thunder);
}

class _CloudsState extends State<Clouds> {
  final Random random = Random();
  final bool thunder;

  _CloudsState({this.thunder = false});

  final List<CloudsModel> particles = [];

  @override
  void initState() {
    List.generate(widget.numberOfParticles, (index) {
      particles.add(CloudsModel(random));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Rendering(
      startTime: Duration(seconds: 100),
      onTick: _simulateParticles,
      builder: (context, time) {
        return CustomPaint(
          painter: CloudsPainter(particles, time, thunder),
        );
      },
    );
  }

  _simulateParticles(Duration time) {
    particles.forEach((particle) => particle.maintainRestart(time));
  }
//
//  @override
//  void didUpdateWidget(Clouds oldWidget) {
//    debugPrint("what");
//    if( (oldWidget.thunder != thunder) || oldWidget.numberOfParticles != particles.length) {
//      setState(() {
//
//      });
//    }
//  }

}

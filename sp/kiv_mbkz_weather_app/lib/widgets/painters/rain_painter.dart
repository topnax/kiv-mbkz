import 'package:flutter/material.dart';
import 'package:kiv_mbkz_weather_app/physics/rain_model.dart';
import 'package:kiv_mbkz_weather_app/physics/snow_model.dart';

class RainPainter extends CustomPainter {
  List<RainModel> particles;
  Duration time;

  RainPainter(this.particles, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withAlpha(50);

    particles.forEach((particle) {
      var progress = particle.animationProgress.progress(time);
      final animation = particle.tween.transform(progress);
      final position =
      Offset(animation["x"] * size.width, animation["y"] * size.height);
//      canvas.drawCircle(position, size.width * 0.2 * particle.size, paint);
      canvas.drawRRect(RRect.fromLTRBR(position.dx, position.dy, position.dx+2, position.dy+50, Radius.circular(5)), paint);

    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
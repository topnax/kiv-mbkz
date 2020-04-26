import 'package:flutter/material.dart';
import 'package:kiv_mbkz_weather_app/physics/cloud_model.dart';

class CloudsPainter extends CustomPainter {
  List<CloudModel> particles;
  Duration time;
  final bool thunder;

  CloudsPainter(this.particles, this.time, this.thunder);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = !thunder ? Colors.white.withAlpha(50) : Colors.black.withAlpha(90);
    final lightningPaint = Paint()..color = Colors.yellow;

    particles.forEach((particle) {
      var progress = particle.animationProgress.progress(time);
      final animation = particle.tween.transform(progress);
      final position = Offset(animation["x"] * size.width, animation["y"] * size.height);

      Path path = Path();

      path.addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(position.dx, position.dy, particle.size * 60, particle.size * 23),
          Radius.circular(particle.size * 50)));
      path = Path.combine(
          PathOperation.union,
          path,
          getPath(Rect.fromLTWH(position.dx + particle.size * 10, position.dy - particle.size * 12, particle.size * 30,
              particle.size * 30)));
      path = Path.combine(
          PathOperation.union,
          path,
          getPath(Rect.fromLTWH(position.dx + particle.size * 31, position.dy - particle.size * 7, particle.size * 20,
              particle.size * 20)));

      path.close();

      canvas.drawPath(path, paint);

      if (thunder && particle.lightning) {
        path = Path();
        path.relativeMoveTo(position.dx + particle.size * 33, position.dy + particle.size * 10);
        path.relativeLineTo(-particle.size * 10, particle.size * 10);
        path.relativeLineTo(particle.size * 10, 0);
        path.relativeLineTo(-particle.size * 11, particle.size * 10);
        path.relativeLineTo(particle.size * 13, -particle.size * 11);
        path.relativeLineTo(-particle.size * 9, 0);
        path.close();
        canvas.drawPath(path, lightningPaint);
      }

      //      canvas.drawRRect(RRect.fromLTRBR(position.dx, position.dy, position.dx+2, position.dy+50, Radius.circular(5)), paint);
    });
  }

  Path getPath(Rect rect) {
    var path = Path();
    path.addOval(rect);
    return path;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

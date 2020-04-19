import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:simple_animations/simple_animations/controlled_animation.dart';

class AnimatedSun extends StatelessWidget {
  final double speed;

  AnimatedSun({this.speed = 0.2});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        width: constraints.biggest.width,
        child: ControlledAnimation(
            playback: Playback.LOOP,
            duration: Duration(milliseconds: (5000 / speed).round()),
            tween: MultiTrackTween([
              Track("value").add(Duration(milliseconds: (5000 / speed).round()), Tween(begin: 0.0, end: pi)),
              Track("shine")
                  .add(Duration(milliseconds: 2500), Tween(begin: 0.2, end: 1.0))
                  .add(Duration(milliseconds: 2500), Tween(begin: 1.0, end: 0.2))
                  .add(Duration(milliseconds: 2500), Tween(begin: 0.2, end: 1.0)),
            ]),
            builder: (context, animation) {
              return CustomPaint(
                foregroundPainter: SunPainter(animation["value"], animation["shine"]),
              );
            }),
      );
    });
  }
}

class SunPainter extends CustomPainter {
  final double value;
  final double shine;

  SunPainter(this.value, this.shine);

  @override
  void paint(Canvas canvas, Size size) {
    final white = Paint()..color = Colors.white.withAlpha(80);
    var radius = 50.0;
    var x = 100;
    var offset = Offset(((size.width + x) * (value / (pi))) - (x / 2), (size.height * 0.2) - (sin(value) * 70));
    canvas.drawCircle(offset, radius, white);

    var count = 15;

    var angleDiff = 360.0 / count.toDouble();
    canvas.translate(offset.dx, offset.dy);
    var half = (pi / 12);
    var max = half * 2;
    var curr = value % max;

    double opacity = (80 * (value % half) / half);
    if (curr > half) {
      opacity = 80 - opacity;
    }

    final shinePaint = Paint()..color = Colors.white.withAlpha(opacity.round());

    for (var i = 0; i < count; i++) {
      canvas.save();
      canvas.rotate(angleDiff * i * pi / 180);

      canvas.translate(radius * 1.2, 0);
      canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(5, 0), width: 20, height: 5), Radius.circular(5)),
          shinePaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

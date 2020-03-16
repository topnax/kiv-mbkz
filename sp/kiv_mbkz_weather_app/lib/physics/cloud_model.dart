import 'dart:math';

import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class CloudsModel {
  Animatable tween;
  AnimationProgress animationProgress;
  Random random;
  double size;
  int offset;
  bool lightning = false;


  CloudsModel(this.random) {
    offset = random.nextInt(100);
    if (random.nextInt(100) <= 20) {
      lightning = true;
    }
    restart();
  }

  restart({Duration time = Duration.zero}) {
    final startPosition = Offset(-0.8* random.nextDouble() - 0.5, (0.25)*random.nextDouble());
    final endPosition = Offset(1 + (0.8*random.nextDouble()), startPosition.dy);
    final duration = Duration(milliseconds: 25000 + random.nextInt(40000));
    size = (2 * random.nextDouble()) + 0.9;


    tween = MultiTrackTween([
      Track("x").add(
          duration, Tween(begin: startPosition.dx, end: endPosition.dx),
          curve: Curves.linear),
      Track("y").add(
          duration, Tween(begin: startPosition.dy, end: endPosition.dy),
          curve: Curves.linear),
    ]);
    animationProgress = AnimationProgress(duration: duration, startTime: time);
  }

  maintainRestart(Duration time) {
    if (animationProgress.progress(time) == 1.0) {
      restart(time: time);
    }
  }
}
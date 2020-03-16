import 'dart:math';

import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class SnowModel {
  Animatable tween;
  double size;
  AnimationProgress animationProgress;
  Random random;

  SnowModel(this.random) {
    restart();
  }

  restart({Duration time = Duration.zero}) {
    final startPosition = Offset(-0.4, 0.2);
    final endPosition = Offset(-0.2 + 1.4 * random.nextDouble(), 0.2);
    final duration = Duration(milliseconds: 2000 + random.nextInt(4500));

    tween = MultiTrackTween([
      Track("x").add(
          duration, Tween(begin: startPosition.dx, end: endPosition.dx),
          curve: Curves.easeInOutSine),
      Track("y").add(
          duration, Tween(begin: startPosition.dy, end: endPosition.dy),
          curve: Curves.easeIn),
    ]);
    animationProgress = AnimationProgress(duration: duration, startTime: time);
    size = 0.1 + random.nextDouble() * 0.2;
  }

  maintainRestart(Duration time) {
    if (animationProgress.progress(time) == 1.0) {
      restart(time: time);
    }
  }
}
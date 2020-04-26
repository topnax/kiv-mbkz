import 'dart:math';

import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class RainModel {
  Animatable tween;
  AnimationProgress animationProgress;
  Random random;
  int offset;

  RainModel(this.random) {
    offset = random.nextInt(100);
    restart();
  }

  restart({Duration time = Duration.zero}) {
    final startPosition = Offset(-0.4 + 1.6 * random.nextDouble(), -0.2);
    final endPosition = Offset(startPosition.dx + 0.2 * random.nextDouble(), 1.2);
    final duration = Duration(milliseconds: 600 + random.nextInt(500));

    tween = MultiTrackTween([
      Track("x").add(duration, Tween(begin: startPosition.dx, end: endPosition.dx), curve: Curves.linear),
      Track("y").add(duration, Tween(begin: startPosition.dy, end: endPosition.dy), curve: Curves.linear),
    ]);
    animationProgress = AnimationProgress(duration: duration, startTime: time);
  }

  maintainRestart(Duration time) {
    if (animationProgress.progress(time) == 1.0) {
      restart(time: time);
    }
  }
}

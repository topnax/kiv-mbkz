import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class AnimatedBackground extends StatelessWidget {

  final Widget child;
  final MaterialColor color1;


  AnimatedBackground({this.child, this.color1});

  @override
  Widget build(BuildContext context) {
    print(color1.red);
    final tween = MultiTrackTween([
      Track("color1").add(Duration(seconds: 1),
          ColorTween(begin: color1[300], end: color1[500])),
      Track("color2").add(Duration(seconds: 3),
          ColorTween(begin: color1[500], end: color1[700]))
    ]);

    return ControlledAnimation(
      key: LabeledGlobalKey(color1.red.toString()),
      playback: Playback.MIRROR,
      tween: tween,
      duration: tween.duration,
      builder: (context, animation) {
        return Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [animation["color1"], animation["color2"]])),
          child: child,
        );
      },
    );
  }


}
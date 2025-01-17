import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class FadeIn extends StatelessWidget {
  final double delay;
  final Widget child;
  final bool enable;

  FadeIn(this.delay, this.child, this.enable);

  @override
  Widget build(BuildContext context) {
    if (!enable) {
      return child;
    }
    final tween = MultiTrackTween([
      Track("opacity").add(Duration(milliseconds: 500), Tween(begin: 0.0, end: 1.0)),
      Track("translateX").add(Duration(milliseconds: 500), Tween(begin: 130.0, end: 0.0), curve: Curves.easeOut)
    ]);

    return ControlledAnimation(
      delay: Duration(milliseconds: (300 * delay).round()),
      duration: tween.duration,
      tween: tween,
      child: child,
      builderWithChild: (context, child, animation) => Opacity(
        opacity: animation["opacity"],
        child: Transform.translate(offset: Offset(animation["translateX"], 0), child: child),
      ),
    );
  }
}

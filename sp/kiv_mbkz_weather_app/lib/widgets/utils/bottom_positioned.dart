import 'package:flutter/material.dart';

class BottomPositionedFill extends StatelessWidget {
  final Widget child;

  const BottomPositionedFill({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: child,
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:meta/meta.dart';
import 'package:intl/intl.dart';

class LastUpdated extends StatelessWidget {
  final DateTime dateTime;
  final int wIndex;

  LastUpdated({Key key, @required this.dateTime, this.wIndex})
      : assert(dateTime != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      _getLabel(wIndex),
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w200,
        color: Colors.white,
      ),
    );
  }

  String _getLabel(int wIndex){
    switch (wIndex) {
      case 0: return "today";
      case 1: return "tommorow";
      default: return  '${DateFormat('dd.MM.yyyy').format(dateTime)}';
    }
  }
}

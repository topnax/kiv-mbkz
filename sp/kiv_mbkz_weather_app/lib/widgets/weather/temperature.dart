import 'package:flutter/material.dart';
import 'package:kiv_mbkz_weather_app/blocs/settings/settings_bloc.dart';
import 'package:kiv_mbkz_weather_app/utils/formatting_utils.dart';

class Temperature extends StatelessWidget {
  final double temperature;
  final double low;
  final double high;
  final Units units;

  Temperature({
    Key key,
    this.temperature,
    this.low,
    this.high,
    this.units,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(right: 20.0),
          child: Text(
            '${formattedTemperatureText(temperature, units)}',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        Column(
          children: [
            Text(
              'max: ${formattedTemperatureText(high, units)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w100,
                color: Colors.white,
              ),
            ),
            Text(
              'min: ${formattedTemperatureText(low, units)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w100,
                color: Colors.white,
              ),
            )
          ],
        )
      ],
    );
  }
}

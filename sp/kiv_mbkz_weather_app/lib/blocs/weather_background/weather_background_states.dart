import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:kiv_mbkz_weather_app/models/weather.dart';

class WeatherBackgroundState extends Equatable {
  final MaterialColor color;
  final WeatherCondition condition;
  final visible;

  const WeatherBackgroundState({@required this.color, @required this.visible, @required this.condition})
      : assert(color != null);

  @override
  List<Object> get props => [color, visible, condition];
}

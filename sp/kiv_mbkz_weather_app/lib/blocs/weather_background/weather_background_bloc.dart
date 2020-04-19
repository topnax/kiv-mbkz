import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:kiv_mbkz_weather_app/blocs/weather_background/weather_background_events.dart';
import 'package:kiv_mbkz_weather_app/blocs/weather_background/weather_background_states.dart';
import 'package:kiv_mbkz_weather_app/models/models.dart';

class WeatherBackgroundBloc extends Bloc<WeatherBackgroundEvent, WeatherBackgroundState> {
  final List<Weather> weathers;

  WeatherBackgroundBloc({this.weathers});

  @override
  WeatherBackgroundState get initialState => WeatherBackgroundState(
      color: mapWeatherConditionToThemeData(weathers[0].condition), visible: true, condition: weathers[0].condition);

  @override
  Stream<WeatherBackgroundState> mapEventToState(WeatherBackgroundEvent event) async* {
    if (event is WeatherBackgroundChanged) {
      var condition = weathers[event.tabIndex].condition;
      var color = mapWeatherConditionToThemeData(condition);
      if (condition != state.condition) {
        // hide the previous background
        yield WeatherBackgroundState(color: state.color, visible: false, condition: state.condition);
        await Future.delayed(Duration(milliseconds: 500));
        // display the new background after a brief delay
        yield WeatherBackgroundState(color: color, visible: true, condition: condition);
      }
    }
  }

  static MaterialColor mapWeatherConditionToThemeData(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.clear:
        return Colors.orange;

      case WeatherCondition.hail:
      case WeatherCondition.snow:
      case WeatherCondition.sleet:
        return Colors.lightBlue;

      case WeatherCondition.lightCloud:
      case WeatherCondition.heavyCloud:
        return Colors.grey;

      case WeatherCondition.heavyRain:
      case WeatherCondition.lightRain:
      case WeatherCondition.showers:
        return Colors.indigo;

      case WeatherCondition.thunderstorm:
        return Colors.deepPurple;

      case WeatherCondition.unknown:
      default:
        return Colors.lightBlue;
    }
  }
}

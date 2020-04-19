import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:kiv_mbkz_weather_app/models/models.dart';
import 'package:meta/meta.dart';

class WeatherBackgroundState extends Equatable {
  final MaterialColor color;
  final WeatherCondition condition;
  final visible;

  const WeatherBackgroundState({@required this.color, @required this.visible, @required this.condition})
      : assert(color != null);

  @override
  List<Object> get props => [color, visible, condition];
}

abstract class WeatherBackgroundEvent extends Equatable {
  const WeatherBackgroundEvent();
}

class WeatherBackgroundChanged extends WeatherBackgroundEvent {
  final int tabIndex;

  const WeatherBackgroundChanged({@required this.tabIndex}) : assert(tabIndex != null);

  @override
  List<Object> get props => [tabIndex];
}

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
        yield WeatherBackgroundState(color: state.color, visible: false, condition: state.condition);
        await Future.delayed(Duration(milliseconds: 500));
        debugPrint(condition.toString());
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

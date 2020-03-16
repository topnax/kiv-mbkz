import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kiv_mbkz_weather_app/blocs/blocs.dart';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:kiv_mbkz_weather_app/models/models.dart';

class WeatherBackgroundState extends Equatable {
  final MaterialColor color;
  final WeatherCondition condition;
  final visible;

  const WeatherBackgroundState({@required this.color, @required this.visible, @required this.condition}):
        assert(color != null);

  @override
  List<Object> get props => [ color, visible, condition];
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
    color: ThemeBloc.mapWeatherConditionToThemeData(weathers[0].condition).color,
    visible: true,
    condition: weathers[0].condition
  );

  @override
  Stream<WeatherBackgroundState> mapEventToState(WeatherBackgroundEvent event) async* {
    if (event is WeatherBackgroundChanged) {
      var condition = weathers[event.tabIndex].condition;
      var color = ThemeBloc.mapWeatherConditionToThemeData(condition).color;
      if(condition != state.condition) {
        yield WeatherBackgroundState(color: state.color, visible: false, condition: state.condition);
        await Future.delayed(Duration(milliseconds: 500));
      debugPrint(condition.toString());
        yield WeatherBackgroundState(color: color, visible: true, condition: condition);
      }
    }
  }



}

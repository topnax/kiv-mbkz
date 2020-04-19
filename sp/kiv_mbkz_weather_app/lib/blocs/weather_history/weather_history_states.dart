import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:kiv_mbkz_weather_app/models/city.dart';

abstract class WeatherHistoryState extends Equatable {
  const WeatherHistoryState();

  @override
  List<Object> get props => [];
}

class WeatherHistoryEmpty extends WeatherHistoryState {}

class WeatherHistoryLoaded extends WeatherHistoryState {
  final List<City> cities;

  const WeatherHistoryLoaded({@required this.cities}) : assert(cities != null);

  @override
  List<Object> get props => [cities];
}

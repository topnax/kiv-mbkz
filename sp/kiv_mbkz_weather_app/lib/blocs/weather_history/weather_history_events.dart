import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:kiv_mbkz_weather_app/models/city.dart';

abstract class WeatherHistoryEvent extends Equatable {
  const WeatherHistoryEvent();
}

class AddRecentlySearchedCity extends WeatherHistoryEvent {
  final City city;

  const AddRecentlySearchedCity({@required this.city}) : assert(city != null);

  @override
  List<Object> get props => [city];
}

class LoadRecentlySearchedCities extends WeatherHistoryEvent {
  @override
  List<Object> get props => [];
}

class ClearRecentlySearchedCities extends WeatherHistoryEvent {
  @override
  List<Object> get props => [];
}

class ClearRecentlySearchedCity extends WeatherHistoryEvent {
  final City city;

  ClearRecentlySearchedCity(this.city);

  @override
  List<Object> get props => [city];
}

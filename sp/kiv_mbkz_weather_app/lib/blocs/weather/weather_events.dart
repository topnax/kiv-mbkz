import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();
}

class FetchWeather extends WeatherEvent {
  final String city;

  const FetchWeather({@required this.city}) : assert(city != null);

  @override
  List<Object> get props => [city];
}

class FetchWeatherFromLocationId extends WeatherEvent {
  final int locationId;

  const FetchWeatherFromLocationId({@required this.locationId}) : assert(locationId != null);

  @override
  List<Object> get props => [locationId];
}

class ResetWeather extends WeatherEvent {
  @override
  List<Object> get props => [];
}

import 'dart:async';

import 'package:kiv_mbkz_weather_app/models/weather.dart';
import 'package:kiv_mbkz_weather_app/repositories/weather/repositories.dart';
import 'package:meta/meta.dart';

class WeatherRepository {
  final WeatherApiClient weatherApiClient;

  WeatherRepository({@required this.weatherApiClient}) : assert(weatherApiClient != null);

  Future<List<Weather>> getWeather(String city) async {
    final int locationId = await weatherApiClient.getLocationId(city);
    return weatherApiClient.fetchWeather(locationId);
  }

  Future<List<Weather>> getWeatherByLocationId(int locationId) async {
    return weatherApiClient.fetchWeather(locationId);
  }
}

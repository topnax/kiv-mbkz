import 'dart:convert';
import 'dart:async';

import 'package:kiv_mbkz_weather_app/models/models.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

class WeatherApiClient {
  static const baseUrl = 'https://www.metaweather.com';
  final http.Client httpClient;

  WeatherApiClient({@required this.httpClient}) : assert(httpClient != null);

  Future<int> getLocationId(String city) async {
    final locationUrl = '$baseUrl/api/location/search/?query=$city';
    final locationResponse = await this.httpClient.get(locationUrl);
    if (locationResponse.statusCode != 200) {
      throw Exception('Network not available');
    }

    final locationJson = jsonDecode(locationResponse.body) as List;

    if (locationJson.length == 0) {
      throw WeatherNotFoundException();
    }
    // return the location ID
    return (locationJson.first)['woeid'];
  }

  Future<List<Weather>> fetchWeather(int locationId) async {
    final weatherUrl = '$baseUrl/api/location/$locationId';
    final weatherResponse = await this.httpClient.get(weatherUrl);

    if (weatherResponse.statusCode != 200) {
      throw Exception('Network not available');
    }

    final weatherJson = jsonDecode(weatherResponse.body);
    return Weather.fromJson(weatherJson);
  }
}

class WeatherNotFoundException implements Exception {}

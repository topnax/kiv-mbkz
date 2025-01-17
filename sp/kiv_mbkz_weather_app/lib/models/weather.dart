import 'package:equatable/equatable.dart';

enum WeatherCondition {
  snow,
  sleet,
  hail,
  thunderstorm,
  heavyRain,
  lightRain,
  showers,
  heavyCloud,
  lightCloud,
  clear,
  unknown
}

class Weather extends Equatable {
  final WeatherCondition condition;
  final String formattedCondition;
  final double minTemp;
  final double temp;
  final double maxTemp;
  final double windSpeed;
  final int humidity;
  final int locationId;
  final String created;
  final DateTime lastUpdated;
  final DateTime applicableDate;
  final String location;

  const Weather(
      {this.condition,
      this.formattedCondition,
      this.minTemp,
      this.temp,
      this.maxTemp,
      this.locationId,
      this.created,
      this.windSpeed,
      this.lastUpdated,
      this.location,
      this.applicableDate,
      this.humidity});

  @override
  List<Object> get props => [
        condition,
        formattedCondition,
        minTemp,
        temp,
        maxTemp,
        locationId,
        created,
        lastUpdated,
        location,
        humidity,
        windSpeed
      ];

  static List<Weather> fromJson(dynamic json) {
    var list = List<Weather>();
    for (var consolidatedWeather in json["consolidated_weather"]) {
      list.add(Weather(
          condition: _mapStringToWeatherCondition(consolidatedWeather['weather_state_abbr']),
          formattedCondition: consolidatedWeather['weather_state_name'],
          minTemp: consolidatedWeather['min_temp'] as double,
          temp: consolidatedWeather['the_temp'] as double,
          maxTemp: consolidatedWeather['max_temp'] as double,
          windSpeed: consolidatedWeather['wind_speed'] as double,
          humidity: consolidatedWeather['humidity'] as int,
          locationId: json['woeid'] as int,
          created: consolidatedWeather['created'],
          lastUpdated: DateTime.now(),
          location: json['title'],
          applicableDate: DateTime.parse(consolidatedWeather["applicable_date"])));
    }

    return list;
  }

  static WeatherCondition _mapStringToWeatherCondition(String input) {
    WeatherCondition state;
    switch (input) {
      case 'sn':
        state = WeatherCondition.snow;
        break;
      case 'sl':
        state = WeatherCondition.sleet;
        break;
      case 'h':
        state = WeatherCondition.hail;
        break;
      case 't':
        state = WeatherCondition.thunderstorm;
        break;
      case 'hr':
        state = WeatherCondition.heavyRain;
        break;
      case 'lr':
        state = WeatherCondition.lightRain;
        break;
      case 's':
        state = WeatherCondition.showers;
        break;
      case 'hc':
        state = WeatherCondition.heavyCloud;
        break;
      case 'lc':
        state = WeatherCondition.lightCloud;
        break;
      case 'c':
        state = WeatherCondition.clear;
        break;
      default:
        state = WeatherCondition.unknown;
    }
    return state;
  }
}

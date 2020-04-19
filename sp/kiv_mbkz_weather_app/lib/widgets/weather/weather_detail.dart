import 'package:flutter/material.dart';
import 'package:kiv_mbkz_weather_app/blocs/settings/bloc.dart';
import 'package:kiv_mbkz_weather_app/blocs/settings/settings_bloc.dart';

import 'package:meta/meta.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kiv_mbkz_weather_app/models/models.dart' as model;
import 'package:kiv_mbkz_weather_app/widgets/widgets.dart';

class WeatherDetail extends StatelessWidget {
  final model.Weather weather;

  WeatherDetail({
    Key key,
    @required this.weather,
  })  : assert(weather != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(20.0),
              child: BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, state) {
                  return Temperature(
                    temperature: weather.temp,
                    high: weather.maxTemp,
                    low: weather.minTemp,
                    units: state.temperatureUnits,
                  );
                },
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Icon(
                Icons.opacity,
                color: Colors.white,
                size: 16,
              ),
            ),
            Text(
              "${(weather.humidity).round().toString()}%",
              style: TextStyle(
                fontWeight: FontWeight.w200,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: Icon(
                  Icons.toys,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, state) => Text(
                  _formatWindSpeed(weather.windSpeed, state.temperatureUnits),
                  style: TextStyle(
                    fontWeight: FontWeight.w200,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              weather.formattedCondition,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w200,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatWindSpeed(double windSpeed, TemperatureUnits temperatureUnits) {
    if (temperatureUnits == TemperatureUnits.fahrenheit) {
      return "${(weather.windSpeed).round().toString()} mph";
    } else {
      return "${(weather.windSpeed * 1.609).round().toString()} km/h";
    }
  }
}

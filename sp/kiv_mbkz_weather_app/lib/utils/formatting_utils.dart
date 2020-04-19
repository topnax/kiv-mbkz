import 'package:kiv_mbkz_weather_app/blocs/settings/settings_bloc.dart';

int toFahrenheit(double celsius) => ((celsius * 9 / 5) + 32).round();

int formattedTemperature(double temperature, Units units) =>
    units == Units.imperial ? toFahrenheit(temperature) : temperature.round();

String formattedTemperatureText(double temperature, Units units) {
  return "${formattedTemperature(temperature, units)} °${units == Units.metric ? "C" : "F"}";
}

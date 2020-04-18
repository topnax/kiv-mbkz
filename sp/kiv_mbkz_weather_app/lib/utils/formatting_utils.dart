import 'package:kiv_mbkz_weather_app/blocs/settings_bloc.dart';

int toFahrenheit(double celsius) => ((celsius * 9 / 5) + 32).round();

int formattedTemperature(double temperature, TemperatureUnits units) =>
    units == TemperatureUnits.fahrenheit ? toFahrenheit(temperature) : temperature.round();

String formattedTemperatureText(double temperature, TemperatureUnits units) {
  return "${formattedTemperature(temperature, units)} °${units == TemperatureUnits.celsius ? "C" : "F"}";
}

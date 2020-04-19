import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:kiv_mbkz_weather_app/blocs/settings/settings_bloc.dart';

class SettingsState extends Equatable {
  final TemperatureUnits temperatureUnits;

  const SettingsState({@required this.temperatureUnits}) : assert(temperatureUnits != null);

  @override
  List<Object> get props => [temperatureUnits];
}

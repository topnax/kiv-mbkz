import 'dart:async';

import 'package:kiv_mbkz_weather_app/repositories/preferences/preferences_repository.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {}

class TemperatureUnitsToggled extends SettingsEvent {
  @override
  List<Object> get props => [];
}

class LoadTemperatureUnits extends SettingsEvent {
  @override
  List<Object> get props => [];
}

enum TemperatureUnits { fahrenheit, celsius }

class SettingsState extends Equatable {
  final TemperatureUnits temperatureUnits;

  const SettingsState({@required this.temperatureUnits}) : assert(temperatureUnits != null);

  @override
  List<Object> get props => [temperatureUnits];
}

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final PersistentStorageRepository _persistentStorageRepository;
  TemperatureUnits _initialUnits;

  SettingsBloc(this._persistentStorageRepository);

  @override
  SettingsState get initialState => SettingsState(temperatureUnits: TemperatureUnits.celsius);

  @override
  Stream<SettingsState> mapEventToState(SettingsEvent event) async* {
    if (event is TemperatureUnitsToggled) {
      yield SettingsState(
        temperatureUnits:
            state.temperatureUnits == TemperatureUnits.celsius ? TemperatureUnits.fahrenheit : TemperatureUnits.celsius,
      );
      _persistentStorageRepository.setTemperatureUnitsPreference(state.temperatureUnits);
    } else if (event is LoadTemperatureUnits) {
      yield SettingsState(
        temperatureUnits: await _persistentStorageRepository.getTemperatureUnitsPreference(),
      );
    }
  }
}

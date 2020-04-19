import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:kiv_mbkz_weather_app/blocs/settings/settings_events.dart';
import 'package:kiv_mbkz_weather_app/blocs/settings/settings_states.dart';
import 'package:kiv_mbkz_weather_app/repositories/preferences/preferences_repository.dart';

enum TemperatureUnits { fahrenheit, celsius }

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final PersistentStorageRepository _persistentStorageRepository;

  SettingsBloc(this._persistentStorageRepository);

  @override
  SettingsState get initialState => SettingsState(temperatureUnits: TemperatureUnits.celsius);

  @override
  Stream<SettingsState> mapEventToState(SettingsEvent event) async* {
    if (event is TemperatureUnitsToggled) {
      // toggle temperature units preference
      yield SettingsState(
        temperatureUnits:
            state.temperatureUnits == TemperatureUnits.celsius ? TemperatureUnits.fahrenheit : TemperatureUnits.celsius,
      );
      // store it in the persistent storage
      _persistentStorageRepository.setTemperatureUnitsPreference(state.temperatureUnits);
    } else if (event is LoadTemperatureUnits) {
      // load preference from the persistent storage
      yield SettingsState(
        temperatureUnits: await _persistentStorageRepository.getTemperatureUnitsPreference(),
      );
    }
  }
}

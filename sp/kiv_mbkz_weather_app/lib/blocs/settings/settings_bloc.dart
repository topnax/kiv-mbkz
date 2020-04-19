import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:kiv_mbkz_weather_app/blocs/settings/settings_events.dart';
import 'package:kiv_mbkz_weather_app/blocs/settings/settings_states.dart';
import 'package:kiv_mbkz_weather_app/repositories/preferences/preferences_repository.dart';

enum Units { imperial, metric }

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final PersistentStorageRepository _persistentStorageRepository;

  SettingsBloc(this._persistentStorageRepository);

  @override
  SettingsState get initialState => SettingsState(temperatureUnits: Units.metric);

  @override
  Stream<SettingsState> mapEventToState(SettingsEvent event) async* {
    if (event is UnitsToggled) {
      // toggle units preference
      yield SettingsState(
        temperatureUnits: state.temperatureUnits == Units.metric ? Units.imperial : Units.metric,
      );
      // store it in the persistent storage
      _persistentStorageRepository.setUnitsPreference(state.temperatureUnits);
    } else if (event is LoadUnits) {
      // load preference from the persistent storage
      yield SettingsState(
        temperatureUnits: await _persistentStorageRepository.getUnitsPreference(),
      );
    }
  }
}

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:kiv_mbkz_weather_app/blocs/weather_history/weather_history_events.dart';
import 'package:kiv_mbkz_weather_app/blocs/weather_history/weather_history_states.dart';
import 'package:kiv_mbkz_weather_app/models/city.dart';
import 'package:kiv_mbkz_weather_app/repositories/preferences/preferences_repository.dart';
import 'package:kiv_mbkz_weather_app/repositories/weather/repositories.dart';
import 'package:meta/meta.dart';

class WeatherHistoryBloc extends Bloc<WeatherHistoryEvent, WeatherHistoryState> {
  final PersistentStorageRepository persistentStorageRepository;
  final WeatherRepository weatherRepository;

  WeatherHistoryBloc({@required this.persistentStorageRepository, @required this.weatherRepository})
      : assert(persistentStorageRepository != null),
        assert(weatherRepository != null) {
    add(LoadRecentlySearchedCities());
  }

  @override
  WeatherHistoryState get initialState => WeatherHistoryEmpty();

  @override
  Stream<WeatherHistoryState> mapEventToState(WeatherHistoryEvent event) async* {
    if (event is ClearRecentlySearchedCities) {
      yield* _clearHistory();
    } else if (event is AddRecentlySearchedCity) {
      yield* _addRecentlySearchedCity(event);
    } else if (event is LoadRecentlySearchedCities) {
      yield* _loadHistory();
    } else if (event is ClearRecentlySearchedCity) {
      yield* _removeCityFromHistory(event);
    }
  }

  Stream<WeatherHistoryState> _clearHistory() async* {
    await persistentStorageRepository.clearCityHistory();
    yield WeatherHistoryLoaded(cities: List<City>());
  }

  Stream<WeatherHistoryState> _addRecentlySearchedCity(AddRecentlySearchedCity event) async* {
    await persistentStorageRepository.addRecentlySearchedCity(event.city);
    yield WeatherHistoryLoaded(cities: await persistentStorageRepository.getRecentlySearchedCitiesNames());
  }

  Stream<WeatherHistoryState> _loadHistory() async* {
    yield WeatherHistoryLoaded(cities: List<City>());
    var cities = await persistentStorageRepository.getRecentlySearchedCitiesNames();

    await Future.delayed(Duration(milliseconds: 1));
    if (cities.length > 0) {
      yield WeatherHistoryLoaded(cities: cities);
    } else {
      yield WeatherHistoryEmpty();
    }
  }

  Stream<WeatherHistoryState> _removeCityFromHistory(ClearRecentlySearchedCity event) async* {
    var list = await persistentStorageRepository.removeCityFromHistory(event.city);
    yield WeatherHistoryLoaded(cities: list);
  }
}

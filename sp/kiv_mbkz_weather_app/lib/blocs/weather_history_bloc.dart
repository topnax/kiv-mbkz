import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:kiv_mbkz_weather_app/repositories/preferences/preferences_repository.dart';
import 'package:kiv_mbkz_weather_app/repositories/weather/repositories.dart';
import 'package:meta/meta.dart';

abstract class WeatherHistoryEvent extends Equatable {
  const WeatherHistoryEvent();
}

class AddRecentlySearchedCity extends WeatherHistoryEvent {
  final String cityName;

  const AddRecentlySearchedCity({@required this.cityName}) : assert(cityName != null);

  @override
  List<Object> get props => [cityName];
}

class LoadRecentlySearchedCities extends WeatherHistoryEvent {
  @override
  List<Object> get props => [];
}

class ClearRecentlySearchedCities extends WeatherHistoryEvent {
  @override
  List<Object> get props => [];
}

abstract class WeatherHistoryState extends Equatable {
  const WeatherHistoryState();

  @override
  List<Object> get props => [];
}

class WeatherHistoryEmpty extends WeatherHistoryState {}

class WeatherHistoryLoaded extends WeatherHistoryState {
  final List<String> cities;

  const WeatherHistoryLoaded({@required this.cities}) : assert(cities != null);

  @override
  List<Object> get props => [cities];
}

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
    }
  }

  Stream<WeatherHistoryState> _clearHistory() async* {
    await persistentStorageRepository.clearCityHistory();
    yield WeatherHistoryLoaded(cities: List<String>());
  }

  Stream<WeatherHistoryState> _addRecentlySearchedCity(AddRecentlySearchedCity event) async* {
    await persistentStorageRepository.addRecentlySearchedCity(event.cityName);
    yield WeatherHistoryLoaded(cities: await persistentStorageRepository.getRecentlySearchedCitiesNames());
  }

  Stream<WeatherHistoryState> _loadHistory() async* {
    var cities = await persistentStorageRepository.getRecentlySearchedCitiesNames();
    if (cities.length > 0) {
      debugPrint("history not empty");
      for (var name in cities) {
        await weatherRepository.getWeather(name);
      }
      yield WeatherHistoryLoaded(cities: cities);
    } else {
      debugPrint("history is EMPTY");
      yield WeatherHistoryEmpty();
    }
  }
}

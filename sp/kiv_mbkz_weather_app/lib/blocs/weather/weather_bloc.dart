import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:kiv_mbkz_weather_app/blocs/weather/weather_events.dart';
import 'package:kiv_mbkz_weather_app/blocs/weather/weather_states.dart';
import 'package:kiv_mbkz_weather_app/models/models.dart';
import 'package:kiv_mbkz_weather_app/repositories/weather/repository.dart';
import 'package:meta/meta.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepository weatherRepository;

  WeatherBloc({@required this.weatherRepository}) : assert(weatherRepository != null);

  @override
  WeatherState get initialState => WeatherEmpty();

  @override
  Stream<WeatherState> mapEventToState(WeatherEvent event) async* {
    if (event is FetchWeather) {
      yield* _mapFetchWeatherToState(event);
    } else if (event is FetchWeatherFromLocationId) {
      yield* _mapFetchWeatherFromLocationIdToState(event);
    } else if (event is ResetWeather) {
      yield WeatherEmpty();
    }
  }

  Stream<WeatherState> _mapFetchWeatherToState(FetchWeather event) async* {
    if (event.city.isNotEmpty) {
      yield WeatherLoading();
      try {
        // load weather by city name from the weather repository
        final List<Weather> weather = await weatherRepository.getWeather(event.city);
        yield WeatherLoaded(weather: weather);
      } catch (e, s) {
        debugPrint(s.toString());
        yield* _throwWeatherError(e);
      }
    }
  }

  Stream<WeatherState> _mapFetchWeatherFromLocationIdToState(FetchWeatherFromLocationId event) async* {
    try {
      yield WeatherLoading();
      // load weather by location id from the weather repository
      final weather = await weatherRepository.getWeatherByLocationId(event.locationId);
      yield WeatherLoaded(weather: weather);
    } catch (e, s) {
      debugPrint(s.toString());
      yield* _throwWeatherError(e);
    }
  }

  Stream<WeatherState> _throwWeatherError(e) async* {
    debugPrint("caught $e");
    if (e is SocketException) {
      yield WeatherError("Network is not available");
    } else if (e is WeatherNotFoundException) {
      yield WeatherError("Cannot find weather for such location");
    } else {
      yield WeatherError("Unknown error");
    }
  }
}

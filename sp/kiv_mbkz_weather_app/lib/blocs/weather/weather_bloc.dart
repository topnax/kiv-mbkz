import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:kiv_mbkz_weather_app/blocs/weather/weather_events.dart';
import 'package:kiv_mbkz_weather_app/blocs/weather/weather_states.dart';
import 'package:kiv_mbkz_weather_app/models/models.dart';
import 'package:kiv_mbkz_weather_app/repositories/weather/repositories.dart';
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
    } else if (event is RefreshWeather) {
      yield* _mapRefreshWeatherToState(event);
    } else if (event is ResetWeather) {
      yield WeatherEmpty();
    }
  }

  Stream<WeatherState> _mapFetchWeatherToState(FetchWeather event) async* {
    if (event.city.isNotEmpty) {
      yield WeatherLoading();
      try {
        final List<Weather> weather = await weatherRepository.getWeather(event.city);
        yield WeatherLoaded(weather: weather);
      } catch (e, s) {
        print("caught $e");
        print("at $s");
        yield WeatherError();
      }
    }
  }

  Stream<WeatherState> _mapRefreshWeatherToState(RefreshWeather event) async* {
    try {
      final List<Weather> weather = await weatherRepository.getWeather(event.city);
      yield WeatherLoaded(weather: weather);
    } catch (_) {
      yield state;
    }
  }

  Stream<WeatherState> _mapFetchWeatherFromLocationIdToState(FetchWeatherFromLocationId event) async* {
    try {
      yield WeatherLoading();
      final List<Weather> weather = await weatherRepository.getWeatherByLocationId(event.locationId);
      yield WeatherLoaded(weather: weather);
    } catch (_) {
      yield state;
    }
  }
}

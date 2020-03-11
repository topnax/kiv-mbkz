import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kiv_mbkz_weather_app/blocs/settings_bloc.dart';
import 'package:kiv_mbkz_weather_app/blocs/theme_bloc.dart';
import 'package:kiv_mbkz_weather_app/blocs/weather_bloc.dart';
import 'package:kiv_mbkz_weather_app/repositories/repositories.dart';
import 'package:kiv_mbkz_weather_app/repositories/weather_repository.dart';
import 'package:kiv_mbkz_weather_app/simple_bloc_delegate.dart';
import 'package:kiv_mbkz_weather_app/widgets/weather.dart';


void main() {
  final WeatherRepository weatherRepository = WeatherRepository(
    weatherApiClient: WeatherApiClient(
      httpClient: http.Client(),
    ),
  );
  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(
          create: (context) => ThemeBloc(),
        ),
        BlocProvider<SettingsBloc>(
          create: (context) => SettingsBloc(),
        ),
      ],
      child: App(weatherRepository: weatherRepository),
    ),
  );
}

class App extends StatelessWidget {
  final WeatherRepository weatherRepository;

  App({Key key, @required this.weatherRepository})
      : assert(weatherRepository != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return MaterialApp(
          title: 'MBKZ Weather',
          theme: themeState.theme,
          home: BlocProvider(
            create: (context) => WeatherBloc(
              weatherRepository: weatherRepository,
            ),
            child: Weather(),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kiv_mbkz_weather_app/blocs/settings/settings_bloc.dart';
import 'package:kiv_mbkz_weather_app/blocs/weather/weather_bloc.dart';
import 'package:kiv_mbkz_weather_app/blocs/weather_history/weather_history_bloc.dart';
import 'package:kiv_mbkz_weather_app/repositories/preferences/preferences_client.dart';
import 'package:kiv_mbkz_weather_app/repositories/preferences/preferences_repository.dart';
import 'package:kiv_mbkz_weather_app/repositories/weather/repositories.dart';
import 'package:kiv_mbkz_weather_app/repositories/weather/weather_repository.dart';
import 'package:kiv_mbkz_weather_app/simple_bloc_delegate.dart';
import 'package:kiv_mbkz_weather_app/pages/initial_page.dart';

void main() async {
  final WeatherRepository weatherRepository = WeatherRepository(
    weatherApiClient: WeatherApiClient(
      httpClient: http.Client(),
    ),
  );
  final PersistentStorageRepository persistentStorageRepository = PersistentStorageRepository(PreferencesClient());

  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<SettingsBloc>(
          create: (context) => SettingsBloc(persistentStorageRepository),
        ),
      ],
      child: App(
        weatherRepository: weatherRepository,
        persistentStorageRepository: persistentStorageRepository,
      ),
    ),
  );
}

class App extends StatefulWidget {
  final WeatherRepository weatherRepository;
  final PersistentStorageRepository persistentStorageRepository;

  App({Key key, @required this.weatherRepository, @required this.persistentStorageRepository})
      : assert(weatherRepository != null),
        assert(persistentStorageRepository != null),
        super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MBKZ Weather',
      home: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => WeatherBloc(
              weatherRepository: widget.weatherRepository,
            ),
          ),
          BlocProvider(
            create: (context) => WeatherHistoryBloc(
                persistentStorageRepository: widget.persistentStorageRepository,
                weatherRepository: widget.weatherRepository),
          ),
        ],
        child: InitialPage(),
      ),
    );
  }
}

import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kiv_mbkz_weather_app/blocs/settings/bloc.dart';
import 'package:kiv_mbkz_weather_app/blocs/weather/bloc.dart';
import 'package:kiv_mbkz_weather_app/blocs/weather_history/bloc.dart';
import 'package:kiv_mbkz_weather_app/models/city.dart';
import 'package:kiv_mbkz_weather_app/pages/weather_page.dart';
import 'package:kiv_mbkz_weather_app/widgets/animated/animated_background.dart';
import 'package:kiv_mbkz_weather_app/widgets/animated/animated_wave.dart';
import 'package:kiv_mbkz_weather_app/widgets/bottom_positioned.dart';
import 'package:kiv_mbkz_weather_app/widgets/menu.dart';
import 'package:kiv_mbkz_weather_app/widgets/widgets.dart';

class InitialPage extends StatefulWidget {
  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> with TickerProviderStateMixin {
  bool initLoad = true;

  @override
  void initState() {
    BlocProvider.of<SettingsBloc>(context).add(LoadTemperatureUnits());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocConsumer<WeatherBloc, WeatherState>(
          listener: (context, state) async {
            if (state is WeatherLoaded) {
              // add loaded city to app persistent storage
              BlocProvider.of<WeatherHistoryBloc>(context)
                  .add(AddRecentlySearchedCity(city: City(state.weather[0].location, state.weather[0].locationId)));

              // display weather page
              await Navigator.of(context).push(MaterialPageRoute(builder: (context) => WeatherPage(state.weather)));

              // reset weather, removes loading screen
              BlocProvider.of<WeatherBloc>(context).add(ResetWeather());
            } else if (state is WeatherError) {
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text("An error has happened while fetching weather data"),
              ));
            }
            initLoad = false;
          },
          builder: (context, state) {
            return Stack(children: [
              Positioned.fill(child: MenuScreen(initLoad: initLoad)),
              if (state is WeatherLoading || state is WeatherLoaded)
                Stack(children: [
                  Positioned.fill(child: AnimatedBackground(color1: Colors.green)),
                  Center(
                      child: SpinKitRotatingCircle(
                    color: Colors.white,
                    size: 50.0,
                  )),
                  BottomPositionedFill(
                      child: AnimatedWave(
                    height: 180,
                    speed: 1.0,
                  )),
                  BottomPositionedFill(
                      child: AnimatedWave(
                    height: 120,
                    speed: 0.9,
                    offset: pi,
                  )),
                  BottomPositionedFill(
                      child: AnimatedWave(
                    height: 220,
                    speed: 1.2,
                    offset: pi / 2,
                  ))
                ])
            ]);
          },
        ),
      ),
    );
  }

  Future onCitySelected(BuildContext context) async {
    final city = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CitySelection(),
      ),
    );
    if (city != null) {
      BlocProvider.of<WeatherBloc>(context).add(FetchWeather(city: city));
    }
  }

  onBottom(Widget child) => BottomPositionedFill(
        child: child,
      );
}

class SettingsDialog extends StatelessWidget {
  final WeatherHistoryBloc _weatherHistoryBloc;

  const SettingsDialog(
    this._weatherHistoryBloc, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
        title: Row(
          children: [
            Expanded(child: Text("Settings")),
            IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.of(context).pop())
          ],
        ),
        content: Padding(
          padding: EdgeInsets.symmetric(horizontal: 7),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BlocBuilder<SettingsBloc, SettingsState>(
                  builder: (context, state) {
                    return Column(children: [
                      ListTile(
                        title: Text(
                          'Temperature Units',
                        ),
                        isThreeLine: true,
                        subtitle: Text('Use metric measurements for temperature units.'),
                        trailing: Switch(
                          value: state.temperatureUnits == TemperatureUnits.celsius,
                          onChanged: (_) => BlocProvider.of<SettingsBloc>(context).add(TemperatureUnitsToggled()),
                        ),
                      ),
                      ListTile(
                          onTap: () => _weatherHistoryBloc.add(ClearRecentlySearchedCities()),
                          title: Text(
                            'Reset recently searched cities',
                          ),
                          isThreeLine: true,
                          subtitle: Text('Clears the history of recently searched cities'))
                    ]);
                  },
                )
              ],
            ),
          ),
        ));
  }
}

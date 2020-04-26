import 'dart:math';

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
import 'package:kiv_mbkz_weather_app/widgets/menu.dart';
import 'package:kiv_mbkz_weather_app/widgets/utils/bottom_positioned.dart';

class InitialPage extends StatefulWidget {
  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> with TickerProviderStateMixin {
  bool initLoad = true;

  @override
  void initState() {
    BlocProvider.of<SettingsBloc>(context).add(LoadUnits());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocConsumer<WeatherBloc, WeatherState>(
          listener: (context, state) async {
            if (state is WeatherLoaded) {
              // display weather page
              await Navigator.of(context).push(MaterialPageRoute(builder: (context) => WeatherPage(state.weather)));

              // reset weather, removes loading screen
              BlocProvider.of<WeatherBloc>(context).add(ResetWeather());

              // add loaded city to app persistent storage
              BlocProvider.of<WeatherHistoryBloc>(context)
                  .add(AddRecentlySearchedCity(city: City(state.weather[0].location, state.weather[0].locationId)));
            } else if (state is WeatherError) {
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text(state.text),
              ));
            }
            initLoad = false;
          },
          builder: (context, state) {
            return Stack(children: [
              Positioned.fill(child: MainMenu(initLoad: initLoad)),
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

  onBottom(Widget child) => BottomPositionedFill(
        child: child,
      );
}

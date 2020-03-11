import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kiv_mbkz_weather_app/blocs/weather_background_bloc.dart';
import 'package:kiv_mbkz_weather_app/models/models.dart';
import 'package:kiv_mbkz_weather_app/widgets/animated_background.dart';
import 'package:kiv_mbkz_weather_app/widgets/animated_wave.dart';
import 'package:kiv_mbkz_weather_app/widgets/painters/snow_painter.dart';
import 'package:kiv_mbkz_weather_app/widgets/particles/rain.dart';
import 'package:kiv_mbkz_weather_app/widgets/particles/snow.dart';

import 'package:kiv_mbkz_weather_app/widgets/widgets.dart';
import 'package:kiv_mbkz_weather_app/blocs/blocs.dart';
import 'package:simple_animations/simple_animations.dart';

class Weather extends StatefulWidget {
  @override
  State<Weather> createState() => _WeatherState();
}

class _WeatherState extends State<Weather> with TickerProviderStateMixin {
  Completer<void> _refreshCompleter;
  TabController _controller;

  Color _color;

  int _previous;

  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer<void>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MBKZ Weather'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Settings(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final city = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CitySelection(),
                ),
              );
              if (city != null) {
                BlocProvider.of<WeatherBloc>(context).add(FetchWeather(city: city));
              }
            },
          )
        ],
      ),
      body: Center(
        child: BlocConsumer<WeatherBloc, WeatherState>(
          listener: (context, state) {
            if (state is WeatherLoaded) {
              BlocProvider.of<ThemeBloc>(context).add(
                WeatherChanged(condition: state.weather[0].condition),
              );
              _refreshCompleter?.complete();
              _refreshCompleter = Completer();
            }
          },
          builder: (context, state) {
            if (state is WeatherLoading) {
              return Center(child: CircularProgressIndicator());
            }
            if (state is WeatherLoaded) {
              final weather = state.weather;

              return BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, themeState) {
                  _controller = TabController(vsync: this, length: weather.length);
                  _color = ThemeBloc.mapWeatherConditionToThemeData(weather[0].condition).color[700];
                  _previous = 0;
                  return BlocProvider<WeatherBackgroundBloc>(
                    create: (_) {
                      final bloc = WeatherBackgroundBloc(weathers: weather);
                      _controller.addListener(() {
                        bloc.add(WeatherBackgroundChanged(tabIndex: _controller.index));
                      });
                      return bloc;
                    },
                    child: BlocBuilder<WeatherBackgroundBloc, WeatherBackgroundState>(
                      builder: (context, state) {
                        print("visible ${state.visible}");
                        return Stack(
                          children: [
                            Positioned.fill(
                              child: Container(
                                color: Colors.black,
                                child: AnimatedOpacity(
                                  duration: Duration(milliseconds: 500),
                                  opacity: state.visible ? 1.0 : 0.0,
                                  child: AnimatedBackground(
                                    color1: state.color,
                                    child: state.condition == WeatherCondition.snow ?  Snow(70) : ((state.condition ==  WeatherCondition.lightRain || state.condition == WeatherCondition.heavyRain) ? Rain(150) : Text("lol")),
                                  ),
                                ),
                              ),
                            ),


                            Positioned.fill(
                                child: TabBarView(
                              controller: _controller,
                              children: [
                                for (var w in weather)
                                  RefreshIndicator(
                                    onRefresh: () {
                                      BlocProvider.of<WeatherBloc>(context).add(
                                        RefreshWeather(city: w.location),
                                      );
                                      return _refreshCompleter.future;
                                    },
                                    child: ListView(
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.only(top: 100.0),
                                          child: Center(
                                            child: Location(location: w.location),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Center(
                                            child: LastUpdated(dateTime: w.applicableDate),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(vertical: 50.0),
                                          child: Center(
                                            child: CombinedWeatherTemperature(
                                              weather: w,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                              ],
                            )),
                            onBottom(AnimatedWave(
                              height: 180,
                              speed: 1.0,
                            )),
                            onBottom(AnimatedWave(
                              height: 120,
                              speed: 0.9,
                              offset: pi,
                            )),
                            onBottom(AnimatedWave(
                              height: 220,
                              speed: 1.2,
                              offset: pi / 2,
                            )),
                          ],
                        );
                      },
                    ),
                  );
                },
              );
            }
            if (state is WeatherError) {
              return Text(
                'Something went wrong!',
                style: TextStyle(color: Colors.red),
              );
            }
            return Center(child: Text('Please Select a Location'));
          },
        ),
      ),
    );
  }

  onBottom(Widget child) => Positioned.fill(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: child,
        ),
      );

}

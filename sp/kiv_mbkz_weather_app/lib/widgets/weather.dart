import 'dart:async';
import 'dart:math';

import 'package:drawing_animation/drawing_animation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kiv_mbkz_weather_app/blocs/weather_background_bloc.dart';
import 'package:kiv_mbkz_weather_app/models/models.dart';
import 'package:kiv_mbkz_weather_app/widgets/animated_background.dart';
import 'package:kiv_mbkz_weather_app/widgets/animated_sun.dart';
import 'package:kiv_mbkz_weather_app/widgets/animated_wave.dart';
import 'package:kiv_mbkz_weather_app/widgets/painters/snow_painter.dart';
import 'package:kiv_mbkz_weather_app/widgets/particles/clouds.dart';
import 'package:kiv_mbkz_weather_app/widgets/particles/rain.dart';
import 'package:kiv_mbkz_weather_app/widgets/particles/snow.dart';

import 'package:kiv_mbkz_weather_app/widgets/widgets.dart';
import 'package:kiv_mbkz_weather_app/blocs/blocs.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Weather extends StatefulWidget {
  @override
  State<Weather> createState() => _WeatherState();
}

class _WeatherState extends State<Weather> with TickerProviderStateMixin {
  Completer<void> _refreshCompleter;
  PageController _controller;

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
            onPressed: () => onCitySelected(context),
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
                  _controller = PageController();
                  _color = ThemeBloc.mapWeatherConditionToThemeData(weather[0].condition).color[700];
                  _previous = 0;
                  return BlocProvider<WeatherBackgroundBloc>(
                    create: (_) {
                      final bloc = WeatherBackgroundBloc(weathers: weather);
                      _controller.addListener(() {
                        bloc.add(WeatherBackgroundChanged(tabIndex: _controller.page.round()));
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
                                color: Colors.transparent,
                                child: AnimatedOpacity(
                                  duration: Duration(milliseconds: 500),
                                  opacity: state.visible ? 1.0 : 0.0,
                                  child: AnimatedBackground(
                                    color1: state.color,
                                    child: Builder(
                                      // ignore: missing_return
                                      builder: (context) {
                                        switch (state.condition) {
                                          case WeatherCondition.snow:
                                            return Stack(children: [
                                              Positioned.fill(child: Snow(70)),
                                              Positioned.fill(child: Clouds(7))
                                            ]);
                                            break;
                                          case WeatherCondition.heavyRain:
                                            return Stack(children: [
                                              Positioned.fill(child: Rain(150)),
                                              Positioned.fill(child: Clouds(20))
                                            ]);
                                            break;
                                          case WeatherCondition.lightRain:
                                            return Stack(children: [
                                              Positioned.fill(child: Rain(100)),
                                              Positioned.fill(child: Clouds(10))
                                            ]);
                                            break;
                                          case WeatherCondition.hail:
                                            return Rain(50);
                                            break;
                                          case WeatherCondition.showers:
                                            return Stack(children: [
                                              Positioned.fill(child: Rain(180)),
                                              Positioned.fill(child: Clouds(30))
                                            ]);
                                          case WeatherCondition.heavyCloud:
                                            return Clouds(10);
                                          case WeatherCondition.lightCloud:
                                            return Clouds(5);
                                            break;

                                          case WeatherCondition.clear:
                                            return AnimatedSun();
                                            break;
                                          case WeatherCondition.thunderstorm:
                                            return Stack(children: [
                                              Positioned.fill(child: Rain(175)),
                                              Positioned.fill(child: Clouds(18, thunder: true))
                                            ]);
                                            break;
                                          default:
                                            return Text("none");
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned.fill(
                                child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(top: 100.0),
                                  child: Center(
                                    child: Location(location: weather[0].location),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: PageView(
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
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 40.0),
                                  child: SmoothPageIndicator(
                                    controller: _controller, // PageController
                                    count: 6,
                                    effect: WormEffect(activeDotColor: Colors.white), // your preferred effect
                                  ),
                                ),
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

  onBottom(Widget child) => Positioned.fill(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: child,
        ),
      );
}

import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kiv_mbkz_weather_app/blocs/weather_background_bloc.dart';
import 'package:kiv_mbkz_weather_app/blocs/weather_bloc.dart';
import 'package:kiv_mbkz_weather_app/models/weather.dart';
import 'package:kiv_mbkz_weather_app/widgets/animated/animated_background.dart';
import 'package:kiv_mbkz_weather_app/widgets/animated/animated_rain.dart';
import 'package:kiv_mbkz_weather_app/widgets/animated/animated_sun.dart';
import 'package:kiv_mbkz_weather_app/widgets/bottom_positioned.dart';
import 'package:kiv_mbkz_weather_app/widgets/combined_weather_temperature.dart';
import 'package:kiv_mbkz_weather_app/widgets/last_updated.dart';
import 'package:kiv_mbkz_weather_app/widgets/location.dart';
import 'package:kiv_mbkz_weather_app/widgets/particles/clouds.dart';
import 'package:kiv_mbkz_weather_app/widgets/particles/rain.dart';
import 'package:kiv_mbkz_weather_app/widgets/particles/snow.dart';
import 'package:kiv_mbkz_weather_app/widgets/widgets.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class WeatherPage extends StatefulWidget {
  final List<Weather> weatherList;

  WeatherPage(this.weatherList);

  @override
  State<WeatherPage> createState() => WeatherPageState(this.weatherList);
}

class WeatherPageState extends State<WeatherPage> {
  final List<Weather> weatherList;
  PageController _controller = PageController();
  Completer<void> _refreshCompleter = Completer<void>();

  WeatherPageState(this.weatherList);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider<WeatherBackgroundBloc>(
        create: (_) {
          final bloc = WeatherBackgroundBloc(weathers: weatherList);
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
                    color: Colors.black87,
                    child: AnimatedOpacity(
                      duration: Duration(milliseconds: 500),
                      opacity: state.visible ? 1.0 : 0.0,
                      child: AnimatedBackground(
                        color1: state.color,
                        child: Builder(
                          // ignore: missing_return
                          builder: (context) {
                            switch (state.condition) {
                              case WeatherCondition.sleet:
                                return Stack(children: [
                                  Positioned.fill(child: Snow(70)),
                                  Positioned.fill(child: Rain(70)),
                                  Positioned.fill(child: Clouds(7))
                                ]);
                                break;
                              case WeatherCondition.snow:
                                return Stack(
                                    children: [Positioned.fill(child: Snow(70)), Positioned.fill(child: Clouds(7))]);
                                break;
                              case WeatherCondition.heavyRain:
                                return Stack(
                                    children: [Positioned.fill(child: Rain(160)), Positioned.fill(child: Clouds(20))]);
                                break;
                              case WeatherCondition.lightRain:
                                return Stack(
                                    children: [Positioned.fill(child: Rain(100)), Positioned.fill(child: Clouds(10))]);
                                break;
                              case WeatherCondition.hail:
                                return Rain(50);
                                break;
                              case WeatherCondition.showers:
                                return Stack(
                                    children: [Positioned.fill(child: Rain(210)), Positioned.fill(child: Clouds(30))]);
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
                      padding: EdgeInsets.only(top: 150.0),
                      child: Center(
                        child: Location(location: weatherList[0].location),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: PageView(
                        controller: _controller,
                        children: [
                          for (var i = 0; i < weatherList.length; i++)
                            RefreshIndicator(
                              onRefresh: () {
                                BlocProvider.of<WeatherBloc>(context).add(
                                  RefreshWeather(city: weatherList[i].location),
                                );
                                return _refreshCompleter.future;
                              },
                              child: ListView(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Center(
                                      child: LastUpdated(dateTime: weatherList[i].applicableDate, wIndex: i),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 50.0),
                                    child: Center(
                                      child: CombinedWeatherTemperature(
                                        weather: weatherList[i],
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
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40.0),
                      child: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.of(context).pop()),
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
      ),
    );
  }

  onBottom(Widget child) => BottomPositionedFill(
        child: child,
      );
}

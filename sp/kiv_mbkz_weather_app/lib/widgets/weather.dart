import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kiv_mbkz_weather_app/blocs/blocs.dart';
import 'package:kiv_mbkz_weather_app/blocs/weather_background_bloc.dart';
import 'package:kiv_mbkz_weather_app/blocs/weather_history_bloc.dart';
import 'package:kiv_mbkz_weather_app/models/models.dart';
import 'package:kiv_mbkz_weather_app/widgets/animated_background.dart';
import 'package:kiv_mbkz_weather_app/widgets/animated_sun.dart';
import 'package:kiv_mbkz_weather_app/widgets/animated_wave.dart';
import 'package:kiv_mbkz_weather_app/widgets/particles/clouds.dart';
import 'package:kiv_mbkz_weather_app/widgets/particles/rain.dart';
import 'package:kiv_mbkz_weather_app/widgets/particles/snow.dart';
import 'package:kiv_mbkz_weather_app/widgets/widgets.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Weather extends StatefulWidget {
  @override
  State<Weather> createState() => _WeatherState();
}

class _WeatherState extends State<Weather> with TickerProviderStateMixin {
  Completer<void> _refreshCompleter;
  PageController _controller;

  bool initLoad = true;

  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer<void>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocConsumer<WeatherBloc, WeatherState>(
          listener: (context, state) {
            if (state is WeatherLoaded) {
              BlocProvider.of<WeatherHistoryBloc>(context)
                  .add(AddRecentlySearchedCity(cityName: state.weather[0].location));
              BlocProvider.of<ThemeBloc>(context).add(
                WeatherChanged(condition: state.weather[0].condition),
              );
              _refreshCompleter?.complete();
              _refreshCompleter = Completer();
            }
            initLoad = false;
          },
          builder: (context, state) {
            if (state is WeatherLoading) {
              return Stack(children: [
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
              ]);
            }
            if (state is WeatherLoaded) {
              final weather = state.weather;

              return WillPopScope(
                onWillPop: () {
                  BlocProvider.of<WeatherBloc>(context).add(ResetWeather());
                  return Future.value(false);
                },
                child: BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, themeState) {
                    _controller = PageController();

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
                                              return Stack(children: [
                                                Positioned.fill(child: Snow(70)),
                                                Positioned.fill(child: Clouds(7))
                                              ]);
                                              break;
                                            case WeatherCondition.heavyRain:
                                              return Stack(children: [
                                                Positioned.fill(child: Rain(160)),
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
                                                Positioned.fill(child: Rain(210)),
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
                                    padding: EdgeInsets.only(top: 150.0),
                                    child: Center(
                                      child: Location(location: weather[0].location),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: PageView(
                                      controller: _controller,
                                      children: [
                                        for (var i = 0; i < weather.length; i++)
                                          RefreshIndicator(
                                            onRefresh: () {
                                              BlocProvider.of<WeatherBloc>(context).add(
                                                RefreshWeather(city: weather[i].location),
                                              );
                                              return _refreshCompleter.future;
                                            },
                                            child: ListView(
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 8.0),
                                                  child: Center(
                                                    child: LastUpdated(dateTime: weather[i].applicableDate, wIndex: i),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(vertical: 50.0),
                                                  child: Center(
                                                    child: CombinedWeatherTemperature(
                                                      weather: weather[i],
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
                                        onPressed: () => BlocProvider.of<WeatherBloc>(context).add(ResetWeather())),
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
                ),
              );
            }

            if (state is WeatherError) {
              return InitialScreenWidget(
                error: "Unable to find such city by name",
                initLoad: initLoad,
              );
            }
            return InitialScreenWidget(initLoad: initLoad);
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

class InitialScreenWidget extends StatelessWidget {
  final controller = PageController(viewportFraction: 0.8);

  final String error;

  final bool initLoad;

  final _cityNameController = TextEditingController();

  InitialScreenWidget({Key key, this.error, this.initLoad}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(child: AnimatedBackground(color1: Colors.green)),
      FadeIn(
          initLoad ? 3 : 0,
          Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Align(
                  alignment: Alignment.topCenter,
                  child: FadeIn(
                      initLoad ? 5 : 2,
                      FractionallySizedBox(
                          widthFactor: 0.4,
                          child: AspectRatio(aspectRatio: 1, child: Image.asset("assets/flutter.png"))),
                      initLoad)),
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 45.0),
                      child: Text("MBKZ Flutter Weather",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w200,
                            color: Colors.white,
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Stanislav Král",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w200,
                            color: Colors.white,
                          )),
                    ),
                    BlocBuilder(
                      bloc: BlocProvider.of<WeatherHistoryBloc>(context),
                      builder: (BuildContext context, state) {
                        if (state is WeatherHistoryLoaded) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 24.0),
                            child: SizedBox(
                              height: 40,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                children: state.cities.map((name) => _buildCityButton(name, context)).toList(),
                              ),
                            ),
                          );
                        }
                        return Container();
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 50),
                      child: TextField(
                        cursorColor: Colors.white,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
                        controller: _cityNameController,
                        decoration: InputDecoration(
                          hintText: "City name",
                          hintStyle: TextStyle(color: Colors.white60),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(15.0)),
                              borderSide: BorderSide(color: Colors.white60)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(15.0)),
                              borderSide: BorderSide(color: Colors.white60)),
                          filled: true,
                          contentPadding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
                        ),
                      ),
                    ),
                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(error,
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 14,
                              color: Colors.white,
                            )),
                      ),
                    FlatButton(
                      child: Text("SEARCH",
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 16,
                            color: Colors.white,
                          )),
                      onPressed: () =>
                          {BlocProvider.of<WeatherBloc>(context).add(FetchWeather(city: _cityNameController.text))},
                    )
                  ],
                ),
              ),
            ],
          )),
          initLoad),
      Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: IconButton(
                icon: Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () => _openFilterRecordsDialog(context),
              ),
            ),
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
    ]);
  }

  Center _buildCityButton(String cityName, context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(15.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(15.0),
            onTap: () => BlocProvider.of<WeatherBloc>(context).add(FetchWeather(city: cityName)),
            child: Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.white), borderRadius: BorderRadius.circular(15.0)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                    child: Text(cityName,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300, fontSize: 14))),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

_openFilterRecordsDialog(context) async {
  var result = await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
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
                      return ListTile(
                        title: Text(
                          'Temperature Units',
                        ),
                        isThreeLine: true,
                        subtitle: Text('Use metric measurements for temperature units.'),
                        trailing: Switch(
                          value: state.temperatureUnits == TemperatureUnits.celsius,
                          onChanged: (_) => BlocProvider.of<SettingsBloc>(context).add(TemperatureUnitsToggled()),
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          ));
    },
  );
}

class FadeIn extends StatelessWidget {
  final double delay;
  final Widget child;
  final bool enable;

  FadeIn(this.delay, this.child, this.enable);

  @override
  Widget build(BuildContext context) {
    debugPrint("this is enable " + enable.toString());
    if (!enable) {
      return child;
    }
    final tween = MultiTrackTween([
      Track("opacity").add(Duration(milliseconds: 500), Tween(begin: 0.0, end: 1.0)),
      Track("translateX").add(Duration(milliseconds: 500), Tween(begin: 130.0, end: 0.0), curve: Curves.easeOut)
    ]);

    return ControlledAnimation(
      delay: Duration(milliseconds: (300 * delay).round()),
      duration: tween.duration,
      tween: tween,
      child: child,
      builderWithChild: (context, child, animation) => Opacity(
        opacity: animation["opacity"],
        child: Transform.translate(offset: Offset(animation["translateX"], 0), child: child),
      ),
    );
  }
}

class BottomPositionedFill extends StatelessWidget {
  final Widget child;

  const BottomPositionedFill({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: child,
      ),
    );
  }
}

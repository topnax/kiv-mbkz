import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kiv_mbkz_weather_app/blocs/blocs.dart';
import 'package:kiv_mbkz_weather_app/blocs/weather_history_bloc.dart';
import 'package:kiv_mbkz_weather_app/models/city.dart';
import 'package:kiv_mbkz_weather_app/pages/weather_page.dart';
import 'package:kiv_mbkz_weather_app/widgets/animated/animated_background.dart';
import 'package:kiv_mbkz_weather_app/widgets/animated/animated_wave.dart';
import 'package:kiv_mbkz_weather_app/widgets/bottom_positioned.dart';
import 'package:kiv_mbkz_weather_app/widgets/city_button.dart';
import 'package:kiv_mbkz_weather_app/widgets/fade_in.dart';
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

class MenuScreen extends StatefulWidget {
  final String error;

  final bool initLoad;

  MenuScreen({this.error, this.initLoad});

  @override
  State<StatefulWidget> createState() {
    return MenuScreenState(initLoad: this.initLoad);
  }
}

class MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  final controller = PageController(viewportFraction: 0.8);

  final FocusNode _focusNode = FocusNode();

  final bool initLoad;

  final _cityNameController = TextEditingController();

  MenuScreenState({this.initLoad});

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
                          for (var city in state.cities) {
                            debugPrint("got ${city.name}");
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 24.0),
                            child: SizedBox(
                              height: 40,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                children: state.cities.map((city) => _buildCityButton(city, context)).toList(),
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
                        focusNode: _focusNode,
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
                    FlatButton(
                      child: Text("SEARCH",
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 16,
                            color: Colors.white,
                          )),
                      onPressed: () {
                        BlocProvider.of<WeatherBloc>(context).add(FetchWeather(city: _cityNameController.text));
                        FocusScope.of(context).unfocus();
                        _cityNameController.clear();
                      },
                    )
                  ],
                ),
              ),
            ],
          )),
          initLoad),
      _buildSettingsIcon(context),
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

  Widget _buildCityButton(City city, context) {
    debugPrint("bcb method ${city.name}");
    return CityButton(city, key: Key(city.toString()));
  }

  _openSettingsDialog(context) async {
    await showDialog(
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

  _buildSettingsIcon(BuildContext context) {
    return Align(
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
              onPressed: () => _openSettingsDialog(context),
            ),
          ),
        ));
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kiv_mbkz_weather_app/blocs/weather/bloc.dart';
import 'package:kiv_mbkz_weather_app/blocs/weather_history/bloc.dart';
import 'package:kiv_mbkz_weather_app/blocs/weather_history/weather_history_bloc.dart';
import 'package:kiv_mbkz_weather_app/widgets/animated/animated_background.dart';
import 'package:kiv_mbkz_weather_app/widgets/city_button.dart';
import 'package:kiv_mbkz_weather_app/widgets/settings_dialog.dart';
import 'package:kiv_mbkz_weather_app/widgets/utils/bottom_positioned.dart';
import 'package:kiv_mbkz_weather_app/widgets/utils/fade_in.dart';

import 'animated/animated_wave.dart';

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

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  MenuScreenState({this.initLoad});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(child: AnimatedBackground(color1: Colors.green)),
      FadeIn(
          initLoad ? 3 : 0,
          RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: () => _onRefresh(context),
            child: Center(
                child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
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
                  Column(
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
                          debugPrint("building " + state.toString());
                          if (state is WeatherHistoryLoaded && state.cities.isNotEmpty) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 24.0),
                              child: SizedBox(
                                height: 40,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  children:
                                      state.cities.map((city) => CityButton(city, key: Key(city.toString()))).toList(),
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
                ],
              ),
            )),
          ),
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

  _openSettingsDialog(context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dContext) {
        return SettingsDialog(BlocProvider.of<WeatherHistoryBloc>(context));
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

  _onRefresh(context) async {
    BlocProvider.of<WeatherHistoryBloc>(context).add(LoadRecentlySearchedCities());
  }
}

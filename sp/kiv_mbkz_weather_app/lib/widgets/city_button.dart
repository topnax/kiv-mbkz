import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kiv_mbkz_weather_app/blocs/settings_bloc.dart';
import 'package:kiv_mbkz_weather_app/blocs/weather_bloc.dart';
import 'package:kiv_mbkz_weather_app/blocs/weather_history_bloc.dart';
import 'package:kiv_mbkz_weather_app/models/city.dart';
import 'package:kiv_mbkz_weather_app/pages/weather_page.dart';

class CityButton extends StatefulWidget {
  final City _city;
  CityButton(
    this._city, {
    Key key,
  }) : super(key: key) {
    debugPrint("const ${_city.name}");
  }

  @override
  _CityButtonState createState() => _CityButtonState(_city);
}

class _CityButtonState extends State<CityButton> with TickerProviderStateMixin {
  final City _city;

  _CityButtonState(this._city);

  @override
  void didUpdateWidget(CityButton oldWidget) {
    debugPrint("old ${oldWidget._city.name} - ${_city.name}");
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("built: ${_city.name}");
    return BlocProvider(
      create: (context) => WeatherBloc(weatherRepository: BlocProvider.of<WeatherBloc>(context).weatherRepository)
        ..add(FetchWeatherFromLocationId(locationId: widget._city.woeid)),
      child: Center(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(15.0),
          child: BlocBuilder<WeatherBloc, WeatherState>(
            builder: (context, state) => InkWell(
              borderRadius: BorderRadius.circular(15.0),
              onTap: () {
                if (state is WeatherLoaded) {
                  debugPrint("clicked: " + _city.name);
//                  BlocProvider.of<WeatherBloc>(context).add(FetchWeatherFromLocationId(locationId: city.woeid));
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => WeatherPage(state.weather)));
                  FocusScope.of(context).unfocus();
                }
              },
              onLongPress: () =>
                  BlocProvider.of<WeatherHistoryBloc>(context).add(ClearRecentlySearchedCity(widget._city)),
              child: Container(
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.white), borderRadius: BorderRadius.circular(15.0)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: <Widget>[
                      Center(
                          child: Text(widget._city.name,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300, fontSize: 14))),
                      Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Builder(
                            builder: (context) => AnimatedSize(
                              curve: Curves.easeInOut,
                              vsync: this,
                              duration: Duration(milliseconds: 500),
                              child: state is WeatherLoaded
                                  ? Text(
                                      state.weather[0].temp.toStringAsFixed(0) + "°C",
                                      style: TextStyle().copyWith(color: Colors.white),
                                    )
                                  : SpinKitPulse(
                                      color: Colors.white,
                                      size: 14,
                                    ),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      )),
    );
  }
}

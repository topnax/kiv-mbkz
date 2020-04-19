import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kiv_mbkz_weather_app/blocs/settings/bloc.dart';
import 'package:kiv_mbkz_weather_app/blocs/weather_history/bloc.dart';
import 'package:url_launcher/url_launcher.dart';

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
                          'Use Metric Units',
                        ),
                        isThreeLine: true,
                        subtitle: Text('Use metric units throughout the application.'),
                        trailing: Switch(
                          value: state.temperatureUnits == Units.metric,
                          onChanged: (_) => BlocProvider.of<SettingsBloc>(context).add(UnitsToggled()),
                        ),
                      ),
                      ListTile(
                          onTap: () => _weatherHistoryBloc.add(ClearRecentlySearchedCities()),
                          title: Text(
                            'Reset recently searched cities',
                          ),
                          isThreeLine: true,
                          subtitle: Text('Clears the history of recently searched cities')),
                      Center(
                          child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(children: [
                          TextSpan(
                              text: "Free weather data supplied by ",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 11,
                                fontWeight: FontWeight.w300,
                              )),
                          TextSpan(
                              recognizer: TapGestureRecognizer()..onTap = () => launch("https://www.metaweather.com/"),
                              text: "https://www.metaweather.com/",
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 11,
                                fontWeight: FontWeight.w300,
                              )),
                        ]),
                      )),
                      Center(
                          child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Icon(
                          Icons.favorite,
                          color: Colors.redAccent,
                        ),
                      )),
                    ]);
                  },
                )
              ],
            ),
          ),
        ));
  }
}

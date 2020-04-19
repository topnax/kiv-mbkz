import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kiv_mbkz_weather_app/blocs/settings/bloc.dart';
import 'package:kiv_mbkz_weather_app/blocs/weather_history/bloc.dart';

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

import 'package:kiv_mbkz_weather_app/blocs/settings/settings_bloc.dart';
import 'package:kiv_mbkz_weather_app/models/city.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class PersistentStorage {
  Future<List<City>> getRecentlySearchedCities();

  putRecentlySearchedCities(List<City> names);

  clearRecentlySearchedCitiesNames();

  putUnitsPreference(Units units);

  Future<Units> getUnitsPreference();
}

class PreferencesClient implements PersistentStorage {
  static const RECENTLY_SEARCHED_CITIES_KEY = "RECENTLY_SEARCHED_CITIES_KEY";
  static const UNITS_PREFERENCE_KEY = "UNITS_PREFERENCE_KEY";

  Future<List<City>> getRecentlySearchedCities() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var storedCities = prefs.getStringList(RECENTLY_SEARCHED_CITIES_KEY) ?? List<String>();

    var list = storedCities
        .map((s) => s.split(City.FIELD_SEPARATOR))
        .where((parts) => parts.length == 2 && (int.tryParse(parts[1]) ?? -1) != -1)
        .map((parts) => City(parts[0], int.parse(parts[1])))
        .toList();

    return Future.value(list);
  }

  putRecentlySearchedCities(List<City> cities) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var list = cities.map((city) => [city.name, city.woeid.toString()].join(City.FIELD_SEPARATOR)).toList();
    prefs.setStringList(RECENTLY_SEARCHED_CITIES_KEY, list);
  }

  clearRecentlySearchedCitiesNames() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(RECENTLY_SEARCHED_CITIES_KEY, List<String>());
  }

  @override
  Future<Units> getUnitsPreference() async {
    var prefs = await SharedPreferences.getInstance();

    var unitsString = prefs.getString(UNITS_PREFERENCE_KEY);

    return unitsString == Units.imperial.toString() ? Units.imperial : Units.metric;
  }

  @override
  putUnitsPreference(Units units) async {
    var prefs = await SharedPreferences.getInstance();

    prefs.setString(UNITS_PREFERENCE_KEY, units.toString());
  }
}

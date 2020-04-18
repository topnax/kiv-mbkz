import 'package:kiv_mbkz_weather_app/blocs/blocs.dart';
import 'package:kiv_mbkz_weather_app/models/city.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class PersistentStorage {
  Future<List<City>> getRecentlySearchedCities();

  putRecentlySearchedCities(List<City> names);

  clearRecentlySearchedCitiesNames();

  putTemperatureUnitPreference(TemperatureUnits units);

  Future<TemperatureUnits> getTemperatureUnitPreference();
}

class PreferencesClient implements PersistentStorage {
  static const RECENTLY_SEARCHED_CITIES_KEY = "RECENTLY_SEARCHED_CITIES_KEY";
  static const TEMPERATURE_UNIT_KEY = "TEMPERATURE_UNIT_KEY";

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
  Future<TemperatureUnits> getTemperatureUnitPreference() async {
    var prefs = await SharedPreferences.getInstance();

    var temperatureUnitString = prefs.getString(TEMPERATURE_UNIT_KEY);

    return temperatureUnitString == TemperatureUnits.celsius.toString()
        ? TemperatureUnits.celsius
        : TemperatureUnits.fahrenheit;
  }

  @override
  putTemperatureUnitPreference(TemperatureUnits units) async {
    var prefs = await SharedPreferences.getInstance();

    prefs.setString(TEMPERATURE_UNIT_KEY, units.toString());
  }
}

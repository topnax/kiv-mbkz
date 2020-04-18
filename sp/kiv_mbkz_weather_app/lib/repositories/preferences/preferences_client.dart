import 'package:kiv_mbkz_weather_app/models/city.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class PersistentStorage {
  Future<List<City>> getRecentlySearchedCities();

  putRecentlySearchedCities(List<City> names);

  clearRecentlySearchedCitiesNames();
}

class PreferencesClient implements PersistentStorage {
  static const RECENTLY_SEARCHED_CITIES_KEY = "RECENTLY_SEARCHED_CITIES_KEY";

  Future<List<City>> getRecentlySearchedCities() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var storedCities = prefs.getStringList(RECENTLY_SEARCHED_CITIES_KEY) ?? List<String>();

    var list = storedCities
        .map((s) => s.split(City.SEPEARATOR))
        .where((parts) => parts.length == 2 && (int.tryParse(parts[1]) ?? -1) != -1)
        .map((parts) => City(parts[0], int.parse(parts[1])))
        .toList();

    return Future.value(list);
  }

  putRecentlySearchedCities(List<City> cities) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var list = cities.map((city) => [city.name, city.woeid.toString()].join(City.SEPEARATOR)).toList();
    prefs.setStringList(RECENTLY_SEARCHED_CITIES_KEY, list);
  }

  clearRecentlySearchedCitiesNames() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(RECENTLY_SEARCHED_CITIES_KEY, List<String>());
  }
}

import 'package:shared_preferences/shared_preferences.dart';

abstract class PersistentStorage {
  Future<List<String>> getRecentlySearchedCitiesNames();

  putRecentlySearchedCitiesNames(List<String> names);

  clearRecentlySearchedCitiesNames();
}

class PreferencesClient implements PersistentStorage {
  static const RECENTLY_SEARCHED_CITIES_KEY = "RECENTLY_SEARCHED_CITIES_KEY";

  Future<List<String>> getRecentlySearchedCitiesNames() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = prefs.getStringList(RECENTLY_SEARCHED_CITIES_KEY) ?? List<String>();
    return Future.value(result);
  }

  putRecentlySearchedCitiesNames(List<String> names) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(RECENTLY_SEARCHED_CITIES_KEY, names);
  }

  clearRecentlySearchedCitiesNames() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(RECENTLY_SEARCHED_CITIES_KEY, List<String>());
  }
}

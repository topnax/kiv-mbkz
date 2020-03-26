import 'package:kiv_mbkz_weather_app/repositories/preferences/preferences_client.dart';

class PersistentStorageRepository {
  static const MAX_RECENTLY_SEARCHED_CITIES_COUNT = 6;

  final PersistentStorage storage;

  PersistentStorageRepository(this.storage);

  Future<List<String>> getRecentlySearchedCitiesNames() async {
    return storage.getRecentlySearchedCitiesNames();
  }

  addRecentlySearchedCity(String city) async {
    var cities = await storage.getRecentlySearchedCitiesNames();
    cities.removeWhere((n) => n == city);
    cities.insert(0, city);
    if (cities.length > MAX_RECENTLY_SEARCHED_CITIES_COUNT) {
      cities = cities.sublist(0, MAX_RECENTLY_SEARCHED_CITIES_COUNT);
    }
    storage.putRecentlySearchedCitiesNames(cities);
  }

  clearCityHistory() async {
    await storage.clearRecentlySearchedCitiesNames();
  }
}

import 'package:kiv_mbkz_weather_app/blocs/settings/settings_bloc.dart';
import 'package:kiv_mbkz_weather_app/models/city.dart';
import 'package:kiv_mbkz_weather_app/repositories/preferences/preferences_client.dart';

class PersistentStorageRepository {
  static const MAX_RECENTLY_SEARCHED_CITIES_COUNT = 5;

  final PersistentStorage storage;

  PersistentStorageRepository(this.storage);

  Future<List<City>> getRecentlySearchedCitiesNames() async {
    return storage.getRecentlySearchedCities();
  }

  addRecentlySearchedCity(City city) async {
    var cities = await storage.getRecentlySearchedCities();
    cities.removeWhere((n) => n == city);
    cities.insert(0, city);
    // total count of stored cities is limited
    if (cities.length > MAX_RECENTLY_SEARCHED_CITIES_COUNT) {
      cities = cities.sublist(0, MAX_RECENTLY_SEARCHED_CITIES_COUNT);
    }
    storage.putRecentlySearchedCities(cities);
  }

  clearCityHistory() async {
    await storage.clearRecentlySearchedCitiesNames();
  }

  Future<List<City>> removeCityFromHistory(City city) async {
    var cities = await storage.getRecentlySearchedCities();
    cities.remove(city);
    storage.putRecentlySearchedCities(cities);
    return Future.value(cities);
  }

  setUnitsPreference(Units units) {
    storage.putUnitsPreference(units);
  }

  Future<Units> getUnitsPreference() async {
    return storage.getUnitsPreference();
  }
}

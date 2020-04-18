import 'package:kiv_mbkz_weather_app/blocs/blocs.dart';
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

  setTemperatureUnitsPreference(TemperatureUnits units) {
    storage.putTemperatureUnitPreference(units);
  }

  Future<TemperatureUnits> getTemperatureUnitsPreference() async {
    return storage.getTemperatureUnitPreference();
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_garden/models/weather_info.dart';
import 'package:meteo_garden/models/weather_provider.dart';

void main() {
  group('WeatherProvider', () {
    late WeatherInfo fakeWeather;

    setUp(() {
      fakeWeather = WeatherInfo(
        stationName: 'Barcelona',
        temp: 22.5,
        precipitation: '0',
        wind: 12.3,
        solarIrradiance: 450.0,
        relativeHumidity: 65.0,
      );
    });

    test('estat inicial correcte', () {
      final provider = WeatherProvider();

      expect(provider.currentWeather, isNull);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });

    test('fetchWeather carrega el temps correctament', () async {
      final provider = WeatherProvider(
        fetchWeatherFunction: ({required String city}) async {
          expect(city, 'Barcelona');
          return fakeWeather;
        },
      );

      await provider.fetchWeather('Barcelona');

      expect(provider.currentWeather, fakeWeather);
      expect(provider.currentWeather?.stationName, 'Barcelona');
      expect(provider.currentWeather?.temp, 22.5);
      expect(provider.currentWeather?.precipitation, '0');
      expect(provider.currentWeather?.wind, 12.3);
      expect(provider.currentWeather?.solarIrradiance, 450.0);
      expect(provider.currentWeather?.relativeHumidity, 65.0);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });

    test('fetchWeather activa isLoading mentre carrega', () async {
      final provider = WeatherProvider(
        fetchWeatherFunction: ({required String city}) async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          return fakeWeather;
        },
      );

      final loadingStates = <bool>[];

      provider.addListener(() {
        loadingStates.add(provider.isLoading);
      });

      await provider.fetchWeather('Barcelona');

      expect(loadingStates, contains(true));
      expect(loadingStates.last, isFalse);
      expect(provider.isLoading, isFalse);
    });

    test('fetchWeather guarda error si el servei falla', () async {
      final provider = WeatherProvider(
        fetchWeatherFunction: ({required String city}) async {
          throw Exception('Error API');
        },
      );

      await provider.fetchWeather('Barcelona');

      expect(provider.currentWeather, isNull);
      expect(provider.isLoading, isFalse);
      expect(provider.error, contains('Error API'));
    });

    test('fetchWeather neteja error anterior quan torna a carregar correctament', () async {
      var shouldFail = true;

      final provider = WeatherProvider(
        fetchWeatherFunction: ({required String city}) async {
          if (shouldFail) {
            throw Exception('Error inicial');
          }

          return fakeWeather;
        },
      );

      await provider.fetchWeather('Barcelona');

      expect(provider.error, contains('Error inicial'));
      expect(provider.currentWeather, isNull);

      shouldFail = false;

      await provider.fetchWeather('Barcelona', forceRefresh: true);

      expect(provider.error, isNull);
      expect(provider.currentWeather, fakeWeather);
      expect(provider.isLoading, isFalse);
    });

    test('si ja té dades i forceRefresh és false, no torna a cridar el servei', () async {
      var callCount = 0;

      final provider = WeatherProvider(
        fetchWeatherFunction: ({required String city}) async {
          callCount++;
          return fakeWeather;
        },
      );

      await provider.fetchWeather('Barcelona');
      await provider.fetchWeather('Barcelona');

      expect(callCount, 1);
      expect(provider.currentWeather, fakeWeather);
    });

    test('si forceRefresh és true, torna a cridar el servei encara que ja tingui dades', () async {
      var callCount = 0;

      final provider = WeatherProvider(
        fetchWeatherFunction: ({required String city}) async {
          callCount++;
          return fakeWeather;
        },
      );

      await provider.fetchWeather('Barcelona');
      await provider.fetchWeather('Barcelona', forceRefresh: true);

      expect(callCount, 2);
      expect(provider.currentWeather, fakeWeather);
    });

    test('notifica els listeners quan comença i acaba la càrrega', () async {
      final provider = WeatherProvider(
        fetchWeatherFunction: ({required String city}) async {
          return fakeWeather;
        },
      );

      var notifyCount = 0;

      provider.addListener(() {
        notifyCount++;
      });

      await provider.fetchWeather('Barcelona');

      expect(notifyCount, 2);
    });

    test('no notifica listeners si ja té dades i no força refresh', () async {
      final provider = WeatherProvider(
        fetchWeatherFunction: ({required String city}) async {
          return fakeWeather;
        },
      );

      await provider.fetchWeather('Barcelona');

      var notifyCount = 0;

      provider.addListener(() {
        notifyCount++;
      });

      await provider.fetchWeather('Barcelona');

      expect(notifyCount, 0);
    });
  });
}
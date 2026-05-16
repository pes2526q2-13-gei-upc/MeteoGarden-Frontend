import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_garden/models/weather_info.dart';

void main() {
  group('WeatherInfo', () {
    test('constructor assigna correctament tots els camps', () {
      final weather = WeatherInfo(
        stationName: 'Barcelona',
        temp: 22.5,
        precipitation: '0',
        wind: 12.3,
        solarIrradiance: 450.0,
        relativeHumidity: 65.0,
      );

      expect(weather.stationName, 'Barcelona');
      expect(weather.temp, 22.5);
      expect(weather.precipitation, '0');
      expect(weather.wind, 12.3);
      expect(weather.solarIrradiance, 450.0);
      expect(weather.relativeHumidity, 65.0);
    });

    test('fromJson converteix correctament valors vàlids', () {
      final weather = WeatherInfo.fromJson({
        'stationName': 'Vic',
        'temperature': '18.7',
        'precipitation': '2.4',
        'wind': '8.5',
        'solarIrradiance': '300.2',
        'relativeHumidity': '70.5',
      });

      expect(weather.stationName, 'Vic');
      expect(weather.temp, 18.7);
      expect(weather.precipitation, '2.4');
      expect(weather.wind, 8.5);
      expect(weather.solarIrradiance, 300.2);
      expect(weather.relativeHumidity, 70.5);
    });

    test('fromJson accepta valors numèrics directes', () {
      final weather = WeatherInfo.fromJson({
        'stationName': 'Girona',
        'temperature': 21.3,
        'precipitation': 0,
        'wind': 10,
        'solarIrradiance': 500,
        'relativeHumidity': 55,
      });

      expect(weather.stationName, 'Girona');
      expect(weather.temp, 21.3);
      expect(weather.precipitation, '0');
      expect(weather.wind, 10.0);
      expect(weather.solarIrradiance, 500.0);
      expect(weather.relativeHumidity, 55.0);
    });

    test('fromJson posa valors per defecte si falten camps', () {
      final weather = WeatherInfo.fromJson({});

      expect(weather.stationName, '');
      expect(weather.temp, 0.0);
      expect(weather.precipitation, '0');
      expect(weather.wind, 0.0);
      expect(weather.solarIrradiance, 0.0);
      expect(weather.relativeHumidity, 0.0);
    });

    test('fromJson posa 0.0 quan els doubles no es poden parsejar', () {
      final weather = WeatherInfo.fromJson({
        'stationName': 'Tarragona',
        'temperature': 'abc',
        'precipitation': 'rain',
        'wind': 'invalid',
        'solarIrradiance': 'invalid',
        'relativeHumidity': 'invalid',
      });

      expect(weather.stationName, 'Tarragona');
      expect(weather.temp, 0.0);
      expect(weather.precipitation, 'rain');
      expect(weather.wind, 0.0);
      expect(weather.solarIrradiance, 0.0);
      expect(weather.relativeHumidity, 0.0);
    });

    test('fromJson gestiona valors null correctament', () {
      final weather = WeatherInfo.fromJson({
        'stationName': null,
        'temperature': null,
        'precipitation': null,
        'wind': null,
        'solarIrradiance': null,
        'relativeHumidity': null,
      });

      expect(weather.stationName, '');
      expect(weather.temp, 0.0);
      expect(weather.precipitation, '0');
      expect(weather.wind, 0.0);
      expect(weather.solarIrradiance, 0.0);
      expect(weather.relativeHumidity, 0.0);
    });
  });
}

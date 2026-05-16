import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:meteo_garden/services/weather_service.dart';

void main() {
  group('WeatherService', () {
    test('fetchCurrent retorna WeatherInfo si la resposta és 200', () async {
      final service = WeatherService(
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, contains('/api/weather/current/'));
          expect(request.url.queryParameters['stationName'], 'Barcelona');

          return http.Response(
            jsonEncode({
              'stationName': 'Barcelona',
              'temperature': 22.5,
              'precipitation': '0',
              'wind': 12.3,
              'solarIrradiance': 450.0,
              'relativeHumidity': 65.0,
            }),
            200,
          );
        }),
      );

      final weather = await service.fetchCurrent(city: 'Barcelona');

      expect(weather.stationName, 'Barcelona');
      expect(weather.temp, 22.5);
      expect(weather.precipitation, '0');
      expect(weather.wind, 12.3);
      expect(weather.solarIrradiance, 450.0);
      expect(weather.relativeHumidity, 65.0);
    });

    test('fetchCurrent codifica correctament una ciutat amb espais', () async {
      final service = WeatherService(
        client: MockClient((request) async {
          expect(request.url.queryParameters['stationName'], 'Sant Cugat');

          return http.Response(
            jsonEncode({
              'stationName': 'Sant Cugat',
              'temperature': 18.0,
              'precipitation': '1.2',
              'wind': 8.0,
              'solarIrradiance': 300.0,
              'relativeHumidity': 70.0,
            }),
            200,
          );
        }),
      );

      final weather = await service.fetchCurrent(city: 'Sant Cugat');

      expect(weather.stationName, 'Sant Cugat');
      expect(weather.temp, 18.0);
      expect(weather.precipitation, '1.2');
      expect(weather.wind, 8.0);
      expect(weather.solarIrradiance, 300.0);
      expect(weather.relativeHumidity, 70.0);
    });

    test('fetchCurrent llença excepció si statusCode no és 200', () async {
      final service = WeatherService(
        client: MockClient((request) async {
          return http.Response(jsonEncode({'error': 'No trobat'}), 404);
        }),
      );

      expect(
        () => service.fetchCurrent(city: 'Barcelona'),
        throwsA(
          predicate(
            (e) =>
                e is Exception && e.toString().contains('Error backend: 404'),
          ),
        ),
      );
    });

    test('fetchCurrent llença excepció si el body no és JSON vàlid', () async {
      final service = WeatherService(
        client: MockClient((request) async {
          return http.Response('resposta no json', 200);
        }),
      );

      expect(
        () => service.fetchCurrent(city: 'Barcelona'),
        throwsA(isA<FormatException>()),
      );
    });

    test('fetchCurrent llença error si el JSON no és un map', () async {
      final service = WeatherService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode([
              {'stationName': 'Barcelona'},
            ]),
            200,
          );
        }),
      );

      expect(
        () => service.fetchCurrent(city: 'Barcelona'),
        throwsA(isA<TypeError>()),
      );
    });
  });
}

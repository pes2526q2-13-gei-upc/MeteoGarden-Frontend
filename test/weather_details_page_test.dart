import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_garden/generated/app_localizations.dart';
import 'package:meteo_garden/models/weather_info.dart';
import 'package:meteo_garden/models/weather_provider.dart';
import 'package:meteo_garden/screens/weather_details_page.dart';
import 'package:provider/provider.dart';

class FakeWeatherProvider extends WeatherProvider {
  WeatherInfo? fakeWeather;

  @override
  WeatherInfo? get currentWeather => fakeWeather;
}

Widget makeTestableWidget({required FakeWeatherProvider weatherProvider}) {
  return ChangeNotifierProvider<WeatherProvider>.value(
    value: weatherProvider,
    child: MaterialApp(
      locale: const Locale('ca'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const WeatherDetailsPage(),
    ),
  );
}

WeatherInfo fakeWeatherInfo({String stationName = 'Estació Barcelona'}) {
  return WeatherInfo(
    temp: 22.5,
    relativeHumidity: 65,
    wind: 12.3,
    precipitation: '1.2',
    solarIrradiance: 450.7,
    stationName: stationName,
  );
}

void main() {
  testWidgets('mostra loading quan no hi ha dades meteorològiques', (
    tester,
  ) async {
    final weatherProvider = FakeWeatherProvider()..fakeWeather = null;

    await tester.pumpWidget(
      makeTestableWidget(weatherProvider: weatherProvider),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('mostra el títol de la pantalla', (tester) async {
    final weatherProvider = FakeWeatherProvider()
      ..fakeWeather = fakeWeatherInfo();

    await tester.pumpWidget(
      makeTestableWidget(weatherProvider: weatherProvider),
    );

    await tester.pumpAndSettle();

    expect(find.text('MeteoGarden'), findsOneWidget);
  });

  testWidgets('mostra el nom de l’estació meteorològica', (tester) async {
    final weatherProvider = FakeWeatherProvider()
      ..fakeWeather = fakeWeatherInfo(stationName: 'Estació Vic');

    await tester.pumpWidget(
      makeTestableWidget(weatherProvider: weatherProvider),
    );

    await tester.pumpAndSettle();

    expect(find.text('Estació Vic'), findsOneWidget);
    expect(find.byIcon(Icons.location_on), findsOneWidget);
  });

  testWidgets('mostra Desconeguda si el nom de l’estació és buit', (
    tester,
  ) async {
    final weatherProvider = FakeWeatherProvider()
      ..fakeWeather = fakeWeatherInfo(stationName: '');

    await tester.pumpWidget(
      makeTestableWidget(weatherProvider: weatherProvider),
    );

    await tester.pumpAndSettle();

    expect(find.text('Desconeguda'), findsOneWidget);
  });

  testWidgets('mostra totes les mètriques meteorològiques', (tester) async {
    final weatherProvider = FakeWeatherProvider()
      ..fakeWeather = fakeWeatherInfo();

    await tester.pumpWidget(
      makeTestableWidget(weatherProvider: weatherProvider),
    );

    await tester.pumpAndSettle();

    expect(find.text('22.5 °C'), findsOneWidget);
    expect(find.text('65 %'), findsOneWidget);
    expect(find.text('12.3 km/h'), findsOneWidget);
    expect(find.text('1.2 mm'), findsOneWidget);
    expect(find.text('450.7 W/m²'), findsOneWidget);
  });

  testWidgets('mostra les icones de les mètriques', (tester) async {
    final weatherProvider = FakeWeatherProvider()
      ..fakeWeather = fakeWeatherInfo();

    await tester.pumpWidget(
      makeTestableWidget(weatherProvider: weatherProvider),
    );

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.thermostat), findsOneWidget);
    expect(find.byIcon(Icons.water_drop), findsOneWidget);
    expect(find.byIcon(Icons.air), findsOneWidget);
    expect(find.byIcon(Icons.umbrella), findsOneWidget);
    expect(find.byIcon(Icons.wb_sunny), findsOneWidget);
  });

  testWidgets('el botó enrere fa pop de la pantalla', (tester) async {
    final weatherProvider = FakeWeatherProvider()
      ..fakeWeather = fakeWeatherInfo();

    await tester.pumpWidget(
      ChangeNotifierProvider<WeatherProvider>.value(
        value: weatherProvider,
        child: MaterialApp(
          locale: const Locale('ca'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const WeatherDetailsPage(),
                        ),
                      );
                    },
                    child: const Text('Obrir weather'),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Obrir weather'));
    await tester.pumpAndSettle();

    expect(find.text('Estació Barcelona'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Obrir weather'), findsOneWidget);
    expect(find.text('Estació Barcelona'), findsNothing);
  });
}

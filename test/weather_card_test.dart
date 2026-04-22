import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_garden/widgets/weather_card.dart';

void main() {
  testWidgets('WeatherCard mostra la informació correctament', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeatherCard(
            nomEstacio: 'Lladurs',
            title: 'Temperatura: 18.5 | Precipitació: 0',
            subtitle: 'Vent: 3 m/s',
            trailing: const Icon(Icons.refresh),
            onRefresh: () {},
            precipitation: 0,
            wind: 3,
          ),
        ),
      ),
    );

    expect(find.text('Lladurs'), findsOneWidget);
    expect(find.text('Temperatura: 18.5 | Precipitació: 0'), findsOneWidget);
    expect(find.text('Vent: 3 m/s'), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
    expect(find.byIcon(Icons.wb_sunny_rounded), findsOneWidget);
  });

  testWidgets('Mostra icona de pluja si hi ha precipitació', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeatherCard(
            nomEstacio: 'Test',
            title: 'Temperatura: 20 | Precipitació: 5',
            subtitle: 'Vent: 2 m/s',
            trailing: const Icon(Icons.refresh),
            onRefresh: () {},
            precipitation: 5,
            wind: 2,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.water_drop_rounded), findsOneWidget);
  });

  testWidgets('Mostra icona de vent si vent >= 8', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeatherCard(
            nomEstacio: 'Test',
            title: 'Temperatura: 20 | Precipitació: 0',
            subtitle: 'Vent: 10 m/s',
            trailing: const Icon(Icons.refresh),
            onRefresh: () {},
            precipitation: 0,
            wind: 10,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.air_rounded), findsOneWidget);
  });

  testWidgets(
    'Mostra icona de sol si no hi ha precipitació ni vent fort',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeatherCard(
              nomEstacio: 'Test',
              title: 'format incorrecte',
              subtitle: '???',
              trailing: const Icon(Icons.refresh),
              onRefresh: () {},
              precipitation: 0,
              wind: 0,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.wb_sunny_rounded), findsOneWidget);
    },
  );

  testWidgets('Crida onRefresh quan es fa tap', (WidgetTester tester) async {
    bool clicked = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeatherCard(
            nomEstacio: 'Test',
            title: 'Temperatura: 20 | Precipitació: 0',
            subtitle: 'Vent: 2 m/s',
            trailing: const Icon(Icons.refresh),
            onRefresh: () {
              clicked = true;
            },
            precipitation: 0,
            wind: 2,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(InkWell));
    await tester.pump();

    expect(clicked, true);
  });
}
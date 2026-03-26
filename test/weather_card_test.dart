import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_garden/widgets/weather_card.dart';

void main() {
  //test per comprovar que es mostra la informació correcte al widget
  testWidgets('WeatherCard mostra la informació correctament', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeatherCard(
            nomEstacio: 'Lladurs',
            title: '18.5 · 0',
            subtitle: 'Vent: 3 m/s',
            trailing: const Icon(Icons.refresh),
            onRefresh: () {},
          ),
        ),
      ),
    );

    expect(find.text('Lladurs'), findsOneWidget);
    expect(find.text('18.5 · 0'), findsOneWidget);
    expect(find.text('Vent: 3 m/s'), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
    expect(find.byIcon(Icons.wb_sunny), findsOneWidget);
  });

  //test per comprovar que es mostra la icona de pluja si  hi ha precipitació
  testWidgets('Mostra icona de pluja si hi ha precipitació', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeatherCard(
            nomEstacio: 'Test',
            title: '20 · 5',
            subtitle: 'Vent: 2 m/s',
            trailing: const Icon(Icons.refresh),
            onRefresh: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.grain), findsOneWidget);
  });

  //test per comprovar que es mostra la icona de vent si es registren valors de vent > 8
  testWidgets('Mostra icona de vent si vent >= 8', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeatherCard(
            nomEstacio: 'Test',
            title: '20 · 0',
            subtitle: 'Vent: 10 m/s',
            trailing: const Icon(Icons.refresh),
            onRefresh: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.air), findsOneWidget);
  });

  testWidgets(
    'Mostra icona de sol si el format no es pot parsejar però no hi ha excepció',
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
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.wb_sunny), findsOneWidget);
    },
  );
  //test per comprovar que funciona el refresh del temps
  testWidgets('Crida onRefresh quan es fa tap', (WidgetTester tester) async {
    bool clicked = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeatherCard(
            nomEstacio: 'Test',
            title: '20 · 0',
            subtitle: 'Vent: 2 m/s',
            trailing: const Icon(Icons.refresh),
            onRefresh: () {
              clicked = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byType(InkWell));
    await tester.pump();

    expect(clicked, true);
  });
}

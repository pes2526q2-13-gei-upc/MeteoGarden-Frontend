import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_garden/generated/app_localizations.dart';
import 'package:meteo_garden/models/plant_identification.dart';
import 'package:meteo_garden/screens/plant_result_page.dart';

PlantIdentification fakePlantResult({
  String commonName = 'Aloe vera',
  String scientificName = 'Aloe barbadensis miller',
  String family = 'Asphodelaceae',
  double? score = 0.873,
  String? imageUrl = '',
}) {
  return PlantIdentification.fromJson({
    'plant': {
      'commonName': commonName,
      'scientificName': scientificName,
      'family': family,
    },
    'plantnet': {'score': score},
    'image': {'url': imageUrl},
  });
}

Widget makeTestableWidget({required PlantIdentification result}) {
  return MaterialApp(
    locale: const Locale('ca'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: PlantResultPage(result: result),
  );
}

Future<void> pumpPlantResultPage(
  WidgetTester tester, {
  required PlantIdentification result,
}) async {
  tester.view.physicalSize = const Size(1200, 2000);
  tester.view.devicePixelRatio = 1.0;

  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(makeTestableWidget(result: result));

  await tester.pumpAndSettle();
}

void main() {
  testWidgets('mostra la pàgina de resultat de planta', (tester) async {
    final result = fakePlantResult();

    await pumpPlantResultPage(tester, result: result);

    expect(find.byKey(const Key('plant_result_page')), findsOneWidget);
  });

  testWidgets('mostra el nom comú i el nom científic', (tester) async {
    final result = fakePlantResult(
      commonName: 'Menta',
      scientificName: 'Mentha spicata',
    );

    await pumpPlantResultPage(tester, result: result);

    expect(find.byKey(const Key('plant_result_common_name')), findsOneWidget);
    expect(
      find.byKey(const Key('plant_result_scientific_name')),
      findsOneWidget,
    );

    expect(find.text('Menta'), findsOneWidget);
    expect(find.text('Mentha spicata'), findsWidgets);
  });

  testWidgets('mostra la família de la planta', (tester) async {
    final result = fakePlantResult(family: 'Lamiaceae');

    await pumpPlantResultPage(tester, result: result);

    expect(find.text('Lamiaceae'), findsOneWidget);
    expect(find.byIcon(Icons.park_outlined), findsOneWidget);
  });

  testWidgets('mostra el percentatge de confiança formatat', (tester) async {
    final result = fakePlantResult(score: 0.873);

    await pumpPlantResultPage(tester, result: result);

    expect(find.text('87.3%'), findsOneWidget);
    expect(find.byIcon(Icons.verified_outlined), findsOneWidget);
  });

  testWidgets('mostra guió quan el score és null', (tester) async {
    final result = fakePlantResult(score: null);

    await pumpPlantResultPage(tester, result: result);

    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('mostra la icona fallback quan no hi ha imatge', (tester) async {
    final result = fakePlantResult(imageUrl: '');

    await pumpPlantResultPage(tester, result: result);

    expect(find.byIcon(Icons.local_florist), findsOneWidget);
  });

  testWidgets('mostra les icones informatives', (tester) async {
    final result = fakePlantResult();

    await pumpPlantResultPage(tester, result: result);

    expect(find.byIcon(Icons.science_outlined), findsOneWidget);
    expect(find.byIcon(Icons.park_outlined), findsOneWidget);
    expect(find.byIcon(Icons.verified_outlined), findsOneWidget);
  });

  testWidgets('existeix el botó per fer una altra foto', (tester) async {
    final result = fakePlantResult();

    await pumpPlantResultPage(tester, result: result);

    expect(
      find.byKey(const Key('plant_result_take_another_photo_button')),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
  });

  testWidgets('el botó enrere fa pop de la pantalla', (tester) async {
    final result = fakePlantResult();

    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
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
                        builder: (_) => PlantResultPage(result: result),
                      ),
                    );
                  },
                  child: const Text('Obrir resultat'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Obrir resultat'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('plant_result_page')), findsOneWidget);

    await tester.tap(find.byKey(const Key('plant_result_back_button')));
    await tester.pumpAndSettle();

    expect(find.text('Obrir resultat'), findsOneWidget);
    expect(find.byKey(const Key('plant_result_page')), findsNothing);
  });

  testWidgets('el botó de fer una altra foto també fa pop', (tester) async {
    final result = fakePlantResult();

    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
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
                        builder: (_) => PlantResultPage(result: result),
                      ),
                    );
                  },
                  child: const Text('Obrir resultat'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Obrir resultat'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('plant_result_page')), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('plant_result_take_another_photo_button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Obrir resultat'), findsOneWidget);
    expect(find.byKey(const Key('plant_result_page')), findsNothing);
  });
}

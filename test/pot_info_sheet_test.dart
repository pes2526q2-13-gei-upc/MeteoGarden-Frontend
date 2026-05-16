import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_garden/generated/app_localizations.dart';
import 'package:meteo_garden/models/garden.dart';
import 'package:meteo_garden/widgets/pot_info_sheet.dart';

void main() {
  group('PotInfoSheet', () {
    testWidgets('mostra la informació bàsica de la planta', (
      WidgetTester tester,
    ) async {
      final pot = _buildPot(
        commonName: 'Tomàquet',
        scientificName: 'Solanum lycopersicum',
        growthPhase: 'germination',
        waterLevel: 60,
        healthLevel: 80,
        lastWateredAt: DateTime(2026, 3, 25, 10, 0),
      );

      await tester.pumpWidget(
        _wrapWithApp(PotInfoSheet(pot: pot, onWater: () async {})),
      );

      expect(find.text('Tomàquet'), findsOneWidget);
      expect(find.textContaining('Brot'), findsNothing);
      expect(find.text("Nivell d'Aigua"), findsOneWidget);
      expect(find.text('Salut'), findsOneWidget);
      expect(find.text('60%'), findsOneWidget);
      expect(find.text('80%'), findsOneWidget);
      expect(find.textContaining('Últim reg:'), findsOneWidget);
      expect(find.textContaining('2026-03-25'), findsOneWidget);
      expect(find.byKey(const Key('water_plant_button')), findsOneWidget);
      expect(
        find.byKey(const Key('collect_mature_plant_button')),
        findsNothing,
      );
    });

    testWidgets('mostra el nom comú de la planta', (WidgetTester tester) async {
      final pot = _buildPot(
        commonName: 'Alfàbrega',
        scientificName: 'Ocimum basilicum',
        growthPhase: 'seed',
        waterLevel: 30,
        healthLevel: 90,
        lastWateredAt: DateTime(2026, 3, 25),
      );

      await tester.pumpWidget(
        _wrapWithApp(PotInfoSheet(pot: pot, onWater: () async {})),
      );

      expect(find.text('Alfàbrega'), findsOneWidget);
      expect(find.text('Llavor'), findsOneWidget);
    });

    testWidgets('mostra Planta si pot.plant és null', (
      WidgetTester tester,
    ) async {
      final pot = GardenPot(
        potNumber: 1,
        occupied: true,
        plant: null,
        growthPhase: 'growth',
        healthLevel: 50,
        waterLevel: 50,
        plantedAt: null,
        lastWateredAt: null,
      );

      await tester.pumpWidget(
        _wrapWithApp(PotInfoSheet(pot: pot, onWater: () async {})),
      );

      expect(find.text('Planta'), findsOneWidget);
      expect(find.text('Planta'), findsOneWidget);
      expect(find.text('50%'), findsWidgets);
      expect(find.textContaining('Últim reg:'), findsOneWidget);
    });

    testWidgets(
      'mostra el botó de recollir si la planta és madura i hi ha onCollect',
      (WidgetTester tester) async {
        final pot = _buildPot(
          commonName: 'Tomàquet',
          scientificName: 'Solanum lycopersicum',
          growthPhase: 'mature',
          waterLevel: 70,
          healthLevel: 90,
          lastWateredAt: DateTime(2026, 3, 25),
        );

        await tester.pumpWidget(
          _wrapWithApp(
            PotInfoSheet(
              pot: pot,
              onWater: () async {},
              onCollect: () async {},
            ),
          ),
        );

        expect(find.text('Madura'), findsOneWidget);
        expect(
          find.byKey(const Key('collect_mature_plant_button')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'no mostra el botó de recollir si és madura però onCollect és null',
      (WidgetTester tester) async {
        final pot = _buildPot(
          commonName: 'Tomàquet',
          scientificName: 'Solanum lycopersicum',
          growthPhase: 'mature',
          waterLevel: 70,
          healthLevel: 90,
          lastWateredAt: DateTime(2026, 3, 25),
        );

        await tester.pumpWidget(
          _wrapWithApp(
            PotInfoSheet(pot: pot, onWater: () async {}, onCollect: null),
          ),
        );

        expect(
          find.byKey(const Key('collect_mature_plant_button')),
          findsNothing,
        );
      },
    );

    testWidgets('no mostra el botó de regar si el nivell d’aigua és 100', (
      WidgetTester tester,
    ) async {
      final pot = _buildPot(
        commonName: 'Tomàquet',
        scientificName: 'Solanum lycopersicum',
        growthPhase: 'growth',
        waterLevel: 100,
        healthLevel: 90,
        lastWateredAt: DateTime(2026, 3, 25),
      );

      await tester.pumpWidget(
        _wrapWithApp(PotInfoSheet(pot: pot, onWater: () async {})),
      );

      expect(find.byKey(const Key('water_plant_button')), findsNothing);
    });

    testWidgets('no mostra el botó de regar si la planta està morta', (
      WidgetTester tester,
    ) async {
      final pot = _buildPot(
        commonName: 'Tomàquet',
        scientificName: 'Solanum lycopersicum',
        growthPhase: 'dead',
        waterLevel: 40,
        healthLevel: 0,
        lastWateredAt: DateTime(2026, 3, 25),
      );

      await tester.pumpWidget(
        _wrapWithApp(PotInfoSheet(pot: pot, onWater: () async {})),
      );

      expect(find.text('Morta'), findsOneWidget);
      expect(find.byKey(const Key('water_plant_button')), findsNothing);
    });

    testWidgets('crida onWater quan es prem el botó de regar', (
      WidgetTester tester,
    ) async {
      bool watered = false;

      final pot = _buildPot(
        commonName: 'Tomàquet',
        scientificName: 'Solanum lycopersicum',
        growthPhase: 'growth',
        waterLevel: 40,
        healthLevel: 90,
        lastWateredAt: DateTime(2026, 3, 25),
      );

      await tester.pumpWidget(
        _wrapWithApp(
          PotInfoSheet(
            pot: pot,
            onWater: () async {
              watered = true;
            },
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('water_plant_button')));
      await tester.pump();

      expect(watered, true);
    });

    testWidgets('crida onCollect quan es prem el botó de recollir', (
      WidgetTester tester,
    ) async {
      bool collected = false;

      final pot = _buildPot(
        commonName: 'Tomàquet',
        scientificName: 'Solanum lycopersicum',
        growthPhase: 'mature',
        waterLevel: 40,
        healthLevel: 90,
        lastWateredAt: DateTime(2026, 3, 25),
      );

      await tester.pumpWidget(
        _wrapWithApp(
          PotInfoSheet(
            pot: pot,
            onWater: () async {},
            onCollect: () async {
              collected = true;
            },
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('collect_mature_plant_button')));
      await tester.pump();

      expect(collected, true);
    });

    testWidgets('mostra botó de pocions si onPotion no és null', (
      WidgetTester tester,
    ) async {
      bool openedPotion = false;

      final pot = _buildPot(
        commonName: 'Menta',
        scientificName: 'Mentha spicata',
        growthPhase: 'growth',
        waterLevel: 80,
        healthLevel: 90,
        lastWateredAt: DateTime(2026, 3, 25),
      );

      await tester.pumpWidget(
        _wrapWithApp(
          PotInfoSheet(
            pot: pot,
            onWater: () async {},
            onPotion: () {
              openedPotion = true;
            },
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('open_potion_selection_button')));
      await tester.pump();

      expect(openedPotion, true);
    });

    testWidgets('mostra botó d’eliminar si onDeletePlant no és null', (
      WidgetTester tester,
    ) async {
      bool deleted = false;

      final pot = _buildPot(
        commonName: 'Menta',
        scientificName: 'Mentha spicata',
        growthPhase: 'growth',
        waterLevel: 80,
        healthLevel: 90,
        lastWateredAt: DateTime(2026, 3, 25),
      );

      await tester.pumpWidget(
        _wrapWithApp(
          PotInfoSheet(
            pot: pot,
            onWater: () async {},
            onDeletePlant: () async {
              deleted = true;
            },
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('delete_plant_button')));
      await tester.pump();

      expect(deleted, true);
    });

    testWidgets('mostra les barres d’aigua i salut amb els valors correctes', (
      WidgetTester tester,
    ) async {
      final pot = _buildPot(
        commonName: 'Lavanda',
        scientificName: 'Lavandula angustifolia',
        growthPhase: 'growth',
        waterLevel: 25,
        healthLevel: 75,
        lastWateredAt: DateTime(2026, 3, 25),
      );

      await tester.pumpWidget(
        _wrapWithApp(PotInfoSheet(pot: pot, onWater: () async {})),
      );

      expect(find.byKey(const Key('plant_water_info')), findsOneWidget);
      expect(find.byKey(const Key('plant_health_info')), findsOneWidget);
      expect(find.text('25%'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
    });
  });
}

Widget _wrapWithApp(Widget child) {
  return MaterialApp(
    locale: const Locale('ca'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

GardenPot _buildPot({
  required String commonName,
  required String scientificName,
  required String growthPhase,
  required double waterLevel,
  required double healthLevel,
  required DateTime? lastWateredAt,
}) {
  return GardenPot(
    potNumber: 1,
    occupied: true,
    growthPhase: growthPhase,
    healthLevel: healthLevel,
    waterLevel: waterLevel,
    plantedAt: DateTime(2026, 3, 20),
    lastWateredAt: lastWateredAt,
    plant: PlantData(
      scientificName: scientificName,
      commonName: commonName,
      family: 'Solanaceae',
      canFlower: true,
      minTemperature: 10,
      maxTemperature: 30,
      imageUrl: null,
    ),
  );
}

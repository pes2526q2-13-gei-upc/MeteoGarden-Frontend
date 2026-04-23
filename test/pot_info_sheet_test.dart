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
        growthPhase: 'sprout',
        waterLevel: 60,
        healthLevel: 80,
        lastWateredAt: DateTime(2026, 3, 25, 10, 0),
      );

      await tester.pumpWidget(
        _wrapWithApp(PotInfoSheet(pot: pot, onWater: () async {})),
      );

      expect(find.text('Tomàquet'), findsOneWidget);
      expect(find.text('Brot'), findsOneWidget);
      expect(find.text("Nivell d'Aigua"), findsOneWidget);
      expect(find.text('Salut'), findsOneWidget);
      expect(find.text('60%'), findsOneWidget);
      expect(find.text('80%'), findsOneWidget);
      expect(find.textContaining('Últim reg:'), findsOneWidget);
      expect(find.textContaining('2026-03-25'), findsOneWidget);
      expect(find.text('Regar planta'), findsOneWidget);
      expect(find.text('Recollir planta'), findsNothing);
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
        growthPhase: 'growing',
        healthLevel: 50,
        waterLevel: 50,
        plantedAt: null,
        lastWateredAt: null,
      );

      await tester.pumpWidget(
        _wrapWithApp(PotInfoSheet(pot: pot, onWater: () async {})),
      );

      expect(find.text('Planta'), findsOneWidget);
      expect(find.text('Creixent'), findsOneWidget);
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
        expect(find.text('Recollir planta'), findsOneWidget);
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

        expect(find.text('Recollir planta'), findsNothing);
      },
    );

    testWidgets('no mostra el botó de regar si el nivell d’aigua és 100', (
      WidgetTester tester,
    ) async {
      final pot = _buildPot(
        commonName: 'Tomàquet',
        scientificName: 'Solanum lycopersicum',
        growthPhase: 'growing',
        waterLevel: 100,
        healthLevel: 90,
        lastWateredAt: DateTime(2026, 3, 25),
      );

      await tester.pumpWidget(
        _wrapWithApp(PotInfoSheet(pot: pot, onWater: () async {})),
      );

      expect(find.text('Regar planta'), findsNothing);
    });

    testWidgets('crida onWater quan es prem el botó de regar', (
      WidgetTester tester,
    ) async {
      bool watered = false;

      final pot = _buildPot(
        commonName: 'Tomàquet',
        scientificName: 'Solanum lycopersicum',
        growthPhase: 'growing',
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

      await tester.tap(find.text('Regar planta'));
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

      await tester.tap(find.text('Recollir planta'));
      await tester.pump();

      expect(collected, true);
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

// mock de les dades d'un pot
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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_garden/generated/app_localizations.dart';
import 'package:meteo_garden/models/garden.dart';
import 'package:meteo_garden/models/seed_option.dart';
import 'package:meteo_garden/services/garden_service.dart';
import 'package:meteo_garden/widgets/seed_selection_sheet.dart';

void main() {
  group('SeedSelectionSheet', () {
    testWidgets('mostra estat buit si no hi ha llavors', (
      WidgetTester tester,
    ) async {
      final pot = _buildEmptyPot();
      final gardenService = TestGardenService();

      await tester.pumpWidget(
        _wrapWithApp(
          SeedSelectionSheet(
            pot: pot,
            seeds: const [],
            username: 'jana',
            gardenName: 'Garden 1',
            gardenService: gardenService,
            onPlantingSuccess: () {},
          ),
        ),
      );

      expect(find.text('Test Buit'), findsOneWidget);
      expect(find.text('No tens llavors disponibles'), findsOneWidget);
      expect(
        find.text("Quan n'aconsegueixis, les podràs plantar aquí."),
        findsOneWidget,
      );
      expect(find.text('Plantar'), findsNothing);
    });

    testWidgets('mostra les llavors disponibles', (
      WidgetTester tester,
    ) async {
      final pot = _buildEmptyPot();
      final gardenService = TestGardenService();
      final seeds = [
        _buildSeed(
          scientificName: 'Rosa canina',
          amount: 3,
          imageUrl: 'https://example.com/rosa.png',
        ),
        _buildSeed(
          scientificName: 'Mentha spicata',
          amount: 2,
          imageUrl: 'https://example.com/menta.png',
        ),
      ];

      await tester.pumpWidget(
        _wrapWithApp(
          SeedSelectionSheet(
            pot: pot,
            seeds: seeds,
            username: 'jana',
            gardenName: 'Garden 1',
            gardenService: gardenService,
            onPlantingSuccess: () {},
          ),
        ),
      );

      expect(find.text('Test Buit'), findsOneWidget);
      expect(find.textContaining('Selecciona una llavor pel test'), findsOneWidget);
      expect(find.text('Rosa canina'), findsOneWidget);
      expect(find.text('Mentha spicata'), findsOneWidget);
      expect(find.text('x3'), findsOneWidget);
      expect(find.text('x2'), findsOneWidget);
      expect(find.text('Plantar'), findsOneWidget);
    });

    testWidgets('el botó Plantar està desactivat fins seleccionar una llavor', (
      WidgetTester tester,
    ) async {
      final pot = _buildEmptyPot();
      final gardenService = TestGardenService();
      final seeds = [
        _buildSeed(
          scientificName: 'Rosa canina',
          amount: 3,
          imageUrl: 'https://example.com/rosa.png',
        ),
      ];

      await tester.pumpWidget(
        _wrapWithApp(
          SeedSelectionSheet(
            pot: pot,
            seeds: seeds,
            username: 'jana',
            gardenName: 'Garden 1',
            gardenService: gardenService,
            onPlantingSuccess: () {},
          ),
        ),
      );

      var button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);

      await tester.tap(find.text('Rosa canina'));
      await tester.pump();

      button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('crida plantSeed i mostra vista d èxit', (
      WidgetTester tester,
    ) async {
      final pot = _buildEmptyPot();
      final gardenService = TestGardenService()
        ..plantSeedResult = PlantingResult(
          message: 'Plantada correctament',
          potNumber: 1,
          scientificName: 'Rosa canina',
          commonName: 'Roser silvestre',
          growthPhase: 'seed',
          healthLevel: 100,
          waterLevel: 100,
          plantedAt: '2026-04-22T00:00:00',
          remainingSeeds: 2,
        );

      final seeds = [
        _buildSeed(
          scientificName: 'Rosa canina',
          amount: 3,
          imageUrl: 'https://example.com/rosa.png',
        ),
      ];

      bool plantingSuccessCalled = false;

      await tester.pumpWidget(
        _wrapWithApp(
          SeedSelectionSheet(
            pot: pot,
            seeds: seeds,
            username: 'jana',
            gardenName: 'Garden 1',
            gardenService: gardenService,
            onPlantingSuccess: () {
              plantingSuccessCalled = true;
            },
          ),
        ),
      );

      await tester.tap(find.text('Rosa canina'));
      await tester.pump();

      await tester.tap(find.text('Plantar'));
      await tester.pumpAndSettle();

      expect(gardenService.lastPlantSeedUsername, 'jana');
      expect(gardenService.lastPlantSeedGardenName, 'Garden 1');
      expect(gardenService.lastPlantSeedPotNumber, 1);
      expect(gardenService.lastPlantSeedScientificName, 'Rosa canina');

      expect(find.text('Plantada correctament'), findsOneWidget);
      expect(find.text('Tancar'), findsOneWidget);

      await tester.tap(find.text('Tancar'));
      await tester.pumpAndSettle();

      expect(plantingSuccessCalled, true);
    });

    testWidgets('mostra error si plantSeed falla', (
      WidgetTester tester,
    ) async {
      final pot = _buildEmptyPot();
      final gardenService = TestGardenService()
        ..plantSeedException = Exception('No queden llavors');

      final seeds = [
        _buildSeed(
          scientificName: 'Rosa canina',
          amount: 3,
          imageUrl: 'https://example.com/rosa.png',
        ),
      ];

      await tester.pumpWidget(
        _wrapWithApp(
          SeedSelectionSheet(
            pot: pot,
            seeds: seeds,
            username: 'jana',
            gardenName: 'Garden 1',
            gardenService: gardenService,
            onPlantingSuccess: () {},
          ),
        ),
      );

      await tester.tap(find.text('Rosa canina'));
      await tester.pump();

      await tester.tap(find.text('Plantar'));
      await tester.pumpAndSettle();

      expect(find.text('No queden llavors'), findsOneWidget);
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

GardenPot _buildEmptyPot() {
  return GardenPot(
    potNumber: 1,
    occupied: false,
    plant: null,
    growthPhase: null,
    healthLevel: null,
    waterLevel: null,
    plantedAt: null,
    lastWateredAt: null,
  );
}

SeedOption _buildSeed({
  required String scientificName,
  required int amount,
  required String imageUrl,
}) {
  return SeedOption(
    scientificName: scientificName,
    amount: amount,
    imageUrl: imageUrl,
  );
}

class TestGardenService implements GardenService {
  PlantingResult? plantSeedResult;
  Exception? plantSeedException;

  String? lastPlantSeedUsername;
  String? lastPlantSeedGardenName;
  int? lastPlantSeedPotNumber;
  String? lastPlantSeedScientificName;

  @override
  Future<PlantingResult> plantSeed({
    required String username,
    required String gardenName,
    required int potNumber,
    required String scientificName,
  }) async {
    lastPlantSeedUsername = username;
    lastPlantSeedGardenName = gardenName;
    lastPlantSeedPotNumber = potNumber;
    lastPlantSeedScientificName = scientificName;

    if (plantSeedException != null) {
      throw plantSeedException!;
    }

    if (plantSeedResult != null) {
      return plantSeedResult!;
    }

    throw Exception('No plantSeedResult configured');
  }

  @override
  Future<List<GardenPot>> fetchGardenPlants({
    required String username,
    required String gardenName,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<String> waterPlant({
    required String username,
    required String gardenName,
    required int potNumber,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<List<SeedOption>> fetchSeeds(String username) async {
    throw UnimplementedError();
  }

  @override
  Future<List<ProductItem>> fetchProducts(String username) async {
    throw UnimplementedError();
  }

  @override
  Future<String> applyPotion({
    required String username,
    required String gardenName,
    required int potNumber,
    required String productName,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<String> collectPlant({
    required String username,
    required String gardenName,
    required int potNumber,
    required String scientificName,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<String> deletePlant({
    required String username,
    required String gardenName,
    required int potNumber,
  }) async {
    throw UnimplementedError();
  }
}
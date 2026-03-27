/*import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_garden/models/garden.dart';
import 'package:meteo_garden/models/seed_option.dart';
import 'package:meteo_garden/services/garden_service.dart';
import 'package:meteo_garden/widgets/seed_selection_sheet.dart';

void main() {
  group('SeedSelectionSheet', () {
    testWidgets('mostra empty state si no hi ha llavors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SeedSelectionSheet(
              pot: _buildPot(),
              seeds: const [],
              username: 'jana',
              gardenName: 'jardi1',
              gardenService: FakeGardenService.success(),
              onPlantingSuccess: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test buit'), findsOneWidget);
      expect(find.text('No tens llavors disponibles'), findsOneWidget);
      expect(
        find.text("Quan n'aconsegueixis, les podràs plantar aquí."),
        findsOneWidget,
      );
      expect(find.text('Plantar'), findsNothing);
    });

    testWidgets('mostra la llista de llavors disponibles', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SeedSelectionSheet(
              pot: _buildPot(),
              seeds: [
                _buildSeed(scientificName: 'Ocimum basilicum', amount: 2),
                _buildSeed(scientificName: 'Mentha spicata', amount: 1),
              ],
              username: 'jana',
              gardenName: 'jardi1',
              gardenService: FakeGardenService.success(),
              onPlantingSuccess: () {},
            ),
          ),
        ),
      );

      expect(find.text('Ocimum basilicum'), findsOneWidget);
      expect(find.text('Mentha spicata'), findsOneWidget);
      expect(find.text('x2'), findsOneWidget);
      expect(find.text('x1'), findsOneWidget);
      expect(find.text('Plantar'), findsOneWidget);
    });

    testWidgets(
      'el botó Plantar està desactivat si no hi ha cap llavor seleccionada',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SeedSelectionSheet(
                pot: _buildPot(),
                seeds: [
                  _buildSeed(scientificName: 'Ocimum basilicum', amount: 2),
                ],
                username: 'jana',
                gardenName: 'jardi1',
                gardenService: FakeGardenService.success(),
                onPlantingSuccess: () {},
              ),
            ),
          ),
        );

        final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );

        expect(button.onPressed, isNull);
      },
    );

    testWidgets('en seleccionar una llavor, el botó Plantar s’activa', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SeedSelectionSheet(
              pot: _buildPot(),
              seeds: [
                _buildSeed(scientificName: 'Ocimum basilicum', amount: 2),
              ],
              username: 'jana',
              gardenName: 'jardi1',
              gardenService: FakeGardenService.success(),
              onPlantingSuccess: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Ocimum basilicum'));
      await tester.pump();

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );

      expect(button.onPressed, isNotNull);
    });

    testWidgets('mostra estat de càrrega mentre planta', (
      WidgetTester tester,
    ) async {
      final service = FakeGardenService.delayedSuccess();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SeedSelectionSheet(
              pot: _buildPot(),
              seeds: [
                _buildSeed(scientificName: 'Ocimum basilicum', amount: 2),
              ],
              username: 'jana',
              gardenName: 'jardi1',
              gardenService: service,
              onPlantingSuccess: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Ocimum basilicum'));
      await tester.pump();

      await tester.tap(find.text('Plantar'));
      await tester.pump();

      expect(find.text('Plantant...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('si el servei retorna èxit, mostra la vista d’èxit', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SeedSelectionSheet(
              pot: _buildPot(),
              seeds: [
                _buildSeed(scientificName: 'Ocimum basilicum', amount: 2),
              ],
              username: 'jana',
              gardenName: 'jardi1',
              gardenService: FakeGardenService.success(
                message: 'Planta plantada correctament',
              ),
              onPlantingSuccess: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Ocimum basilicum'));
      await tester.pump();

      await tester.tap(find.text('Plantar'));
      await tester.pumpAndSettle();

      expect(find.text('Planta plantada correctament'), findsOneWidget);
      expect(find.text('Tancar'), findsOneWidget);
      expect(find.text('Plantar'), findsNothing);
    });

    testWidgets('si el servei falla, mostra el missatge d’error', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SeedSelectionSheet(
              pot: _buildPot(),
              seeds: [
                _buildSeed(scientificName: 'Ocimum basilicum', amount: 2),
              ],
              username: 'jana',
              gardenName: 'jardi1',
              gardenService: FakeGardenService.error(
                message: 'No es pot plantar aquesta llavor',
              ),
              onPlantingSuccess: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Ocimum basilicum'));
      await tester.pump();

      await tester.tap(find.text('Plantar'));
      await tester.pumpAndSettle();

      expect(find.text('No es pot plantar aquesta llavor'), findsOneWidget);
      expect(find.text('Plantar'), findsOneWidget);
    });

    testWidgets('el botó Tancar crida onPlantingSuccess', (
      WidgetTester tester,
    ) async {
      bool plantingSuccessCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SeedSelectionSheet(
              pot: _buildPot(),
              seeds: [
                _buildSeed(scientificName: 'Ocimum basilicum', amount: 2),
              ],
              username: 'jana',
              gardenName: 'jardi1',
              gardenService: FakeGardenService.success(
                message: 'Planta plantada correctament',
              ),
              onPlantingSuccess: () {
                plantingSuccessCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Ocimum basilicum'));
      await tester.pump();

      await tester.tap(find.text('Plantar'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tancar'));
      await tester.pumpAndSettle();

      expect(plantingSuccessCalled, true);
    });
  });
}

GardenPot _buildPot() {
  return GardenPot(
    potNumber: 3,
    occupied: false,
    plant: null,
    growthPhase: null,
    healthLevel: null,
    waterLevel: null,
    plantedAt: null,
    lastWateredAt: null,
  );
}

/// Si el constructor real de SeedOption té més camps obligatoris,
/// afegeix-los aquí.
SeedOption _buildSeed({
  required String scientificName,
  required int amount,
}) {
  return SeedOption(
    scientificName: scientificName,
    amount: amount,
  );
}

class FakeGardenService extends GardenService {
  final Future<PlantingResult> Function() _handler;

  FakeGardenService._(this._handler);

  factory FakeGardenService.success({String message = 'Èxit'}) {
    return FakeGardenService._(() async {
      return _buildPlantingResult(message: message);
    });
  }

  factory FakeGardenService.delayedSuccess({String message = 'Èxit'}) {
    return FakeGardenService._(() async {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return _buildPlantingResult(message: message);
    });
  }

  factory FakeGardenService.error({required String message}) {
    return FakeGardenService._(() async {
      throw Exception(message);
    });
  }

  @override
  Future<PlantingResult> plantSeed({
    required String username,
    required String gardenName,
    required int potNumber,
    required String scientificName,
  }) {
    return _handler();
  }
}

PlantingResult _buildPlantingResult({
  required String message,
  String scientificName = 'Ocimum basilicum',
  int potNumber = 3,
}) {
  return PlantingResult(
    message: message,
    potNumber: potNumber,
    scientificName: scientificName,
  );
}*/

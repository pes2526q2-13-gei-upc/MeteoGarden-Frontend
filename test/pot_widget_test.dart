import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_garden/models/garden.dart';
import 'package:meteo_garden/widgets/pot_widget.dart';

void main() {
  group('PotWidget', () {
    testWidgets('mostra la planta i el nom si el test està ocupat', (
      WidgetTester tester,
    ) async {
      final pot = _buildPot(
        occupied: true,
        commonName: 'Tomàquet',
        scientificName: 'Solanum lycopersicum',
        imageUrl: '',
        waterLevel: 60,
      );

      await tester.pumpWidget(
        _wrapWithApp(
          SizedBox(
            width: 140,
            height: 140,
            child: PotWidget(
              pot: pot,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Tomàquet'), findsOneWidget);
      expect(find.byIcon(Icons.local_florist), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('no mostra planta ni barra si el test no està ocupat', (
      WidgetTester tester,
    ) async {
      final pot = GardenPot(
        potNumber: 1,
        occupied: false,
        plant: null,
        growthPhase: null,
        healthLevel: null,
        waterLevel: null,
        plantedAt: null,
        lastWateredAt: null,
      );

      await tester.pumpWidget(
        _wrapWithApp(
          SizedBox(
            width: 140,
            height: 140,
            child: PotWidget(
              pot: pot,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.byIcon(Icons.local_florist), findsNothing);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('mostra la barra d aigua si waterLevel no és null', (
      WidgetTester tester,
    ) async {
      final pot = _buildPot(
        occupied: true,
        commonName: 'Menta',
        scientificName: 'Mentha spicata',
        imageUrl: '',
        waterLevel: 75,
      );

      await tester.pumpWidget(
        _wrapWithApp(
          SizedBox(
            width: 140,
            height: 140,
            child: PotWidget(
              pot: pot,
              onTap: () {},
            ),
          ),
        ),
      );

      final progress = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );

      expect(progress.value, 0.75);
    });

    testWidgets('no mostra la barra d aigua si waterLevel és null', (
      WidgetTester tester,
    ) async {
      final pot = _buildPot(
        occupied: true,
        commonName: 'Lavanda',
        scientificName: 'Lavandula angustifolia',
        imageUrl: '',
        waterLevel: null,
      );

      await tester.pumpWidget(
        _wrapWithApp(
          SizedBox(
            width: 140,
            height: 140,
            child: PotWidget(
              pot: pot,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('crida onTap quan es prem el test', (
      WidgetTester tester,
    ) async {
      bool tapped = false;

      final pot = _buildPot(
        occupied: true,
        commonName: 'Clavell',
        scientificName: 'Dianthus caryophyllus',
        imageUrl: '',
        waterLevel: 40,
      );

      await tester.pumpWidget(
        _wrapWithApp(
          SizedBox(
            width: 140,
            height: 140,
            child: PotWidget(
              pot: pot,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('mostra icona fallback si no hi ha imageUrl', (
      WidgetTester tester,
    ) async {
      final pot = _buildPot(
        occupied: true,
        commonName: 'Roser',
        scientificName: 'Rosa canina',
        imageUrl: '',
        waterLevel: 50,
      );

      await tester.pumpWidget(
        _wrapWithApp(
          SizedBox(
            width: 140,
            height: 140,
            child: PotWidget(
              pot: pot,
              onTap: () {},
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.local_florist));
      expect(icon.color, Colors.yellow);
    });

    testWidgets('mostra Image.network si hi ha imageUrl', (
      WidgetTester tester,
    ) async {
      final pot = _buildPot(
        occupied: true,
        commonName: 'Roser',
        scientificName: 'Rosa canina',
        imageUrl: 'https://example.com/rosa.png',
        waterLevel: 50,
      );

      await tester.pumpWidget(
        _wrapWithApp(
          SizedBox(
            width: 140,
            height: 140,
            child: PotWidget(
              pot: pot,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsWidgets);
      expect(find.text('Roser'), findsOneWidget);
    });
  });
}

Widget _wrapWithApp(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Center(child: child),
    ),
  );
}

GardenPot _buildPot({
  required bool occupied,
  required String commonName,
  required String scientificName,
  required String imageUrl,
  required double? waterLevel,
}) {
  return GardenPot(
    potNumber: 1,
    occupied: occupied,
    growthPhase: 'growing',
    healthLevel: 90,
    waterLevel: waterLevel,
    plantedAt: DateTime(2026, 4, 20),
    lastWateredAt: DateTime(2026, 4, 22),
    plant: PlantData(
      scientificName: scientificName,
      commonName: commonName,
      family: 'TestFamily',
      canFlower: true,
      minTemperature: 10,
      maxTemperature: 30,
      imageUrl: imageUrl,
    ),
  );
}
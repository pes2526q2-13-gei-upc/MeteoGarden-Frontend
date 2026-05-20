import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_garden/models/garden.dart';
import 'package:meteo_garden/widgets/pot_widget.dart';

void main() {
  group('PotWidget', () {
    testWidgets('mostra la planta si el test està ocupat', (
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
            child: PotWidget(pot: pot, onTap: () {}),
          ),
        ),
      );

      expect(find.byIcon(Icons.local_florist), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.byKey(const Key('garden_pot_1_occupied')), findsOneWidget);
    });

    testWidgets('no mostra planta ni barra si el test no està ocupat', (
      WidgetTester tester,
    ) async {
      final pot = _buildEmptyPot();

      await tester.pumpWidget(
        _wrapWithApp(
          SizedBox(
            width: 140,
            height: 140,
            child: PotWidget(pot: pot, onTap: () {}),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.byIcon(Icons.local_florist), findsNothing);
      expect(find.byKey(const Key('garden_pot_1_empty')), findsOneWidget);
    });

    testWidgets('no mostra planta si occupied és true però plant és null', (
      WidgetTester tester,
    ) async {
      final pot = GardenPot(
        potNumber: 1,
        occupied: true,
        plant: null,
        growthPhase: null,
        healthLevel: null,
        waterLevel: 80,
        plantedAt: null,
        lastWateredAt: null,
      );

      await tester.pumpWidget(
        _wrapWithApp(
          SizedBox(
            width: 140,
            height: 140,
            child: PotWidget(pot: pot, onTap: () {}),
          ),
        ),
      );

      expect(find.byKey(const Key('garden_pot_1_empty')), findsOneWidget);
      expect(find.byIcon(Icons.local_florist), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('mostra la barra d’aigua si waterLevel no és null', (
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
            child: PotWidget(pot: pot, onTap: () {}),
          ),
        ),
      );

      final progress = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );

      expect(progress.value, 0.75);
    });

    testWidgets('clampa waterLevel per sota de 0 a 0', (
      WidgetTester tester,
    ) async {
      final pot = _buildPot(
        occupied: true,
        commonName: 'Menta',
        scientificName: 'Mentha spicata',
        imageUrl: '',
        waterLevel: -20,
      );

      await tester.pumpWidget(
        _wrapWithApp(
          SizedBox(
            width: 140,
            height: 140,
            child: PotWidget(pot: pot, onTap: () {}),
          ),
        ),
      );

      final progress = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );

      expect(progress.value, 0.0);
    });

    testWidgets('clampa waterLevel per sobre de 100 a 1', (
      WidgetTester tester,
    ) async {
      final pot = _buildPot(
        occupied: true,
        commonName: 'Menta',
        scientificName: 'Mentha spicata',
        imageUrl: '',
        waterLevel: 150,
      );

      await tester.pumpWidget(
        _wrapWithApp(
          SizedBox(
            width: 140,
            height: 140,
            child: PotWidget(pot: pot, onTap: () {}),
          ),
        ),
      );

      final progress = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );

      expect(progress.value, 1.0);
    });

    testWidgets('no mostra la barra d’aigua si waterLevel és null', (
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
            child: PotWidget(pot: pot, onTap: () {}),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.byIcon(Icons.local_florist), findsOneWidget);
    });

    testWidgets('crida onTap quan es prem el test ocupat', (
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

      await tester.tap(find.byKey(const Key('garden_pot_1_occupied')));
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('crida onTap quan es prem el test buit', (
      WidgetTester tester,
    ) async {
      bool tapped = false;

      final pot = _buildEmptyPot();

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

      await tester.tap(find.byKey(const Key('garden_pot_1_empty')));
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('mostra icona fallback groga si imageUrl és buit', (
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
            child: PotWidget(pot: pot, onTap: () {}),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.local_florist));

      expect(icon.color, Colors.yellow);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('mostra icona fallback groga si imageUrl és null', (
      WidgetTester tester,
    ) async {
      final pot = _buildPot(
        occupied: true,
        commonName: 'Roser',
        scientificName: 'Rosa canina',
        imageUrl: null,
        waterLevel: 50,
      );

      await tester.pumpWidget(
        _wrapWithApp(
          SizedBox(
            width: 140,
            height: 140,
            child: PotWidget(pot: pot, onTap: () {}),
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
            child: PotWidget(pot: pot, onTap: () {}),
          ),
        ),
      );

      final images = tester.widgetList<Image>(find.byType(Image)).toList();

      expect(images, isNotEmpty);
      expect(images.any((image) => image.image is NetworkImage), isTrue);
      expect(find.byIcon(Icons.local_florist), findsNothing);
      expect(find.byKey(const Key('garden_pot_1_occupied')), findsOneWidget);
    });

    testWidgets('mostra escut si el test té una poció activa', (
      WidgetTester tester,
    ) async {
      final pot = _buildPot(
        occupied: true,
        commonName: 'Menta',
        scientificName: 'Mentha spicata',
        imageUrl: '',
        waterLevel: 50,
        activeProducts: [
          ActivePotion(
            name: 'shield',
            displayName: 'Escut',
            appliedAt: DateTime.now().subtract(const Duration(minutes: 10)),
            expiresAt: DateTime.now().add(const Duration(hours: 1)),
          ),
        ],
      );

      await tester.pumpWidget(
        _wrapWithApp(
          SizedBox(
            width: 140,
            height: 140,
            child: PotWidget(pot: pot, onTap: () {}),
          ),
        ),
      );

      final assetImages = tester
          .widgetList<Image>(find.byType(Image))
          .where((image) => image.image is AssetImage)
          .map((image) => image.image as AssetImage)
          .toList();

      expect(
        assetImages.any(
          (image) => image.assetName == 'assets/images/escut.png',
        ),
        isTrue,
      );
    });

    testWidgets('no mostra escut si la poció està expirada', (
      WidgetTester tester,
    ) async {
      final pot = _buildPot(
        occupied: true,
        commonName: 'Menta',
        scientificName: 'Mentha spicata',
        imageUrl: '',
        waterLevel: 50,
        activeProducts: [
          ActivePotion(
            name: 'shield',
            displayName: 'Escut',
            appliedAt: DateTime.now().subtract(const Duration(hours: 2)),
            expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ],
      );

      await tester.pumpWidget(
        _wrapWithApp(
          SizedBox(
            width: 140,
            height: 140,
            child: PotWidget(pot: pot, onTap: () {}),
          ),
        ),
      );

      final assetImages = tester
          .widgetList<Image>(find.byType(Image))
          .where((image) => image.image is AssetImage)
          .map((image) => image.image as AssetImage)
          .toList();

      expect(
        assetImages.any(
          (image) => image.assetName == 'assets/images/escut.png',
        ),
        isFalse,
      );
    });
  });
}

Widget _wrapWithApp(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
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

GardenPot _buildPot({
  required bool occupied,
  required String commonName,
  required String scientificName,
  required String? imageUrl,
  required double? waterLevel,
  List<ActivePotion> activeProducts = const [],
}) {
  return GardenPot(
    potNumber: 1,
    occupied: occupied,
    growthPhase: 'growing',
    healthLevel: 90,
    waterLevel: waterLevel,
    plantedAt: DateTime(2026, 4, 20),
    lastWateredAt: DateTime(2026, 4, 22),
    activeProducts: activeProducts,
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
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:meteo_garden/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Login, identify plant from test image and show seed in inventory', (
    WidgetTester tester,
  ) async {
    const storage = FlutterSecureStorage();

    // Ens assegurem que el test comença sempre des de login.
    await storage.deleteAll();

    app.main();

    // Esperem que carregui LoginPage.
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.byKey(const Key('login_username_field')), findsOneWidget);
    expect(find.byKey(const Key('login_password_field')), findsOneWidget);
    expect(find.byKey(const Key('login_button')), findsOneWidget);

    // Login amb usuari de prova.
    await tester.enterText(
      find.byKey(const Key('login_username_field')),
      'j',
    );

    await tester.enterText(
      find.byKey(const Key('login_password_field')),
      'j',
    );

    await tester.tap(find.byKey(const Key('login_button')));

    // Esperem que faci login i entri a HomeShell.
    await tester.pumpAndSettle(const Duration(seconds: 10));

    // Anem a la pestanya de càmera.
    expect(
      find.byKey(const Key('nav_camera')),
      findsOneWidget,
      reason: 'HomeShell should show the camera navigation button.',
    );

    await tester.tap(find.byKey(const Key('nav_camera')));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Comprovem que som a la pantalla de càmera.
    expect(
      find.byKey(const Key('plant_camera_screen')),
      findsOneWidget,
      reason: 'Camera screen should be visible.',
    );

    // Identifiquem la imatge de prova.
    expect(
      find.byKey(const Key('identify_test_image_button')),
      findsOneWidget,
      reason: 'Camera screen should show the test image identification button.',
    );

    await tester.tap(find.byKey(const Key('identify_test_image_button')));

    // Pot trigar perquè fa crida al backend i possiblement a una API externa.
    await tester.pumpAndSettle(const Duration(seconds: 45));

    // Comprovem que s'ha obert la pantalla de resultat.
    expect(
      find.byKey(const Key('plant_result_page')),
      findsOneWidget,
      reason: 'After identifying the image, PlantResultPage should be shown.',
    );

    expect(
      find.byKey(const Key('plant_result_scientific_name')),
      findsOneWidget,
      reason: 'PlantResultPage should show the scientific name.',
    );

    // Llegim el nom científic identificat.
    final scientificNameText = tester.widget<Text>(
      find.byKey(const Key('plant_result_scientific_name')),
    );

    final scientificName = scientificNameText.data ?? '';

    expect(
      scientificName.isNotEmpty,
      isTrue,
      reason: 'The identified plant should have a scientific name.',
    );

    // Tornem a la pantalla de càmera.
    await tester.tap(find.byKey(const Key('plant_result_back_button')));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Tornem al jardí.
    await tester.tap(find.byKey(const Key('nav_garden')));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Obrim inventari des de GardenPage.
    expect(
      find.byKey(const Key('garden_inventory_button')),
      findsOneWidget,
      reason: 'GardenPage should show the inventory button.',
    );

    await tester.tap(find.byKey(const Key('garden_inventory_button')));
    await tester.pumpAndSettle(const Duration(seconds: 8));

    expect(find.byKey(const Key('inventory_title')), findsOneWidget);

    // Busquem la llavor corresponent al nom científic identificat.
    final seedFinder = find.byKey(Key('seed_card_$scientificName'));

    if (seedFinder.evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        seedFinder,
        300,
        scrollable: find.byKey(const Key('inventory_seeds_grid')),
      );
    }

    expect(
      seedFinder,
      findsOneWidget,
      reason:
          'After identifying the plant, the inventory should contain the seed $scientificName.',
    );
  });
}
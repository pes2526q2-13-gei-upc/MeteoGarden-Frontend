import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:meteo_garden/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Login, open an occupied pot and show pot detail', (
    WidgetTester tester,
  ) async {
    const storage = FlutterSecureStorage();

    // Ens assegurem que el test comença sempre des de login.
    await storage.deleteAll();

    app.main();

    // Esperem que carregui la pantalla de login.
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

    // Esperem que faci login i carregui GardenPage.
    await tester.pumpAndSettle(const Duration(seconds: 10));

    // Comprovem que hem arribat a GardenPage.
    expect(
      find.byKey(const Key('garden_inventory_button')),
      findsOneWidget,
      reason: 'After login, the app should open GardenPage.',
    );

    // Busquem un pot ocupat.
    final occupiedPotFinder = find.byWidgetPredicate((widget) {
      final key = widget.key;
      return key is ValueKey &&
          key.value.toString().startsWith('garden_pot_') &&
          key.value.toString().endsWith('_occupied');
    });

    expect(
      occupiedPotFinder,
      findsAtLeastNWidgets(1),
      reason: 'The garden should contain at least one occupied pot.',
    );

    // Cliquem el primer pot ocupat.
    await tester.tap(occupiedPotFinder.first);

    // Esperem que s'obri el bottom sheet amb el detall del pot.
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Comprovem que s'ha obert el detall de la planta.
    expect(
      find.byKey(const Key('pot_info_sheet')),
      findsOneWidget,
      reason: 'Tapping an occupied pot should open PotInfoSheet.',
    );

    // Comprovem que es mostra la informació de l'aigua.
    expect(
      find.byKey(const Key('plant_water_info')),
      findsOneWidget,
      reason: 'PotInfoSheet should show the plant water information.',
    );

    // Comprovem que es mostra la informació de salut/qualitat.
    expect(
      find.byKey(const Key('plant_health_info')),
      findsOneWidget,
      reason: 'PotInfoSheet should show the plant health information.',
    );

    // Comprovem que apareix el botó d'aplicar poció.
    expect(
      find.byKey(const Key('open_potion_selection_button')),
      findsOneWidget,
      reason: 'PotInfoSheet should show the apply potion button.',
    );

    // Comprovem que apareix el botó d'eliminar planta.
    expect(
      find.byKey(const Key('delete_plant_button')),
      findsOneWidget,
      reason: 'PotInfoSheet should show the delete plant button.',
    );

    // El botó de regar només apareix si la planta no està al 100%.
    final waterButton = find.byKey(const Key('water_plant_button'));

    if (waterButton.evaluate().isNotEmpty) {
      expect(
        waterButton,
        findsOneWidget,
        reason:
            'If the plant is not fully watered, the water button should be visible.',
      );
    }
  });
}
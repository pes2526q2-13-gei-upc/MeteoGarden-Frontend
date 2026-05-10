import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:meteo_garden/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Login, open inventory and show products', (
    WidgetTester tester,
  ) async {
    const storage = FlutterSecureStorage();

    // Ens assegurem que el test comença sempre des de login.
    await storage.deleteAll();

    app.main();

    // Esperem que carregui la pantalla inicial.
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Comprovem que el formulari de login existeix.
    expect(find.byKey(const Key('login_username_field')), findsOneWidget);
    expect(find.byKey(const Key('login_password_field')), findsOneWidget);
    expect(find.byKey(const Key('login_button')), findsOneWidget);

    // Omplim el login.
    await tester.enterText(find.byKey(const Key('login_username_field')), 'j');

    await tester.enterText(find.byKey(const Key('login_password_field')), 'j');

    await tester.tap(find.byKey(const Key('login_button')));

    // Esperem que faci login, carregui perfil i entri a GardenPage.
    await tester.pumpAndSettle(const Duration(seconds: 10));

    // Comprovem que som a GardenPage i que existeix la icona d'inventari.
    expect(
      find.byKey(const Key('garden_inventory_button')),
      findsOneWidget,
      reason:
          'After login, the app should open GardenPage and show the inventory button.',
    );

    // Obrim inventari.
    await tester.tap(find.byKey(const Key('garden_inventory_button')));
    await tester.pumpAndSettle(const Duration(seconds: 8));

    // Comprovem que s'ha obert la pantalla d'inventari.
    expect(find.byKey(const Key('inventory_title')), findsOneWidget);

    // Com que aquest usuari no té llavors, anem directament a la pestanya de pocions.
    expect(find.byKey(const Key('inventory_products_tab')), findsOneWidget);

    await tester.tap(find.byKey(const Key('inventory_products_tab')));
    await tester.pumpAndSettle(const Duration(seconds: 8));

    // Comprovem que el grid de productes/pocions existeix.
    expect(find.byKey(const Key('inventory_products_grid')), findsOneWidget);

    // Busquem almenys una card de producte/poció.
    final productCards = find.byWidgetPredicate((widget) {
      final key = widget.key;
      return key is ValueKey &&
          key.value.toString().startsWith('product_card_');
    });

    final hasProducts = productCards.evaluate().isNotEmpty;

    expect(
      hasProducts,
      isTrue,
      reason: 'Inventory should show at least one product or potion.',
    );
  });
}

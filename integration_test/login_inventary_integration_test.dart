import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Login, open inventory and show products', (
    WidgetTester tester,
  ) async {
    await ensureLoggedIn(tester);
    await openInventoryFromGarden(tester);

    expect(find.byKey(const Key('inventory_products_tab')), findsOneWidget);
    await tester.tap(find.byKey(const Key('inventory_products_tab')));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(
      find.byKey(const Key('inventory_products_grid')),
      findsOneWidget,
      reason: 'El grid de productes de l\'inventari hauria de ser visible.',
    );

    final productCards = find.byWidgetPredicate((widget) {
      final key = widget.key;
      return key != null && key.toString().contains('product_card_');
    });

    expect(
      productCards.evaluate().isNotEmpty,
      isTrue,
      reason: 'L\'inventari hauria de mostrar almenys un producte o pocio.',
    );
  });
}

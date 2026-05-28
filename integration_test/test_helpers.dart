import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_garden/main.dart' as app;

Future<void> _waitForGardenPage(WidgetTester tester) async {
  for (int i = 0; i < 40; i++) {
    await tester.pump(const Duration(milliseconds: 500));
    if (tester.any(find.byKey(const Key('garden_inventory_button')))) return;
  }
  expect(
    find.byKey(const Key('garden_inventory_button')),
    findsOneWidget,
    reason: 'GardenPage hauria de ser visible.',
  );
}

/// Assegura que l'usuari j/j està loguejat i a GardenPage.
/// Reutilitza la sessió si ja està al jardí per evitar reiniciar l'app
/// entre tests (providers async dispose).
Future<void> ensureLoggedIn(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 500));

  if (tester.any(find.byKey(const Key('garden_inventory_button')))) {
    return;
  }

  if (tester.any(find.byKey(const Key('login_button')))) {
    await tester.enterText(
      find.byKey(const Key('login_username_field')),
      'j',
    );
    await tester.enterText(
      find.byKey(const Key('login_password_field')),
      'j',
    );
    await tester.tap(find.byKey(const Key('login_button')));
    await _waitForGardenPage(tester);
    return;
  }

  if (tester.any(find.byKey(const Key('nav_garden')))) {
    await tester.tap(find.byKey(const Key('nav_garden')));
    await _waitForGardenPage(tester);
    return;
  }

  if (tester.any(find.byKey(const Key('shop_page'))) ||
      tester.any(find.byKey(const Key('album_page')))) {
    await returnToGardenPage(tester);
    return;
  }

  const storage = FlutterSecureStorage();
  await storage.deleteAll();
  app.main();

  for (int i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 500));
    if (tester.any(find.byKey(const Key('login_button')))) break;
  }

  expect(
    find.byKey(const Key('login_button')),
    findsOneWidget,
    reason: 'Amb storage buit hauria d\'apareixer la pantalla de login.',
  );

  await tester.enterText(
    find.byKey(const Key('login_username_field')),
    'j',
  );
  await tester.enterText(
    find.byKey(const Key('login_password_field')),
    'j',
  );
  await tester.tap(find.byKey(const Key('login_button')));
  await _waitForGardenPage(tester);
}

Future<void> waitForLoading(WidgetTester tester, {int maxSeconds = 15}) async {
  for (int i = 0; i < maxSeconds; i++) {
    if (!tester.any(find.byType(CircularProgressIndicator))) break;
    await tester.pump(const Duration(seconds: 1));
  }
  await tester.pumpAndSettle(const Duration(seconds: 1));
}

Finder gardenPotFinder(int potNumber, {required bool occupied}) {
  return find.byKey(
    Key('garden_pot_${potNumber}_${occupied ? 'occupied' : 'empty'}'),
  );
}

Future<void> waitForGardenPage(WidgetTester tester) async {
  await _waitForGardenPage(tester);
}

Future<void> waitForLoginScreen(WidgetTester tester) async {
  for (int i = 0; i < 40; i++) {
    await tester.pump(const Duration(milliseconds: 500));
    if (tester.any(find.byKey(const Key('login_button')))) return;
  }
  expect(
    find.byKey(const Key('login_button')),
    findsOneWidget,
    reason: 'La pantalla de login hauria de ser visible.',
  );
}

Future<void> _selectCityInDropdown(
  WidgetTester tester,
  Key dropdownKey,
  String cityName,
) async {
  final dropdown = find.byKey(dropdownKey);
  await tester.tap(dropdown);
  await tester.pumpAndSettle();

  final editable = find.descendant(
    of: dropdown,
    matching: find.byType(EditableText),
  );
  if (tester.any(editable)) {
    await tester.enterText(editable, cityName);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  }

  final cityOption = find.text(cityName);
  if (tester.any(cityOption)) {
    await tester.tap(cityOption.last);
    await tester.pumpAndSettle();
  }

  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
}

Future<void> selectProfileCity(WidgetTester tester, String cityName) async {
  await _selectCityInDropdown(
    tester,
    const Key('edit_profile_city_dropdown'),
    cityName,
  );
}

Future<void> selectRegisterCity(WidgetTester tester, String cityName) async {
  await _selectCityInDropdown(
    tester,
    const Key('register_city_dropdown'),
    cityName,
  );
}

/// Tanca modals/rutes fins tornar a GardenPage.
Future<void> returnToGardenPage(WidgetTester tester) async {
  for (int attempt = 0; attempt < 16; attempt++) {
    await tester.pump(const Duration(milliseconds: 500));

    final onGarden = tester.any(find.byKey(const Key('garden_inventory_button'))) &&
        !tester.any(find.byKey(const Key('shop_page'))) &&
        !tester.any(find.byKey(const Key('album_page'))) &&
        !tester.any(find.byType(BottomSheet));
    if (onGarden) {
      await tester.pumpAndSettle(const Duration(seconds: 1));
      return;
    }

    if (tester.any(find.byType(BottomSheet))) {
      final navigators = find.byType(Navigator);
      if (navigators.evaluate().isNotEmpty) {
        final nav = tester.state<NavigatorState>(navigators.last);
        if (nav.canPop()) {
          nav.pop();
          await tester.pumpAndSettle(const Duration(seconds: 2));
          continue;
        }
      }
    }

    final backButton = find.byWidgetPredicate(
      (widget) =>
          widget is Icon &&
          (widget.icon == Icons.arrow_back ||
              widget.icon == Icons.arrow_back_rounded),
    );
    if (tester.any(backButton)) {
      await tester.tap(backButton.first, warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      continue;
    }

    final navigators = find.byType(Navigator);
    if (navigators.evaluate().isNotEmpty) {
      final nav = tester.state<NavigatorState>(navigators.last);
      if (nav.canPop()) {
        nav.pop();
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
    }
  }
}

Future<void> openShopFromGarden(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('garden_shop_button')));
  for (int i = 0; i < 40; i++) {
    await tester.pump(const Duration(milliseconds: 500));
    if (tester.any(find.byKey(const Key('shop_page')))) return;
  }
  expect(
    find.byKey(const Key('shop_page')),
    findsOneWidget,
    reason: 'La botiga hauria d\'obrir-se des del jardi.',
  );
}

Future<void> openAlbumFromGarden(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('garden_album_button')));
  for (int i = 0; i < 40; i++) {
    await tester.pump(const Duration(milliseconds: 500));
    if (tester.any(find.byKey(const Key('album_page')))) return;
  }
  expect(
    find.byKey(const Key('album_page')),
    findsOneWidget,
    reason: 'L\'album hauria d\'obrir-se des del jardi.',
  );
  await waitForLoading(tester);
}

Future<void> openInventoryFromGarden(WidgetTester tester) async {
  await returnToGardenPage(tester);

  final inventoryButton = find.byKey(const Key('garden_inventory_button'));
  expect(inventoryButton, findsOneWidget);
  await tester.ensureVisible(inventoryButton);
  await tester.pumpAndSettle();
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await tester.tap(inventoryButton, warnIfMissed: false);

  for (int i = 0; i < 24; i++) {
    await tester.pump(const Duration(milliseconds: 500));
    if (tester.any(find.byKey(const Key('inventory_title')))) break;
  }

  expect(
    find.byKey(const Key('inventory_title')),
    findsOneWidget,
    reason: 'S\'hauria d\'obrir la pàgina d\'inventari.',
  );
}

Future<void> tapGardenPot(
  WidgetTester tester,
  int potNumber, {
  required bool occupied,
}) async {
  await waitForLoading(tester);
  await Future.delayed(const Duration(seconds: 2));
  await tester.pumpAndSettle();

  final pot = gardenPotFinder(potNumber, occupied: occupied);
  expect(pot, findsOneWidget);
  await tester.ensureVisible(pot);
  await tester.pumpAndSettle();
  await tester.tap(pot);
  await tester.pumpAndSettle(const Duration(seconds: 5));
}

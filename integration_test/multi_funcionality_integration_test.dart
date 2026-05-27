import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:meteo_garden/main.dart' as app;

// ─────────────────────────────────────────────────────────────────────────────
// HELPER: assegura que l'usuari està loguejat i a GardenPage.
// ─────────────────────────────────────────────────────────────────────────────
Future<void> _ensureLoggedIn(WidgetTester tester) async {
  app.main();
  await tester.pumpAndSettle(const Duration(seconds: 8));

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
    await tester.pumpAndSettle(const Duration(seconds: 10));
  }

  expect(
    find.byKey(const Key('garden_inventory_button')),
    findsOneWidget,
    reason: 'S\'hauria de veure GardenPage després del login.',
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPER: obre la botiga i espera que carregui.
// Com que ShopPage no té keys, detectem que ha obert comprovant que
// GardenPage ja no és visible (garden_inventory_button desapareix)
// i que hi ha un TabBar a la pantalla (el selector Llavors / Altres).
// ─────────────────────────────────────────────────────────────────────────────
Future<void> _openShop(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('garden_shop_button')));
  await tester.pumpAndSettle(const Duration(seconds: 8));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ───────────────────────────────────────────────────────────────────────────
  // TEST 1: Navegació entre pestanyes del menú inferior
  // ───────────────────────────────────────────────────────────────────────────
  testWidgets('Navegació entre pestanyes principals (nav bar)', (
    WidgetTester tester,
  ) async {
    await _ensureLoggedIn(tester);

    await tester.tap(find.byKey(const Key('nav_profile')));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(
      find.byKey(const Key('profile_page')),
      findsOneWidget,
      reason: 'La pestanya de perfil hauria de mostrar PerfilPage.',
    );

    await tester.tap(find.byKey(const Key('nav_garden')));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(
      find.byKey(const Key('garden_inventory_button')),
      findsOneWidget,
      reason: 'La pestanya del jardí hauria de tornar a GardenPage.',
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // TEST 2: Obrir la botiga i veure llavors i productes
  // ───────────────────────────────────────────────────────────────────────────
  testWidgets('Obrir botiga, veure llavors i canviar a productes', (
    WidgetTester tester,
  ) async {
    await _ensureLoggedIn(tester);
    await _openShop(tester);

    // La botiga no té keys, però sempre té un TabBar amb dues pestanyes.
    // Comprovem que GardenPage ja no és visible i que el TabBar existeix.
    expect(
      find.byKey(const Key('garden_inventory_button')),
      findsNothing,
      reason: 'Un cop oberta la botiga, GardenPage no hauria de ser visible.',
    );
    expect(
      find.byType(TabBar),
      findsOneWidget,
      reason: 'La botiga hauria de mostrar el TabBar de llavors/productes.',
    );

    // Els tabs es troben pel seu text (no per key)
    final seedsTab = find.byType(Tab).first;
    final productsTab = find.byType(Tab).last;

    // Pestanya de llavors
    await tester.tap(seedsTab);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Ha d'haver almenys un ListView o el missatge de buit
    final hasItems = tester.any(find.byType(ListView));
    expect(
      hasItems || tester.any(find.byType(Center)),
      isTrue,
      reason: 'La pestanya de llavors hauria de mostrar contingut.',
    );

    // Pestanya de productes
    await tester.tap(productsTab);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(
      tester.any(find.byType(ListView)) || tester.any(find.byType(Center)),
      isTrue,
      reason: 'La pestanya de productes hauria de mostrar contingut.',
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // TEST 3: Obrir detall d'un article i cancel·lar la compra
  // ───────────────────────────────────────────────────────────────────────────
  testWidgets('Obrir detall d\'un article de la botiga i cancel·lar', (
    WidgetTester tester,
  ) async {
    await _ensureLoggedIn(tester);
    await _openShop(tester);

    // Esperem que la llista carregui
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Comprovem que hi ha un ListView (la llista d'articles)
    final listView = find.byType(ListView);
    if (!tester.any(listView)) return; // botiga buida, saltem

    // Busquem els InkWell que són fills directes del ListView.
    // Això evita agafar el botó de tornar del header, que també és un IconButton
    // i no un InkWell dins de la llista.
    final itemsInList = find.descendant(
      of: listView,
      matching: find.byType(InkWell),
    );

    if (itemsInList.evaluate().isEmpty) return; // no hi ha articles, saltem

    // Fem scroll per assegurar-nos que el primer article és visible
    await tester.ensureVisible(itemsInList.first);
    await tester.pumpAndSettle();

    await tester.tap(itemsInList.first);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // El bottom sheet de detalls sempre té dos botons: Tornar i Comprar.
    // OutlinedButton = cancel·lar, FilledButton = comprar.
    expect(
      find.byType(FilledButton),
      findsOneWidget,
      reason: 'El bottom sheet hauria de mostrar el botó de compra.',
    );
    expect(
      find.byType(OutlinedButton),
      findsOneWidget,
      reason: 'El bottom sheet hauria de mostrar el botó de cancel·lar.',
    );

    // Cancel·lem
    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // El bottom sheet s'ha de tancar: FilledButton ja no és visible
    expect(
      find.byType(FilledButton),
      findsNothing,
      reason: 'El bottom sheet s\'hauria de tancar en prémer cancel·lar.',
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // TEST 4: Àlbum - obrir i veure plantes col·leccionades
  // ───────────────────────────────────────────────────────────────────────────
  testWidgets('Obrir àlbum i veure plantes col·leccionades', (
    WidgetTester tester,
  ) async {
    await _ensureLoggedIn(tester);

    await tester.tap(find.byKey(const Key('garden_album_button')));
    await tester.pumpAndSettle(const Duration(seconds: 8));

    expect(
      find.byKey(const Key('album_page')),
      findsOneWidget,
      reason: 'S\'hauria d\'obrir AlbumPage.',
    );

    final hasGrid = tester.any(find.byKey(const Key('album_grid')));
    final hasEmptyState =
        tester.any(find.byKey(const Key('album_empty_state')));

    expect(
      hasGrid || hasEmptyState,
      isTrue,
      reason: 'L\'àlbum hauria de mostrar el grid o el missatge de buit.',
    );

    if (hasGrid) {
      final plantCards = find.byWidgetPredicate((widget) {
        final key = widget.key;
        return key is ValueKey &&
            key.value.toString().startsWith('album_card_');
      });
      expect(
        plantCards.evaluate().isNotEmpty,
        isTrue,
        reason: 'El grid hauria de tenir almenys una planta.',
      );
    }
  });

  // ───────────────────────────────────────────────────────────────────────────
  // TEST 5: Àlbum - obrir el detall d'una planta i tancar-lo
  // ───────────────────────────────────────────────────────────────────────────
  testWidgets('Obrir detall d\'una planta de l\'àlbum i tancar-lo', (
    WidgetTester tester,
  ) async {
    await _ensureLoggedIn(tester);

    await tester.tap(find.byKey(const Key('garden_album_button')));
    await tester.pumpAndSettle(const Duration(seconds: 8));

    if (!tester.any(find.byKey(const Key('album_grid')))) return;

    await tester.tap(find.byKey(const ValueKey('album_card_0')));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(
      find.byKey(const Key('album_plant_detail_dialog')),
      findsOneWidget,
      reason: 'Hauria d\'aparèixer el dialog amb els detalls de la planta.',
    );

    await tester.tap(find.byKey(const Key('album_detail_close_button')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(
      find.byKey(const Key('album_plant_detail_dialog')),
      findsNothing,
      reason: 'El dialog s\'hauria de tancar.',
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // TEST 6: El grid de macetes del jardí mostra macetes
  // ───────────────────────────────────────────────────────────────────────────
  testWidgets('El grid de macetes del jardí mostra macetes', (
    WidgetTester tester,
  ) async {
    await _ensureLoggedIn(tester);

    expect(
      find.byKey(const Key('garden_pots_grid')),
      findsOneWidget,
      reason: 'GardenPage hauria de mostrar el grid de macetes.',
    );

    final potWidgets = find.byWidgetPredicate((widget) {
      final key = widget.key;
      return key is ValueKey &&
          key.value.toString().startsWith('pot_widget_');
    });

    expect(
      potWidgets.evaluate().isNotEmpty,
      isTrue,
      reason: 'El jardí hauria de tenir almenys una maceta visible.',
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // TEST 7: Tap a una maceta obre el bottom sheet corresponent
  // ───────────────────────────────────────────────────────────────────────────
  testWidgets('Tap a una maceta obre el PotInfoSheet o SeedSelectionSheet', (
    WidgetTester tester,
  ) async {
    await _ensureLoggedIn(tester);

    final potWidgets = find.byWidgetPredicate((widget) {
      final key = widget.key;
      return key is ValueKey &&
          key.value.toString().startsWith('pot_widget_');
    });

    if (potWidgets.evaluate().isEmpty) return;

    await tester.tap(potWidgets.first);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(
      tester.any(find.byType(BottomSheet)) ||
          tester.any(find.byType(DraggableScrollableSheet)) ||
          tester.any(find.byType(AlertDialog)),
      isTrue,
      reason:
          'Fer tap a una maceta hauria d\'obrir el full d\'informació o selecció de llavor.',
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // TEST 8: Logout des de PerfilPage
  // ───────────────────────────────────────────────────────────────────────────
  testWidgets('Logout des de la pàgina de perfil', (
    WidgetTester tester,
  ) async {
    await _ensureLoggedIn(tester);

    await tester.tap(find.byKey(const Key('nav_profile')));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.byKey(const Key('profile_page')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('logout_button')),
      200,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('logout_button')));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(
      find.byKey(const Key('login_button')),
      findsOneWidget,
      reason: 'Després del logout s\'hauria de mostrar la pantalla de login.',
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // TEST 9: Flux complet — jardí → botiga → àlbum → perfil → logout
  // ───────────────────────────────────────────────────────────────────────────
  testWidgets('Flux complet: jardí → botiga → àlbum → perfil → logout', (
    WidgetTester tester,
  ) async {
    const storage = FlutterSecureStorage();
    await storage.deleteAll();

    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    await tester.enterText(
      find.byKey(const Key('login_username_field')),
      'j',
    );
    await tester.enterText(
      find.byKey(const Key('login_password_field')),
      'j',
    );
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle(const Duration(seconds: 10));

    expect(find.byKey(const Key('garden_inventory_button')), findsOneWidget);

    // 1. Botiga — detectem que ha obert perquè apareix un TabBar
    await _openShop(tester);
    expect(
      find.byType(TabBar),
      findsOneWidget,
      reason: 'La botiga hauria de mostrar el TabBar.',
    );
    final NavigatorState navigator = tester.state(find.byType(Navigator).last);
    navigator.pop();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // 2. Àlbum
    await tester.tap(find.byKey(const Key('garden_album_button')));
    await tester.pumpAndSettle(const Duration(seconds: 6));
    expect(find.byKey(const Key('album_page')), findsOneWidget);
    navigator.pop();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // 3. Perfil
    await tester.tap(find.byKey(const Key('nav_profile')));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.byKey(const Key('profile_page')), findsOneWidget);

    // 4. Logout
    await tester.scrollUntilVisible(
      find.byKey(const Key('logout_button')),
      200,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('logout_button')));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(
      find.byKey(const Key('login_button')),
      findsOneWidget,
      reason: 'El flux complet hauria d\'acabar a la pantalla de login.',
    );
  });
}
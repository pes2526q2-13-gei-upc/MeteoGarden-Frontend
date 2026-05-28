import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ---------------------------------------------------------------------------
  // TEST 1: Navegacio entre pestanyes del menu inferior
  // ---------------------------------------------------------------------------
  testWidgets('Navegació entre pestanyes principals (nav bar)', (
    WidgetTester tester,
  ) async {
    await ensureLoggedIn(tester);

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
      reason: 'La pestanya del jardi hauria de tornar a GardenPage.',
    );
  });

  // ---------------------------------------------------------------------------
  // TEST 2: Obrir la botiga i veure llavors i productes
  // ---------------------------------------------------------------------------
  testWidgets('Obrir botiga, veure llavors i canviar a productes', (
    WidgetTester tester,
  ) async {
    await ensureLoggedIn(tester);
    await openShopFromGarden(tester);

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

    final seedsTab = find.byType(Tab).first;
    final productsTab = find.byType(Tab).last;

    await tester.tap(seedsTab);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(
      tester.any(find.byType(ListView)) || tester.any(find.byType(Center)),
      isTrue,
      reason: 'La pestanya de llavors hauria de mostrar contingut.',
    );

    await tester.tap(productsTab);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(
      tester.any(find.byType(ListView)) || tester.any(find.byType(Center)),
      isTrue,
      reason: 'La pestanya de productes hauria de mostrar contingut.',
    );
  });

  // ---------------------------------------------------------------------------
  // TEST 3: Obrir detall d'un article i cancel·lar la compra
  // ---------------------------------------------------------------------------
  testWidgets('Obrir detall d\'un article de la botiga i cancel·lar', (
    WidgetTester tester,
  ) async {
    await ensureLoggedIn(tester);
    await openShopFromGarden(tester);
    await waitForLoading(tester);

    final listView = find.byType(ListView);
    if (!tester.any(listView)) return;

    final itemsInList = find.descendant(
      of: listView,
      matching: find.byType(InkWell),
    );
    if (itemsInList.evaluate().isEmpty) return;

    await tester.ensureVisible(itemsInList.first);
    await tester.pumpAndSettle();
    await tester.tap(itemsInList.first);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.byType(OutlinedButton), findsOneWidget);

    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.byType(FilledButton), findsNothing);
  });

  // ---------------------------------------------------------------------------
  // TEST 4: Album - obrir i veure plantes colleccionades
  // ---------------------------------------------------------------------------
  testWidgets('Obrir àlbum i veure plantes col·leccionades', (
    WidgetTester tester,
  ) async {
    await ensureLoggedIn(tester);
    await openAlbumFromGarden(tester);

    final hasGrid = tester.any(find.byKey(const Key('album_grid')));
    final hasEmptyState =
        tester.any(find.byKey(const Key('album_empty_state')));

    expect(
      hasGrid || hasEmptyState,
      isTrue,
      reason: 'L\'album hauria de mostrar el grid o el missatge de buit.',
    );

    if (hasGrid) {
      final plantCards = find.byWidgetPredicate((widget) {
        final key = widget.key;
        return key != null && key.toString().contains('album_card_');
      });
      expect(
        plantCards.evaluate().isNotEmpty,
        isTrue,
        reason: 'El grid hauria de tenir almenys una planta.',
      );
    }
  });

  // ---------------------------------------------------------------------------
  // TEST 5: Album - obrir el detall d'una planta i tancar-lo
  // ---------------------------------------------------------------------------
  testWidgets('Obrir detall d\'una planta de l\'àlbum i tancar-lo', (
    WidgetTester tester,
  ) async {
    await ensureLoggedIn(tester);
    await openAlbumFromGarden(tester);

    if (!tester.any(find.byKey(const Key('album_grid')))) return;

    await tester.tap(find.byKey(const Key('album_card_0')));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(
      find.byKey(const Key('album_plant_detail_dialog')),
      findsOneWidget,
      reason: 'Hauria d\'apareixer el dialog amb els detalls de la planta.',
    );

    await tester.tap(find.byKey(const Key('album_detail_close_button')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(
      find.byKey(const Key('album_plant_detail_dialog')),
      findsNothing,
      reason: 'El dialog s\'hauria de tancar.',
    );
  });

  // ---------------------------------------------------------------------------
  // TEST 6: El grid de macetes del jardi mostra macetes
  // ---------------------------------------------------------------------------
  testWidgets('El grid de macetes del jardí mostra macetes', (
    WidgetTester tester,
  ) async {
    await ensureLoggedIn(tester);
    await waitForLoading(tester);

    for (int i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (tester.any(find.byKey(const Key('garden_pots_grid')))) break;
    }

    expect(
      find.byKey(const Key('garden_pots_grid')),
      findsOneWidget,
      reason: 'GardenPage hauria de mostrar el grid de macetes.',
    );

    final potWidgets = find.byWidgetPredicate((widget) {
      final key = widget.key;
      return key != null && key.toString().contains('garden_pot_');
    });

    expect(
      potWidgets.evaluate().isNotEmpty,
      isTrue,
      reason: 'El jardi hauria de tenir almenys una maceta visible.',
    );
  });

  // ---------------------------------------------------------------------------
  // TEST 7: Tap a una maceta obre el bottom sheet corresponent
  // ---------------------------------------------------------------------------
  testWidgets('Tap a una maceta obre el PotInfoSheet o SeedSelectionSheet', (
    WidgetTester tester,
  ) async {
    await ensureLoggedIn(tester);
    await waitForLoading(tester);

    final potWidgets = find.byWidgetPredicate((widget) {
      final key = widget.key;
      return key != null && key.toString().contains('garden_pot_');
    });

    if (potWidgets.evaluate().isEmpty) return;

    await tester.ensureVisible(potWidgets.first);
    await tester.pumpAndSettle();
    await tester.tap(potWidgets.first);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(
      tester.any(find.byType(BottomSheet)) ||
          tester.any(find.byType(DraggableScrollableSheet)) ||
          tester.any(find.byKey(const Key('pot_info_sheet'))),
      isTrue,
      reason:
          'Fer tap a una maceta hauria d\'obrir el full d\'informacio o seleccio de llavor.',
    );
  });

  // ---------------------------------------------------------------------------
  // TEST 8: Logout des de PerfilPage
  // ---------------------------------------------------------------------------
  testWidgets('Logout des de la pàgina de perfil', (
    WidgetTester tester,
  ) async {
    await ensureLoggedIn(tester);

    await tester.tap(find.byKey(const Key('nav_profile')));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.byKey(const Key('profile_page')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('logout_button')),
      200,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('logout_button')));

    await waitForLoginScreen(tester);
  });

  // ---------------------------------------------------------------------------
  // TEST 9: Flux complet - jardi -> botiga -> album -> perfil -> logout
  // ---------------------------------------------------------------------------
  testWidgets('Flux complet: jardí → botiga → àlbum → perfil → logout', (
    WidgetTester tester,
  ) async {
    await ensureLoggedIn(tester);

    await openShopFromGarden(tester);
    expect(find.byType(TabBar), findsOneWidget);
    await returnToGardenPage(tester);

    await openAlbumFromGarden(tester);
    expect(find.byKey(const Key('album_page')), findsOneWidget);

    final backButton = find.byWidgetPredicate(
      (widget) =>
          widget is Icon &&
          (widget.icon == Icons.arrow_back ||
              widget.icon == Icons.arrow_back_rounded),
    );
    if (tester.any(backButton)) {
      await tester.tap(backButton.first, warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    } else {
      final navigators = find.byType(Navigator);
      if (navigators.evaluate().isNotEmpty) {
        final nav = tester.state<NavigatorState>(navigators.last);
        if (nav.canPop()) {
          nav.pop();
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      }
    }

    await tester.tap(find.byKey(const Key('nav_profile')));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.byKey(const Key('profile_page')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('logout_button')),
      200,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('logout_button')));

    await waitForLoginScreen(tester);
  });
}

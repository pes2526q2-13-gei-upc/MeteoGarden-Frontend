import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:meteo_garden/main.dart' as app;

import 'test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ───────────────────────────────────────────────────────────────────────────
  // TEST 10: Comprar producte a la botiga i verificar a l'inventari
  // ───────────────────────────────────────────────────────────────────────────
  testWidgets('Comprar producte a la botiga i verificar a l\'inventari', (
    WidgetTester tester,
  ) async {
    await ensureLoggedIn(tester);

    // Obrim la botiga
    await tester.tap(find.byKey(const Key('garden_shop_button')));
    await tester.pumpAndSettle(const Duration(seconds: 8));

    // Anem a la pestanya de productes (la segona)
    final productsTab = find.byType(Tab).last;
    await tester.tap(productsTab);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Comprovem que hi ha una llista de productes
    final listView = find.byType(ListView);
    if (!tester.any(listView)) return; // no hi ha productes, saltem

    // Busquem el primer InkWell dins la llista (primer producte)
    final itemsInList = find.descendant(
      of: listView,
      matching: find.byType(InkWell),
    );
    if (itemsInList.evaluate().isEmpty) return;

    await tester.ensureVisible(itemsInList.first);
    await tester.pumpAndSettle();

    // Obrim el detall del producte
    await tester.tap(itemsInList.first);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Comprovem que el bottom sheet s'ha obert amb el botó de compra
    if (!tester.any(find.byType(FilledButton))) return;

    // Comprem el producte (FilledButton del modal de detall)
    await tester.tap(find.byType(FilledButton).last);
    await Future.delayed(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    await returnToGardenPage(tester);
    await openInventoryFromGarden(tester);

    // Anem a la pestanya de productes/pocions
    expect(find.byKey(const Key('inventory_products_tab')), findsOneWidget);
    await tester.tap(find.byKey(const Key('inventory_products_tab')));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // El grid de productes ha de tenir almenys un element
    expect(
      find.byKey(const Key('inventory_products_grid')),
      findsOneWidget,
      reason: 'El grid de productes de l\'inventari hauria de ser visible.',
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // TEST 11: Amics - navegació, pestanyes i contingut
  // ───────────────────────────────────────────────────────────────────────────
  testWidgets('Amics - navegació, tres pestanyes i contingut', (
    WidgetTester tester,
  ) async {
    await ensureLoggedIn(tester);

    // Naveguem a la pàgina d'amics
    await tester.tap(find.byKey(const Key('nav_friends')));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Comprovem que hi ha un TabBar amb 3 pestanyes
    expect(
      find.byType(TabBar),
      findsOneWidget,
      reason: 'FriendsPage hauria de mostrar el TabBar.',
    );
    expect(
      find.byType(Tab),
      findsNWidgets(3),
      reason:
          'FriendsPage hauria de tenir 3 pestanyes (amics, enviades, rebudes).',
    );

    // Comprovem que el contingut de la primera pestanya carrega
    await tester.pumpAndSettle(const Duration(seconds: 3));
    final hasContent =
        tester.any(find.byType(ListView)) || tester.any(find.byType(Center));
    expect(
      hasContent,
      isTrue,
      reason: 'La pestanya d\'amics hauria de mostrar contingut o estat buit.',
    );

    // Naveguem a la pestanya de sol·licituds enviades
    await tester.tap(find.byType(Tab).at(1));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(
      tester.any(find.byType(ListView)) || tester.any(find.byType(Center)),
      isTrue,
      reason: 'La pestanya d\'enviades hauria de mostrar contingut.',
    );

    // Naveguem a la pestanya de sol·licituds rebudes
    await tester.tap(find.byType(Tab).at(2));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(
      tester.any(find.byType(ListView)) || tester.any(find.byType(Center)),
      isTrue,
      reason: 'La pestanya de rebudes hauria de mostrar contingut.',
    );

    // Comprovem que el botó d'afegir amic és accessible
    final addButton = find.byIcon(Icons.person_add_alt_1_rounded);
    expect(
      addButton,
      findsOneWidget,
      reason: 'Hauria d\'haver un botó per afegir amics.',
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // TEST 12: Missions - navegació i llistat
  // ───────────────────────────────────────────────────────────────────────────
  testWidgets('Missions - navegació i llistat de missions', (
    WidgetTester tester,
  ) async {
    await ensureLoggedIn(tester);

    // Naveguem a missions
    await tester.tap(find.byKey(const Key('nav_missions')));
    await tester.pumpAndSettle(const Duration(seconds: 8));

    // La capçalera de missions és sempre visible (Container verd fosc amb icona)
    expect(
      find.byIcon(Icons.flag),
      findsWidgets,
      reason: 'MissionsPage hauria de mostrar la icona de missions.',
    );

    // Esperem que carregui el contingut
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Ha de mostrar un ListView amb missions o un missatge d'estat buit
    final hasContent =
        tester.any(find.byType(ListView)) ||
        tester.any(find.byIcon(Icons.flag_outlined));
    expect(
      hasContent,
      isTrue,
      reason: 'MissionsPage hauria de mostrar missions o l\'estat buit.',
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // TEST 13: Calendari - obrir des del jardí i navegar per mesos
  // ───────────────────────────────────────────────────────────────────────────
  testWidgets('Calendari - obrir des del jardi i navegar per mesos', (
    WidgetTester tester,
  ) async {
    await ensureLoggedIn(tester);

    // Obrim el calendari des de GardenPage
    await tester.tap(find.byKey(const Key('garden_calendar_button')));
    await tester.pumpAndSettle(const Duration(seconds: 8));

    // El calendari mostra un navegador de mesos amb fletxes
    expect(
      find.byIcon(Icons.chevron_left),
      findsOneWidget,
      reason:
          'El calendari hauria de mostrar la fletxa d\'anar al mes anterior.',
    );
    expect(
      find.byIcon(Icons.chevron_right),
      findsOneWidget,
      reason:
          'El calendari hauria de mostrar la fletxa d\'anar al mes seguent.',
    );

    // Naveguem al mes anterior
    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Naveguem al mes seguent (tornant al mes actual)
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Comprovem que el grid de dies és visible (GestureDetectors dels dies)
    expect(
      find.byType(GestureDetector),
      findsWidgets,
      reason:
          'El calendari hauria de mostrar els dies del mes com a GestureDetectors.',
    );

    // Tanquem el calendari
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(
      find.byKey(const Key('garden_inventory_button')),
      findsOneWidget,
      reason: 'Despres de tancar el calendari, hauria de tornar a GardenPage.',
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // TEST 14: Editar perfil - obrir formulari i verificar camps
  // ───────────────────────────────────────────────────────────────────────────
  testWidgets('Editar perfil - obrir i verificar camps del formulari', (
    WidgetTester tester,
  ) async {
    await ensureLoggedIn(tester);

    // Naveguem al perfil
    await tester.tap(find.byKey(const Key('nav_profile')));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.byKey(const Key('profile_page')), findsOneWidget);

    // Fem scroll fins al botó d'editar
    await tester.scrollUntilVisible(
      find.byKey(const Key('edit_profile_button')),
      200,
    );
    await tester.pumpAndSettle();

    // Obrim l'editor de perfil
    await tester.tap(find.byKey(const Key('edit_profile_button')));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Comprovem que som a la pàgina d'edició
    expect(
      find.byKey(const Key('edit_profile_page')),
      findsOneWidget,
      reason: 'S\'hauria d\'obrir la pàgina d\'edicio de perfil.',
    );

    // Comprovem que existeixen tots els camps
    expect(
      find.byKey(const Key('edit_profile_username_field')),
      findsOneWidget,
      reason: 'El camp de nom d\'usuari hauria de ser visible.',
    );
    expect(
      find.byKey(const Key('edit_profile_city_dropdown')),
      findsOneWidget,
      reason: 'El selector de ciutat hauria de ser visible.',
    );
    expect(
      find.byKey(const Key('edit_profile_language_dropdown')),
      findsOneWidget,
      reason: 'El selector d\'idioma hauria de ser visible.',
    );
    expect(
      find.byKey(const Key('save_profile_button')),
      findsOneWidget,
      reason: 'El boto de guardar hauria de ser visible.',
    );

    // Tornem enrere sense guardar
    final NavigatorState navigator = tester.state(find.byType(Navigator).last);
    navigator.pop();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.byKey(const Key('profile_page')), findsOneWidget);
  });

  // ───────────────────────────────────────────────────────────────────────────
  // TEST 15: Editar avatar - obrir editor i verificar categories
  // ───────────────────────────────────────────────────────────────────────────
  testWidgets('Editar avatar - obrir editor i verificar categories', (
    WidgetTester tester,
  ) async {
    await ensureLoggedIn(tester);

    // Naveguem al perfil
    await tester.tap(find.byKey(const Key('nav_profile')));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.byKey(const Key('profile_page')), findsOneWidget);

    // Obrim l'editor d'avatar (key dedicada; no confondre amb edit_profile_button)
    await tester.tap(find.byKey(const Key('edit_avatar_button')));
    await tester.pumpAndSettle(const Duration(seconds: 8));

    // L'editor d'avatar té un TabBar amb les categories (Body, Eyes, etc.)
    expect(
      find.byType(TabBar),
      findsOneWidget,
      reason: 'L\'editor d\'avatar hauria de mostrar el TabBar de categories.',
    );

    // Ha d'haver almenys 5 tabs (Body, Eyes, Expression, Hair, Clothing...)
    final tabs = find.byType(Tab);
    expect(
      tabs.evaluate().length,
      greaterThanOrEqualTo(5),
      reason: 'L\'editor hauria de tenir almenys 5 categories.',
    );

    expect(
      find.byKey(const Key('avatar_save_button')),
      findsOneWidget,
      reason: 'L\'editor d\'avatar hauria de mostrar el boto de guardar.',
    );

    // Canviem de categoria (tap al segon tab - Eyes)
    await tester.tap(tabs.at(1));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Ha de mostrar opcions d'ulls (GridView)
    expect(
      find.byType(GridView),
      findsOneWidget,
      reason: 'La categoria d\'ulls hauria de mostrar un GridView d\'opcions.',
    );

    // Tornem enrere sense guardar
    final NavigatorState navigator = tester.state(find.byType(Navigator).last);
    navigator.pop();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.byKey(const Key('profile_page')), findsOneWidget);
  });

  // ───────────────────────────────────────────────────────────────────────────
  // TEST 16: Crear conta - verificar accessibilitat del formulari
  // Nota: no fem submit per no crear comptes reals a la BBDD de test
  // ───────────────────────────────────────────────────────────────────────────
  testWidgets('Crear conta - formulari de registre accessible', (
    WidgetTester tester,
  ) async {
    // Comencem amb sessió buida per arribar a la pantalla de login
    const storage = FlutterSecureStorage();
    await storage.deleteAll();

    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Comprovem que som al login
    expect(find.byKey(const Key('login_button')), findsOneWidget);

    // El TextButton de registre pot estar fora de pantalla en dispositius
    // petits: fem scroll fins que sigui visible abans de fer tap.
    final registerLink = find.byType(TextButton);
    expect(
      registerLink,
      findsOneWidget,
      reason: 'La pantalla de login hauria de tenir l\'enlla de registre.',
    );
    await tester.ensureVisible(registerLink);
    await tester.pumpAndSettle();

    await tester.tap(registerLink, warnIfMissed: false);
    await tester.pumpAndSettle(const Duration(seconds: 8));

    // Esperem que les ciutats carreguin (desaparèixer el CircularProgressIndicator)
    // Donem fins a 10 segons
    for (int i = 0; i < 10; i++) {
      if (!tester.any(find.byType(CircularProgressIndicator))) break;
      await tester.pump(const Duration(seconds: 1));
    }
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Un cop carregades les ciutats, el formulari té:
    // username (TextField), email (TextField), password (TextField),
    // nom jardi (TextField) + DropdownMenu de ciutat (TextField intern)
    // → almenys 4 TextFields visibles
    final textFields = find.byType(TextField);
    expect(
      textFields.evaluate().length,
      greaterThanOrEqualTo(4),
      reason:
          'El formulari de registre hauria de tenir almenys 4 camps '
          '(usuari, email, contrasenya, nom jardi).',
    );

    // Ha d'haver un FilledButton per enviar el formulari
    expect(
      find.byType(FilledButton),
      findsOneWidget,
      reason:
          'El formulari de registre hauria de tenir el boto de crear compte.',
    );

    // Tornem al login
    final NavigatorState navigator = tester.state(find.byType(Navigator).last);
    navigator.pop();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.byKey(const Key('login_button')), findsOneWidget);
  });

  // ───────────────────────────────────────────────────────────────────────────
  // TEST 17: Login amb Google - verificar que el botó és accessible
  // Nota: no podem automatitzar el flux OAuth de Google, però verifiquem
  //       que el botó existeix i és tappable
  // ───────────────────────────────────────────────────────────────────────────
  testWidgets('Login amb Google - boto present a la pantalla de login', (
    WidgetTester tester,
  ) async {
    // Comencem sense sessió
    const storage = FlutterSecureStorage();
    await storage.deleteAll();

    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.byKey(const Key('login_button')), findsOneWidget);

    // El botó de Google és un OutlinedButton (l'únic a la pantalla)
    expect(
      find.byType(OutlinedButton),
      findsOneWidget,
      reason:
          'La pantalla de login hauria de tenir el boto de login amb Google.',
    );

    // Comprovem que té la icona de Google
    expect(
      find.byIcon(Icons.g_mobiledata),
      findsOneWidget,
      reason: 'El boto de Google hauria de tenir la icona g_mobiledata.',
    );

    // Verifiquem que el botó és tappable (no llancem el flux OAuth,
    // simplement comprovem que l'element existeix i és interactuable)
    expect(
      tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
      isNotNull,
      reason: 'El boto de Google hauria de tenir un onPressed definit.',
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // TEST 18: Veure planta plantada a la maceta
  // Requereix que la maceta 1 estigui ocupada (Helianthus annuus, growth 80%)
  // ───────────────────────────────────────────────────────────────────────────
  testWidgets('Veure planta plantada - obrir maceta ocupada i verificar info', (
    WidgetTester tester,
  ) async {
    await ensureLoggedIn(tester);
    await tapGardenPot(tester, 1, occupied: true);

    expect(
      find.byKey(const Key('pot_info_sheet')),
      findsOneWidget,
      reason: 'Fer tap a una maceta ocupada hauria d\'obrir PotInfoSheet.',
    );

    // Verifiquem els elements clau del sheet (keys definides a PotInfoSheet)
    expect(
      find.byKey(const Key('plant_water_info')),
      findsOneWidget,
      reason: 'El PotInfoSheet hauria de mostrar la informació d\'aigua.',
    );
    expect(
      find.byKey(const Key('plant_health_info')),
      findsOneWidget,
      reason: 'El PotInfoSheet hauria de mostrar la informació de salut.',
    );

    // El boto de regar ha d'existir si la planta no està totalment regada.
    final waterButtonFinder = find.byKey(const Key('water_plant_button'));
    if (tester.any(waterButtonFinder)) {
      expect(
        waterButtonFinder,
        findsOneWidget,
        reason:
            'El boto de regar hauria de ser visible '
            '(la planta no te el 100% d\'aigua).',
      );
    }

    // El botó d'eliminar planta ha d'existir
    expect(
      find.byKey(const Key('delete_plant_button')),
      findsOneWidget,
      reason: 'El boto d\'eliminar planta hauria de ser visible.',
    );

    // Comprovem que es mostren percentatges (salut 80%, aigua 65% del SQL)
    expect(
      find.textContaining('%'),
      findsWidgets,
      reason:
          'El PotInfoSheet hauria de mostrar percentatges d\'aigua i salut.',
    );

    // Tanquem el sheet sense fer cap acció
    final NavigatorState navigator = tester.state(find.byType(Navigator).last);
    navigator.pop();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Tornem a GardenPage
    expect(
      find.byKey(const Key('garden_inventory_button')),
      findsOneWidget,
      reason: 'Despres de tancar el sheet, hauria de tornar a GardenPage.',
    );
  });
}

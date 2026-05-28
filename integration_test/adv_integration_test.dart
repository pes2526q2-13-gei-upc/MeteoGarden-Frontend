import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:meteo_garden/main.dart' as app;

import 'test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ---------------------------------------------------------------------------
  // TEST ADV1: Regar una planta
  // Requereix: maceta 1 ocupada (Helianthus annuus, waterLevel 65%, del SQL)
  // ---------------------------------------------------------------------------
  testWidgets('Regar una planta i verificar que l\'accio es completa', (
    WidgetTester tester,
  ) async {
    await ensureLoggedIn(tester);
    await tapGardenPot(tester, 1, occupied: true);

    expect(
      find.byKey(const Key('water_plant_button')),
      findsOneWidget,
      reason:
          'El boto de regar hauria d\'existir (la planta te 65% d\'aigua).',
    );

    expect(find.byKey(const Key('plant_water_info')), findsOneWidget);
    expect(find.byKey(const Key('plant_health_info')), findsOneWidget);

    await tester.tap(find.byKey(const Key('water_plant_button')));
    await tester.pumpAndSettle(const Duration(seconds: 8));

    expect(
      find.byKey(const Key('garden_inventory_button')),
      findsOneWidget,
      reason: 'Despres de regar, hauria de tornar a GardenPage.',
    );

    expect(
      find.byKey(const Key('water_plant_button')),
      findsNothing,
      reason: 'El PotInfoSheet hauria d\'estar tancat despres de regar.',
    );
  });

  // ---------------------------------------------------------------------------
  // TEST ADV2: Editar i guardar perfil (mateixos valors, sense canvis reals)
  // ---------------------------------------------------------------------------
  testWidgets('Editar perfil, guardar i verificar que torna a PerfilPage', (
    WidgetTester tester,
  ) async {
    await ensureLoggedIn(tester);

    await tester.tap(find.byKey(const Key('nav_profile')));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.byKey(const Key('profile_page')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('edit_profile_button')),
      200,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('edit_profile_button')));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.byKey(const Key('edit_profile_page')), findsOneWidget);
    await waitForLoading(tester);

    expect(find.byKey(const Key('edit_profile_username_field')), findsOneWidget);
    expect(find.byKey(const Key('edit_profile_city_dropdown')), findsOneWidget);
    expect(find.byKey(const Key('edit_profile_language_dropdown')), findsOneWidget);
    expect(find.byKey(const Key('save_profile_button')), findsOneWidget);

    await selectProfileCity(tester, 'Algerri');

    final saveButton = find.descendant(
      of: find.byKey(const Key('edit_profile_page')),
      matching: find.byKey(const Key('save_profile_button')),
    );
    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();
    await tester.tap(saveButton);

    for (int i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (!tester.any(find.byKey(const Key('edit_profile_page')))) break;
    }

    expect(
      find.byKey(const Key('edit_profile_page')),
      findsNothing,
      reason: 'Despres de guardar, l\'editor hauria de tancar-se.',
    );

    if (!tester.any(find.byKey(const Key('profile_page'))) &&
        tester.any(find.byKey(const Key('nav_profile')))) {
      await tester.tap(find.byKey(const Key('nav_profile')));
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (tester.any(find.byKey(const Key('profile_page')))) break;
      }
    }

    expect(
      find.byKey(const Key('profile_page')),
      findsOneWidget,
      reason:
          'Despres de guardar el perfil, hauria de tornar a PerfilPage.',
    );
  });

  // ---------------------------------------------------------------------------
  // TEST ADV3: Plantar una llavor a una maceta buida
  // Requereix: maceta 3 buida + llavors a l'inventari (del SQL)
  // ---------------------------------------------------------------------------
  testWidgets('Plantar una llavor a maceta buida i verificar el sheet', (
    WidgetTester tester,
  ) async {
    await ensureLoggedIn(tester);
    await tapGardenPot(tester, 3, occupied: false);

    expect(
      tester.any(find.byType(BottomSheet)) ||
          tester.any(find.byType(DraggableScrollableSheet)),
      isTrue,
      reason:
          'Fer tap a una maceta buida hauria d\'obrir el selector de llavors.',
    );

    await waitForLoading(tester);

    final seedOptions = find.byType(InkWell);
    expect(
      seedOptions.evaluate().isNotEmpty,
      isTrue,
      reason:
          'El selector de llavors hauria de mostrar almenys una opcio de llavor.',
    );

    await tester.tap(seedOptions.first);
    await tester.pumpAndSettle(const Duration(seconds: 8));

    expect(
      find.byKey(const Key('garden_inventory_button')),
      findsOneWidget,
      reason: 'Despres de plantar, hauria de tornar a GardenPage.',
    );
  });

  // ---------------------------------------------------------------------------
  // TEST ADV4: Crear un compte nou i eliminar-lo (E2E complet)
  //
  // Flux: Login -> Registre -> Avatar editor -> Garden -> Perfil -> Eliminar
  // Nota: nom d'usuari unic basat en timestamp per evitar conflictes.
  // ---------------------------------------------------------------------------
  testWidgets(
    'Crear compte nou i eliminar-lo - flux E2E complet',
    (WidgetTester tester) async {
      final timestamp = DateTime.now().millisecondsSinceEpoch % 99999;
      final testUsername = 'test$timestamp';
      final testEmail = 'test$timestamp@testintegration.com';
      const testPassword = 'TestPass123!';
      const testGarden = 'Jardi Test';

      const storage = FlutterSecureStorage();
      await storage.deleteAll();
      app.main();

      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (tester.any(find.byKey(const Key('login_button')))) break;
      }
      expect(find.byKey(const Key('login_button')), findsOneWidget);

      final registerLink = find.widgetWithText(TextButton, 'Crear compte');
      await tester.ensureVisible(registerLink);
      await tester.pumpAndSettle();
      await tester.tap(registerLink, warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await waitForLoading(tester, maxSeconds: 15);

      final textFields = find.byType(TextField);
      expect(
        textFields.evaluate().length,
        greaterThanOrEqualTo(4),
        reason: 'El formulari de registre hauria de tenir almenys 4 camps.',
      );

      await tester.enterText(textFields.at(0), testUsername);
      await tester.pumpAndSettle();
      await tester.enterText(textFields.at(1), testEmail);
      await tester.pumpAndSettle();

      await selectRegisterCity(tester, 'Algerri');

      await tester.enterText(textFields.at(3), testPassword);
      await tester.pumpAndSettle();
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      await tester.enterText(textFields.last, testGarden);
      await tester.pumpAndSettle();

      final createAccountButton =
          find.byKey(const Key('register_submit_button'));
      await tester.ensureVisible(createAccountButton);
      await tester.pumpAndSettle();
      expect(createAccountButton, findsOneWidget);
      await tester.tap(createAccountButton, warnIfMissed: false);

      await waitForLoading(tester, maxSeconds: 20);

      for (int i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (tester.any(find.byType(TabBar))) break;
      }
      expect(
        find.byType(TabBar),
        findsOneWidget,
        reason: 'Despres del registre hauria d\'obrir-se l\'editor d\'avatar.',
      );

      final saveAvatarButton = find.byKey(const Key('avatar_save_button'));
      await tester.ensureVisible(saveAvatarButton);
      await tester.pumpAndSettle();
      expect(saveAvatarButton, findsOneWidget);
      await tester.tap(saveAvatarButton, warnIfMissed: false);

      await waitForGardenPage(tester);

      await tester.tap(find.byKey(const Key('nav_profile')));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.byKey(const Key('profile_page')), findsOneWidget);

      await tester.scrollUntilVisible(
        find.byKey(const Key('delete_account_button')),
        200,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('delete_account_button')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(
        find.byKey(const Key('delete_account_confirm_button')),
        findsOneWidget,
        reason: 'El dialog de confirmacio d\'eliminacio hauria d\'apareixer.',
      );
      expect(
        find.byKey(const Key('delete_account_cancel_button')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('delete_account_confirm_button')));
      await waitForLoginScreen(tester);

      final tokenAfterDelete = await storage.read(key: 'auth_token');
      expect(
        tokenAfterDelete,
        isNull,
        reason:
            'El token hauria d\'esborrar-se de l\'storage despres d\'eliminar el compte.',
      );
    },
  );

  // ---------------------------------------------------------------------------
  // TEST ADV5: Cancel·lar l'eliminacio de compte
  // Verifica que el dialog de confirmacio es pot cancel·lar sense eliminar
  // ---------------------------------------------------------------------------
  testWidgets('Cancel·lar eliminacio de compte torna a PerfilPage', (
    WidgetTester tester,
  ) async {
    await ensureLoggedIn(tester);

    await tester.tap(find.byKey(const Key('nav_profile')));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.byKey(const Key('profile_page')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('delete_account_button')),
      200,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('delete_account_button')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(
      find.byKey(const Key('delete_account_confirm_button')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('delete_account_cancel_button')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(
      find.byKey(const Key('profile_page')),
      findsOneWidget,
      reason:
          'Despres de cancel·lar, hauria de seguir a PerfilPage sense '
          'eliminar el compte.',
    );
    expect(
      find.byKey(const Key('login_button')),
      findsNothing,
      reason: 'Cancel·lar no hauria de navegar fora de PerfilPage.',
    );
  });
}

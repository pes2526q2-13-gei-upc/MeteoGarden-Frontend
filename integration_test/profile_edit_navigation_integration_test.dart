import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:meteo_garden/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Login, open profile and open edit profile page', (
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
    await tester.enterText(find.byKey(const Key('login_username_field')), 'j');

    await tester.enterText(find.byKey(const Key('login_password_field')), 'j');

    await tester.tap(find.byKey(const Key('login_button')));

    // Esperem que faci login i carregui HomeShell.
    await tester.pumpAndSettle(const Duration(seconds: 10));

    // Anem a la pestanya Perfil.
    expect(
      find.byKey(const Key('nav_profile')),
      findsOneWidget,
      reason: 'HomeShell should show the profile navigation button.',
    );

    await tester.tap(find.byKey(const Key('nav_profile')));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Comprovem que s'ha obert la pantalla de perfil.
    expect(
      find.byKey(const Key('profile_page')),
      findsOneWidget,
      reason:
          'Profile page should be visible after tapping profile navigation.',
    );

    // Obrim editar perfil.
    expect(
      find.byKey(const Key('edit_profile_button')),
      findsOneWidget,
      reason: 'Profile page should show the edit profile button.',
    );

    await tester.tap(find.byKey(const Key('edit_profile_button')));
    await tester.pumpAndSettle(const Duration(seconds: 8));

    // Comprovem que s'ha obert la pantalla d'editar perfil.
    expect(
      find.byKey(const Key('edit_profile_page')),
      findsOneWidget,
      reason: 'Edit profile page should be visible.',
    );

    // Comprovem que el formulari mostra els camps principals.
    expect(
      find.byKey(const Key('edit_profile_username_field')),
      findsOneWidget,
      reason: 'Edit profile page should show the username field.',
    );

    expect(
      find.byKey(const Key('edit_profile_city_dropdown')),
      findsOneWidget,
      reason: 'Edit profile page should show the city dropdown.',
    );

    expect(
      find.byKey(const Key('edit_profile_language_dropdown')),
      findsOneWidget,
      reason: 'Edit profile page should show the language dropdown.',
    );

    expect(
      find.byKey(const Key('save_profile_button')),
      findsOneWidget,
      reason: 'Edit profile page should show the save button.',
    );
  });
}

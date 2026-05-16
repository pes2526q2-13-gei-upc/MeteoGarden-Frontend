import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_garden/generated/app_localizations.dart';
import 'package:meteo_garden/models/dades_usr.dart';
import 'package:meteo_garden/screens/completar_nova_conta.dart';
import 'package:provider/provider.dart';

Widget makeTestableWidget() {
  return ChangeNotifierProvider<UserModel>.value(
    value: UserModel(),
    child: const MaterialApp(
      locale: Locale('ca'),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: CompleteGoogleProfilePage(
        googleToken: 'fake-google-token',
        email: 'jana@test.com',
      ),
    ),
  );
}

Future<void> pumpCompleteGoogleProfilePage(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 2200);
  tester.view.devicePixelRatio = 1.0;

  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(makeTestableWidget());

  // Render inicial.
  await tester.pump();

  // Deixa que fetchCities acabi. En widget tests normalment l'HTTP retorna 400.
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('mostra la pantalla de completar perfil de Google', (
    tester,
  ) async {
    await pumpCompleteGoogleProfilePage(tester);

    expect(find.byType(CompleteGoogleProfilePage), findsOneWidget);
  });

  testWidgets('mostra el títol de completar perfil', (tester) async {
    await pumpCompleteGoogleProfilePage(tester);

    final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

    expect(find.text(l10n.completeProfileTitle), findsOneWidget);
    expect(find.text(l10n.completeProfileHeading), findsOneWidget);
    expect(find.text(l10n.completeProfileSubtitle), findsOneWidget);
  });

  testWidgets('mostra els camps principals del formulari', (tester) async {
    await pumpCompleteGoogleProfilePage(tester);

    final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

    expect(find.text(l10n.loginUsernameLabel), findsOneWidget);
    expect(find.text(l10n.commonCity), findsOneWidget);
    expect(find.text(l10n.completeProfilePasswordOptional), findsOneWidget);
    expect(find.text(l10n.commonLanguage), findsOneWidget);
    expect(find.text(l10n.createAccountGardenNameLabel), findsOneWidget);
  });

  testWidgets('permet escriure username, password i nom del jardí', (
    tester,
  ) async {
    await pumpCompleteGoogleProfilePage(tester);

    final textFields = find.byType(TextField);

    // 0: username
    // 1: TextField intern del DropdownMenu de ciutat
    // 2: password
    // 3: nom del jardí
    await tester.enterText(textFields.at(0), 'jana');
    await tester.enterText(textFields.at(2), '123456');
    await tester.enterText(textFields.at(3), 'JardiJana');

    await tester.pump();

    expect(find.text('jana'), findsOneWidget);
    expect(find.text('123456'), findsOneWidget);
    expect(find.text('JardiJana'), findsOneWidget);
  });

  testWidgets('el camp password és obscureText', (tester) async {
    await pumpCompleteGoogleProfilePage(tester);

    final textFields = find.byType(TextField);

    final passwordTextField = tester.widget<TextField>(textFields.at(2));

    expect(passwordTextField.obscureText, true);
  });

  testWidgets('el camp username no és obscureText', (tester) async {
    await pumpCompleteGoogleProfilePage(tester);

    final textFields = find.byType(TextField);

    final usernameTextField = tester.widget<TextField>(textFields.at(0));

    expect(usernameTextField.obscureText, false);
  });

  testWidgets('mostra el dropdown de llengua', (tester) async {
    await pumpCompleteGoogleProfilePage(tester);

    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
  });

  testWidgets('obre el dropdown de llengua', (tester) async {
    await pumpCompleteGoogleProfilePage(tester);

    final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    expect(find.text(l10n.languageCatalan), findsOneWidget);
    expect(find.text(l10n.languageSpanish), findsOneWidget);
    expect(find.text(l10n.languageEnglish), findsOneWidget);
  });

  testWidgets('permet seleccionar llengua espanyola', (tester) async {
    await pumpCompleteGoogleProfilePage(tester);

    final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.languageSpanish).last);
    await tester.pumpAndSettle();

    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
  });

  testWidgets('mostra el botó de continuar', (tester) async {
    await pumpCompleteGoogleProfilePage(tester);

    final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

    expect(find.text(l10n.commonContinue), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
  });

  testWidgets('City.fromJson crea una ciutat correctament', (tester) async {
    final city = City.fromJson({'code': '08019', 'name': 'Barcelona'});

    expect(city.code, '08019');
    expect(city.name, 'Barcelona');
  });

  testWidgets('City compara igualtat per code', (tester) async {
    final cityA = City(code: '001', name: 'Barcelona');
    final cityB = City(code: '001', name: 'BCN');
    final cityC = City(code: '002', name: 'Vic');

    expect(cityA, cityB);
    expect(cityA == cityC, false);
    expect(cityA.hashCode, cityB.hashCode);
  });

  testWidgets('mostra loading inicial mentre carrega ciutats', (tester) async {
    tester.view.physicalSize = const Size(1200, 2200);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(makeTestableWidget());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('mostra AppBar amb el títol de completar perfil', (tester) async {
    await pumpCompleteGoogleProfilePage(tester);

    final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text(l10n.completeProfileTitle), findsOneWidget);
  });

  testWidgets('mostra les icones dels camps del formulari', (tester) async {
    await pumpCompleteGoogleProfilePage(tester);

    expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
    expect(find.byIcon(Icons.location_city_rounded), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
    expect(find.byIcon(Icons.language_rounded), findsOneWidget);
    expect(find.byIcon(Icons.local_florist_outlined), findsOneWidget);
  });

  testWidgets('permet seleccionar llengua anglesa', (tester) async {
    await pumpCompleteGoogleProfilePage(tester);

    final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.languageEnglish).last);
    await tester.pumpAndSettle();

    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
  });

  testWidgets('el dropdown de ciutat existeix després de carregar', (
    tester,
  ) async {
    await pumpCompleteGoogleProfilePage(tester);

    expect(find.byType(DropdownMenu<City>), findsOneWidget);
    expect(find.byIcon(Icons.location_city_rounded), findsOneWidget);
  });

  testWidgets(
    'pot prémer continuar i mantenir-se a la pantalla si falla HTTP',
    (tester) async {
      await pumpCompleteGoogleProfilePage(tester);

      await tester.enterText(find.byType(TextField).at(0), 'jana');
      await tester.enterText(find.byType(TextField).at(2), '123456');
      await tester.enterText(find.byType(TextField).at(3), 'JardiJana');

      final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

      await tester.tap(find.text(l10n.commonContinue));
      await tester.pump();

      expect(find.byType(CompleteGoogleProfilePage), findsOneWidget);
    },
  );

  testWidgets('mostra SnackBar d’error si el registre amb Google falla', (
    tester,
  ) async {
    await pumpCompleteGoogleProfilePage(tester);

    final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

    await tester.tap(find.text(l10n.commonContinue));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(l10n.completeProfileError), findsOneWidget);
  });
}

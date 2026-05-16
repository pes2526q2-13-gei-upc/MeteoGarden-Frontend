import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_garden/generated/app_localizations.dart';
import 'package:meteo_garden/models/dades_usr.dart';
import 'package:meteo_garden/screens/crea_nova_conta.dart';
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
      home: CreaNovaConta(),
    ),
  );
}

Future<void> pumpCreateAccountPage(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 2200);
  tester.view.devicePixelRatio = 1.0;

  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(makeTestableWidget());

  // Primer pump: render inicial.
  await tester.pump();

  // Segon pump: deixa acabar el fetchCities, que en test normalment retorna 400.
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('mostra la pantalla de crear compte', (tester) async {
    await pumpCreateAccountPage(tester);

    final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

    expect(find.byType(CreaNovaConta), findsOneWidget);
    expect(find.text(l10n.createAccountWelcome), findsOneWidget);
    expect(find.text(l10n.createAccountSubtitle), findsOneWidget);
  });

  testWidgets('mostra el selector d’idioma superior en català per defecte', (
    tester,
  ) async {
    await pumpCreateAccountPage(tester);

    expect(find.text('CA'), findsOneWidget);
    expect(find.byIcon(Icons.language), findsWidgets);
    expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
  });

  testWidgets('obre el menú superior de selecció d’idioma', (tester) async {
    await pumpCreateAccountPage(tester);

    await tester.tap(find.text('CA'));
    await tester.pumpAndSettle();

    expect(find.text('Català'), findsWidgets);
    expect(find.text('Español'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
  });

  testWidgets('canvia idioma superior a espanyol', (tester) async {
    await pumpCreateAccountPage(tester);

    await tester.tap(find.text('CA'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();

    expect(find.text('ES'), findsOneWidget);
  });

  testWidgets('canvia idioma superior a anglès', (tester) async {
    await pumpCreateAccountPage(tester);

    await tester.tap(find.text('CA'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('EN'), findsOneWidget);
  });

  testWidgets('mostra els camps principals del formulari', (tester) async {
    await pumpCreateAccountPage(tester);

    final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

    expect(find.text(l10n.loginUsernameLabel), findsOneWidget);
    expect(find.text(l10n.createAccountEmailLabel), findsOneWidget);
    expect(find.text(l10n.loginPasswordLabel), findsOneWidget);
    expect(find.text(l10n.createAccountGardenNameLabel), findsOneWidget);
    expect(find.text(l10n.commonLanguage), findsOneWidget);
  });

  testWidgets('permet escriure username, email, password i nom del jardí', (
    tester,
  ) async {
    await pumpCreateAccountPage(tester);

    final textFields = find.byType(TextField);

    // Username
    await tester.enterText(textFields.at(0), 'jana');

    // Email
    await tester.enterText(textFields.at(1), 'jana@test.com');

    // Password
    await tester.enterText(textFields.at(3), '123456');

    // Nom del jardí
    await tester.enterText(textFields.at(4), 'JardiJana');

    await tester.pump();

    expect(find.text('jana'), findsOneWidget);
    expect(find.text('jana@test.com'), findsOneWidget);
    expect(find.text('123456'), findsOneWidget);
    expect(find.text('JardiJana'), findsOneWidget);
  });

  testWidgets('el camp password és obscureText', (tester) async {
    await pumpCreateAccountPage(tester);

    final textFields = find.byType(TextField);

    final passwordTextField = tester.widget<TextField>(textFields.at(3));

    expect(passwordTextField.obscureText, true);
  });

  testWidgets('els camps username i email no són obscureText', (tester) async {
    await pumpCreateAccountPage(tester);

    final textFields = find.byType(TextField);

    final usernameTextField = tester.widget<TextField>(textFields.at(0));
    final emailTextField = tester.widget<TextField>(textFields.at(1));

    expect(usernameTextField.obscureText, false);
    expect(emailTextField.obscureText, false);
  });

  testWidgets('mostra el dropdown de llengua del formulari', (tester) async {
    await pumpCreateAccountPage(tester);

    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    expect(find.text('Català'), findsWidgets);
  });

  testWidgets('permet canviar la llengua del formulari a espanyol', (
    tester,
  ) async {
    await pumpCreateAccountPage(tester);

    final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.languageSpanish).last);
    await tester.pumpAndSettle();

    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
  });

  testWidgets('mostra el botó de crear compte', (tester) async {
    await pumpCreateAccountPage(tester);

    final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

    expect(find.text(l10n.loginCreateAccount), findsOneWidget);
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
}

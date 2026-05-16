import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_garden/generated/app_localizations.dart';
import 'package:meteo_garden/models/avatar_user.dart';
import 'package:meteo_garden/models/dades_usr.dart';
import 'package:meteo_garden/models/plantes_desbl.dart';
import 'package:meteo_garden/models/weather_provider.dart';
import 'package:meteo_garden/screens/login_page.dart';
import 'package:provider/provider.dart';

Widget makeTestableWidget() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<UserModel>.value(value: UserModel()),
      ChangeNotifierProvider<AvatarUser>.value(value: AvatarUser()),
      ChangeNotifierProvider<PlantProvider>.value(value: PlantProvider()),
      ChangeNotifierProvider<WeatherProvider>.value(value: WeatherProvider()),
    ],
    child: const MaterialApp(
      locale: Locale('ca'),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: LoginPage(),
    ),
  );
}

Future<void> pumpLoginPage(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1600, 2200);
  tester.view.devicePixelRatio = 1.0;

  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(makeTestableWidget());
  await tester.pump();
}

void main() {
  testWidgets('mostra la pantalla de login', (tester) async {
    await pumpLoginPage(tester);

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byKey(const Key('login_username_field')), findsOneWidget);
    expect(find.byKey(const Key('login_password_field')), findsOneWidget);
    expect(find.byKey(const Key('login_button')), findsOneWidget);
  });

  testWidgets('mostra els camps de username i password', (tester) async {
    await pumpLoginPage(tester);

    final usernameField = find.byKey(const Key('login_username_field'));
    final passwordField = find.byKey(const Key('login_password_field'));

    expect(usernameField, findsOneWidget);
    expect(passwordField, findsOneWidget);

    await tester.enterText(usernameField, 'jana');
    await tester.enterText(passwordField, '1234');
    await tester.pump();

    expect(find.text('jana'), findsOneWidget);
    expect(find.text('1234'), findsOneWidget);
  });

  testWidgets('mostra error si es prem login amb camps buits', (tester) async {
    await pumpLoginPage(tester);

    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pump();

    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
  });

  testWidgets(
    'si hi ha credencials intenta fer login i pot mostrar error HTTP',
    (tester) async {
      await pumpLoginPage(tester);

      await tester.enterText(
        find.byKey(const Key('login_username_field')),
        'jana',
      );
      await tester.enterText(
        find.byKey(const Key('login_password_field')),
        '1234',
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump();

      expect(find.byType(LoginPage), findsOneWidget);
    },
  );

  testWidgets('mostra el selector d’idioma en català per defecte', (
    tester,
  ) async {
    await pumpLoginPage(tester);

    expect(find.text('CA'), findsOneWidget);
    expect(find.byIcon(Icons.language), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
  });

  testWidgets('obre el menú de selecció d’idioma', (tester) async {
    await pumpLoginPage(tester);

    await tester.tap(find.text('CA'));
    await tester.pumpAndSettle();

    expect(find.text('Català'), findsOneWidget);
    expect(find.text('Español'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
  });

  testWidgets('canvia idioma a espanyol', (tester) async {
    await pumpLoginPage(tester);

    await tester.tap(find.text('CA'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();

    expect(find.text('ES'), findsOneWidget);
  });

  testWidgets('canvia idioma a anglès', (tester) async {
    await pumpLoginPage(tester);

    await tester.tap(find.text('CA'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('EN'), findsOneWidget);
  });

  testWidgets('mostra el botó de Google', (tester) async {
    await pumpLoginPage(tester);

    expect(find.text('Google'), findsOneWidget);
    expect(find.byIcon(Icons.g_mobiledata), findsOneWidget);
  });

  testWidgets('mostra el botó per crear compte', (tester) async {
    await pumpLoginPage(tester);

    final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

    expect(find.text(l10n.loginCreateAccount), findsOneWidget);
  });

  testWidgets('el camp password és obscureText', (tester) async {
    await pumpLoginPage(tester);

    final passwordTextField = tester.widget<TextField>(
      find.byKey(const Key('login_password_field')),
    );

    expect(passwordTextField.obscureText, true);
  });

  testWidgets('el camp username no és obscureText', (tester) async {
    await pumpLoginPage(tester);

    final usernameTextField = tester.widget<TextField>(
      find.byKey(const Key('login_username_field')),
    );

    expect(usernameTextField.obscureText, false);
  });
}

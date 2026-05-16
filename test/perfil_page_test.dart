import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_garden/generated/app_localizations.dart';
import 'package:meteo_garden/models/avatar_user.dart';
import 'package:meteo_garden/models/dades_usr.dart';
import 'package:meteo_garden/models/plantes_desbl.dart';
import 'package:meteo_garden/screens/perfil_page.dart';
import 'package:provider/provider.dart';

Widget makeTestableWidget({
  String username = 'jana',
  String email = 'jana@test.com',
  String city = 'Barcelona',
  String language = 'ca',
  int coins = 25,
}) {
  final userModel = UserModel();

  userModel.setToken('fake-token');
  userModel.setProfile(
    newUsername: username,
    newEmail: email,
    newCity: city,
    newLanguage: language,
    newLastEntry: '',
    newNumPlantsCollected: 0,
    newMonedes: coins,
    newGardens: const ['JardiJana'],
  );

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<UserModel>.value(value: userModel),
      ChangeNotifierProvider<PlantProvider>.value(value: PlantProvider()),
      ChangeNotifierProvider<AvatarUser>.value(value: AvatarUser()),
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
      home: PerfilPage(),
    ),
  );
}

Future<void> pumpPerfilPage(
  WidgetTester tester, {
  String username = 'jana',
  String email = 'jana@test.com',
  String city = 'Barcelona',
  String language = 'ca',
  int coins = 25,
}) async {
  tester.view.physicalSize = const Size(1200, 2000);
  tester.view.devicePixelRatio = 1.0;

  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    makeTestableWidget(
      username: username,
      email: email,
      city: city,
      language: language,
      coins: coins,
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  testWidgets('mostra la pàgina de perfil', (tester) async {
    await pumpPerfilPage(tester);

    expect(find.byKey(const Key('profile_page')), findsOneWidget);
  });

  testWidgets('mostra les dades principals de l’usuari', (tester) async {
    await pumpPerfilPage(
      tester,
      username: 'jana',
      email: 'jana@test.com',
      city: 'Barcelona',
      language: 'ca',
    );

    expect(find.text('jana'), findsWidgets);
    expect(find.text('jana@test.com'), findsOneWidget);
    expect(find.text('Barcelona'), findsWidgets);
    expect(find.text('ca'), findsOneWidget);
  });

  testWidgets('mostra les monedes de l’usuari', (tester) async {
    await pumpPerfilPage(
      tester,
      coins: 25,
    );

    expect(find.text('25'), findsOneWidget);
    expect(find.byIcon(Icons.monetization_on_rounded), findsOneWidget);
  });

  testWidgets('mostra les plantes descobertes', (tester) async {
    await pumpPerfilPage(tester);

    expect(find.text('0'), findsOneWidget);
    expect(find.byIcon(Icons.photo_camera_rounded), findsOneWidget);
  });

  testWidgets('mostra el botó d’editar perfil', (tester) async {
    await pumpPerfilPage(tester);

    expect(find.byKey(const Key('edit_profile_button')), findsOneWidget);
    expect(find.byIcon(Icons.edit_rounded), findsWidgets);
  });

  testWidgets('mostra el botó de logout', (tester) async {
    await pumpPerfilPage(tester);

    expect(find.byIcon(Icons.logout), findsOneWidget);
  });

  testWidgets('mostra el botó d’eliminar compte', (tester) async {
    await pumpPerfilPage(tester);

    expect(find.byIcon(Icons.delete_forever), findsOneWidget);
  });

  testWidgets('obre el diàleg de confirmació per eliminar compte',
      (tester) async {
    await pumpPerfilPage(tester);

    await tester.tap(find.byIcon(Icons.delete_forever));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
  });

  testWidgets('pot cancel·lar el diàleg d’eliminar compte', (tester) async {
    await pumpPerfilPage(tester);

    await tester.tap(find.byIcon(Icons.delete_forever));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.byType(TextButton).last);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('mostra valors per defecte si falten dades del perfil',
      (tester) async {
    await pumpPerfilPage(
      tester,
      username: '',
      email: '',
      city: '',
      language: '',
      coins: 0,
    );

    expect(find.text('—'), findsWidgets);
    expect(find.text('0'), findsNWidgets(2));
  });

  testWidgets('mostra els blocs principals del perfil', (tester) async {
    await pumpPerfilPage(tester);

    expect(find.byIcon(Icons.person_rounded), findsOneWidget);
    expect(find.byIcon(Icons.email_rounded), findsOneWidget);
    expect(find.byIcon(Icons.location_city_rounded), findsOneWidget);
    expect(find.byIcon(Icons.language_rounded), findsOneWidget);
    expect(find.byIcon(Icons.bar_chart_rounded), findsOneWidget);
  });
}
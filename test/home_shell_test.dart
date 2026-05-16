import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_garden/generated/app_localizations.dart';
import 'package:meteo_garden/models/dades_usr.dart';
import 'package:meteo_garden/screens/home_shell.dart';
import 'package:provider/provider.dart';

class FakePage extends StatelessWidget {
  final String title;

  const FakePage({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          title,
          key: Key('fake_page_$title'),
        ),
      ),
    );
  }
}

Widget makeTestableWidget() {
  final userModel = UserModel();

  userModel.setToken('fake-token');
  userModel.setProfile(
    newUsername: 'jana',
    newEmail: 'jana@test.com',
    newCity: 'Barcelona',
    newLanguage: 'ca',
    newLastEntry: '',
    newNumPlantsCollected: 0,
    newMonedes: 25,
    newGardens: const ['JardiJana'],
  );

  return ChangeNotifierProvider<UserModel>.value(
    value: userModel,
    child: MaterialApp(
      locale: const Locale('ca'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomeShell(
        pagesForTests: [
          FakePage(title: 'garden'),
          FakePage(title: 'friends'),
          FakePage(title: 'camera'),
          FakePage(title: 'missions'),
          FakePage(title: 'profile'),
          FakePage(title: 'inventory'),
          FakePage(title: 'album'),
        ],
      ),
    ),
  );
}

Future<void> pumpHomeShell(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 2200);
  tester.view.devicePixelRatio = 1.0;

  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(makeTestableWidget());
  await tester.pump();
}

Future<void> tapNav(
  WidgetTester tester,
  String keyName,
) async {
  await tester.tap(find.byKey(Key(keyName)));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
}

void main() {
  testWidgets('mostra HomeShell amb la pàgina de jardí per defecte',
      (tester) async {
    await pumpHomeShell(tester);

    expect(find.byType(HomeShell), findsOneWidget);
    expect(find.byKey(const Key('fake_page_garden')), findsOneWidget);
    expect(find.byKey(const Key('fake_page_friends')), findsNothing);
  });

  testWidgets('mostra tots els botons de navegació inferior', (tester) async {
    await pumpHomeShell(tester);

    expect(find.byKey(const Key('nav_garden')), findsOneWidget);
    expect(find.byKey(const Key('nav_friends')), findsOneWidget);
    expect(find.byKey(const Key('nav_camera')), findsOneWidget);
    expect(find.byKey(const Key('nav_missions')), findsOneWidget);
    expect(find.byKey(const Key('nav_profile')), findsOneWidget);
  });

  testWidgets('mostra les etiquetes de navegació traduïdes', (tester) async {
    await pumpHomeShell(tester);

    final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

    expect(find.text(l10n.navGarden), findsOneWidget);
    expect(find.text(l10n.navFriends), findsOneWidget);
    expect(find.text(l10n.navCamera), findsOneWidget);
    expect(find.text(l10n.navMissions), findsOneWidget);
    expect(find.text(l10n.navProfile), findsOneWidget);
  });

  testWidgets('el jardí està seleccionat inicialment', (tester) async {
    await pumpHomeShell(tester);

    expect(find.byIcon(Icons.local_florist), findsOneWidget);
    expect(find.byIcon(Icons.local_florist_outlined), findsNothing);
  });

  testWidgets('pot navegar a la pàgina d’amics', (tester) async {
    await pumpHomeShell(tester);

    await tapNav(tester, 'nav_friends');

    expect(find.byKey(const Key('fake_page_friends')), findsOneWidget);
    expect(find.byKey(const Key('fake_page_garden')), findsNothing);
    expect(find.byIcon(Icons.people), findsOneWidget);
  });

  testWidgets('pot navegar a la pàgina de càmera', (tester) async {
    await pumpHomeShell(tester);

    await tapNav(tester, 'nav_camera');

    expect(find.byKey(const Key('fake_page_camera')), findsOneWidget);
    expect(find.byKey(const Key('fake_page_garden')), findsNothing);
    expect(find.byIcon(Icons.camera_alt), findsOneWidget);
  });

  testWidgets('pot navegar a la pàgina de missions', (tester) async {
    await pumpHomeShell(tester);

    await tapNav(tester, 'nav_missions');

    expect(find.byKey(const Key('fake_page_missions')), findsOneWidget);
    expect(find.byKey(const Key('fake_page_garden')), findsNothing);
    expect(find.byIcon(Icons.flag), findsOneWidget);
  });

  testWidgets('pot navegar a la pàgina de perfil', (tester) async {
    await pumpHomeShell(tester);

    await tapNav(tester, 'nav_profile');

    expect(find.byKey(const Key('fake_page_profile')), findsOneWidget);
    expect(find.byKey(const Key('fake_page_garden')), findsNothing);
    expect(find.byIcon(Icons.person), findsOneWidget);
  });

  testWidgets('pot tornar de perfil a jardí', (tester) async {
    await pumpHomeShell(tester);

    await tapNav(tester, 'nav_profile');

    expect(find.byKey(const Key('fake_page_profile')), findsOneWidget);

    await tapNav(tester, 'nav_garden');

    expect(find.byKey(const Key('fake_page_garden')), findsOneWidget);
    expect(find.byKey(const Key('fake_page_profile')), findsNothing);
    expect(find.byIcon(Icons.local_florist), findsOneWidget);
  });

  testWidgets('canvia les icones actives i inactives quan es navega',
      (tester) async {
    await pumpHomeShell(tester);

    expect(find.byIcon(Icons.local_florist), findsOneWidget);
    expect(find.byIcon(Icons.people_outline), findsOneWidget);

    await tapNav(tester, 'nav_friends');

    expect(find.byIcon(Icons.people), findsOneWidget);
    expect(find.byIcon(Icons.local_florist_outlined), findsOneWidget);
  });

  testWidgets('manté visible la barra de navegació en canviar de pàgina',
      (tester) async {
    await pumpHomeShell(tester);

    await tapNav(tester, 'nav_camera');

    expect(find.byKey(const Key('nav_garden')), findsOneWidget);
    expect(find.byKey(const Key('nav_friends')), findsOneWidget);
    expect(find.byKey(const Key('nav_camera')), findsOneWidget);
    expect(find.byKey(const Key('nav_missions')), findsOneWidget);
    expect(find.byKey(const Key('nav_profile')), findsOneWidget);
  });

  testWidgets('tocar la pestanya actual manté la mateixa pàgina',
      (tester) async {
    await pumpHomeShell(tester);

    expect(find.byKey(const Key('fake_page_garden')), findsOneWidget);

    await tapNav(tester, 'nav_garden');

    expect(find.byKey(const Key('fake_page_garden')), findsOneWidget);
  });
}
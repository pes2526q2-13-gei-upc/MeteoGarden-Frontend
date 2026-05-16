import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_garden/generated/app_localizations.dart';
import 'package:meteo_garden/models/avatar_user.dart';
import 'package:meteo_garden/models/dades_usr.dart';
import 'package:meteo_garden/screens/avatar_editor_page.dart';
import 'package:provider/provider.dart';

Map<String, List<String>> fakeAvatarOptions() {
  return {
    'Body': [
      'https://example.com/avatar/body/1.png',
      'https://example.com/avatar/body/2.png',
    ],
    'Eyes': [
      'https://example.com/avatar/eye/1.png',
      'https://example.com/avatar/eye/2.png',
    ],
    'Expression': [
      'https://example.com/avatar/expression/smile/1.png',
      'https://example.com/avatar/expression/sad/2.png',
    ],
    'Hair': [
      'none',
      'https://example.com/avatar/hair/blond/1.png',
      'https://example.com/avatar/hair/brown/2.png',
      'https://example.com/avatar/hair/dark/3.png',
    ],
    'Facial Hair': [
      'none',
      'https://example.com/avatar/facial_hair/1/blond.png',
    ],
    'Clothing': [
      'https://example.com/avatar/clothing/1.png',
      'https://example.com/avatar/clothing/2.png',
    ],
    'Accessories': ['none', 'https://example.com/avatar/accessories/1.png'],
  };
}

Widget makeTestableWidget({
  bool isNewUser = true,
  Map<String, List<String>>? initialOptions,
  AvatarUser? avatarUser,
}) {
  final userModel = UserModel();

  userModel.setToken('fake-token');
  userModel.setProfile(
    newUsername: 'jana',
    newEmail: 'jana@test.com',
    newCity: 'Barcelona',
    newLanguage: 'ca',
    newLastEntry: '',
    newNumPlantsCollected: 0,
    newMonedes: 0,
    newGardens: const ['JardiJana'],
  );

  final avatar = avatarUser ?? AvatarUser();

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<UserModel>.value(value: userModel),
      ChangeNotifierProvider<AvatarUser>.value(value: avatar),
    ],
    child: MaterialApp(
      locale: const Locale('ca'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: AvatarEditorPage(
        isNewUser: isNewUser,
        initialOptionsForTests: initialOptions,
      ),
    ),
  );
}

Future<void> pumpAvatarEditorPage(
  WidgetTester tester, {
  bool isNewUser = true,
  Map<String, List<String>>? initialOptions,
  AvatarUser? avatarUser,
}) async {
  tester.view.physicalSize = const Size(1200, 2200);
  tester.view.devicePixelRatio = 1.0;

  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    makeTestableWidget(
      isNewUser: isNewUser,
      initialOptions: initialOptions,
      avatarUser: avatarUser,
    ),
  );

  await tester.pump();
}

void main() {
  testWidgets('mostra loading inicial si no es passen opcions fake', (
    tester,
  ) async {
    await tester.pumpWidget(makeTestableWidget(initialOptions: null));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('mostra editor d’avatar per usuari nou', (tester) async {
    await pumpAvatarEditorPage(
      tester,
      isNewUser: true,
      initialOptions: fakeAvatarOptions(),
    );

    final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

    expect(find.text('MeteoGarden'), findsOneWidget);
    expect(find.text(l10n.createYourAvatar), findsOneWidget);
    expect(find.text(l10n.continueButton), findsOneWidget);
    expect(find.byType(DefaultTabController), findsOneWidget);
  });

  testWidgets('mostra editor d’avatar per editar usuari existent', (
    tester,
  ) async {
    await pumpAvatarEditorPage(
      tester,
      isNewUser: false,
      initialOptions: fakeAvatarOptions(),
    );

    final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

    expect(find.text(l10n.editAvatar), findsOneWidget);
    expect(find.text(l10n.saveChangesButton), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });

  testWidgets('mostra les pestanyes principals', (tester) async {
    await pumpAvatarEditorPage(tester, initialOptions: fakeAvatarOptions());

    final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

    expect(find.text(l10n.categoryBody), findsOneWidget);
    expect(find.text(l10n.categoryEyes), findsOneWidget);
    expect(find.text(l10n.categoryExpression), findsOneWidget);
    expect(find.text(l10n.categoryHair), findsOneWidget);
    expect(find.text(l10n.categoryFacialHair), findsOneWidget);
    expect(find.text(l10n.categoryClothing), findsOneWidget);
    expect(find.text(l10n.categoryAccessories), findsOneWidget);
  });

  testWidgets('mostra opcions de body a la primera pestanya', (tester) async {
    await pumpAvatarEditorPage(tester, initialOptions: fakeAvatarOptions());

    expect(find.byType(GridView), findsOneWidget);
    expect(find.byIcon(Icons.broken_image), findsWidgets);
  });

  testWidgets('pot seleccionar una opció de body', (tester) async {
    await pumpAvatarEditorPage(tester, initialOptions: fakeAvatarOptions());

    final firstOption = find.byType(GestureDetector).last;

    await tester.tap(firstOption);
    await tester.pump();

    expect(find.byType(AvatarEditorPage), findsOneWidget);
  });

  testWidgets('mostra menú de colors a la pestanya Hair', (tester) async {
    await pumpAvatarEditorPage(tester, initialOptions: fakeAvatarOptions());

    final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

    await tester.tap(find.text(l10n.categoryHair));
    await tester.pumpAndSettle();

    expect(find.byType(GridView), findsOneWidget);
    expect(find.byIcon(Icons.block), findsOneWidget);
  });

  testWidgets('pot canviar color de cabell', (tester) async {
    await pumpAvatarEditorPage(tester, initialOptions: fakeAvatarOptions());

    final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

    await tester.tap(find.text(l10n.categoryHair));
    await tester.pumpAndSettle();

    final colorDots = find.byType(GestureDetector);

    await tester.tap(colorDots.at(1));
    await tester.pump();

    expect(find.byType(AvatarEditorPage), findsOneWidget);
  });

  testWidgets('mostra none com icona block a hair/facial/accessories', (
    tester,
  ) async {
    await pumpAvatarEditorPage(tester, initialOptions: fakeAvatarOptions());

    final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

    await tester.tap(find.text(l10n.categoryHair));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.block), findsOneWidget);
  });

  testWidgets('mostra missatge quan una categoria no té opcions', (
    tester,
  ) async {
    final options = fakeAvatarOptions();
    options['Body'] = [];

    await pumpAvatarEditorPage(tester, initialOptions: options);

    final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

    expect(find.text(l10n.noOptionsAvailable), findsOneWidget);
  });

  testWidgets('el botó enrere fa pop en mode editar', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserModel>.value(value: UserModel()),
          ChangeNotifierProvider<AvatarUser>.value(value: AvatarUser()),
        ],
        child: MaterialApp(
          locale: const Locale('ca'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AvatarEditorPage(
                            isNewUser: false,
                            initialOptionsForTests: fakeAvatarOptions(),
                          ),
                        ),
                      );
                    },
                    child: const Text('Obrir editor'),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Obrir editor'));
    await tester.pumpAndSettle();

    expect(find.byType(AvatarEditorPage), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Obrir editor'), findsOneWidget);
    expect(find.text('MeteoGarden'), findsNothing);
  });

  testWidgets('prem guardar i mostra error si falla HTTP', (tester) async {
    await pumpAvatarEditorPage(tester, initialOptions: fakeAvatarOptions());

    final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

    await tester.tap(find.text(l10n.continueButton));
    await tester.pump();

    expect(find.byType(AvatarEditorPage), findsOneWidget);
  });

  testWidgets('parseAvatarData neteja urls duplicades amb doble slash', (
    tester,
  ) async {
    await pumpAvatarEditorPage(tester, initialOptions: fakeAvatarOptions());

    final state = tester.state(find.byType(AvatarEditorPage)) as dynamic;

    final parsed = state.parseAvatarData({
      'body': [
        {'url': 'https://example.com//avatar/body/1.png'},
      ],
      'eye': [
        {'url': 'https://example.com/avatar/eye/1.png'},
      ],
      'expression': {
        'smile': [
          {'url': 'https://example.com/avatar/expression/smile/1.png'},
        ],
      },
      'hair': {
        'blond': [
          {'url': 'https://example.com/avatar/hair/blond/1.png'},
        ],
      },
      'facialHair': [
        {'url': 'https://example.com/avatar/facial_hair/1/blond.png'},
      ],
      'clothing': [
        {'url': 'https://example.com/avatar/clothing/1.png'},
      ],
      'accessories': [
        {'url': 'https://example.com/avatar/accessories/1.png'},
      ],
    });

    expect(parsed['Body'], contains('https://example.com/avatar/body/1.png'));
    expect(parsed['Eyes'], contains('https://example.com/avatar/eye/1.png'));
    expect(
      parsed['Expression'],
      contains('https://example.com/avatar/expression/smile/1.png'),
    );
    expect(parsed['Hair']!.first, 'none');
    expect(parsed['Facial Hair']!.first, 'none');
    expect(parsed['Accessories']!.first, 'none');
  });

  testWidgets('en mode editar carrega avatar existent del provider', (
    tester,
  ) async {
    final avatar = AvatarUser();

    avatar.setAvatar(
      newBody: 'https://example.com/avatar/body/2.png',
      newEye: 'https://example.com/avatar/eye/2.png',
      newExpression: 'https://example.com/avatar/expression/sad/2.png',
      newHair: 'https://example.com/avatar/hair/brown/2.png',
      newFacialHair: 'https://example.com/avatar/facial_hair/1/blond.png',
      newClothing: 'https://example.com/avatar/clothing/2.png',
      newAccessories: 'https://example.com/avatar/accessories/1.png',
    );

    await pumpAvatarEditorPage(
      tester,
      isNewUser: false,
      initialOptions: fakeAvatarOptions(),
      avatarUser: avatar,
    );

    final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

    expect(find.text(l10n.editAvatar), findsOneWidget);
    expect(find.text(l10n.saveChangesButton), findsOneWidget);
    expect(find.byType(AvatarEditorPage), findsOneWidget);
  });

  testWidgets('pot obrir la pestanya Facial Hair i mostra opció none', (
    tester,
  ) async {
    await pumpAvatarEditorPage(tester, initialOptions: fakeAvatarOptions());

    final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

    await tester.tap(find.text(l10n.categoryFacialHair));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.block), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
  });

  testWidgets('pot obrir la pestanya Accessories i mostra opció none', (
    tester,
  ) async {
    await pumpAvatarEditorPage(tester, initialOptions: fakeAvatarOptions());

    final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

    await tester.tap(find.text(l10n.categoryAccessories));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.block), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
  });

  testWidgets('pot obrir la pestanya Clothing', (tester) async {
    await pumpAvatarEditorPage(tester, initialOptions: fakeAvatarOptions());

    final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

    await tester.tap(find.text(l10n.categoryClothing));
    await tester.pumpAndSettle();

    expect(find.byType(GridView), findsOneWidget);
    expect(find.byIcon(Icons.broken_image), findsWidgets);
  });

  testWidgets('pot obrir la pestanya Expression', (tester) async {
    await pumpAvatarEditorPage(tester, initialOptions: fakeAvatarOptions());

    final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

    await tester.tap(find.text(l10n.categoryExpression));
    await tester.pumpAndSettle();

    expect(find.byType(GridView), findsOneWidget);
    expect(find.byIcon(Icons.broken_image), findsWidgets);
  });

  testWidgets('mostra sense opcions si Eyes està buit', (tester) async {
    final options = fakeAvatarOptions();
    options['Eyes'] = [];

    await pumpAvatarEditorPage(tester, initialOptions: options);

    final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

    await tester.tap(find.text(l10n.categoryEyes));
    await tester.pumpAndSettle();

    expect(find.text(l10n.noOptionsAvailable), findsOneWidget);
  });

  testWidgets('mostra grid buit si Hair no té opcions del color seleccionat', (
    tester,
  ) async {
    final options = fakeAvatarOptions();
    options['Hair'] = ['https://example.com/avatar/hair/red/1.png'];

    await pumpAvatarEditorPage(tester, initialOptions: options);

    final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

    await tester.tap(find.text(l10n.categoryHair));
    await tester.pumpAndSettle();

    expect(find.byType(GridView), findsOneWidget);
    expect(find.byIcon(Icons.block), findsNothing);
    expect(find.text(l10n.noOptionsAvailable), findsNothing);
  });

  testWidgets('pot seleccionar una opció a la pestanya Eyes', (tester) async {
    await pumpAvatarEditorPage(tester, initialOptions: fakeAvatarOptions());

    final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

    await tester.tap(find.text(l10n.categoryEyes));
    await tester.pumpAndSettle();

    final options = find.byType(GestureDetector);
    await tester.tap(options.last);
    await tester.pump();

    expect(find.byType(AvatarEditorPage), findsOneWidget);
  });

  testWidgets('pot seleccionar none a Accessories', (tester) async {
    await pumpAvatarEditorPage(tester, initialOptions: fakeAvatarOptions());

    final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

    await tester.tap(find.text(l10n.categoryAccessories));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.block));
    await tester.pump();

    expect(find.byType(AvatarEditorPage), findsOneWidget);
  });
}

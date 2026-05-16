import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_garden/generated/app_localizations.dart';
import 'package:meteo_garden/models/dades_usr.dart';
import 'package:meteo_garden/models/plantes_desbl.dart';
import 'package:meteo_garden/screens/photo_page.dart';
import 'package:provider/provider.dart';

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
    newMonedes: 0,
    newGardens: const [],
  );

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<UserModel>.value(value: userModel),
      ChangeNotifierProvider<PlantProvider>.value(value: PlantProvider()),
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
      home: PlantCameraScreen(enableCamera: false),
    ),
  );
}

Future<void> pumpPlantCameraScreen(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 2000);
  tester.view.devicePixelRatio = 1.0;

  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(makeTestableWidget());
  await tester.pump();
}

void main() {
  testWidgets('mostra la pantalla de càmera de planta', (tester) async {
    await pumpPlantCameraScreen(tester);

    expect(find.byKey(const Key('plant_camera_screen')), findsOneWidget);
  });

  testWidgets('mostra loading quan la càmera no està inicialitzada',
      (tester) async {
    await pumpPlantCameraScreen(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('no mostra el botó de fer foto si la càmera no està inicialitzada',
      (tester) async {
    await pumpPlantCameraScreen(tester);

    expect(find.byKey(const Key('take_plant_picture_button')), findsNothing);
  });
}
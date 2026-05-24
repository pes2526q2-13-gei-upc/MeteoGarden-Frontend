import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_garden/generated/app_localizations.dart';
import 'package:meteo_garden/models/dades_usr.dart';
import 'package:meteo_garden/screens/photo_page.dart';
import 'package:meteo_garden/services/plant_service.dart';
import 'package:provider/provider.dart';

Widget makeTestablePhotoPage({
  Future<String> Function()? takePictureForTest,
  Future<String> Function(String imagePath)? cropImageForTest,
  IdentifyPlantForTest? identifyPlantForTest,
  Future<void> Function(UserModel user)? reloadPlantsForTest,
  bool enableCamera = true,
  bool useFakeCameraPreview = true,
  bool navigateToResultPage = false,
}) {
  final userModel = createTestUserModel();

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
      home: PlantCameraScreen(
        enableCamera: enableCamera,
        useFakeCameraPreview: useFakeCameraPreview,
        navigateToResultPage: navigateToResultPage,
        takePictureForTest: takePictureForTest,
        cropImageForTest: cropImageForTest,
        identifyPlantForTest: identifyPlantForTest,
        reloadPlantsForTest: reloadPlantsForTest,
      ),
    ),
  );
}

UserModel createTestUserModel() {
  final userModel = UserModel();

  userModel.setToken('fake-token');
  userModel.setProfile(
    newUsername: 'jana',
    newEmail: 'jana@test.com',
    newCity: 'Barcelona',
    newLanguage: 'ca',
    newLastEntry: '',
    newNumPlantsCollected: 0,
    newMonedes: 100,
    newGardens: const ['JardiJana'],
  );

  return userModel;
}

void configureMobileTestView(WidgetTester tester) {
  tester.view.physicalSize = const Size(430, 932);
  tester.view.devicePixelRatio = 1.0;

  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

Future<void> pumpPhotoPage(
  WidgetTester tester, {
  Future<String> Function()? takePictureForTest,
  Future<String> Function(String imagePath)? cropImageForTest,
  IdentifyPlantForTest? identifyPlantForTest,
  Future<void> Function(UserModel user)? reloadPlantsForTest,
  bool enableCamera = true,
  bool useFakeCameraPreview = true,
  bool navigateToResultPage = false,
}) async {
  configureMobileTestView(tester);

  await tester.pumpWidget(
    makeTestablePhotoPage(
      takePictureForTest: takePictureForTest,
      cropImageForTest: cropImageForTest,
      identifyPlantForTest: identifyPlantForTest,
      reloadPlantsForTest: reloadPlantsForTest,
      enableCamera: enableCamera,
      useFakeCameraPreview: useFakeCameraPreview,
      navigateToResultPage: navigateToResultPage,
    ),
  );

  await tester.pumpAndSettle();
}

Future<void> clearSnackBarTimer(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 4));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PlantCameraScreen', () {
    testWidgets('mostra la pantalla de càmera en mode fake preview', (
      tester,
    ) async {
      await pumpPhotoPage(
        tester,
        takePictureForTest: () async => '/tmp/original.jpg',
        cropImageForTest: (imagePath) async => '/tmp/cropped.jpg',
        identifyPlantForTest:
            ({required username, required imagePath, required organ}) async {
              return null;
            },
        reloadPlantsForTest: (_) async {},
      );

      expect(find.byKey(const Key('plant_camera_screen')), findsOneWidget);
      expect(find.byKey(const Key('fake_camera_preview')), findsOneWidget);
      expect(find.text('MeteoGarden'), findsOneWidget);
      expect(find.byIcon(Icons.park), findsOneWidget);
      expect(find.byIcon(Icons.local_florist), findsOneWidget);
      expect(
        find.byKey(const Key('take_plant_picture_button')),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.photo), findsOneWidget);
      expect(find.byIcon(Icons.cameraswitch), findsOneWidget);
    });

    testWidgets('per defecte envia organ leaf quan es fa foto', (tester) async {
      String? capturedUsername;
      String? capturedImagePath;
      String? capturedOrgan;
      var reloadCalled = false;

      await pumpPhotoPage(
        tester,
        takePictureForTest: () async => '/tmp/original.jpg',
        cropImageForTest: (imagePath) async {
          expect(imagePath, '/tmp/original.jpg');
          return '/tmp/cropped.jpg';
        },
        identifyPlantForTest:
            ({required username, required imagePath, required organ}) async {
              capturedUsername = username;
              capturedImagePath = imagePath;
              capturedOrgan = organ;
              return null;
            },
        reloadPlantsForTest: (_) async {
          reloadCalled = true;
        },
      );

      await tester.tap(find.byKey(const Key('take_plant_picture_button')));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(capturedUsername, 'jana');
      expect(capturedImagePath, '/tmp/cropped.jpg');
      expect(capturedOrgan, 'leaf');
      expect(reloadCalled, isTrue);
    });

    testWidgets('si selecciona flor envia organ flower', (tester) async {
      String? capturedOrgan;

      await pumpPhotoPage(
        tester,
        takePictureForTest: () async => '/tmp/original.jpg',
        cropImageForTest: (_) async => '/tmp/cropped.jpg',
        identifyPlantForTest:
            ({required username, required imagePath, required organ}) async {
              capturedOrgan = organ;
              return null;
            },
        reloadPlantsForTest: (_) async {},
      );

      await tester.tap(find.byIcon(Icons.local_florist));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('take_plant_picture_button')));
      await tester.pumpAndSettle();

      expect(capturedOrgan, 'flower');
    });

    testWidgets('pot tornar de flower a leaf i envia leaf', (tester) async {
      String? capturedOrgan;

      await pumpPhotoPage(
        tester,
        takePictureForTest: () async => '/tmp/original.jpg',
        cropImageForTest: (_) async => '/tmp/cropped.jpg',
        identifyPlantForTest:
            ({required username, required imagePath, required organ}) async {
              capturedOrgan = organ;
              return null;
            },
        reloadPlantsForTest: (_) async {},
      );

      await tester.tap(find.byIcon(Icons.local_florist));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.park));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('take_plant_picture_button')));
      await tester.pumpAndSettle();

      expect(capturedOrgan, 'leaf');
    });

    testWidgets(
      'mostra SnackBar si PlantService retorna PlantIdentificationException',
      (tester) async {
        await pumpPhotoPage(
          tester,
          takePictureForTest: () async => '/tmp/original.jpg',
          cropImageForTest: (_) async => '/tmp/cropped.jpg',
          identifyPlantForTest:
              ({required username, required imagePath, required organ}) async {
                throw PlantIdentificationException(
                  'No s’ha pogut identificar la planta',
                );
              },
          reloadPlantsForTest: (_) async {},
        );

        await tester.tap(find.byKey(const Key('take_plant_picture_button')));
        await tester.pumpAndSettle();

        expect(find.text('No s’ha pogut identificar la planta'), findsWidgets);

        await clearSnackBarTimer(tester);
      },
    );

    testWidgets('mostra error inesperat si falla qualsevol altre pas', (
      tester,
    ) async {
      await pumpPhotoPage(
        tester,
        takePictureForTest: () async => '/tmp/original.jpg',
        cropImageForTest: (_) async => '/tmp/cropped.jpg',
        identifyPlantForTest:
            ({required username, required imagePath, required organ}) async {
              throw Exception('server down');
            },
        reloadPlantsForTest: (_) async {},
      );

      await tester.tap(find.byKey(const Key('take_plant_picture_button')));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);

      await clearSnackBarTimer(tester);
    });

    testWidgets('si falla la captura mostra error inesperat', (tester) async {
      var cropCalled = false;
      var identifyCalled = false;

      await pumpPhotoPage(
        tester,
        takePictureForTest: () async {
          throw Exception('camera failed');
        },
        cropImageForTest: (_) async {
          cropCalled = true;
          return '/tmp/cropped.jpg';
        },
        identifyPlantForTest:
            ({required username, required imagePath, required organ}) async {
              identifyCalled = true;
              return null;
            },
        reloadPlantsForTest: (_) async {},
      );

      await tester.tap(find.byKey(const Key('take_plant_picture_button')));
      await tester.pumpAndSettle();

      expect(cropCalled, isFalse);
      expect(identifyCalled, isFalse);
      expect(find.byType(SnackBar), findsOneWidget);

      await clearSnackBarTimer(tester);
    });

    testWidgets('si el crop falla mostra error inesperat', (tester) async {
      var identifyCalled = false;

      await pumpPhotoPage(
        tester,
        takePictureForTest: () async => '/tmp/original.jpg',
        cropImageForTest: (_) async {
          throw Exception('crop failed');
        },
        identifyPlantForTest:
            ({required username, required imagePath, required organ}) async {
              identifyCalled = true;
              return null;
            },
        reloadPlantsForTest: (_) async {},
      );

      await tester.tap(find.byKey(const Key('take_plant_picture_button')));
      await tester.pumpAndSettle();

      expect(identifyCalled, isFalse);
      expect(find.byType(SnackBar), findsOneWidget);

      await clearSnackBarTimer(tester);
    });

    testWidgets('si falla reloadPlantsForTest mostra error inesperat', (
      tester,
    ) async {
      var identifyCalled = false;

      await pumpPhotoPage(
        tester,
        takePictureForTest: () async => '/tmp/original.jpg',
        cropImageForTest: (_) async => '/tmp/cropped.jpg',
        identifyPlantForTest:
            ({required username, required imagePath, required organ}) async {
              identifyCalled = true;
              return null;
            },
        reloadPlantsForTest: (_) async {
          throw Exception('reload failed');
        },
      );

      await tester.tap(find.byKey(const Key('take_plant_picture_button')));
      await tester.pumpAndSettle();

      expect(identifyCalled, isTrue);
      expect(find.byType(SnackBar), findsOneWidget);

      await clearSnackBarTimer(tester);
    });

    testWidgets(
      'evita dobles identificacions si es prem el botó dues vegades ràpid',
      (tester) async {
        var identifyCalls = 0;
        final completer = Completer<void>();

        await pumpPhotoPage(
          tester,
          takePictureForTest: () async => '/tmp/original.jpg',
          cropImageForTest: (_) async => '/tmp/cropped.jpg',
          identifyPlantForTest:
              ({required username, required imagePath, required organ}) async {
                identifyCalls++;
                await completer.future;
                return null;
              },
          reloadPlantsForTest: (_) async {},
        );

        final button = find.byKey(const Key('take_plant_picture_button'));

        await tester.tap(button);
        await tester.pump();

        await tester.tap(button);
        await tester.pump();

        expect(identifyCalls, 1);

        completer.complete();
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'si enableCamera és false i no hi ha fake preview mostra loading',
      (tester) async {
        configureMobileTestView(tester);

        await tester.pumpWidget(
          makeTestablePhotoPage(
            enableCamera: false,
            useFakeCameraPreview: false,
          ),
        );

        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );
  });
}

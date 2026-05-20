import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_garden/generated/app_localizations.dart';
import 'package:meteo_garden/models/dades_usr.dart';
import 'package:meteo_garden/models/garden.dart';
import 'package:meteo_garden/models/seed_option.dart';
import 'package:meteo_garden/services/garden_service.dart';
import 'package:meteo_garden/widgets/potion_selection_sheet.dart';
import 'package:provider/provider.dart';

class FakeGardenService extends GardenService {
  bool throwOnFetchProducts = false;
  bool throwOnApplyPotion = false;

  String? fetchedProductsUsername;
  String? appliedUsername;
  String? appliedGardenName;
  int? appliedPotNumber;
  String? appliedProductName;
  String? appliedToken;

  List<ProductItem> products = [
    ProductItem(
      productName: 'growth_potion',
      displayName: 'Poció de creixement',
      amount: 2,
      imageUrl: '',
      description: 'Accelera el creixement de la planta.',
    ),
    ProductItem(
      productName: 'magic_potion',
      displayName: 'Poció màgica',
      amount: 1,
      imageUrl: '',
      description: 'Poció màgica de prova.',
    ),
  ];

  @override
  Future<List<ProductItem>> fetchProducts(String username) async {
    fetchedProductsUsername = username;

    if (throwOnFetchProducts) {
      throw Exception('Error carregant productes fake');
    }

    return products;
  }

  @override
  Future<String> applyPotion({
    required String username,
    required String gardenName,
    required int potNumber,
    required String productName,
    required String token,
  }) async {
    appliedUsername = username;
    appliedGardenName = gardenName;
    appliedPotNumber = potNumber;
    appliedProductName = productName;
    appliedToken = token;

    if (throwOnApplyPotion) {
      throw Exception('No es pot aplicar la poció fake');
    }

    return 'Poció aplicada correctament';
  }
}

GardenPot fakePot() {
  return GardenPot(
    potNumber: 3,
    occupied: true,
    plant: null,
    growthPhase: null,
    healthLevel: null,
    waterLevel: null,
    plantedAt: null,
    lastWateredAt: null,
    activeProducts: const [],
  );
}

Widget makeTestableWidget({
  required FakeGardenService gardenService,
  required Future<void> Function(int potNumber) onPotionSuccess,
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
      home: Scaffold(
        body: Center(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => PotionSelectionSheet(
                      pot: fakePot(),
                      username: 'jana',
                      gardenName: 'JardiJana',
                      gardenService: gardenService,
                      onPotionSuccess: onPotionSuccess,
                    ),
                  );
                },
                child: const Text('Obrir pocions'),
              );
            },
          ),
        ),
      ),
    ),
  );
}

Future<void> openPotionSheet(
  WidgetTester tester, {
  required FakeGardenService gardenService,
  Future<void> Function(int potNumber)? onPotionSuccess,
}) async {
  tester.view.physicalSize = const Size(1200, 2000);
  tester.view.devicePixelRatio = 1.0;

  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    makeTestableWidget(
      gardenService: gardenService,
      onPotionSuccess: onPotionSuccess ?? (_) async {},
    ),
  );

  await tester.tap(find.text('Obrir pocions'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('carrega les pocions de l’usuari', (tester) async {
    final gardenService = FakeGardenService();

    await openPotionSheet(tester, gardenService: gardenService);

    expect(gardenService.fetchedProductsUsername, 'jana');
    expect(find.text('Poció de creixement'), findsOneWidget);
    expect(find.text('Poció màgica'), findsOneWidget);
    expect(find.text('x2'), findsOneWidget);
    expect(find.text('x1'), findsOneWidget);
  });

  testWidgets(
    'el botó aplicar està desactivat si no hi ha poció seleccionada',
    (tester) async {
      final gardenService = FakeGardenService();

      await openPotionSheet(tester, gardenService: gardenService);

      final elevatedButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton).last,
      );

      expect(elevatedButton.onPressed, isNull);
    },
  );

  testWidgets('selecciona una poció i activa el botó aplicar', (tester) async {
    final gardenService = FakeGardenService();

    await openPotionSheet(tester, gardenService: gardenService);

    await tester.tap(find.text('Poció de creixement'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

    final elevatedButton = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton).last,
    );

    expect(elevatedButton.onPressed, isNotNull);
  });

  testWidgets('aplica una poció correctament i mostra vista d’èxit', (
    tester,
  ) async {
    final gardenService = FakeGardenService();

    await openPotionSheet(tester, gardenService: gardenService);

    await tester.tap(find.text('Poció de creixement'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ElevatedButton).last);
    await tester.pumpAndSettle();

    expect(gardenService.appliedUsername, 'jana');
    expect(gardenService.appliedGardenName, 'JardiJana');
    expect(gardenService.appliedPotNumber, 3);
    expect(gardenService.appliedProductName, 'growth_potion');
    expect(gardenService.appliedToken, 'fake-token');

    expect(find.text('Poció aplicada correctament'), findsOneWidget);
    expect(find.text('Tancar'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  });

  testWidgets('crida onPotionSuccess i tanca el bottom sheet', (tester) async {
    final gardenService = FakeGardenService();

    int? successPotNumber;

    await openPotionSheet(
      tester,
      gardenService: gardenService,
      onPotionSuccess: (potNumber) async {
        successPotNumber = potNumber;
      },
    );

    await tester.tap(find.text('Poció de creixement'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ElevatedButton).last);
    await tester.pumpAndSettle();

    expect(find.text('Tancar'), findsOneWidget);

    await tester.tap(find.text('Tancar'));
    await tester.pumpAndSettle();

    expect(successPotNumber, 3);
    expect(find.text('Poció aplicada correctament'), findsNothing);
    expect(find.text('Obrir pocions'), findsOneWidget);
  });

  testWidgets('mostra error si falla aplicar la poció', (tester) async {
    final gardenService = FakeGardenService()..throwOnApplyPotion = true;

    await openPotionSheet(tester, gardenService: gardenService);

    await tester.tap(find.text('Poció de creixement'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ElevatedButton).last);
    await tester.pumpAndSettle();

    expect(gardenService.appliedProductName, 'growth_potion');
    expect(gardenService.appliedToken, 'fake-token');
    expect(find.text('No es pot aplicar la poció fake'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
  });

  testWidgets('mostra estat buit quan no hi ha pocions', (tester) async {
    final gardenService = FakeGardenService()..products = [];

    await openPotionSheet(tester, gardenService: gardenService);

    expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    expect(find.text('Poció de creixement'), findsNothing);
  });

  testWidgets('mostra error si falla carregar les pocions', (tester) async {
    final gardenService = FakeGardenService()..throwOnFetchProducts = true;

    await openPotionSheet(tester, gardenService: gardenService);

    expect(find.text('Error carregant pocions'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
  });

  testWidgets('mostra icona per defecte si la poció no té imatge', (
    tester,
  ) async {
    final gardenService = FakeGardenService();

    await openPotionSheet(tester, gardenService: gardenService);

    expect(find.byIcon(Icons.local_drink), findsWidgets);
  });

  testWidgets('mostra Image.network si la poció té imatge', (tester) async {
  final gardenService = FakeGardenService()
    ..products = [
      ProductItem(
        productName: 'hydration_shield',
        displayName: 'Escut hidratant',
        amount: 1,
        imageUrl: 'https://example.com/potion.png',
        description: 'Redueix la pèrdua d’aigua.',
      ),
    ];

  await openPotionSheet(tester, gardenService: gardenService);

  expect(find.text('Escut hidratant'), findsOneWidget);

  final networkImages = tester
      .widgetList<Image>(find.byType(Image))
      .where((image) => image.image is NetworkImage)
      .toList();

  expect(networkImages.length, 1);
  expect(networkImages.first.image, isA<NetworkImage>());
});
}
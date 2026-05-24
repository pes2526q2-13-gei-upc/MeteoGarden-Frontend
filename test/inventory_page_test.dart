import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_garden/generated/app_localizations.dart';
import 'package:meteo_garden/models/seed_option.dart';
import 'package:meteo_garden/screens/inventory_page.dart';
import 'package:meteo_garden/services/garden_service.dart';

class FakeGardenService extends GardenService {
  bool throwOnLoad = false;

  int fetchSeedsCalls = 0;
  int fetchProductsCalls = 0;

  String? fetchedSeedsUsername;
  String? fetchedProductsUsername;
  String? fetchedPlantScientificName;
  String? fetchedPlantLanguage;

  List<SeedOption> seeds = [
    const SeedOption(scientificName: 'Aloe vera', amount: 2, imageUrl: ''),
    const SeedOption(scientificName: 'Basilicum', amount: 5, imageUrl: ''),
  ];

  List<ProductItem> products = [
    ProductItem(
      productName: 'growth_potion',
      displayName: 'Pocio de creixement',
      amount: 3,
      imageUrl: '',
      description: 'Accelera el creixement de la planta.',
    ),
    ProductItem(
      productName: 'fertilizer',
      displayName: 'Fertilitzant',
      amount: 1,
      imageUrl: '',
      description: 'Millora l’estat general de la planta.',
    ),
  ];

  @override
  Future<List<SeedOption>> fetchSeeds(String username) async {
    fetchSeedsCalls++;
    fetchedSeedsUsername = username;

    if (throwOnLoad) {
      throw Exception('Error inventari fake');
    }

    return seeds;
  }

  @override
  Future<List<ProductItem>> fetchProducts(String username) async {
    fetchProductsCalls++;
    fetchedProductsUsername = username;

    if (throwOnLoad) {
      throw Exception('Error inventari fake');
    }

    return products;
  }

  @override
  Future<Map<String, dynamic>> fetchPlantDetails(
    String scientificName,
    String lang,
  ) async {
    fetchedPlantScientificName = scientificName;
    fetchedPlantLanguage = lang;

    return {
      'commonName': 'Aloe vera comuna',
      'scientificName': scientificName,
      'family': 'Asphodelaceae',
      'canFlower': true,
      'minTemperature': 10,
      'maxTemperature': 30,
      'description': 'Descripcio fake de la planta.',
    };
  }
}

Widget makeTestableWidget({required Widget child}) {
  return MaterialApp(
    locale: const Locale('ca'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

Future<void> pumpInventoryPage(
  WidgetTester tester, {
  required FakeGardenService gardenService,
}) async {
  tester.view.physicalSize = const Size(1200, 2000);
  tester.view.devicePixelRatio = 1.0;

  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    makeTestableWidget(
      child: InventoryPage(username: 'jana', gardenService: gardenService),
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  testWidgets('carrega inventari i crida fetchSeeds i fetchProducts', (
    tester,
  ) async {
    final gardenService = FakeGardenService();

    await pumpInventoryPage(tester, gardenService: gardenService);

    expect(gardenService.fetchSeedsCalls, 1);
    expect(gardenService.fetchProductsCalls, 1);
    expect(gardenService.fetchedSeedsUsername, 'jana');
    expect(gardenService.fetchedProductsUsername, 'jana');
  });

  testWidgets('mostra el títol i la graella de llavors', (tester) async {
    final gardenService = FakeGardenService();

    await pumpInventoryPage(tester, gardenService: gardenService);

    expect(find.byKey(const Key('inventory_title')), findsOneWidget);
    expect(find.byKey(const Key('inventory_seeds_grid')), findsOneWidget);
    expect(find.byKey(const Key('seed_card_Aloe vera')), findsOneWidget);
    expect(find.byKey(const Key('seed_card_Basilicum')), findsOneWidget);
    expect(find.text('Aloe vera'), findsOneWidget);
    expect(find.text('Basilicum'), findsOneWidget);
  });

  testWidgets('mostra la pestanya de productes', (tester) async {
    final gardenService = FakeGardenService();

    await pumpInventoryPage(tester, gardenService: gardenService);

    await tester.tap(find.byKey(const Key('inventory_products_tab')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('inventory_products_grid')), findsOneWidget);

    expect(find.byKey(const Key('product_card_growth_potion')), findsOneWidget);
    expect(find.byKey(const Key('product_card_fertilizer')), findsOneWidget);

    expect(find.text('Pocio de creixement'), findsOneWidget);
    expect(find.text('Fertilitzant'), findsOneWidget);
  });

  testWidgets('filtra les llavors amb el cercador', (tester) async {
    final gardenService = FakeGardenService();

    await pumpInventoryPage(tester, gardenService: gardenService);

    await tester.enterText(find.byType(TextField), 'aloe');
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('seed_card_Aloe vera')), findsOneWidget);
    expect(find.byKey(const Key('seed_card_Basilicum')), findsNothing);
  });

  testWidgets('filtra els productes amb el cercador per displayName', (
    tester,
  ) async {
    final gardenService = FakeGardenService();

    await pumpInventoryPage(tester, gardenService: gardenService);

    await tester.tap(find.byKey(const Key('inventory_products_tab')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'fert');
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('product_card_fertilizer')), findsOneWidget);
    expect(find.byKey(const Key('product_card_growth_potion')), findsNothing);
  });

  testWidgets('filtra els productes amb el cercador per productName', (
    tester,
  ) async {
    final gardenService = FakeGardenService();

    await pumpInventoryPage(tester, gardenService: gardenService);

    await tester.tap(find.byKey(const Key('inventory_products_tab')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'growth');
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('product_card_growth_potion')), findsOneWidget);
    expect(find.byKey(const Key('product_card_fertilizer')), findsNothing);
  });

  testWidgets('mostra estat buit si no hi ha llavors', (tester) async {
    final gardenService = FakeGardenService()..seeds = [];

    await pumpInventoryPage(tester, gardenService: gardenService);

    expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    expect(find.byKey(const Key('inventory_seeds_grid')), findsNothing);
  });

  testWidgets('mostra estat buit si no hi ha productes', (tester) async {
    final gardenService = FakeGardenService()..products = [];

    await pumpInventoryPage(tester, gardenService: gardenService);

    await tester.tap(find.byKey(const Key('inventory_products_tab')));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    expect(find.byKey(const Key('inventory_products_grid')), findsNothing);
  });

  testWidgets('mostra error si falla la càrrega de l’inventari', (
    tester,
  ) async {
    final gardenService = FakeGardenService()..throwOnLoad = true;

    await pumpInventoryPage(tester, gardenService: gardenService);

    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.textContaining('Error inventari fake'), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });

  testWidgets('pot reintentar després d’un error', (tester) async {
    final gardenService = FakeGardenService()..throwOnLoad = true;

    await pumpInventoryPage(tester, gardenService: gardenService);

    expect(find.textContaining('Error inventari fake'), findsOneWidget);

    gardenService.throwOnLoad = false;

    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('inventory_seeds_grid')), findsOneWidget);
    expect(find.byKey(const Key('seed_card_Aloe vera')), findsOneWidget);
    expect(gardenService.fetchSeedsCalls, greaterThanOrEqualTo(2));
    expect(gardenService.fetchProductsCalls, greaterThanOrEqualTo(2));
  });

  testWidgets('obre el diàleg d’informació d’una llavor', (tester) async {
    final gardenService = FakeGardenService();

    await pumpInventoryPage(tester, gardenService: gardenService);

    await tester.tap(find.byKey(const Key('seed_card_Aloe vera')));
    await tester.pumpAndSettle();

    expect(gardenService.fetchedPlantScientificName, 'Aloe vera');
    expect(gardenService.fetchedPlantLanguage, 'ca');

    expect(find.text('Aloe vera comuna'), findsOneWidget);
    expect(find.text('Aloe vera'), findsWidgets);
    expect(find.textContaining('Asphodelaceae'), findsOneWidget);
    expect(find.textContaining('10° - 30°'), findsOneWidget);
    expect(find.text('Descripcio fake de la planta.'), findsOneWidget);
  });

  testWidgets('obre i tanca el diàleg d’informació d’un producte', (
    tester,
  ) async {
    final gardenService = FakeGardenService();

    await pumpInventoryPage(tester, gardenService: gardenService);

    await tester.tap(find.byKey(const Key('inventory_products_tab')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('product_card_fertilizer')));
    await tester.pumpAndSettle();

    expect(find.text('Fertilitzant'), findsWidgets);
    expect(
      find.textContaining('Millora l’estat general de la planta.'),
      findsOneWidget,
    );
    expect(find.text('Tancar'), findsOneWidget);

    await tester.tap(find.text('Tancar'));
    await tester.pumpAndSettle();

    expect(find.text('Tancar'), findsNothing);
  });

  testWidgets('obre producte sense description i no falla', (tester) async {
    final gardenService = FakeGardenService()
      ..products = [
        ProductItem(
          productName: 'medium_heal',
          displayName: 'Curació mitjana',
          amount: 2,
          imageUrl: '',
        ),
      ];

    await pumpInventoryPage(tester, gardenService: gardenService);

    await tester.tap(find.byKey(const Key('inventory_products_tab')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('product_card_medium_heal')));
    await tester.pumpAndSettle();

    expect(find.text('Curació mitjana'), findsWidgets);
    expect(find.text('Tancar'), findsOneWidget);
  });

  testWidgets('el botó enrere fa pop de la pantalla', (tester) async {
    final gardenService = FakeGardenService();

    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      makeTestableWidget(
        child: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => InventoryPage(
                          username: 'jana',
                          gardenService: gardenService,
                        ),
                      ),
                    );
                  },
                  child: const Text('Obrir inventari'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Obrir inventari'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('inventory_title')), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Obrir inventari'), findsOneWidget);
    expect(find.byKey(const Key('inventory_title')), findsNothing);
  });
}

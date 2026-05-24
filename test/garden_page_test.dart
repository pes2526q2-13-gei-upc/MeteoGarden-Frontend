import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_garden/generated/app_localizations.dart';
import 'package:meteo_garden/models/dades_usr.dart';
import 'package:meteo_garden/models/garden.dart';
import 'package:meteo_garden/models/plantes_desbl.dart';
import 'package:meteo_garden/models/seed_option.dart';
import 'package:meteo_garden/models/weather_info.dart';
import 'package:meteo_garden/models/weather_provider.dart';
import 'package:meteo_garden/screens/garden_page.dart';
import 'package:meteo_garden/services/garden_service.dart';
import 'package:meteo_garden/widgets/pot_info_sheet.dart';
import 'package:meteo_garden/widgets/pot_widget.dart';
import 'package:meteo_garden/widgets/weather_card.dart';
import 'package:provider/provider.dart';

class FakeGardenService extends GardenService {
  bool throwOnFetch = false;
  bool throwOnFetchSeeds = false;
  bool throwOnWater = false;
  bool throwOnCollect = false;
  bool throwOnDelete = false;

  String? fetchedUsername;
  String? fetchedGardenName;
  String? fetchedSeedsUsername;

  int fetchGardenPlantsCalls = 0;
  int fetchSeedsCalls = 0;
  int fetchPotStatusCalls = 0;
  int waterPlantCalls = 0;
  int collectPlantCalls = 0;
  int deletePlantCalls = 0;

  List<GardenPot> pots = [];

  @override
  Future<List<GardenPot>> fetchGardenPlants({
    required String username,
    required String gardenName,
  }) async {
    fetchGardenPlantsCalls++;
    fetchedUsername = username;
    fetchedGardenName = gardenName;

    if (throwOnFetch) {
      throw Exception('Error carregant testos fake');
    }

    return pots;
  }

  @override
  Future<List<SeedOption>> fetchSeeds(String username) async {
    fetchSeedsCalls++;
    fetchedSeedsUsername = username;

    if (throwOnFetchSeeds) {
      throw Exception('Error carregant llavors fake');
    }

    return [
      const SeedOption(scientificName: 'Aloe vera', amount: 2, imageUrl: ''),
      const SeedOption(
        scientificName: 'Mentha spicata',
        amount: 1,
        imageUrl: '',
      ),
    ];
  }

  @override
  Future<GardenPot> fetchPotStatus({
    required String username,
    required String gardenName,
    required int potNumber,
  }) async {
    fetchPotStatusCalls++;
    return fakeEmptyPot(potNumber: potNumber);
  }

  @override
  Future<String> waterPlant({
    required String username,
    required String gardenName,
    required int potNumber,
    required String token,
  }) async {
    waterPlantCalls++;

    if (throwOnWater) {
      throw Exception('No es pot regar ara');
    }

    return 'Planta regada correctament';
  }

  @override
  Future<CollectPlantResult> collectPlant({
    required String username,
    required String gardenName,
    required int potNumber,
    required String scientificName,
  }) async {
    collectPlantCalls++;

    if (throwOnCollect) {
      throw Exception('No es pot recol·lectar ara');
    }

    return CollectPlantResult.fromJson({
      'message': 'Planta recol·lectada correctament',
      'new_balance': 35,
    });
  }

  @override
  Future<String> deletePlant({
    required String username,
    required String gardenName,
    required int potNumber,
    required String token,
  }) async {
    deletePlantCalls++;

    if (throwOnDelete) {
      throw Exception('No es pot eliminar ara');
    }

    return 'Planta eliminada correctament';
  }
}

class FakeWeatherProvider extends WeatherProvider {
  String? fetchedCity;
  String? fetchedToken;
  bool? fetchedForceRefresh;

  WeatherInfo? fakeWeather;
  bool fakeIsLoading = false;
  String? fakeError;

  int fetchWeatherCalls = 0;

  @override
  WeatherInfo? get currentWeather => fakeWeather;

  @override
  bool get isLoading => fakeIsLoading;

  @override
  String? get error => fakeError;

  @override
  Future<void> fetchWeather(
    String city, {
    required String token,
    bool forceRefresh = false,
  }) async {
    fetchWeatherCalls++;
    fetchedCity = city;
    fetchedToken = token;
    fetchedForceRefresh = forceRefresh;
  }
}

WeatherInfo fakeWeatherInfo() {
  return WeatherInfo(
    temp: 22.5,
    relativeHumidity: 65,
    wind: 12.3,
    precipitation: '1.2',
    solarIrradiance: 450.7,
    stationName: 'Estació Barcelona',
  );
}

PlantData fakePlantData() {
  return PlantData(
    scientificName: 'aloe_vera',
    commonName: 'Aloe vera',
    family: 'Asphodelaceae',
    canFlower: true,
    minTemperature: 8,
    maxTemperature: 30,
    imageUrl: '',
  );
}

GardenPot fakeEmptyPot({int potNumber = 1}) {
  return GardenPot(
    potNumber: potNumber,
    occupied: false,
    plant: null,
    growthPhase: null,
    healthLevel: null,
    waterLevel: null,
    plantedAt: null,
    lastWateredAt: null,
    activeProducts: [],
  );
}

GardenPot fakeOccupiedPot({
  int potNumber = 1,
  List<ActivePotion> activeProducts = const [],
}) {
  return GardenPot(
    potNumber: potNumber,
    occupied: true,
    plant: fakePlantData(),
    growthPhase: 'mature',
    healthLevel: 80,
    waterLevel: 60,
    plantedAt: DateTime(2026, 5, 20),
    lastWateredAt: DateTime(2026, 5, 20),
    activeProducts: activeProducts,
  );
}

Widget makeTestableWidget({
  required Widget child,
  required FakeWeatherProvider weatherProvider,
  String token = 'fake-token',
  int monedes = 25,
}) {
  final userModel = UserModel();

  userModel.setToken(token);
  userModel.setProfile(
    newUsername: 'jana',
    newEmail: 'jana@test.com',
    newCity: 'Barcelona',
    newLanguage: 'ca',
    newLastEntry: '',
    newNumPlantsCollected: 0,
    newMonedes: monedes,
    newGardens: const ['JardiJana'],
  );

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<UserModel>.value(value: userModel),
      ChangeNotifierProvider<WeatherProvider>.value(value: weatherProvider),
      ChangeNotifierProvider<PlantProvider>(
        create: (_) => PlantProvider(),
      ),
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
      home: child,
    ),
  );
}

Future<void> pumpGardenPage(
  WidgetTester tester, {
  required FakeWeatherProvider weatherProvider,
  required FakeGardenService gardenService,
  Size size = const Size(1200, 2000),
  String token = 'fake-token',
  int monedes = 25,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;

  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    makeTestableWidget(
      weatherProvider: weatherProvider,
      token: token,
      monedes: monedes,
      child: GardenPage(
        username: 'jana',
        gardenName: 'JardiJana',
        gardenService: gardenService,
      ),
    ),
  );

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void setUserToken(WidgetTester tester, String token) {
  final context = tester.element(find.byType(GardenPage));
  Provider.of<UserModel>(context, listen: false).setToken(token);
}

Future<PotInfoSheet> openOccupiedPotSheet(
  WidgetTester tester,
  FakeGardenService gardenService,
  FakeWeatherProvider weatherProvider,
) async {
  gardenService.pots = [fakeOccupiedPot(potNumber: 1)];
  weatherProvider.fakeWeather = fakeWeatherInfo();

  await pumpGardenPage(
    tester,
    gardenService: gardenService,
    weatherProvider: weatherProvider,
  );

  expect(find.byType(PotWidget), findsOneWidget);

  await tester.tap(find.byType(PotWidget).first);
  await tester.pumpAndSettle();

  expect(find.byType(PotInfoSheet), findsOneWidget);

  return tester.widget<PotInfoSheet>(find.byType(PotInfoSheet));
}

Future<void> finishCenteredMessageTimer(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

Future<void> closeCollectDialog(WidgetTester tester) async {
  await tester.pumpAndSettle();

  expect(find.byType(Dialog), findsOneWidget);
  expect(find.text('Planta recol·lectada correctament'), findsOneWidget);

  await tester.tap(find.byType(ElevatedButton).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('carrega GardenPage i crida fetchGardenPlants', (tester) async {
    final gardenService = FakeGardenService();
    final weatherProvider = FakeWeatherProvider();

    await pumpGardenPage(
      tester,
      gardenService: gardenService,
      weatherProvider: weatherProvider,
    );

    expect(gardenService.fetchGardenPlantsCalls, 1);
    expect(gardenService.fetchedUsername, 'jana');
    expect(gardenService.fetchedGardenName, 'JardiJana');
    expect(find.byType(GardenPage), findsOneWidget);
  });

  testWidgets('mostra error si no hi ha token en carregar testos', (
    tester,
  ) async {
    final gardenService = FakeGardenService();
    final weatherProvider = FakeWeatherProvider();

    await pumpGardenPage(
      tester,
      gardenService: gardenService,
      weatherProvider: weatherProvider,
      token: '',
    );

    expect(gardenService.fetchGardenPlantsCalls, 0);
    expect(find.textContaining('No hi ha token guardat'), findsOneWidget);
  });

  testWidgets('crida fetchWeather amb la ciutat i el token de l’usuari', (
    tester,
  ) async {
    final gardenService = FakeGardenService();
    final weatherProvider = FakeWeatherProvider();

    await pumpGardenPage(
      tester,
      gardenService: gardenService,
      weatherProvider: weatherProvider,
    );

    expect(weatherProvider.fetchWeatherCalls, greaterThanOrEqualTo(1));
    expect(weatherProvider.fetchedCity, 'Barcelona');
    expect(weatherProvider.fetchedToken, 'fake-token');
    expect(weatherProvider.fetchedForceRefresh, true);
  });

  testWidgets('mostra les monedes de l’usuari', (tester) async {
    final gardenService = FakeGardenService();
    final weatherProvider = FakeWeatherProvider();

    await pumpGardenPage(
      tester,
      gardenService: gardenService,
      weatherProvider: weatherProvider,
    );

    expect(find.text('25'), findsOneWidget);
  });

  testWidgets('mostra missatge quan no hi ha testos disponibles', (
    tester,
  ) async {
    final gardenService = FakeGardenService();
    final weatherProvider = FakeWeatherProvider();

    await pumpGardenPage(
      tester,
      gardenService: gardenService,
      weatherProvider: weatherProvider,
    );

    final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

    expect(find.text(l10n.gardenNoPotsAvailable), findsOneWidget);
  });

  testWidgets('mostra error quan falla la càrrega dels testos', (tester) async {
    final gardenService = FakeGardenService()..throwOnFetch = true;
    final weatherProvider = FakeWeatherProvider();

    await pumpGardenPage(
      tester,
      gardenService: gardenService,
      weatherProvider: weatherProvider,
    );

    expect(find.textContaining('Error carregant testos fake'), findsOneWidget);
  });

  testWidgets('existeix el botó d’inventari', (tester) async {
    final gardenService = FakeGardenService();
    final weatherProvider = FakeWeatherProvider();

    await pumpGardenPage(
      tester,
      gardenService: gardenService,
      weatherProvider: weatherProvider,
    );

    expect(find.byKey(const Key('garden_inventory_button')), findsOneWidget);
  });

  testWidgets('existeix el botó de calendari', (tester) async {
    final gardenService = FakeGardenService();
    final weatherProvider = FakeWeatherProvider();

    await pumpGardenPage(
      tester,
      gardenService: gardenService,
      weatherProvider: weatherProvider,
    );

    expect(find.byKey(const Key('garden_calendar_button')), findsOneWidget);
  });

  testWidgets('existeix el botó de botiga', (tester) async {
    final gardenService = FakeGardenService();
    final weatherProvider = FakeWeatherProvider();

    await pumpGardenPage(
      tester,
      gardenService: gardenService,
      weatherProvider: weatherProvider,
    );

    expect(find.byKey(const Key('garden_shop_button')), findsOneWidget);
  });

  testWidgets('existeix el botó de l’àlbum', (tester) async {
    final gardenService = FakeGardenService();
    final weatherProvider = FakeWeatherProvider();

    await pumpGardenPage(
      tester,
      gardenService: gardenService,
      weatherProvider: weatherProvider,
    );

    expect(find.byKey(const Key('garden_album_button')), findsOneWidget);
  });

  testWidgets('mostra estat de càrrega del temps', (tester) async {
    final gardenService = FakeGardenService();
    final weatherProvider = FakeWeatherProvider()
      ..fakeIsLoading = true
      ..fakeWeather = null;

    await pumpGardenPage(
      tester,
      gardenService: gardenService,
      weatherProvider: weatherProvider,
    );

    expect(find.byType(WeatherCard), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });

  testWidgets('mostra estat d’error del temps', (tester) async {
    final gardenService = FakeGardenService();
    final weatherProvider = FakeWeatherProvider()
      ..fakeError = 'Error fake'
      ..fakeWeather = null;

    await pumpGardenPage(
      tester,
      gardenService: gardenService,
      weatherProvider: weatherProvider,
    );

    expect(find.byType(WeatherCard), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
  });

  testWidgets('no mostra WeatherCard si no hi ha temps, ni loading ni error', (
    tester,
  ) async {
    final gardenService = FakeGardenService();
    final weatherProvider = FakeWeatherProvider()
      ..fakeWeather = null
      ..fakeIsLoading = false
      ..fakeError = null;

    await pumpGardenPage(
      tester,
      gardenService: gardenService,
      weatherProvider: weatherProvider,
    );

    expect(find.byType(WeatherCard), findsNothing);
  });

  testWidgets('mostra targeta del temps amb dades', (tester) async {
    final gardenService = FakeGardenService();
    final weatherProvider = FakeWeatherProvider()
      ..fakeWeather = fakeWeatherInfo();

    await pumpGardenPage(
      tester,
      gardenService: gardenService,
      weatherProvider: weatherProvider,
    );

    expect(find.byType(WeatherCard), findsOneWidget);
    expect(find.textContaining('22.5'), findsWidgets);
    expect(find.textContaining('12.3'), findsWidgets);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });

  testWidgets('pot refrescar el temps des de la WeatherCard', (tester) async {
    final gardenService = FakeGardenService();
    final weatherProvider = FakeWeatherProvider()
      ..fakeWeather = fakeWeatherInfo();

    await pumpGardenPage(
      tester,
      gardenService: gardenService,
      weatherProvider: weatherProvider,
    );

    final initialCalls = weatherProvider.fetchWeatherCalls;

    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();

    expect(weatherProvider.fetchWeatherCalls, greaterThan(initialCalls));
    expect(weatherProvider.fetchedCity, 'Barcelona');
    expect(weatherProvider.fetchedToken, 'fake-token');
    expect(weatherProvider.fetchedForceRefresh, true);
  });

  testWidgets('mostra una graella quan hi ha testos', (tester) async {
    final gardenService = FakeGardenService()
      ..pots = [
        fakeEmptyPot(potNumber: 1),
        fakeEmptyPot(potNumber: 2),
        fakeEmptyPot(potNumber: 3),
        fakeEmptyPot(potNumber: 4),
      ];

    final weatherProvider = FakeWeatherProvider()
      ..fakeWeather = fakeWeatherInfo();

    await pumpGardenPage(
      tester,
      gardenService: gardenService,
      weatherProvider: weatherProvider,
    );

    expect(find.byType(GridView), findsOneWidget);
    expect(find.byType(PotWidget), findsNWidgets(4));
  });

  testWidgets('mostra correctament molts testos en graella', (tester) async {
    final gardenService = FakeGardenService()
      ..pots = List.generate(8, (index) => fakeEmptyPot(potNumber: index + 1));

    final weatherProvider = FakeWeatherProvider()
      ..fakeWeather = fakeWeatherInfo();

    await pumpGardenPage(
      tester,
      gardenService: gardenService,
      weatherProvider: weatherProvider,
    );

    expect(find.byType(GridView), findsOneWidget);
    expect(find.byType(PotWidget), findsNWidgets(8));
  });

  testWidgets('tocar un test buit obre el selector de llavors', (tester) async {
    final gardenService = FakeGardenService()
      ..pots = [fakeEmptyPot(potNumber: 1)];

    final weatherProvider = FakeWeatherProvider()
      ..fakeWeather = fakeWeatherInfo();

    await pumpGardenPage(
      tester,
      gardenService: gardenService,
      weatherProvider: weatherProvider,
    );

    await tester.tap(find.byType(PotWidget).first);
    await tester.pumpAndSettle();

    expect(gardenService.fetchSeedsCalls, 1);
    expect(gardenService.fetchedSeedsUsername, 'jana');
    expect(find.text('Aloe vera'), findsOneWidget);
    expect(find.text('Mentha spicata'), findsOneWidget);
  });

  testWidgets('tocar test buit sense token mostra SnackBar', (tester) async {
    final gardenService = FakeGardenService()
      ..pots = [fakeEmptyPot(potNumber: 1)];

    final weatherProvider = FakeWeatherProvider()
      ..fakeWeather = fakeWeatherInfo();

    await pumpGardenPage(
      tester,
      gardenService: gardenService,
      weatherProvider: weatherProvider,
      token: 'fake-token',
    );

    setUserToken(tester, '');

    await tester.tap(find.byType(PotWidget).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(gardenService.fetchSeedsCalls, 0);
    expect(find.textContaining('No hi ha token guardat'), findsOneWidget);
  });

  testWidgets('mostra SnackBar si falla carregar llavors en tocar test buit', (
    tester,
  ) async {
    final gardenService = FakeGardenService()
      ..throwOnFetchSeeds = true
      ..pots = [fakeEmptyPot(potNumber: 1)];

    final weatherProvider = FakeWeatherProvider()
      ..fakeWeather = fakeWeatherInfo();

    await pumpGardenPage(
      tester,
      gardenService: gardenService,
      weatherProvider: weatherProvider,
    );

    await tester.tap(find.byType(PotWidget).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(gardenService.fetchSeedsCalls, 1);
    expect(find.textContaining('Error carregant llavors fake'), findsOneWidget);
  });

  testWidgets('tocar un test ocupat obre el full d’informació de la planta', (
    tester,
  ) async {
    final gardenService = FakeGardenService()
      ..pots = [fakeOccupiedPot(potNumber: 1)];

    final weatherProvider = FakeWeatherProvider()
      ..fakeWeather = fakeWeatherInfo();

    await pumpGardenPage(
      tester,
      gardenService: gardenService,
      weatherProvider: weatherProvider,
    );

    await tester.tap(find.byType(PotWidget).first);
    await tester.pumpAndSettle();

    expect(find.byType(PotInfoSheet), findsOneWidget);
    expect(find.text('Aloe vera'), findsWidgets);
  });

  testWidgets('tocar un test ocupat no carrega llavors', (tester) async {
    final gardenService = FakeGardenService()
      ..pots = [fakeOccupiedPot(potNumber: 1)];

    final weatherProvider = FakeWeatherProvider()
      ..fakeWeather = fakeWeatherInfo();

    await pumpGardenPage(
      tester,
      gardenService: gardenService,
      weatherProvider: weatherProvider,
    );

    await tester.tap(find.byType(PotWidget).first);
    await tester.pumpAndSettle();

    expect(gardenService.fetchSeedsCalls, 0);
    expect(find.byType(PotInfoSheet), findsOneWidget);
  });

  testWidgets('test ocupat amb poció activa calcula hasBuff', (tester) async {
    final activePotion = ActivePotion(
      name: 'growth_potion',
      displayName: 'Poció de creixement',
      appliedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );

    final pot = fakeOccupiedPot(
      potNumber: 1,
      activeProducts: [activePotion],
    );

    expect(pot.hasBuff, true);

    final gardenService = FakeGardenService()..pots = [pot];

    final weatherProvider = FakeWeatherProvider()
      ..fakeWeather = fakeWeatherInfo();

    await pumpGardenPage(
      tester,
      gardenService: gardenService,
      weatherProvider: weatherProvider,
    );

    expect(find.byType(PotWidget), findsOneWidget);
  });

  testWidgets('ActivePotion inactiva no compta com a buff', (tester) async {
    final inactivePotion = ActivePotion(
      name: 'growth_potion',
      displayName: 'Poció antiga',
      appliedAt: DateTime.now().subtract(const Duration(hours: 2)),
      expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
    );

    final pot = fakeOccupiedPot(
      potNumber: 1,
      activeProducts: [inactivePotion],
    );

    expect(pot.hasBuff, false);
  });

  testWidgets('GardenPot.fromJson crea test buit correctament', (tester) async {
    final pot = GardenPot.fromJson({
      'pot_number': 1,
      'occupied': false,
      'plant': null,
      'growth_phase': null,
      'health_level': null,
      'water_level': null,
      'planted_at': null,
      'last_watered_at': null,
    });

    expect(pot.potNumber, 1);
    expect(pot.occupied, false);
    expect(pot.plant, null);
    expect(pot.hasBuff, false);
  });

  testWidgets('GardenPot.fromJson crea test ocupat amb planta', (tester) async {
    final pot = GardenPot.fromJson({
      'pot_number': 2,
      'occupied': true,
      'growth_phase': 'growth',
      'health_level': 90,
      'water_level': 70,
      'planted_at': '2026-05-20T10:00:00Z',
      'last_watered_at': '2026-05-20T12:00:00Z',
      'plant': {
        'scientific_name': 'aloe_vera',
        'common_name': 'Aloe vera',
        'family': 'Asphodelaceae',
        'can_flower': true,
        'min_temperature': 8,
        'max_temperature': 30,
        'image_url': '',
        'active_products': [
          {
            'name': 'growth_potion',
            'displayName': 'Poció de creixement',
            'applied_at': DateTime.now()
                .subtract(const Duration(minutes: 5))
                .toIso8601String(),
            'expires_at': DateTime.now()
                .add(const Duration(hours: 1))
                .toIso8601String(),
          },
          {
            'productName': 'old_potion',
            'display_name': 'Poció antiga',
            'applied_at': DateTime.now()
                .subtract(const Duration(hours: 3))
                .toIso8601String(),
            'expires_at': DateTime.now()
                .subtract(const Duration(hours: 1))
                .toIso8601String(),
          },
        ],
      },
    });

    expect(pot.potNumber, 2);
    expect(pot.occupied, true);
    expect(pot.plant?.commonName, 'Aloe vera');
    expect(pot.healthLevel, 90);
    expect(pot.waterLevel, 70);
    expect(pot.activeProducts.length, 1);
    expect(pot.hasBuff, true);
  });

  testWidgets('CollectPlantResult.fromJson usa message i new_balance', (
    tester,
  ) async {
    final result = CollectPlantResult.fromJson({
      'message': 'Planta recollida',
      'new_balance': 99,
    });

    expect(result.message, 'Planta recollida');
    expect(result.newBalance, 99);
  });

  testWidgets('CollectPlantResult.fromJson funciona sense new_balance', (
    tester,
  ) async {
    final result = CollectPlantResult.fromJson({
      'message': 'Planta recollida',
    });

    expect(result.message, 'Planta recollida');
    expect(result.newBalance, isA<int>());
  });

  testWidgets('regar una planta crida waterPlant i refresca el test', (
    tester,
  ) async {
    final gardenService = FakeGardenService();
    final weatherProvider = FakeWeatherProvider();

    final sheet = await openOccupiedPotSheet(
      tester,
      gardenService,
      weatherProvider,
    );

    await sheet.onWater();
    await finishCenteredMessageTimer(tester);

    expect(gardenService.waterPlantCalls, 1);
    expect(gardenService.fetchPotStatusCalls, 1);
  });

  testWidgets('error en regar mostra missatge i no refresca el test', (
    tester,
  ) async {
    final gardenService = FakeGardenService()..throwOnWater = true;
    final weatherProvider = FakeWeatherProvider();

    final sheet = await openOccupiedPotSheet(
      tester,
      gardenService,
      weatherProvider,
    );

    await sheet.onWater();
    await finishCenteredMessageTimer(tester);

    expect(gardenService.waterPlantCalls, 1);
    expect(gardenService.fetchPotStatusCalls, 0);
  });

  testWidgets('regar sense token mostra error i no refresca el test', (
    tester,
  ) async {
    final gardenService = FakeGardenService();
    final weatherProvider = FakeWeatherProvider();

    final sheet = await openOccupiedPotSheet(
      tester,
      gardenService,
      weatherProvider,
    );

    setUserToken(tester, '');

    await sheet.onWater();
    await finishCenteredMessageTimer(tester);

    expect(gardenService.waterPlantCalls, 0);
    expect(gardenService.fetchPotStatusCalls, 0);
  });

  testWidgets('recol·lectar una planta crida collectPlant i refresca el test', (
    tester,
  ) async {
    final gardenService = FakeGardenService();
    final weatherProvider = FakeWeatherProvider();

    final sheet = await openOccupiedPotSheet(
      tester,
      gardenService,
      weatherProvider,
    );

    final collectFuture = sheet.onCollect!();

    await closeCollectDialog(tester);
    await collectFuture;

    expect(gardenService.collectPlantCalls, 1);
    expect(gardenService.fetchPotStatusCalls, 1);
    expect(find.text('35'), findsOneWidget);
  });

  testWidgets('error en recol·lectar mostra missatge i no refresca el test', (
    tester,
  ) async {
    final gardenService = FakeGardenService()..throwOnCollect = true;
    final weatherProvider = FakeWeatherProvider();

    final sheet = await openOccupiedPotSheet(
      tester,
      gardenService,
      weatherProvider,
    );

    await sheet.onCollect!();
    await finishCenteredMessageTimer(tester);

    expect(gardenService.collectPlantCalls, 1);
    expect(gardenService.fetchPotStatusCalls, 0);
  });

  testWidgets('el callback de pocions existeix en un test ocupat', (
    tester,
  ) async {
    final gardenService = FakeGardenService();
    final weatherProvider = FakeWeatherProvider();

    final sheet = await openOccupiedPotSheet(
      tester,
      gardenService,
      weatherProvider,
    );

    expect(sheet.onPotion, isNotNull);
  });

  testWidgets('cancel·lar eliminar planta no crida deletePlant', (
    tester,
  ) async {
    final gardenService = FakeGardenService();
    final weatherProvider = FakeWeatherProvider();

    final sheet = await openOccupiedPotSheet(
      tester,
      gardenService,
      weatherProvider,
    );

    final deleteFuture = sheet.onDeletePlant!();

    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);

    await tester.tap(find.byType(OutlinedButton).last);
    await tester.pumpAndSettle();

    await deleteFuture;

    expect(gardenService.deletePlantCalls, 0);
    expect(gardenService.fetchPotStatusCalls, 0);
  });

  testWidgets('confirmar eliminar planta crida deletePlant i refresca el test', (
    tester,
  ) async {
    final gardenService = FakeGardenService();
    final weatherProvider = FakeWeatherProvider();

    final sheet = await openOccupiedPotSheet(
      tester,
      gardenService,
      weatherProvider,
    );

    final deleteFuture = sheet.onDeletePlant!();

    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton).last);
    await tester.pump();

    await deleteFuture;
    await finishCenteredMessageTimer(tester);

    expect(gardenService.deletePlantCalls, 1);
    expect(gardenService.fetchPotStatusCalls, 1);
  });

  testWidgets('eliminar planta sense token mostra error i no crida deletePlant', (
    tester,
  ) async {
    final gardenService = FakeGardenService();
    final weatherProvider = FakeWeatherProvider();

    final sheet = await openOccupiedPotSheet(
      tester,
      gardenService,
      weatherProvider,
    );

    setUserToken(tester, '');

    final deleteFuture = sheet.onDeletePlant!();

    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton).last);
    await tester.pump();

    await deleteFuture;
    await finishCenteredMessageTimer(tester);

    expect(gardenService.deletePlantCalls, 0);
    expect(gardenService.fetchPotStatusCalls, 0);
  });

  testWidgets('error en eliminar planta mostra missatge i no refresca el test', (
    tester,
  ) async {
    final gardenService = FakeGardenService()..throwOnDelete = true;
    final weatherProvider = FakeWeatherProvider();

    final sheet = await openOccupiedPotSheet(
      tester,
      gardenService,
      weatherProvider,
    );

    final deleteFuture = sheet.onDeletePlant!();

    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton).last);
    await tester.pump();

    await deleteFuture;
    await finishCenteredMessageTimer(tester);

    expect(gardenService.deletePlantCalls, 1);
    expect(gardenService.fetchPotStatusCalls, 0);
  });

  testWidgets('el botó d’inventari existeix a la pàgina del jardí', (
    tester,
  ) async {
    final gardenService = FakeGardenService();
    final weatherProvider = FakeWeatherProvider()
      ..fakeWeather = fakeWeatherInfo();

    await pumpGardenPage(
      tester,
      gardenService: gardenService,
      weatherProvider: weatherProvider,
    );

    expect(find.byKey(const Key('garden_inventory_button')), findsOneWidget);
  });

  testWidgets('el botó de calendari existeix a la pàgina del jardí', (
    tester,
  ) async {
    final gardenService = FakeGardenService();
    final weatherProvider = FakeWeatherProvider()
      ..fakeWeather = fakeWeatherInfo();

    await pumpGardenPage(
      tester,
      gardenService: gardenService,
      weatherProvider: weatherProvider,
    );

    expect(find.byKey(const Key('garden_calendar_button')), findsOneWidget);
  });

  testWidgets('el botó de botiga existeix a la pàgina del jardí', (
    tester,
  ) async {
    final gardenService = FakeGardenService();
    final weatherProvider = FakeWeatherProvider()
      ..fakeWeather = fakeWeatherInfo();

    await pumpGardenPage(
      tester,
      gardenService: gardenService,
      weatherProvider: weatherProvider,
    );

    expect(find.byKey(const Key('garden_shop_button')), findsOneWidget);
  });

  testWidgets('el botó de l’àlbum existeix a la pàgina del jardí', (
    tester,
  ) async {
    final gardenService = FakeGardenService();
    final weatherProvider = FakeWeatherProvider()
      ..fakeWeather = fakeWeatherInfo();

    await pumpGardenPage(
      tester,
      gardenService: gardenService,
      weatherProvider: weatherProvider,
    );

    expect(find.byKey(const Key('garden_album_button')), findsOneWidget);
  });

  testWidgets('funciona amb layout extra petit', (tester) async {
    final gardenService = FakeGardenService()
      ..pots = [
        fakeEmptyPot(potNumber: 1),
        fakeEmptyPot(potNumber: 2),
        fakeEmptyPot(potNumber: 3),
        fakeEmptyPot(potNumber: 4),
      ];

    final weatherProvider = FakeWeatherProvider()
      ..fakeWeather = fakeWeatherInfo();

    await pumpGardenPage(
      tester,
      gardenService: gardenService,
      weatherProvider: weatherProvider,
      size: const Size(330, 1300),
    );

    expect(find.byType(GardenPage), findsOneWidget);
    expect(find.byType(PotWidget), findsNWidgets(4));
  });

  testWidgets('funciona amb layout petit', (tester) async {
    final gardenService = FakeGardenService()
      ..pots = [
        fakeEmptyPot(potNumber: 1),
        fakeEmptyPot(potNumber: 2),
      ];

    final weatherProvider = FakeWeatherProvider()
      ..fakeWeather = fakeWeatherInfo();

    await pumpGardenPage(
      tester,
      gardenService: gardenService,
      weatherProvider: weatherProvider,
      size: const Size(340, 1400),
    );

    expect(find.byType(GardenPage), findsOneWidget);
    expect(find.byType(PotWidget), findsNWidgets(2));
  });

  testWidgets('funciona amb layout mitjà', (tester) async {
    final gardenService = FakeGardenService()
      ..pots = [
        fakeEmptyPot(potNumber: 1),
        fakeEmptyPot(potNumber: 2),
      ];

    final weatherProvider = FakeWeatherProvider()
      ..fakeWeather = fakeWeatherInfo();

    await pumpGardenPage(
      tester,
      gardenService: gardenService,
      weatherProvider: weatherProvider,
      size: const Size(500, 1400),
    );

    expect(find.byType(GardenPage), findsOneWidget);
    expect(find.byType(PotWidget), findsNWidgets(2));
  });

  testWidgets('funciona amb layout ample', (tester) async {
    final gardenService = FakeGardenService()
      ..pots = [
        fakeEmptyPot(potNumber: 1),
        fakeEmptyPot(potNumber: 2),
        fakeEmptyPot(potNumber: 3),
        fakeEmptyPot(potNumber: 4),
      ];

    final weatherProvider = FakeWeatherProvider()
      ..fakeWeather = fakeWeatherInfo();

    await pumpGardenPage(
      tester,
      gardenService: gardenService,
      weatherProvider: weatherProvider,
      size: const Size(900, 1600),
    );

    expect(find.byType(GardenPage), findsOneWidget);
    expect(find.byType(PotWidget), findsNWidgets(4));
  });
}
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_garden/generated/app_localizations.dart';
import 'package:meteo_garden/models/dades_usr.dart';
import 'package:meteo_garden/models/garden.dart';
import 'package:meteo_garden/models/weather_provider.dart';
import 'package:meteo_garden/screens/garden_page.dart';
import 'package:meteo_garden/services/garden_service.dart';
import 'package:provider/provider.dart';

class FakeGardenService extends GardenService {
  bool throwOnFetch = false;

  String? fetchedUsername;
  String? fetchedGardenName;

  @override
  Future<List<GardenPot>> fetchGardenPlants({
    required String username,
    required String gardenName,
  }) async {
    fetchedUsername = username;
    fetchedGardenName = gardenName;

    if (throwOnFetch) {
      throw Exception('Error carregant testos fake');
    }

    return [];
  }
}

class FakeWeatherProvider extends WeatherProvider {
  String? fetchedCity;
  bool? fetchedForceRefresh;

  @override
  Future<void> fetchWeather(String city, {bool forceRefresh = false}) async {
    fetchedCity = city;
    fetchedForceRefresh = forceRefresh;
  }
}

Widget makeTestableWidget({
  required Widget child,
  required FakeWeatherProvider weatherProvider,
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

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<UserModel>.value(value: userModel),
      ChangeNotifierProvider<WeatherProvider>.value(value: weatherProvider),
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
}) async {
  tester.view.physicalSize = const Size(1200, 2000);
  tester.view.devicePixelRatio = 1.0;

  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    makeTestableWidget(
      weatherProvider: weatherProvider,
      child: GardenPage(
        username: 'jana',
        gardenName: 'JardiJana',
        gardenService: gardenService,
      ),
    ),
  );

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

    expect(gardenService.fetchedUsername, 'jana');
    expect(gardenService.fetchedGardenName, 'JardiJana');
  });

  testWidgets('crida fetchWeather amb la ciutat de l’usuari', (tester) async {
    final gardenService = FakeGardenService();
    final weatherProvider = FakeWeatherProvider();

    await pumpGardenPage(
      tester,
      gardenService: gardenService,
      weatherProvider: weatherProvider,
    );

    expect(weatherProvider.fetchedCity, 'Barcelona');
    expect(weatherProvider.fetchedForceRefresh, false);
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

  testWidgets('mostra missatge quan no hi ha testos disponibles',
      (tester) async {
    final gardenService = FakeGardenService();
    final weatherProvider = FakeWeatherProvider();

    await pumpGardenPage(
      tester,
      gardenService: gardenService,
      weatherProvider: weatherProvider,
    );

    expect(find.textContaining('test'), findsWidgets);
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
}
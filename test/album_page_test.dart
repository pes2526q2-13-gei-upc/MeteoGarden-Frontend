import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meteo_garden/generated/app_localizations.dart';
import 'package:meteo_garden/models/dades_usr.dart';
import 'package:meteo_garden/models/plantes_desbl.dart';
import 'package:meteo_garden/screens/album_page.dart'; // Ajusta la ruta

class MockUserModel extends Mock implements UserModel {}

class MockPlantProvider extends Mock implements PlantProvider {}

class FakeUserModel extends Fake implements UserModel {}

void main() {
  late MockUserModel mockUserModel;
  late MockPlantProvider mockPlantProvider;

  setUpAll(() {
    registerFallbackValue(FakeUserModel());
  });

  setUp(() {
    mockUserModel = MockUserModel();
    mockPlantProvider = MockPlantProvider();

    when(() => mockUserModel.language).thenReturn('Català');
    when(() => mockPlantProvider.loadPlants(any())).thenAnswer((_) async => {});
  });

  // Actualizamos el widget para inyectar el cliente HTTP
  Widget createAlbumPage(http.Client client) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserModel>.value(value: mockUserModel),
        ChangeNotifierProvider<PlantProvider>.value(value: mockPlantProvider),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AlbumPage(httpClient: client), // 👈 Pasamos el mock
      ),
    );
  }

  group('AlbumPage Tests', () {
    // --- TUS TESTS (Visuales) ---

    testWidgets('Muestra el estado de carga inicial', (tester) async {
      when(() => mockPlantProvider.isLoading).thenReturn(true);
      when(() => mockPlantProvider.plants).thenReturn([]);

      final dummyClient = MockClient(
        (request) async => http.Response('{}', 200),
      );
      await tester.pumpWidget(createAlbumPage(dummyClient));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Muestra la vista vacía si no hay plantas', (tester) async {
      when(() => mockPlantProvider.isLoading).thenReturn(false);
      when(() => mockPlantProvider.plants).thenReturn([]);

      final dummyClient = MockClient(
        (request) async => http.Response('{}', 200),
      );
      await tester.pumpWidget(createAlbumPage(dummyClient));

      expect(find.textContaining('estado vacío'), findsNothing);
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    // --- NUEVO TEST (Integración API Popup) ---

    testWidgets('Abre el popup y muestra los detalles de la planta desde la API', (
      tester,
    ) async {
      // 1. Engañamos al provider para que la lista tenga una planta
      when(() => mockPlantProvider.isLoading).thenReturn(false);

      // NOTA: Ajusta los parámetros del constructor según cómo sea tu modelo 'PlantaDesbloquejada'
      when(
        () => mockPlantProvider.plants,
      ).thenReturn([Plant(name: 'Rosa', image: '')]);

      // 2. Preparamos la respuesta HTTP falsa para cuando se abra el popup
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('/api/plants/info')) {
          return http.Response(
            jsonEncode({
              "scientificName": "Rosa",
              "commonName": "Rosa Mágica",
              "family": "Rosaceae",
              "canFlower": true,
              "minTemperature": 10,
              "maxTemperature": 25,
              "description": "Una flor muy bonita que cura el alma.",
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      // 3. Arrancamos la app
      await tester.pumpWidget(createAlbumPage(mockClient));
      await tester.pumpAndSettle();

      // Vemos que la planta "Rosa" está en la cuadrícula y la tocamos
      expect(find.text('Rosa'), findsOneWidget);
      await tester.tap(find.text('Rosa'));

      // pumpAndSettle esperará a que termine de mostrarse el popup y se resuelva el FutureBuilder
      await tester.pumpAndSettle();

      // 4. ¡Comprobamos la magia! Verificamos que la información del HTTP falso está en pantalla
      expect(find.text('Rosa Mágica'), findsOneWidget); // commonName
      expect(
        find.text('Una flor muy bonita que cura el alma.'),
        findsOneWidget,
      ); // description
      expect(find.textContaining('Rosaceae'), findsOneWidget); // family
      expect(find.textContaining('10º - 25º'), findsOneWidget); // Temperatura
    });
  });
}

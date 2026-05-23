import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meteo_garden/generated/app_localizations.dart';
import 'package:meteo_garden/models/dades_usr.dart';
import 'package:meteo_garden/screens/botiga_page.dart'; // Ajusta la ruta

// 1. Mantenemos tu Mock del UserModel
class MockUserModel extends Mock implements UserModel {}

void main() {
  late MockUserModel mockUserModel;

  setUp(() {
    mockUserModel = MockUserModel();
    // Comportamiento por defecto de tu mock
    when(() => mockUserModel.token).thenReturn('fake-token-123');
    when(() => mockUserModel.username).thenReturn('testUser');
  });

  // Función de apoyo que ahora inyecta tanto tu UserModel como el cliente HTTP falso
  Widget createShopPage(http.Client client) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserModel>.value(value: mockUserModel),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ShopPage(
          httpClient: client,
        ), // 👈 IMPORTANTE: inyectamos el cliente
      ),
    );
  }

  group('ShopPage Tests Completos', () {
    // --- TUS TESTS (Visuales) ---

    testWidgets('Muestra el indicador de carga al iniciar', (tester) async {
      // Usamos un cliente vacío porque solo nos interesa el primer instante
      final dummyClient = MockClient(
        (request) async => http.Response('{}', 200),
      );

      await tester.pumpWidget(createShopPage(dummyClient));

      // Al arrancar (sin esperar a que cargue), isLoading es true
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Renderiza las pestañas correctamente', (tester) async {
      final dummyClient = MockClient(
        (request) async => http.Response('{}', 200),
      );

      await tester.pumpWidget(createShopPage(dummyClient));
      await tester
          .pumpAndSettle(); // Espera a que desaparezca el indicador de carga

      // Verifica que existen las pestañas de Semillas y Otros
      expect(find.byType(TabBar), findsOneWidget);
      expect(find.byType(Tab), findsNWidgets(2));
    });

    // --- NUESTROS TESTS (Lógica e Integración API) ---

    testWidgets('Debe cargar y mostrar la lista de semillas', (tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            "seeds": [
              {
                "scientificName": "Rosa",
                "commonName": "Rosa Mágica",
                "price": 25,
                "family": "Rosaceae",
                "image_url": "https://fakeurl.com/rosa.png",
              },
            ],
            "products": [],
          }),
          200,
        );
      });

      await tester.pumpWidget(createShopPage(mockClient));
      await tester.pumpAndSettle();

      // Comprobamos que el nombre y el precio de la semilla aparecen en la pantalla
      expect(find.text('Rosa Mágica'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
    });

    testWidgets('Debe abrir el BottomSheet y procesar la compra', (
      tester,
    ) async {
      final mockClient = MockClient((request) async {
        if (request.method == 'GET') {
          return http.Response(
            jsonEncode({
              "seeds": [
                {
                  "scientificName": "Girasol",
                  "commonName": "Girasol Gigante",
                  "price": 10,
                  "description": "Una semilla grande y amarilla",
                  "image_url": "",
                },
              ],
              "products": [],
            }),
            200,
          );
        }

        if (request.method == 'POST') {
          return http.Response(
            jsonEncode({"message": "Compra exitosa", "coins_remaining": 90}),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      await tester.pumpWidget(createShopPage(mockClient));
      await tester.pumpAndSettle();

      // Tocamos la semilla para abrir detalles
      await tester.tap(find.text('Girasol Gigante'));
      await tester.pumpAndSettle();

      // Vemos la descripción
      expect(find.text('Una semilla grande y amarilla'), findsOneWidget);

      // Le damos a comprar
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      // El bottom sheet se ha cerrado tras comprar
      expect(find.text('Una semilla grande y amarilla'), findsNothing);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });
  });
}

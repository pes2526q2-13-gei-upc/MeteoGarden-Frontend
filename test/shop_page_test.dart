import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:meteo_garden/generated/app_localizations.dart';
import 'package:meteo_garden/models/dades_usr.dart';
import 'package:meteo_garden/screens/botiga_page.dart';
import 'package:provider/provider.dart';

Widget makeTestableShopPage({required http.Client client}) {
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
      home: ShopPage(httpClient: client),
    ),
  );
}

http.Response jsonResponse(Object body, {int statusCode = 200}) {
  return http.Response(
    jsonEncode(body),
    statusCode,
    headers: {'content-type': 'application/json'},
  );
}

Future<void> clearCenteredMessageTimer(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

List<Map<String, dynamic>> manySeeds(String firstName) {
  return [
    {
      'scientificName': 'rosa_rugosa',
      'commonName': firstName,
      'price': 4,
      'image_url': null,
    },
    ...List.generate(
      20,
      (index) => {
        'scientificName': 'plant_$index',
        'commonName': 'Planta $index',
        'price': index + 1,
        'image_url': null,
      },
    ),
  ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ShopPage', () {
    testWidgets('carrega primer les llavors i després productes en segon pla', (
      tester,
    ) async {
      final requestedUrls = <String>[];

      final client = MockClient((request) async {
        requestedUrls.add(request.url.toString());

        if (request.url.path == '/api/shop/seeds/') {
          return jsonResponse([
            {
              'scientificName': 'rosa_rugosa',
              'commonName': 'Rosa Mágica',
              'price': 4,
              'image_url': null,
            },
            {
              'scientificName': 'Helianthus annuus',
              'commonName': 'Girasol Gigante',
              'price': 7,
              'image_url': null,
            },
          ]);
        }

        if (request.url.path == '/api/shop/products/') {
          return jsonResponse([
            {
              'name': 'Small Heal',
              'displayName': 'Cura petita',
              'price': 10,
              'rarity': 'common',
              'image_url': null,
            },
          ]);
        }

        return jsonResponse({'error': 'not found'}, statusCode: 404);
      });

      await tester.pumpWidget(makeTestableShopPage(client: client));
      await tester.pumpAndSettle();

      expect(find.text('Rosa Mágica'), findsOneWidget);
      expect(find.text('Girasol Gigante'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);

      expect(
        requestedUrls.any((url) => url.contains('/api/shop/seeds/')),
        isTrue,
      );

      expect(
        requestedUrls.any((url) => url.contains('/api/shop/products/')),
        isTrue,
      );
    });

    testWidgets('mostra els productes quan es canvia de pestanya', (
      tester,
    ) async {
      final client = MockClient((request) async {
        if (request.url.path == '/api/shop/seeds/') {
          return jsonResponse([
            {
              'scientificName': 'rosa_rugosa',
              'commonName': 'Rosa Mágica',
              'price': 4,
              'image_url': null,
            },
          ]);
        }

        if (request.url.path == '/api/shop/products/') {
          return jsonResponse([
            {
              'name': 'Small Heal',
              'displayName': 'Cura petita',
              'price': 10,
              'rarity': 'common',
              'image_url': null,
            },
            {
              'name': 'Hydration Shield',
              'displayName': 'Escut hidratant',
              'price': 25,
              'rarity': 'rare',
              'image_url': null,
            },
          ]);
        }

        return jsonResponse({'error': 'not found'}, statusCode: 404);
      });

      await tester.pumpWidget(makeTestableShopPage(client: client));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Tab).at(1));
      await tester.pumpAndSettle();

      expect(find.text('Cura petita'), findsOneWidget);
      expect(find.text('Escut hidratant'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
    });

    testWidgets('obre el detall d’una llavor i compra correctament', (
      tester,
    ) async {
      final requestedUrls = <String>[];
      Map<String, dynamic>? buyBody;

      final client = MockClient((request) async {
        requestedUrls.add(request.url.toString());

        if (request.url.path == '/api/shop/seeds/') {
          return jsonResponse([
            {
              'scientificName': 'Helianthus annuus',
              'commonName': 'Girasol Gigante',
              'price': 7,
              'image_url': null,
            },
          ]);
        }

        if (request.url.path == '/api/shop/products/') {
          return jsonResponse([]);
        }

        if (request.url.toString().endsWith(
          '/api/shop/seeds/Helianthus%20annuus/',
        )) {
          return jsonResponse({
            'scientificName': 'Helianthus annuus',
            'commonName': 'Girasol Gigante',
            'family': 'Asteraceae',
            'description': 'Llavor de gira-sol molt resistent.',
            'price': 7,
            'image_url': null,
          });
        }

        if (request.url.path == '/api/users/jana/buy/') {
          buyBody = jsonDecode(request.body) as Map<String, dynamic>;

          return jsonResponse({
            'message': 'Compra realitzada correctament',
            'coins_remaining': 93,
          });
        }

        return jsonResponse({'error': 'not found'}, statusCode: 404);
      });

      await tester.pumpWidget(makeTestableShopPage(client: client));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Girasol Gigante'));
      await tester.pump();
      expect(find.text('Girasol Gigante'), findsWidgets);

      await tester.pumpAndSettle();

      expect(find.text('Asteraceae'), findsOneWidget);
      expect(find.text('Llavor de gira-sol molt resistent.'), findsOneWidget);

      await tester.tap(find.byType(FilledButton).last);
      await tester.pumpAndSettle();

      expect(buyBody, isNotNull);
      expect(buyBody!['type'], 'seed');
      expect(buyBody!['name'], 'Helianthus annuus');
      expect(buyBody!['price'], 7);

      expect(
        requestedUrls.any(
          (url) => url.endsWith('/api/shop/seeds/Helianthus%20annuus/'),
        ),
        isTrue,
      );

      await clearCenteredMessageTimer(tester);
    });

    testWidgets('obre el detall d’un producte i compra correctament', (
      tester,
    ) async {
      Map<String, dynamic>? buyBody;

      final client = MockClient((request) async {
        if (request.url.path == '/api/shop/seeds/') {
          return jsonResponse([]);
        }

        if (request.url.path == '/api/shop/products/') {
          return jsonResponse([
            {
              'name': 'Small Heal',
              'displayName': 'Cura petita',
              'price': 10,
              'rarity': 'common',
              'image_url': null,
            },
          ]);
        }

        if (request.url.toString().endsWith(
          '/api/shop/products/Small%20Heal/',
        )) {
          return jsonResponse({
            'name': 'Small Heal',
            'displayName': 'Cura petita',
            'description': 'Restaura una part de la salut de la planta.',
            'effectType': 'health',
            'value': 20,
            'durationHours': null,
            'isInstant': true,
            'price': 10,
            'rarity': 'common',
            'image_url': null,
          });
        }

        if (request.url.path == '/api/users/jana/buy/') {
          buyBody = jsonDecode(request.body) as Map<String, dynamic>;

          return jsonResponse({
            'message': 'Compra realitzada correctament',
            'coins_remaining': 90,
          });
        }

        return jsonResponse({'error': 'not found'}, statusCode: 404);
      });

      await tester.pumpWidget(makeTestableShopPage(client: client));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Tab).at(1));
      await tester.pumpAndSettle();

      expect(find.text('Cura petita'), findsOneWidget);

      await tester.tap(find.text('Cura petita'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(
        find.text('Restaura una part de la salut de la planta.'),
        findsOneWidget,
      );

      await tester.tap(find.byType(FilledButton).last);
      await tester.pumpAndSettle();

      expect(buyBody, isNotNull);
      expect(buyBody!['type'], 'product');
      expect(buyBody!['name'], 'Small Heal');
      expect(buyBody!['price'], 10);

      await clearCenteredMessageTimer(tester);
    });

    testWidgets('mostra error si falla la càrrega inicial de llavors', (
      tester,
    ) async {
      final client = MockClient((request) async {
        if (request.url.path == '/api/shop/seeds/') {
          return jsonResponse({'error': 'error'}, statusCode: 500);
        }

        if (request.url.path == '/api/shop/products/') {
          return jsonResponse([]);
        }

        return jsonResponse({'error': 'not found'}, statusCode: 404);
      });

      await tester.pumpWidget(makeTestableShopPage(client: client));
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);

      await clearCenteredMessageTimer(tester);
    });

    testWidgets('mostra error si falla el detall d’una llavor', (tester) async {
      final client = MockClient((request) async {
        if (request.url.path == '/api/shop/seeds/') {
          return jsonResponse([
            {
              'scientificName': 'rosa_rugosa',
              'commonName': 'Rosa Mágica',
              'price': 4,
              'image_url': null,
            },
          ]);
        }

        if (request.url.path == '/api/shop/products/') {
          return jsonResponse([]);
        }

        if (request.url.toString().endsWith('/api/shop/seeds/rosa_rugosa/')) {
          return jsonResponse({'error': 'Seed not found'}, statusCode: 404);
        }

        return jsonResponse({'error': 'not found'}, statusCode: 404);
      });

      await tester.pumpWidget(makeTestableShopPage(client: client));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Rosa Mágica'));
      await tester.pumpAndSettle();

      expect(find.text('Seed not found'), findsOneWidget);

      await clearCenteredMessageTimer(tester);
    });

    testWidgets('mostra error si la compra retorna error del backend', (
      tester,
    ) async {
      final client = MockClient((request) async {
        if (request.url.path == '/api/shop/seeds/') {
          return jsonResponse([
            {
              'scientificName': 'rosa_rugosa',
              'commonName': 'Rosa Mágica',
              'price': 4,
              'image_url': null,
            },
          ]);
        }

        if (request.url.path == '/api/shop/products/') {
          return jsonResponse([]);
        }

        if (request.url.toString().endsWith('/api/shop/seeds/rosa_rugosa/')) {
          return jsonResponse({
            'scientificName': 'rosa_rugosa',
            'commonName': 'Rosa Mágica',
            'family': 'Rosaceae',
            'description': 'Una llavor bonica.',
            'price': 4,
            'image_url': null,
          });
        }

        if (request.url.path == '/api/users/jana/buy/') {
          return jsonResponse({
            'error': 'No tens prou monedes',
          }, statusCode: 400);
        }

        return jsonResponse({'error': 'not found'}, statusCode: 404);
      });

      await tester.pumpWidget(makeTestableShopPage(client: client));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Rosa Mágica'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FilledButton).last);
      await tester.pumpAndSettle();

      expect(find.text('No tens prou monedes'), findsOneWidget);

      await clearCenteredMessageTimer(tester);
    });

    testWidgets('refresca la pestanya de llavors amb RefreshIndicator', (
      tester,
    ) async {
      var seedCalls = 0;

      final client = MockClient((request) async {
        if (request.url.path == '/api/shop/seeds/') {
          seedCalls++;

          return jsonResponse(
            manySeeds(seedCalls == 1 ? 'Rosa Mágica' : 'Rosa Actualitzada'),
          );
        }

        if (request.url.path == '/api/shop/products/') {
          return jsonResponse([]);
        }

        return jsonResponse({'error': 'not found'}, statusCode: 404);
      });

      await tester.pumpWidget(makeTestableShopPage(client: client));
      await tester.pumpAndSettle();

      expect(find.text('Rosa Mágica'), findsOneWidget);
      expect(seedCalls, 1);

      await tester.drag(find.byType(ListView), const Offset(0, 500));

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(seedCalls, greaterThanOrEqualTo(2));
      expect(find.text('Rosa Actualitzada'), findsOneWidget);
    });
  });
}

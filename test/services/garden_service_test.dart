import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:meteo_garden/services/garden_service.dart';

void main() {
  group('PlantingResult', () {
    test('fromJson converteix correctament el JSON', () {
      final result = PlantingResult.fromJson({
        'message': 'Plantada correctament',
        'pot_number': 1,
        'plant': {
          'scientificName': 'Mentha spicata',
          'commonName': 'Menta',
        },
        'growthPhase': 'Seedling',
        'healthLevel': 90,
        'waterLevel': 70.5,
        'plantedAt': '2026-05-16T10:00:00',
        'remainingSeeds': 3,
      });

      expect(result.message, 'Plantada correctament');
      expect(result.potNumber, 1);
      expect(result.scientificName, 'Mentha spicata');
      expect(result.commonName, 'Menta');
      expect(result.growthPhase, 'Seedling');
      expect(result.healthLevel, 90.0);
      expect(result.waterLevel, 70.5);
      expect(result.plantedAt, '2026-05-16T10:00:00');
      expect(result.remainingSeeds, 3);
    });
  });

  group('GardenService', () {
    const username = 'jana';
    const gardenName = 'Jardi principal';

    Map<String, dynamic> potJson({
      int potNumber = 1,
      bool occupied = true,
      Map<String, dynamic>? plant,
    }) {
      return {
        'pot_number': potNumber,
        'occupied': occupied,
        'growth_phase': occupied ? 'Growing' : null,
        'health_level': occupied ? 80 : null,
        'water_level': occupied ? 60 : null,
        'planted_at': occupied ? '2026-05-10T09:00:00' : null,
        'last_watered_at': occupied ? '2026-05-15T12:30:00' : null,
        'plant': plant ??
            (occupied
                ? {
                    'scientific_name': 'Mentha spicata',
                    'common_name': 'Menta',
                    'family': 'Lamiaceae',
                    'can_flower': true,
                    'min_temperature': 8,
                    'max_temperature': 28,
                    'image_url': 'menta.png',
                    'active_products': [],
                  }
                : null),
      };
    }

    test('fetchGardenPlants retorna una llista de GardenPot', () async {
      final service = GardenService(
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(
            request.url.path,
            contains('/api/users/jana/gardens/Jardi%20principal/plants/'),
          );

          return http.Response(
            jsonEncode([
              potJson(potNumber: 1),
              potJson(potNumber: 2, occupied: false),
            ]),
            200,
          );
        }),
      );

      final pots = await service.fetchGardenPlants(
        username: username,
        gardenName: gardenName,
      );

      expect(pots.length, 2);
      expect(pots[0].potNumber, 1);
      expect(pots[0].occupied, isTrue);
      expect(pots[0].plant!.scientificName, 'Mentha spicata');
      expect(pots[1].potNumber, 2);
      expect(pots[1].occupied, isFalse);
      expect(pots[1].plant, isNull);
    });

    test('fetchGardenPlants llença excepció si statusCode no és 200', () async {
      final service = GardenService(
        client: MockClient((request) async {
          return http.Response('Error', 500);
        }),
      );

      expect(
        () => service.fetchGardenPlants(
          username: username,
          gardenName: gardenName,
        ),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains('Error carregant els tests: 500'),
          ),
        ),
      );
    });

    test('fetchPotStatus retorna GardenPot si statusCode és 200', () async {
      final service = GardenService(
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(
            request.url.path,
            contains('/api/users/jana/gardens/Jardi%20principal/pots/1/plant/'),
          );

          return http.Response(
            jsonEncode(potJson(potNumber: 1)),
            200,
          );
        }),
      );

      final pot = await service.fetchPotStatus(
        username: username,
        gardenName: gardenName,
        potNumber: 1,
      );

      expect(pot.potNumber, 1);
      expect(pot.occupied, isTrue);
      expect(pot.plant!.commonName, 'Menta');
    });

    test('fetchPotStatus llença message si statusCode no és 200', () async {
      final service = GardenService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({'message': 'Test no trobat'}),
            404,
          );
        }),
      );

      expect(
        () => service.fetchPotStatus(
          username: username,
          gardenName: gardenName,
          potNumber: 1,
        ),
        throwsA(
          predicate(
            (e) => e is Exception && e.toString().contains('Test no trobat'),
          ),
        ),
      );
    });

    test('waterPlant retorna message si statusCode és 200', () async {
      final service = GardenService(
        client: MockClient((request) async {
          expect(request.method, 'PATCH');
          expect(
            request.url.path,
            contains('/api/users/jana/gardens/Jardi%20principal/pots/1/water/'),
          );

          return http.Response(
            jsonEncode({'message': 'Planta regada'}),
            200,
          );
        }),
      );

      final message = await service.waterPlant(
        username: username,
        gardenName: gardenName,
        potNumber: 1,
      );

      expect(message, 'Planta regada');
    });

    test('waterPlant retorna missatge per defecte si no hi ha message', () async {
      final service = GardenService(
        client: MockClient((request) async {
          return http.Response(jsonEncode({}), 200);
        }),
      );

      final message = await service.waterPlant(
        username: username,
        gardenName: gardenName,
        potNumber: 1,
      );

      expect(message, 'Plant watered successfully.');
    });

    test('waterPlant llença error si statusCode no és 200', () async {
      final service = GardenService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({'error': 'No es pot regar'}),
            400,
          );
        }),
      );

      expect(
        () => service.waterPlant(
          username: username,
          gardenName: gardenName,
          potNumber: 1,
        ),
        throwsA(
          predicate(
            (e) => e is Exception && e.toString().contains('No es pot regar'),
          ),
        ),
      );
    });

    test('fetchSeeds retorna llista de SeedOption', () async {
      final service = GardenService(
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, contains('/api/users/jana/seeds/'));

          return http.Response(
            jsonEncode([
              {
                'scientificName': 'Mentha spicata',
                'amount': 5,
                'image_url': 'menta.png',
              },
              {
                'scientificName': 'Rosa rubiginosa',
                'amount': 2,
                'image_url': null,
              },
            ]),
            200,
          );
        }),
      );

      final seeds = await service.fetchSeeds(username);

      expect(seeds.length, 2);
      expect(seeds[0].scientificName, 'Mentha spicata');
      expect(seeds[0].amount, 5);
      expect(seeds[0].imageUrl, 'menta.png');
      expect(seeds[1].scientificName, 'Rosa rubiginosa');
      expect(seeds[1].amount, 2);
      expect(seeds[1].imageUrl, isNull);
    });

    test('fetchSeeds llença excepció si statusCode no és 200', () async {
      final service = GardenService(
        client: MockClient((request) async {
          return http.Response('Error', 500);
        }),
      );

      expect(
        () => service.fetchSeeds(username),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains('Error carregant llavors: 500'),
          ),
        ),
      );
    });

    test('fetchProducts retorna llista de ProductItem', () async {
      final service = GardenService(
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, contains('/api/users/jana/products/'));

          return http.Response(
            jsonEncode([
              {
                'productName': 'Fertilitzant',
                'amount': 3,
                'image_url': 'fertilitzant.png',
              },
              {
                'productName': 'Poció de creixement',
                'amount': 1,
                'image_url': null,
              },
            ]),
            200,
          );
        }),
      );

      final products = await service.fetchProducts(username);

      expect(products.length, 2);
      expect(products[0].productName, 'Fertilitzant');
      expect(products[0].amount, 3);
      expect(products[0].imageUrl, 'fertilitzant.png');
      expect(products[1].productName, 'Poció de creixement');
      expect(products[1].amount, 1);
      expect(products[1].imageUrl, isNull);
    });

    test('fetchProducts llença excepció si statusCode no és 200', () async {
      final service = GardenService(
        client: MockClient((request) async {
          return http.Response('Error', 500);
        }),
      );

      expect(
        () => service.fetchProducts(username),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains('Error carregant pocions: 500'),
          ),
        ),
      );
    });

    test('applyPotion retorna missatge per poció instantània', () async {
      final service = GardenService(
        client: MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, contains('/api/use_product/'));
          expect(request.headers['Content-Type'], 'application/json');

          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['pot_number'], 1);
          expect(body['product_name'], 'Fertilitzant');
          expect(body['username'], username);
          expect(body['garden_name'], gardenName);

          return http.Response(
            jsonEncode({
              'isInstant': true,
              'product': 'Fertilitzant',
            }),
            200,
          );
        }),
      );

      final message = await service.applyPotion(
        username: username,
        gardenName: gardenName,
        potNumber: 1,
        productName: 'Fertilitzant',
      );

      expect(message, 'Poció Fertilitzant aplicada correctament');
    });

    test('applyPotion retorna missatge per poció no instantània', () async {
      final service = GardenService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'isInstant': false,
              'product': 'Escut',
            }),
            200,
          );
        }),
      );

      final message = await service.applyPotion(
        username: username,
        gardenName: gardenName,
        potNumber: 1,
        productName: 'Escut',
      );

      expect(message, 'Efecte Escut activat');
    });

    test('applyPotion usa productName si product no ve al body', () async {
      final service = GardenService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({'isInstant': true}),
            200,
          );
        }),
      );

      final message = await service.applyPotion(
        username: username,
        gardenName: gardenName,
        potNumber: 1,
        productName: 'Producte fallback',
      );

      expect(message, 'Poció Producte fallback aplicada correctament');
    });

    test('applyPotion llença error si statusCode no és 200', () async {
      final service = GardenService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({'error': 'No tens aquest producte'}),
            400,
          );
        }),
      );

      expect(
        () => service.applyPotion(
          username: username,
          gardenName: gardenName,
          potNumber: 1,
          productName: 'Fertilitzant',
        ),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains('No tens aquest producte'),
          ),
        ),
      );
    });

    test('applyPotion llença error si body conté error encara que statusCode sigui 200', () async {
      final service = GardenService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({'error': 'Error aplicant'}),
            200,
          );
        }),
      );

      expect(
        () => service.applyPotion(
          username: username,
          gardenName: gardenName,
          potNumber: 1,
          productName: 'Fertilitzant',
        ),
        throwsA(
          predicate(
            (e) => e is Exception && e.toString().contains('Error aplicant'),
          ),
        ),
      );
    });

    test('plantSeed retorna PlantingResult amb statusCode 200', () async {
      final service = GardenService(
        client: MockClient((request) async {
          expect(request.method, 'POST');
          expect(
            request.url.path,
            contains('/api/users/jana/gardens/Jardi%20principal/pots/1/planting/'),
          );

          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['scientificName'], 'Mentha spicata');

          return http.Response(
            jsonEncode({
              'message': 'Plantada',
              'pot_number': 1,
              'plant': {
                'scientificName': 'Mentha spicata',
                'commonName': 'Menta',
              },
              'growthPhase': 'Seedling',
              'healthLevel': 100,
              'waterLevel': 80,
              'plantedAt': '2026-05-16T10:00:00',
              'remainingSeeds': 4,
            }),
            200,
          );
        }),
      );

      final result = await service.plantSeed(
        username: username,
        gardenName: gardenName,
        potNumber: 1,
        scientificName: 'Mentha spicata',
      );

      expect(result.message, 'Plantada');
      expect(result.potNumber, 1);
      expect(result.scientificName, 'Mentha spicata');
      expect(result.commonName, 'Menta');
      expect(result.growthPhase, 'Seedling');
      expect(result.healthLevel, 100.0);
      expect(result.waterLevel, 80.0);
      expect(result.remainingSeeds, 4);
    });

    test('plantSeed retorna PlantingResult amb statusCode 201', () async {
      final service = GardenService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'message': 'Plantada creada',
              'pot_number': 2,
              'plant': {
                'scientificName': 'Rosa rubiginosa',
                'commonName': 'Rosa',
              },
              'growthPhase': 'Seedling',
              'healthLevel': 95,
              'waterLevel': 60,
              'plantedAt': '2026-05-16T10:00:00',
              'remainingSeeds': 1,
            }),
            201,
          );
        }),
      );

      final result = await service.plantSeed(
        username: username,
        gardenName: gardenName,
        potNumber: 2,
        scientificName: 'Rosa rubiginosa',
      );

      expect(result.potNumber, 2);
      expect(result.scientificName, 'Rosa rubiginosa');
      expect(result.remainingSeeds, 1);
    });

    test('plantSeed llença error si statusCode no és 200 ni 201', () async {
      final service = GardenService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({'message': 'No tens llavors'}),
            400,
          );
        }),
      );

      expect(
        () => service.plantSeed(
          username: username,
          gardenName: gardenName,
          potNumber: 1,
          scientificName: 'Mentha spicata',
        ),
        throwsA(
          predicate(
            (e) => e is Exception && e.toString().contains('No tens llavors'),
          ),
        ),
      );
    });

    test('collectPlant retorna message si statusCode és 200', () async {
      final service = GardenService(
        client: MockClient((request) async {
          expect(request.method, 'POST');
          expect(
            request.url.path,
            contains('/api/users/jana/gardens/Jardi%20principal/pots/1/collect/'),
          );

          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['plant'], 'Mentha spicata');

          return http.Response(
            jsonEncode({'message': 'Planta recollida'}),
            200,
          );
        }),
      );

      final message = await service.collectPlant(
        username: username,
        gardenName: gardenName,
        potNumber: 1,
        scientificName: 'Mentha spicata',
      );

      expect(message, 'Planta recollida');
    });

    test('collectPlant retorna missatge per defecte si no hi ha message', () async {
      final service = GardenService(
        client: MockClient((request) async {
          return http.Response(jsonEncode({}), 200);
        }),
      );

      final message = await service.collectPlant(
        username: username,
        gardenName: gardenName,
        potNumber: 1,
        scientificName: 'Mentha spicata',
      );

      expect(message, 'Planta recollida correctament.');
    });

    test('collectPlant llença error si statusCode no és 200', () async {
      final service = GardenService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({'error': 'No es pot recollir'}),
            400,
          );
        }),
      );

      expect(
        () => service.collectPlant(
          username: username,
          gardenName: gardenName,
          potNumber: 1,
          scientificName: 'Mentha spicata',
        ),
        throwsA(
          predicate(
            (e) =>
                e is Exception && e.toString().contains('No es pot recollir'),
          ),
        ),
      );
    });

    test('deletePlant retorna message si statusCode és 200', () async {
      final service = GardenService(
        client: MockClient((request) async {
          expect(request.method, 'DELETE');
          expect(
            request.url.path,
            contains('/api/users/jana/gardens/Jardi%20principal/pots/1/delete/'),
          );

          return http.Response(
            jsonEncode({'message': 'Planta eliminada'}),
            200,
          );
        }),
      );

      final message = await service.deletePlant(
        username: username,
        gardenName: gardenName,
        potNumber: 1,
      );

      expect(message, 'Planta eliminada');
    });

    test('deletePlant retorna missatge per defecte si no hi ha message', () async {
      final service = GardenService(
        client: MockClient((request) async {
          return http.Response(jsonEncode({}), 200);
        }),
      );

      final message = await service.deletePlant(
        username: username,
        gardenName: gardenName,
        potNumber: 1,
      );

      expect(message, 'Plant deleted successfully.');
    });

    test('deletePlant llença error si statusCode no és 200', () async {
      final service = GardenService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({'error': 'No es pot eliminar'}),
            400,
          );
        }),
      );

      expect(
        () => service.deletePlant(
          username: username,
          gardenName: gardenName,
          potNumber: 1,
        ),
        throwsA(
          predicate(
            (e) =>
                e is Exception && e.toString().contains('No es pot eliminar'),
          ),
        ),
      );
    });

    test('fetchPlantDetails retorna map de detalls', () async {
      final service = GardenService(
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, contains('/api/plants/info'));
          expect(
            request.url.queryParameters['scientificName'],
            'Mentha spicata',
          );
          expect(request.url.queryParameters['lang'], 'ca');

          return http.Response(
            jsonEncode({
              'scientificName': 'Mentha spicata',
              'commonName': 'Menta',
              'family': 'Lamiaceae',
              'canFlower': true,
              'minTemperature': 8,
              'maxTemperature': 28,
              'description': 'Planta aromàtica',
            }),
            200,
          );
        }),
      );

      final details = await service.fetchPlantDetails('Mentha spicata', 'ca');

      expect(details['scientificName'], 'Mentha spicata');
      expect(details['commonName'], 'Menta');
      expect(details['family'], 'Lamiaceae');
      expect(details['canFlower'], isTrue);
      expect(details['minTemperature'], 8);
      expect(details['maxTemperature'], 28);
      expect(details['description'], 'Planta aromàtica');
    });

    test('fetchPlantDetails llença error si statusCode no és 200', () async {
      final service = GardenService(
        client: MockClient((request) async {
          return http.Response('Error', 404);
        }),
      );

      expect(
        () => service.fetchPlantDetails('Mentha spicata', 'ca'),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains('plant_info_load_error'),
          ),
        ),
      );
    });
  });
}
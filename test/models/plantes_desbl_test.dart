import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:meteo_garden/models/dades_usr.dart';
import 'package:meteo_garden/models/plantes_desbl.dart';

class FakePlantProvider extends PlantProvider {
  FakePlantProvider({
    required this.fakePlants,
    this.shouldFail = false,
  });

  final List<Plant> fakePlants;
  final bool shouldFail;

  @override
  Future<List<Plant>> fetchPlants(UserModel user) async {
    if (shouldFail) {
      throw Exception('Error carregant plantes');
    }

    return fakePlants;
  }
}

void main() {
  group('Plant', () {
    test('constructor assigna correctament els camps', () {
      final plant = Plant(
        name: 'Rosa',
        image: 'https://example.com/rosa.png',
      );

      expect(plant.name, 'Rosa');
      expect(plant.image, 'https://example.com/rosa.png');
    });

    test('fromJson converteix correctament el JSON', () {
      final plant = Plant.fromJson({
        'name': 'Lavanda',
        'image': 'https://example.com/lavanda.png',
      });

      expect(plant.name, 'Lavanda');
      expect(plant.image, 'https://example.com/lavanda.png');
    });
  });

  group('PlantProvider amb FakePlantProvider', () {
    test('estat inicial correcte', () {
      final provider = PlantProvider();

      expect(provider.plants, isEmpty);
      expect(provider.isLoading, isFalse);
    });

    test('loadPlants carrega plantes correctament', () async {
      final provider = FakePlantProvider(
        fakePlants: [
          Plant(name: 'Rosa', image: 'rosa.png'),
          Plant(name: 'Menta', image: 'menta.png'),
        ],
      );

      final user = UserModel();

      await provider.loadPlants(user);

      expect(provider.isLoading, isFalse);
      expect(provider.plants.length, 2);
      expect(provider.plants[0].name, 'Rosa');
      expect(provider.plants[0].image, 'rosa.png');
      expect(provider.plants[1].name, 'Menta');
      expect(provider.plants[1].image, 'menta.png');
    });

    test('loadPlants posa isLoading a true mentre carrega', () async {
      final provider = FakePlantProvider(
        fakePlants: [
          Plant(name: 'Rosa', image: 'rosa.png'),
        ],
      );

      final user = UserModel();
      final loadingStates = <bool>[];

      provider.addListener(() {
        loadingStates.add(provider.isLoading);
      });

      await provider.loadPlants(user);

      expect(loadingStates, contains(true));
      expect(loadingStates.last, isFalse);
      expect(provider.isLoading, isFalse);
    });

    test('loadPlants notifica listeners quan comença i acaba', () async {
      final provider = FakePlantProvider(
        fakePlants: [
          Plant(name: 'Rosa', image: 'rosa.png'),
        ],
      );

      final user = UserModel();
      var notifyCount = 0;

      provider.addListener(() {
        notifyCount++;
      });

      await provider.loadPlants(user);

      expect(notifyCount, 2);
    });

    test('loadPlants deixa plants buit si fetchPlants falla', () async {
      final provider = FakePlantProvider(
        fakePlants: [],
        shouldFail: true,
      );

      final user = UserModel();

      await provider.loadPlants(user);

      expect(provider.isLoading, isFalse);
      expect(provider.plants, isEmpty);
    });

    test('loadPlants notifica listeners encara que fetchPlants falli', () async {
      final provider = FakePlantProvider(
        fakePlants: [],
        shouldFail: true,
      );

      final user = UserModel();
      var notifyCount = 0;

      provider.addListener(() {
        notifyCount++;
      });

      await provider.loadPlants(user);

      expect(notifyCount, 2);
      expect(provider.isLoading, isFalse);
      expect(provider.plants, isEmpty);
    });
  });

  group('PlantProvider fetchPlants amb HTTP mockejat', () {
    UserModel createUser() {
      final user = UserModel();

      user.setProfile(
        newUsername: 'jana',
        newEmail: 'jana@example.com',
        newCity: 'Barcelona',
        newLanguage: 'ca',
        newLastEntry: '2026-05-16',
        newNumPlantsCollected: 2,
        newMonedes: 50,
        newGardens: ['Jardi principal'],
      );

      user.setToken('token123');

      return user;
    }

    test('fetchPlants retorna plantes quan la resposta és una llista', () async {
      final user = createUser();

      final provider = PlantProvider(
        client: MockClient((request) async {
          expect(request.url.toString(), contains('/api/users/jana/album/'));
          expect(request.headers['Authorization'], 'Token token123');

          return http.Response(
            jsonEncode([
              {
                'name': 'Rosa',
                'image': 'rosa.png',
              },
              {
                'name': 'Menta',
                'image': 'menta.png',
              },
            ]),
            200,
          );
        }),
      );

      final plants = await provider.fetchPlants(user);

      expect(plants.length, 2);
      expect(plants[0].name, 'Rosa');
      expect(plants[0].image, 'rosa.png');
      expect(plants[1].name, 'Menta');
      expect(plants[1].image, 'menta.png');
    });

    test('fetchPlants retorna plantes quan la resposta té results', () async {
      final user = createUser();

      final provider = PlantProvider(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'results': [
                {
                  'name': 'Lavanda',
                  'image': 'lavanda.png',
                },
              ],
            }),
            200,
          );
        }),
      );

      final plants = await provider.fetchPlants(user);

      expect(plants.length, 1);
      expect(plants.first.name, 'Lavanda');
      expect(plants.first.image, 'lavanda.png');
    });

    test('fetchPlants retorna llista buida si results no existeix', () async {
      final user = createUser();

      final provider = PlantProvider(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'count': 0,
            }),
            200,
          );
        }),
      );

      final plants = await provider.fetchPlants(user);

      expect(plants, isEmpty);
    });

    test('fetchPlants llença excepció si la resposta no és 200', () async {
      final user = createUser();

      final provider = PlantProvider(
        client: MockClient((request) async {
          return http.Response('Unauthorized', 401);
        }),
      );

      expect(
        () => provider.fetchPlants(user),
        throwsException,
      );
    });

    test('loadPlants carrega plantes fent servir el client HTTP mockejat', () async {
      final user = createUser();

      final provider = PlantProvider(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode([
              {
                'name': 'Romaní',
                'image': 'romani.png',
              },
            ]),
            200,
          );
        }),
      );

      await provider.loadPlants(user);

      expect(provider.isLoading, isFalse);
      expect(provider.plants.length, 1);
      expect(provider.plants.first.name, 'Romaní');
      expect(provider.plants.first.image, 'romani.png');
    });

    test('loadPlants deixa la llista buida si el client HTTP retorna error', () async {
      final user = createUser();

      final provider = PlantProvider(
        client: MockClient((request) async {
          return http.Response('Server error', 500);
        }),
      );

      await provider.loadPlants(user);

      expect(provider.isLoading, isFalse);
      expect(provider.plants, isEmpty);
    });
  });
}
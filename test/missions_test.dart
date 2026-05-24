// test/missions_test.dart
//
// Tests unitaris de la funcionalitat de missions:
//   - Model Mission (fromJson + getters)
//   - MissionService (fetchMissions + claimMission)

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:meteo_garden/models/missions.dart';
import 'package:meteo_garden/services/mission_service.dart';

void main() {
  group('Mission.fromJson', () {
    test('parseja un JSON complet correctament amb displayName', () {
      final json = {
        'Name': 'PLANT_5_ROSES',
        'displayName': 'Plantar 5 roses',
        'Description': 'Planta 5 roses al jardí',
        'Goal': 5,
        'Action': 'PLANT',
        'Plant needed scientific name': 'Rosa canina',
        'Product needed': null,
        'Plant reward common name': 'Roser silvestre',
        'Plant reward scientific name': 'Rosa canina',
        'Reward coins': 50,
        'Product reward': null,
        'Mission state': 'completed',
        'Current number': 5,
        'acquired at': '2026-04-22T10:00:00',
      };

      final mission = Mission.fromJson(json);

      expect(mission.name, 'PLANT_5_ROSES');
      expect(mission.displayName, 'Plantar 5 roses');
      expect(mission.description, 'Planta 5 roses al jardí');
      expect(mission.goal, 5);
      expect(mission.action, 'PLANT');
      expect(mission.plantNeeded, 'Rosa canina');
      expect(mission.productNeeded, isNull);
      expect(mission.plantRewardCommonName, 'Roser silvestre');
      expect(mission.plantRewardScientificName, 'Rosa canina');
      expect(mission.rewardCoins, 50);
      expect(mission.productReward, isNull);
      expect(mission.missionState, 'COMPLETED');
      expect(mission.currentNumber, 5);
      expect(mission.acquiredAt, DateTime.parse('2026-04-22T10:00:00'));
    });

    test('accepta DisplayName en majúscula inicial', () {
      final mission = Mission.fromJson({
        'Name': 'WATER_PLANTS',
        'DisplayName': 'Regar plantes',
        'Description': 'Rega les teves plantes',
        'Goal': 3,
        'Action': 'WATER',
        'Reward coins': 20,
        'Mission state': 'in progress',
        'Current number': 1,
      });

      expect(mission.name, 'WATER_PLANTS');
      expect(mission.displayName, 'Regar plantes');
    });

    test('usa Name com a fallback si no arriba displayName', () {
      final mission = Mission.fromJson({
        'Name': 'WATER_PLANTS',
        'Description': 'Rega les teves plantes',
        'Goal': 3,
        'Action': 'WATER',
        'Reward coins': 20,
        'Mission state': 'in progress',
        'Current number': 1,
      });

      expect(mission.name, 'WATER_PLANTS');
      expect(mission.displayName, 'WATER_PLANTS');
    });

    test('parseja un JSON amb camps opcionals absents', () {
      final json = {
        'Name': 'WATER_PLANTS',
        'displayName': 'Regar plantes',
        'Description': 'Rega les teves plantes',
        'Goal': 3,
        'Action': 'WATER',
        'Reward coins': 20,
        'Mission state': 'in progress',
        'Current number': 1,
      };

      final mission = Mission.fromJson(json);

      expect(mission.name, 'WATER_PLANTS');
      expect(mission.displayName, 'Regar plantes');
      expect(mission.plantNeeded, isNull);
      expect(mission.productNeeded, isNull);
      expect(mission.plantRewardCommonName, isNull);
      expect(mission.plantRewardScientificName, isNull);
      expect(mission.productReward, isNull);
      expect(mission.acquiredAt, isNull);
      expect(mission.missionState, 'IN_PROGRESS');
    });

    test('parseja un JSON buit sense llançar excepció', () {
      final mission = Mission.fromJson({});

      expect(mission.name, '');
      expect(mission.displayName, '');
      expect(mission.description, '');
      expect(mission.goal, 0);
      expect(mission.action, '');
      expect(mission.rewardCoins, 0);
      expect(mission.missionState, 'IN_PROGRESS');
      expect(mission.currentNumber, 0);
      expect(mission.acquiredAt, isNull);
    });

    test('normalitza correctament l\'estat de la missió', () {
      final cases = [
        ['completed', 'COMPLETED'],
        ['  COMPLETED  ', 'COMPLETED'],
        ['in progress', 'IN_PROGRESS'],
        ['IN PROGRESS', 'IN_PROGRESS'],
        ['claimed', 'CLAIMED'],
        ['CLAIMED', 'CLAIMED'],
      ];

      for (final c in cases) {
        final mission = Mission.fromJson({
          'Name': 'TEST_MISSION',
          'displayName': 'Missió de prova',
          'Description': '',
          'Goal': 1,
          'Action': '',
          'Reward coins': 0,
          'Mission state': c[0],
          'Current number': 0,
        });

        expect(
          mission.missionState,
          c[1],
          reason: '"${c[0]}" hauria de normalitzar-se a "${c[1]}"',
        );
      }
    });

    test('retorna acquiredAt null si la data és invàlida', () {
      final mission = Mission.fromJson({
        'Name': 'TEST_MISSION',
        'displayName': 'Missió de prova',
        'Description': '',
        'Goal': 1,
        'Action': '',
        'Reward coins': 0,
        'Mission state': 'in progress',
        'Current number': 0,
        'acquired at': 'data-no-valida',
      });

      expect(mission.acquiredAt, isNull);
    });
  });

  group('Mission.percentage', () {
    test('calcula el percentatge correctament', () {
      expect(
        _buildMission(currentNumber: 3, goal: 5).percentage,
        closeTo(0.6, 0.001),
      );
    });

    test('retorna 1.0 quan currentNumber és igual al goal', () {
      expect(_buildMission(currentNumber: 5, goal: 5).percentage, 1.0);
    });

    test('clampeja a 1.0 si currentNumber supera el goal', () {
      expect(_buildMission(currentNumber: 10, goal: 5).percentage, 1.0);
    });

    test('retorna 0.0 si el goal és zero', () {
      expect(_buildMission(currentNumber: 0, goal: 0).percentage, 0.0);
    });

    test('retorna 0.0 si no hi ha progrés', () {
      expect(_buildMission(currentNumber: 0, goal: 10).percentage, 0.0);
    });
  });

  group('Mission state booleans', () {
    test('isCompleted és true només quan l\'estat és COMPLETED', () {
      final mission = _buildMission(state: 'COMPLETED');

      expect(mission.isCompleted, isTrue);
      expect(mission.isClaimed, isFalse);
      expect(mission.isInProgress, isFalse);
    });

    test('isClaimed és true només quan l\'estat és CLAIMED', () {
      final mission = _buildMission(state: 'CLAIMED');

      expect(mission.isCompleted, isFalse);
      expect(mission.isClaimed, isTrue);
      expect(mission.isInProgress, isFalse);
    });

    test('isInProgress és true només quan l\'estat és IN_PROGRESS', () {
      final mission = _buildMission(state: 'IN_PROGRESS');

      expect(mission.isCompleted, isFalse);
      expect(mission.isClaimed, isFalse);
      expect(mission.isInProgress, isTrue);
    });

    test('tots els booleans són false per a un estat desconegut', () {
      final mission = _buildMission(state: 'UNKNOWN');

      expect(mission.isCompleted, isFalse);
      expect(mission.isClaimed, isFalse);
      expect(mission.isInProgress, isFalse);
    });
  });

  group('MissionService.fetchMissions', () {
    test('retorna la llista de missions en cas d\'èxit 200', () async {
      final client = MockClient((_) async {
        return http.Response(
          jsonEncode({
            'missions': [
              _missionJson(
                name: 'PLANT_5_ROSES',
                displayName: 'Plantar 5 roses',
                currentNumber: 3,
                state: 'in progress',
              ),
              _missionJson(
                name: 'WATER_10_TIMES',
                displayName: 'Regar 10 cops',
                goal: 10,
                currentNumber: 10,
                state: 'completed',
              ),
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final missions = await MissionService.fetchMissions(
        token: 'test-token',
        client: client,
      );

      expect(missions.length, 2);

      expect(missions[0].name, 'PLANT_5_ROSES');
      expect(missions[0].displayName, 'Plantar 5 roses');
      expect(missions[0].isInProgress, isTrue);

      expect(missions[1].name, 'WATER_10_TIMES');
      expect(missions[1].displayName, 'Regar 10 cops');
      expect(missions[1].isCompleted, isTrue);
    });

    test('retorna llista buida si el backend no té missions', () async {
      final client = MockClient((_) async {
        return http.Response(jsonEncode({'missions': []}), 200);
      });

      final missions = await MissionService.fetchMissions(
        token: 'test-token',
        client: client,
      );

      expect(missions, isEmpty);
    });

    test(
      'llança MissionException amb statusCode si el servidor retorna 401',
      () {
        final client = MockClient(
          (_) async => http.Response('Unauthorized', 401),
        );

        expect(
          () => MissionService.fetchMissions(
            token: 'token-invàlid',
            client: client,
          ),
          throwsA(
            isA<MissionException>().having(
              (e) => e.statusCode,
              'statusCode',
              401,
            ),
          ),
        );
      },
    );

    test('llança MissionException si el servidor retorna 500', () {
      final client = MockClient(
        (_) async => http.Response('Internal Server Error', 500),
      );

      expect(
        () => MissionService.fetchMissions(token: 'test-token', client: client),
        throwsA(
          isA<MissionException>().having(
            (e) => e.statusCode,
            'statusCode',
            500,
          ),
        ),
      );
    });

    test('llança MissionException de connexió si no hi ha xarxa', () {
      final client = MockClient(
        (_) async => throw const SocketException('No network'),
      );

      expect(
        () => MissionService.fetchMissions(token: 'test-token', client: client),
        throwsA(
          isA<MissionException>().having(
            (e) => e.message,
            'message',
            'No hi ha connexió amb el servidor.',
          ),
        ),
      );
    });
  });

  group('MissionService.claimMission', () {
    test('retorna les monedes de la missió en cas d\'èxit 200', () async {
      final client = MockClient((_) async {
        return http.Response(jsonEncode({'status': 'ok'}), 200);
      });

      final coins = await MissionService.claimMission(
        token: 'test-token',
        mission: _buildServiceMission(rewardCoins: 50),
        client: client,
      );

      expect(coins, 50);
    });

    test('retorna 0 si la missió no té recompensa en monedes', () async {
      final client = MockClient((_) async {
        return http.Response(jsonEncode({'status': 'ok'}), 200);
      });

      final coins = await MissionService.claimMission(
        token: 'test-token',
        mission: _buildServiceMission(rewardCoins: 0),
        client: client,
      );

      expect(coins, 0);
    });

    test(
      'continua identificant la missió amb name i no amb displayName',
      () async {
        String? sentBody;

        final client = MockClient((request) async {
          sentBody = request.body;
          return http.Response(jsonEncode({'status': 'ok'}), 200);
        });

        await MissionService.claimMission(
          token: 'test-token',
          mission: _buildServiceMission(
            rewardCoins: 50,
            name: 'INTERNAL_MISSION_ID',
            displayName: 'Nom traduït visible',
          ),
          client: client,
        );

        expect(sentBody, isNotNull);
        expect(sentBody, contains('INTERNAL_MISSION_ID'));
        expect(sentBody, isNot(contains('Nom traduït visible')));
      },
    );

    test('llança MissionException amb la clau d\'error del servidor 400', () {
      final client = MockClient((_) async {
        return http.Response(
          jsonEncode({'error': 'Mission already claimed'}),
          400,
          headers: {'content-type': 'application/json'},
        );
      });

      expect(
        () => MissionService.claimMission(
          token: 'test-token',
          mission: _buildServiceMission(rewardCoins: 50),
          client: client,
        ),
        throwsA(
          isA<MissionException>().having(
            (e) => e.message,
            'message',
            'Mission already claimed',
          ),
        ),
      );
    });

    test('llança MissionException "Mission in progress"', () {
      final client = MockClient((_) async {
        return http.Response(
          jsonEncode({'error': 'Mission in progress'}),
          400,
          headers: {'content-type': 'application/json'},
        );
      });

      expect(
        () => MissionService.claimMission(
          token: 'test-token',
          mission: _buildServiceMission(rewardCoins: 50),
          client: client,
        ),
        throwsA(
          isA<MissionException>().having(
            (e) => e.message,
            'message',
            'Mission in progress',
          ),
        ),
      );
    });

    test(
      'llança MissionException amb missatge buit si el body no és JSON vàlid',
      () {
        final client = MockClient(
          (_) async => http.Response('Bad Request', 400),
        );

        expect(
          () => MissionService.claimMission(
            token: 'test-token',
            mission: _buildServiceMission(rewardCoins: 50),
            client: client,
          ),
          throwsA(
            isA<MissionException>().having((e) => e.message, 'message', ''),
          ),
        );
      },
    );

    test('llança MissionException de connexió si no hi ha xarxa', () {
      final client = MockClient(
        (_) async => throw const SocketException('No network'),
      );

      expect(
        () => MissionService.claimMission(
          token: 'test-token',
          mission: _buildServiceMission(rewardCoins: 50),
          client: client,
        ),
        throwsA(
          isA<MissionException>().having(
            (e) => e.message,
            'message',
            'No hi ha connexió amb el servidor.',
          ),
        ),
      );
    });
  });
}

Mission _buildMission({
  String state = 'IN_PROGRESS',
  int currentNumber = 0,
  int goal = 10,
  String name = 'TEST_MISSION',
  String displayName = 'Missió de prova',
}) {
  return Mission(
    name: name,
    displayName: displayName,
    description: 'Descripció de prova',
    goal: goal,
    action: 'PLANT',
    rewardCoins: 10,
    missionState: state,
    currentNumber: currentNumber,
  );
}

Mission _buildServiceMission({
  required int rewardCoins,
  String name = 'TEST_MISSION',
  String displayName = 'Missió de prova',
}) {
  return Mission(
    name: name,
    displayName: displayName,
    description: 'Descripció',
    goal: 5,
    action: 'PLANT',
    rewardCoins: rewardCoins,
    missionState: 'COMPLETED',
    currentNumber: 5,
  );
}

Map<String, dynamic> _missionJson({
  String name = 'TEST_MISSION',
  String displayName = 'Missió de prova',
  int goal = 5,
  int currentNumber = 0,
  String state = 'in progress',
  int rewardCoins = 20,
}) {
  return {
    'Name': name,
    'displayName': displayName,
    'Description': 'Descripció de prova',
    'Goal': goal,
    'Action': 'PLANT',
    'Reward coins': rewardCoins,
    'Mission state': state,
    'Current number': currentNumber,
  };
}

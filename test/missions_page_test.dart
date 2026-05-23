import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_garden/generated/app_localizations.dart';
import 'package:meteo_garden/models/missions.dart';
import 'package:meteo_garden/screens/missions_page.dart';
import 'package:meteo_garden/services/mission_service.dart';
import 'package:meteo_garden/widgets/mission_card.dart';

void main() {
  group('MissionsPage', () {
    testWidgets(
      'mostra loading inicialment i després les missions amb displayName',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            MissionsPage(
              tokenOverride: 'test-token',
              fetchMissions: (_) async {
                return [
                  _mission(
                    name: 'INTERNAL_PLANT',
                    displayName: 'Plantar una flor',
                  ),
                ];
              },
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.pumpAndSettle();

        expect(find.text('Plantar una flor'), findsOneWidget);
        expect(find.text('INTERNAL_PLANT'), findsNothing);
        expect(find.byType(MissionCard), findsOneWidget);
      },
    );

    testWidgets('mostra estat buit si no hi ha missions', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MissionsPage(
            tokenOverride: 'test-token',
            fetchMissions: (_) async => [],
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.flag_outlined), findsOneWidget);
      expect(find.byType(MissionCard), findsNothing);
    });

    testWidgets('mostra error si fetchMissions falla', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MissionsPage(
            tokenOverride: 'test-token',
            fetchMissions: (_) async {
              throw MissionException(
                'Error carregant missions',
                statusCode: 500,
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Error carregant missions'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('el botó de retry torna a carregar les missions', (
      tester,
    ) async {
      var attempts = 0;

      await tester.pumpWidget(
        _wrap(
          MissionsPage(
            tokenOverride: 'test-token',
            fetchMissions: (_) async {
              attempts++;

              if (attempts == 1) {
                throw MissionException(
                  'Error carregant missions',
                  statusCode: 500,
                );
              }

              return [
                _mission(
                  name: 'INTERNAL_RETRY',
                  displayName: 'Missió carregada després',
                ),
              ];
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Error carregant missions'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Missió carregada després'), findsOneWidget);
      expect(find.text('INTERNAL_RETRY'), findsNothing);
      expect(attempts, 2);
    });

    testWidgets('separa missions actives i reclamades', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MissionsPage(
            tokenOverride: 'test-token',
            fetchMissions: (_) async {
              return [
                _mission(
                  name: 'ACTIVE_MISSION',
                  displayName: 'Missió activa',
                  missionState: 'IN_PROGRESS',
                ),
                _mission(
                  name: 'CLAIMED_MISSION',
                  displayName: 'Missió reclamada',
                  missionState: 'CLAIMED',
                  currentNumber: 5,
                  goal: 5,
                ),
              ];
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Missió activa'), findsOneWidget);
      expect(find.text('Missió reclamada'), findsOneWidget);
      expect(find.text('ACTIVE_MISSION'), findsNothing);
      expect(find.text('CLAIMED_MISSION'), findsNothing);
      expect(find.byType(MissionCard), findsNWidgets(2));
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('ordena les actives posant les completades primer', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          MissionsPage(
            tokenOverride: 'test-token',
            fetchMissions: (_) async {
              return [
                _mission(
                  name: 'IN_PROGRESS_INTERNAL',
                  displayName: 'Missió en progrés',
                  missionState: 'IN_PROGRESS',
                  currentNumber: 1,
                  goal: 5,
                ),
                _mission(
                  name: 'COMPLETED_INTERNAL',
                  displayName: 'Missió completada',
                  missionState: 'COMPLETED',
                  currentNumber: 5,
                  goal: 5,
                ),
              ];
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      final completedFinder = find.text('Missió completada');
      final inProgressFinder = find.text('Missió en progrés');

      expect(completedFinder, findsOneWidget);
      expect(inProgressFinder, findsOneWidget);
      expect(find.text('COMPLETED_INTERNAL'), findsNothing);
      expect(find.text('IN_PROGRESS_INTERNAL'), findsNothing);

      final completedY = tester.getTopLeft(completedFinder).dy;
      final inProgressY = tester.getTopLeft(inProgressFinder).dy;

      expect(completedY, lessThan(inProgressY));
    });

    testWidgets(
      'reclama una missió completada usant name intern i actualitza monedes',
      (tester) async {
        var coinsAdded = 0;
        var claimedMissionName = '';
        var claimedMissionDisplayName = '';
        var fetchCount = 0;

        await tester.pumpWidget(
          _wrap(
            MissionsPage(
              tokenOverride: 'test-token',
              fetchMissions: (_) async {
                fetchCount++;

                if (fetchCount == 1) {
                  return [
                    _mission(
                      name: 'INTERNAL_COMPLETED',
                      displayName: 'Missió completada',
                      missionState: 'COMPLETED',
                      currentNumber: 5,
                      goal: 5,
                      rewardCoins: 30,
                    ),
                  ];
                }

                return [
                  _mission(
                    name: 'INTERNAL_COMPLETED',
                    displayName: 'Missió completada',
                    missionState: 'CLAIMED',
                    currentNumber: 5,
                    goal: 5,
                    rewardCoins: 30,
                  ),
                ];
              },
              claimMission: (_, mission) async {
                claimedMissionName = mission.name;
                claimedMissionDisplayName = mission.displayName;
                return mission.rewardCoins;
              },
              onCoinsEarned: (coins) {
                coinsAdded += coins;
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Missió completada'), findsOneWidget);
        expect(find.text('INTERNAL_COMPLETED'), findsNothing);
        expect(find.byType(ElevatedButton), findsOneWidget);

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();

        expect(claimedMissionName, 'INTERNAL_COMPLETED');
        expect(claimedMissionDisplayName, 'Missió completada');
        expect(coinsAdded, 30);
        expect(fetchCount, 2);
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      },
    );

    testWidgets('si reclamar falla no afegeix monedes', (tester) async {
      var coinsAdded = 0;

      await tester.pumpWidget(
        _wrap(
          MissionsPage(
            tokenOverride: 'test-token',
            fetchMissions: (_) async {
              return [
                _mission(
                  name: 'INTERNAL_COMPLETED',
                  displayName: 'Missió completada',
                  missionState: 'COMPLETED',
                  currentNumber: 5,
                  goal: 5,
                  rewardCoins: 30,
                ),
              ];
            },
            claimMission: (_, __) async {
              throw MissionException('Mission in progress', statusCode: 400);
            },
            onCoinsEarned: (coins) {
              coinsAdded += coins;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Missió completada'), findsOneWidget);
      expect(find.text('INTERNAL_COMPLETED'), findsNothing);
      expect(find.byType(ElevatedButton), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(coinsAdded, 0);
      expect(find.text('Missió completada'), findsOneWidget);
    });
  });
}

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

Mission _mission({
  String name = 'INTERNAL_TEST_MISSION',
  String displayName = 'Missió de prova',
  String description = 'Descripció de prova',
  int goal = 5,
  String action = 'PLANT',
  int rewardCoins = 10,
  String missionState = 'IN_PROGRESS',
  int currentNumber = 0,
}) {
  return Mission(
    name: name,
    displayName: displayName,
    description: description,
    goal: goal,
    action: action,
    rewardCoins: rewardCoins,
    missionState: missionState.trim().toUpperCase().replaceAll(' ', '_'),
    currentNumber: currentNumber,
  );
}
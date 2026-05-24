import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_garden/generated/app_localizations.dart';
import 'package:meteo_garden/models/missions.dart';
import 'package:meteo_garden/widgets/mission_card.dart';

void main() {
  group('MissionCard', () {
    testWidgets('mostra displayName i no name a la pantalla', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MissionCard(
            mission: _mission(
              name: 'INTERNAL_MISSION_ID',
              displayName: 'Regar plantes',
            ),
          ),
        ),
      );

      expect(find.text('Regar plantes'), findsOneWidget);
      expect(find.text('INTERNAL_MISSION_ID'), findsNothing);
    });

    testWidgets('mostra la descripció de la missió', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MissionCard(
            mission: _mission(
              displayName: 'Plantar roses',
              description: 'Planta roses al jardí',
            ),
          ),
        ),
      );

      expect(find.text('Plantar roses'), findsOneWidget);
      expect(find.text('Planta roses al jardí'), findsOneWidget);
    });

    testWidgets('mostra el progrés actual i el percentatge', (tester) async {
      await tester.pumpWidget(
        _wrap(MissionCard(mission: _mission(currentNumber: 3, goal: 5))),
      );

      expect(find.text('3 / 5'), findsOneWidget);
      expect(find.text('60%'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('mostra el 100% si currentNumber supera el goal', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(MissionCard(mission: _mission(currentNumber: 10, goal: 5))),
      );

      expect(find.text('10 / 5'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('mostra 0% si el goal és zero', (tester) async {
      await tester.pumpWidget(
        _wrap(MissionCard(mission: _mission(currentNumber: 0, goal: 0))),
      );

      expect(find.text('0 / 0'), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('mostra la recompensa en monedes', (tester) async {
      await tester.pumpWidget(
        _wrap(MissionCard(mission: _mission(rewardCoins: 25))),
      );

      expect(find.textContaining('+25'), findsOneWidget);
      expect(find.byIcon(Icons.monetization_on), findsOneWidget);
    });

    testWidgets('mostra recompensa de planta si existeix', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MissionCard(
            mission: _mission(plantRewardCommonName: 'Roser silvestre'),
          ),
        ),
      );

      expect(find.text('Roser silvestre'), findsOneWidget);
      expect(find.byIcon(Icons.local_florist), findsWidgets);
    });

    testWidgets('no mostra recompensa de planta si no existeix', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(MissionCard(mission: _mission(plantRewardCommonName: null))),
      );

      expect(find.text('Roser silvestre'), findsNothing);
    });

    testWidgets('mostra botó de claim si està completada i té callback', (
      tester,
    ) async {
      var claimed = false;

      await tester.pumpWidget(
        _wrap(
          MissionCard(
            mission: _mission(
              missionState: 'COMPLETED',
              currentNumber: 5,
              goal: 5,
            ),
            onClaim: () {
              claimed = true;
            },
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(claimed, isTrue);
    });

    testWidgets(
      'no mostra botó de claim si està completada però no té callback',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            MissionCard(
              mission: _mission(
                missionState: 'COMPLETED',
                currentNumber: 5,
                goal: 5,
              ),
              onClaim: null,
            ),
          ),
        );

        expect(find.byType(ElevatedButton), findsNothing);
      },
    );

    testWidgets('no mostra botó de claim si està en progrés', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MissionCard(
            mission: _mission(
              missionState: 'IN_PROGRESS',
              currentNumber: 2,
              goal: 5,
            ),
            onClaim: () {},
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('mostra check si la missió està reclamada', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MissionCard(
            mission: _mission(
              missionState: 'CLAIMED',
              currentNumber: 5,
              goal: 5,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('canvia la icona segons action PLANT', (tester) async {
      await tester.pumpWidget(
        _wrap(MissionCard(mission: _mission(action: 'PLANT'))),
      );

      expect(find.byIcon(Icons.local_florist), findsOneWidget);
    });

    testWidgets('canvia la icona segons action WATER', (tester) async {
      await tester.pumpWidget(
        _wrap(MissionCard(mission: _mission(action: 'WATER'))),
      );

      expect(find.byIcon(Icons.water_drop), findsOneWidget);
    });

    testWidgets('canvia la icona segons action COLLECT', (tester) async {
      await tester.pumpWidget(
        _wrap(MissionCard(mission: _mission(action: 'COLLECT'))),
      );

      expect(find.byIcon(Icons.eco), findsOneWidget);
    });

    testWidgets('canvia la icona segons action FLOWER', (tester) async {
      await tester.pumpWidget(
        _wrap(MissionCard(mission: _mission(action: 'FLOWER'))),
      );

      expect(find.byIcon(Icons.yard), findsOneWidget);
    });

    testWidgets('canvia la icona segons action DIE', (tester) async {
      await tester.pumpWidget(
        _wrap(MissionCard(mission: _mission(action: 'DIE'))),
      );

      expect(find.byIcon(Icons.sentiment_dissatisfied), findsOneWidget);
    });

    testWidgets('usa icona per defecte si action és desconeguda', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(MissionCard(mission: _mission(action: 'UNKNOWN'))),
      );

      expect(find.byIcon(Icons.flag), findsOneWidget);
    });
  });
}

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
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
  String? plantRewardCommonName,
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
    plantRewardCommonName: plantRewardCommonName,
  );
}

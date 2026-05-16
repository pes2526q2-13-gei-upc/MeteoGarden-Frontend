import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_garden/generated/app_localizations.dart';
import 'package:meteo_garden/models/dades_usr.dart';
import 'package:meteo_garden/models/garden.dart';
import 'package:meteo_garden/screens/friend_garden_page.dart';
import 'package:meteo_garden/services/amics_service.dart';
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
      throw Exception('Error carregant jardí fake');
    }

    return [];
  }
}

class FakeAmicsService extends AmicsService {
  bool initialLiked = false;
  bool nextLikeState = true;
  bool throwOnLikeState = false;
  bool throwOnLike = false;

  String? likeStateUsername;
  String? likedUsername;
  int likeCalls = 0;

  @override
  Future<bool> getGardenLikeState({
    required String username,
    required String token,
  }) async {
    likeStateUsername = username;

    if (throwOnLikeState) {
      throw Exception('Error carregant like fake');
    }

    return initialLiked;
  }

  @override
  Future<bool> likeGarden({
    required String username,
    required String token,
  }) async {
    likedUsername = username;
    likeCalls++;

    if (throwOnLike) {
      throw Exception('Error enviant like fake');
    }

    return nextLikeState;
  }
}

Widget makeTestableWidget({
  required Widget child,
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
    newMonedes: 0,
    newGardens: const [],
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
      home: child,
    ),
  );
}

FriendGardenPage buildPage({
  required FakeGardenService gardenService,
  required FakeAmicsService amicsService,
  String friendUsername = 'laia',
  String gardenName = 'JardiLaia',
  Map<String, dynamic>? avatarParts,
}) {
  return FriendGardenPage(
    friendUsername: friendUsername,
    gardenName: gardenName,
    avatarParts: avatarParts,
    gardenService: gardenService,
    amicsService: amicsService,
  );
}

void main() {
  testWidgets('mostra el nom de l’amic i el nom del jardí', (tester) async {
    final gardenService = FakeGardenService();
    final amicsService = FakeAmicsService();

    await tester.pumpWidget(
      makeTestableWidget(
        child: buildPage(
          gardenService: gardenService,
          amicsService: amicsService,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('laia'), findsOneWidget);
    expect(find.text('JardiLaia'), findsOneWidget);

    expect(gardenService.fetchedUsername, 'laia');
    expect(gardenService.fetchedGardenName, 'JardiLaia');
    expect(amicsService.likeStateUsername, 'laia');
  });

  testWidgets('mostra la inicial si no hi ha avatar', (tester) async {
    final gardenService = FakeGardenService();
    final amicsService = FakeAmicsService();

    await tester.pumpWidget(
      makeTestableWidget(
        child: buildPage(
          gardenService: gardenService,
          amicsService: amicsService,
          friendUsername: 'oriol',
          gardenName: 'JardiOriol',
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('O'), findsOneWidget);
  });

  testWidgets('mostra jardí buit quan no hi ha testos', (tester) async {
    final gardenService = FakeGardenService();
    final amicsService = FakeAmicsService();

    await tester.pumpWidget(
      makeTestableWidget(
        child: buildPage(
          gardenService: gardenService,
          amicsService: amicsService,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('jardí'), findsWidgets);
  });

  testWidgets('mostra error quan falla la càrrega del jardí', (tester) async {
    final gardenService = FakeGardenService()..throwOnFetch = true;
    final amicsService = FakeAmicsService();

    await tester.pumpWidget(
      makeTestableWidget(
        child: buildPage(
          gardenService: gardenService,
          amicsService: amicsService,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.textContaining('Error carregant jardí fake'), findsOneWidget);
  });

  testWidgets('si el jardí ja té like, mostra el cor ple', (tester) async {
    final gardenService = FakeGardenService();
    final amicsService = FakeAmicsService()..initialLiked = true;

    await tester.pumpWidget(
      makeTestableWidget(
        child: buildPage(
          gardenService: gardenService,
          amicsService: amicsService,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border_rounded), findsNothing);
  });

  testWidgets('si el jardí no té like, mostra el cor buit', (tester) async {
    final gardenService = FakeGardenService();
    final amicsService = FakeAmicsService()..initialLiked = false;

    await tester.pumpWidget(
      makeTestableWidget(
        child: buildPage(
          gardenService: gardenService,
          amicsService: amicsService,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
    expect(find.byIcon(Icons.favorite_rounded), findsNothing);
  });

  testWidgets('pot donar like al jardí', (tester) async {
    final gardenService = FakeGardenService();
    final amicsService = FakeAmicsService()
      ..initialLiked = false
      ..nextLikeState = true;

    await tester.pumpWidget(
      makeTestableWidget(
        child: buildPage(
          gardenService: gardenService,
          amicsService: amicsService,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.favorite_border_rounded));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(amicsService.likedUsername, 'laia');
    expect(amicsService.likeCalls, 1);
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
  });

  testWidgets('pot treure like del jardí', (tester) async {
    final gardenService = FakeGardenService();
    final amicsService = FakeAmicsService()
      ..initialLiked = true
      ..nextLikeState = false;

    await tester.pumpWidget(
      makeTestableWidget(
        child: buildPage(
          gardenService: gardenService,
          amicsService: amicsService,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.favorite_rounded));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(amicsService.likedUsername, 'laia');
    expect(amicsService.likeCalls, 1);
    expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
  });

  testWidgets('mostra SnackBar si falla donar like', (tester) async {
    final gardenService = FakeGardenService();
    final amicsService = FakeAmicsService()
      ..initialLiked = false
      ..throwOnLike = true;

    await tester.pumpWidget(
      makeTestableWidget(
        child: buildPage(
          gardenService: gardenService,
          amicsService: amicsService,
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.favorite_border_rounded));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(amicsService.likeCalls, 1);
    expect(find.text('Error enviant like fake'), findsOneWidget);
  });

  testWidgets('si falla carregar estat del like, la pantalla no es bloqueja',
      (tester) async {
    final gardenService = FakeGardenService();
    final amicsService = FakeAmicsService()..throwOnLikeState = true;

    await tester.pumpWidget(
      makeTestableWidget(
        child: buildPage(
          gardenService: gardenService,
          amicsService: amicsService,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('laia'), findsOneWidget);
    expect(find.text('JardiLaia'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
  });

  testWidgets('el botó enrere fa pop de la pantalla', (tester) async {
    final gardenService = FakeGardenService();
    final amicsService = FakeAmicsService();

    await tester.pumpWidget(
      ChangeNotifierProvider<UserModel>.value(
        value: UserModel()
          ..setToken('fake-token')
          ..setProfile(
            newUsername: 'jana',
            newEmail: 'jana@test.com',
            newCity: 'Barcelona',
            newLanguage: 'ca',
            newLastEntry: '',
            newNumPlantsCollected: 0,
            newMonedes: 0,
            newGardens: const [],
          ),
        child: MaterialApp(
          locale: const Locale('ca'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => buildPage(
                            gardenService: gardenService,
                            amicsService: amicsService,
                          ),
                        ),
                      );
                    },
                    child: const Text('Obrir jardí'),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Obrir jardí'));
    await tester.pumpAndSettle();

    expect(find.text('laia'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Obrir jardí'), findsOneWidget);
    expect(find.text('laia'), findsNothing);
  });
}
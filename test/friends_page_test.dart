import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_garden/generated/app_localizations.dart';
import 'package:meteo_garden/models/dades_usr.dart';
import 'package:meteo_garden/screens/friends_page.dart';
import 'package:meteo_garden/services/amics_service.dart';
import 'package:provider/provider.dart';

class FakeAmicsService extends AmicsService {
  List<Map<String, dynamic>> friends = [
    {
      'username': 'laia',
      'garden_name': 'JardiLaia',
    },
  ];

  List<String> sentRequests = ['oriol'];
  List<String> receivedRequests = ['albert'];

  bool throwOnLoad = false;

  String? deletedUsername;
  String? cancelledUsername;
  String? answeredRequester;
  String? answeredAction;
  String? searchedQuery;
  String? requestedUsername;

  @override
  Future<List<Map<String, dynamic>>> fetchFriends({
    required String token,
  }) async {
    if (throwOnLoad) {
      throw Exception('Error carregant amics');
    }

    return friends;
  }

  @override
  Future<List<String>> fetchFriendRequests({
    required String action,
    required String token,
  }) async {
    if (throwOnLoad) {
      throw Exception('Error carregant sol·licituds');
    }

    if (action == 'sent') return sentRequests;
    if (action == 'received') return receivedRequests;
    return [];
  }

  @override
  Future<Map<String, dynamic>?> fetchAvatar({
    required String username,
    required String token,
  }) async {
    return null;
  }

  @override
  Future<String> deleteFriend({
    required String username,
    required String token,
  }) async {
    deletedUsername = username;
    friends.removeWhere((friend) => friend['username'] == username);
    return 'Amic eliminat correctament';
  }

  @override
  Future<String> cancelFriendRequest({
    required String requestedUsername,
    required String token,
  }) async {
    cancelledUsername = requestedUsername;
    sentRequests.remove(requestedUsername);
    return 'Sol·licitud cancel·lada correctament';
  }

  @override
  Future<String> answerFriendRequest({
    required String requesterUsername,
    required String action,
    required String token,
  }) async {
    answeredRequester = requesterUsername;
    answeredAction = action;
    receivedRequests.remove(requesterUsername);
    return 'Sol·licitud resposta correctament';
  }

  @override
  Future<List<Map<String, dynamic>>> searchUsers({
    required String query,
    required String token,
  }) async {
    searchedQuery = query;

    return [
      {'username': 'marta'},
      {'username': 'jana'},
    ];
  }

  @override
  Future<String> sendFriendRequest({
    required String requestedUsername,
    required String token,
  }) async {
    this.requestedUsername = requestedUsername;
    sentRequests.add(requestedUsername);
    return 'Sol·licitud enviada correctament';
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

void main() {
  testWidgets('mostra la llista d’amics carregada', (tester) async {
    final fakeService = FakeAmicsService();

    await tester.pumpWidget(
      makeTestableWidget(
        child: FriendsPage(amicsService: fakeService),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('laia'), findsOneWidget);
    expect(find.text('oriol'), findsNothing);
    expect(find.text('albert'), findsNothing);
  });

  testWidgets('mostra les sol·licituds enviades en la pestanya corresponent',
      (tester) async {
    final fakeService = FakeAmicsService();

    await tester.pumpWidget(
      makeTestableWidget(
        child: FriendsPage(amicsService: fakeService),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.outbox_rounded));
    await tester.pumpAndSettle();

    expect(find.text('oriol'), findsOneWidget);
  });

  testWidgets('mostra les sol·licituds rebudes en la pestanya corresponent',
      (tester) async {
    final fakeService = FakeAmicsService();

    await tester.pumpWidget(
      makeTestableWidget(
        child: FriendsPage(amicsService: fakeService),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.mark_email_unread_rounded));
    await tester.pumpAndSettle();

    expect(find.text('albert'), findsOneWidget);
  });

  testWidgets('pot cancel·lar una sol·licitud enviada', (tester) async {
    final fakeService = FakeAmicsService();

    await tester.pumpWidget(
      makeTestableWidget(
        child: FriendsPage(amicsService: fakeService),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.outbox_rounded));
    await tester.pumpAndSettle();

    expect(find.text('oriol'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.cancel_outlined).first);
    await tester.pumpAndSettle();

    expect(fakeService.cancelledUsername, 'oriol');
    expect(find.text('oriol'), findsNothing);
  });

  testWidgets('pot acceptar una sol·licitud rebuda', (tester) async {
    final fakeService = FakeAmicsService();

    await tester.pumpWidget(
      makeTestableWidget(
        child: FriendsPage(amicsService: fakeService),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.mark_email_unread_rounded));
    await tester.pumpAndSettle();

    expect(find.text('albert'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.check_circle_outline));
    await tester.pumpAndSettle();

    expect(fakeService.answeredRequester, 'albert');
    expect(fakeService.answeredAction, 'accept');
    expect(find.text('albert'), findsNothing);
  });

  testWidgets('pot rebutjar una sol·licitud rebuda', (tester) async {
    final fakeService = FakeAmicsService();

    await tester.pumpWidget(
      makeTestableWidget(
        child: FriendsPage(amicsService: fakeService),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.mark_email_unread_rounded));
    await tester.pumpAndSettle();

    expect(find.text('albert'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.cancel_outlined).first);
    await tester.pumpAndSettle();

    expect(fakeService.answeredRequester, 'albert');
    expect(fakeService.answeredAction, 'reject');
    expect(find.text('albert'), findsNothing);
  });

  testWidgets('pot eliminar un amic després de confirmar el diàleg',
      (tester) async {
    final fakeService = FakeAmicsService();

    await tester.pumpWidget(
      makeTestableWidget(
        child: FriendsPage(amicsService: fakeService),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('laia'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.person_remove_rounded).last);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();

    expect(fakeService.deletedUsername, 'laia');
    expect(find.text('laia'), findsNothing);
  });

  testWidgets('mostra estat buit quan no hi ha amics', (tester) async {
    final fakeService = FakeAmicsService()
      ..friends = []
      ..sentRequests = []
      ..receivedRequests = [];

    await tester.pumpWidget(
      makeTestableWidget(
        child: FriendsPage(amicsService: fakeService),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.people_outline), findsOneWidget);
  });

  testWidgets('mostra estat buit quan no hi ha sol·licituds enviades',
      (tester) async {
    final fakeService = FakeAmicsService()
      ..sentRequests = [];

    await tester.pumpWidget(
      makeTestableWidget(
        child: FriendsPage(amicsService: fakeService),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.outbox_rounded));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.send_outlined), findsOneWidget);
  });

  testWidgets('mostra estat buit quan no hi ha sol·licituds rebudes',
      (tester) async {
    final fakeService = FakeAmicsService()
      ..receivedRequests = [];

    await tester.pumpWidget(
      makeTestableWidget(
        child: FriendsPage(amicsService: fakeService),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.mark_email_unread_rounded));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
  });

  testWidgets('mostra pantalla d’error quan falla la càrrega', (tester) async {
    final fakeService = FakeAmicsService()..throwOnLoad = true;

    await tester.pumpWidget(
      makeTestableWidget(
        child: FriendsPage(amicsService: fakeService),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
    expect(find.text('Error carregant amics'), findsOneWidget);
  });

  testWidgets('obre el diàleg per afegir amic', (tester) async {
    final fakeService = FakeAmicsService();

    await tester.pumpWidget(
      makeTestableWidget(
        child: FriendsPage(amicsService: fakeService),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.person_add_alt_1_rounded));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.search), findsOneWidget);
  });

  testWidgets('cerca usuaris i amaga l’usuari actual dels resultats',
      (tester) async {
    final fakeService = FakeAmicsService();

    await tester.pumpWidget(
      makeTestableWidget(
        child: FriendsPage(amicsService: fakeService),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.person_add_alt_1_rounded));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'mar');
    await tester.pumpAndSettle();

    expect(fakeService.searchedQuery, 'mar');
    expect(find.text('marta'), findsOneWidget);
    expect(find.text('jana'), findsNothing);
  });

  testWidgets('pot enviar una sol·licitud des del diàleg d’afegir amic',
      (tester) async {
    final fakeService = FakeAmicsService();

    await tester.pumpWidget(
      makeTestableWidget(
        child: FriendsPage(amicsService: fakeService),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.person_add_alt_1_rounded));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'mar');
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Enviar').last);
    await tester.pumpAndSettle();

    expect(fakeService.requestedUsername, 'marta');
    expect(find.text('Sol·licitud enviada correctament'), findsOneWidget);
  });
}
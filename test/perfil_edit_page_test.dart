import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_garden/generated/app_localizations.dart';
import 'package:meteo_garden/models/dades_usr.dart';
import 'package:meteo_garden/models/perfil_info.dart';
import 'package:meteo_garden/screens/perfil_edit_page.dart';
import 'package:provider/provider.dart';

class FakeHttpClient implements HttpClient {
  int stationsStatusCode = 200;
  Object stationsBody = [
    {'code': '08019', 'name': 'Barcelona'},
    {'code': '08298', 'name': 'Vic'},
    {'code': '17079', 'name': 'Girona'},
  ];
  bool throwOnStations = false;

  int editProfileStatusCode = 200;
  Object editProfileBody = {'message': 'Profile updated'};
  bool throwOnEditProfile = false;

  final List<FakeHttpRequestData> requests = [];

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return FakeHttpClientRequest(this, method, url);
  }

  @override
  Future<HttpClientRequest> getUrl(Uri url) {
    return openUrl('GET', url);
  }

  @override
  Future<HttpClientRequest> postUrl(Uri url) {
    return openUrl('POST', url);
  }

  Future<HttpClientResponse> respond(
    String method,
    Uri url,
    List<int> bodyBytes,
    FakeHttpHeaders requestHeaders,
  ) async {
    final body = utf8.decode(bodyBytes);

    requests.add(
      FakeHttpRequestData(
        method: method,
        url: url,
        body: body,
        headers: requestHeaders.values,
      ),
    );

    if (url.path.endsWith('/api/stations/')) {
      if (throwOnStations) {
        throw Exception('stations failed');
      }

      return FakeHttpClientResponse(
        statusCode: stationsStatusCode,
        body: jsonEncode(stationsBody),
      );
    }

    if (url.path.endsWith('/api/edit_profile/')) {
      if (throwOnEditProfile) {
        throw Exception('edit profile failed');
      }

      return FakeHttpClientResponse(
        statusCode: editProfileStatusCode,
        body: jsonEncode(editProfileBody),
      );
    }

    return FakeHttpClientResponse(
      statusCode: 404,
      body: jsonEncode({'error': 'not found'}),
    );
  }

  @override
  void close({bool force = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class FakeHttpRequestData {
  FakeHttpRequestData({
    required this.method,
    required this.url,
    required this.body,
    required this.headers,
  });

  final String method;
  final Uri url;
  final String body;
  final Map<String, List<String>> headers;
}

class FakeHttpClientRequest implements HttpClientRequest {
  FakeHttpClientRequest(this.client, String method, this.url)
    : _method = method;

  final FakeHttpClient client;
  final String _method;
  final Uri url;
  final FakeHttpHeaders _headers = FakeHttpHeaders();
  final BytesBuilder _body = BytesBuilder();

  @override
  HttpHeaders get headers => _headers;

  @override
  Encoding encoding = utf8;

  @override
  bool followRedirects = true;

  @override
  int maxRedirects = 5;

  @override
  bool persistentConnection = true;

  @override
  bool bufferOutput = true;

  @override
  int contentLength = -1;

  @override
  List<Cookie> get cookies => <Cookie>[];

  @override
  Uri get uri => url;

  @override
  String get method => _method;

  @override
  void add(List<int> data) {
    _body.add(data);
  }

  @override
  Future<void> addStream(Stream<List<int>> stream) async {
    await for (final chunk in stream) {
      _body.add(chunk);
    }
  }

  @override
  void write(Object? object) {
    _body.add(encoding.encode(object.toString()));
  }

  @override
  void writeAll(Iterable<dynamic> objects, [String separator = '']) {
    _body.add(encoding.encode(objects.join(separator)));
  }

  @override
  void writeCharCode(int charCode) {
    _body.add([charCode]);
  }

  @override
  void writeln([Object? object = '']) {
    _body.add(encoding.encode('$object\n'));
  }

  @override
  Future<HttpClientResponse> close() async {
    return client.respond(_method, url, _body.takeBytes(), _headers);
  }

  @override
  Future<void> flush() async {}

  @override
  void abort([Object? exception, StackTrace? stackTrace]) {}

  @override
  Future<HttpClientResponse> get done => close();

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class FakeHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  FakeHttpClientResponse({
    required this.statusCode,
    required String body,
  }) : _bodyBytes = utf8.encode(body);

  final List<int> _bodyBytes;

  @override
  final int statusCode;

  @override
  int get contentLength => _bodyBytes.length;

  @override
  String get reasonPhrase => '';

  @override
  HttpHeaders get headers => FakeHttpHeaders()
    ..set(HttpHeaders.contentTypeHeader, 'application/json');

  @override
  bool get isRedirect => false;

  @override
  bool get persistentConnection => false;

  @override
  List<RedirectInfo> get redirects => const [];

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  X509Certificate? get certificate => null;

  @override
  Future<Socket> detachSocket() {
    throw UnimplementedError();
  }

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_bodyBytes]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class FakeHttpHeaders implements HttpHeaders {
  final Map<String, List<String>> values = {};

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {
    values.putIfAbsent(name.toLowerCase(), () => []).add(value.toString());
  }

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    values[name.toLowerCase()] = [value.toString()];
  }

  @override
  List<String>? operator [](String name) {
    return values[name.toLowerCase()];
  }

  @override
  String? value(String name) {
    return values[name.toLowerCase()]?.join(',');
  }

  @override
  void forEach(void Function(String name, List<String> values) action) {
    values.forEach(action);
  }

  @override
  void remove(String name, Object value) {
    values[name.toLowerCase()]?.remove(value.toString());
  }

  @override
  void removeAll(String name) {
    values.remove(name.toLowerCase());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

PerfilInfo fakeProfile({
  String username = 'JardineroFiel',
  String email = 'test@test.com',
  String city = 'Barcelona',
  String language = 'ca',
  int coins = 50,
  int plantsDiscovered = 5,
}) {
  return PerfilInfo(
    username: username,
    email: email,
    city: city,
    language: language,
    coins: coins,
    plantsDiscovered: plantsDiscovered,
  );
}

Widget makeTestableWidget({
  required PerfilInfo profile,
  required UserModel userModel,
  NavigatorObserver? navigatorObserver,
}) {
  return ChangeNotifierProvider<UserModel>.value(
    value: userModel,
    child: MaterialApp(
      locale: const Locale('ca'),
      navigatorObservers: [
        if (navigatorObserver != null) navigatorObserver,
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: PerfilEditPage(profile: profile),
    ),
  );
}

Future<void> pumpPerfilEditPage(
  WidgetTester tester, {
  required PerfilInfo profile,
  required UserModel userModel,
  NavigatorObserver? navigatorObserver,
}) async {
  tester.view.physicalSize = const Size(1200, 1600);
  tester.view.devicePixelRatio = 1.0;

  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    makeTestableWidget(
      profile: profile,
      userModel: userModel,
      navigatorObserver: navigatorObserver,
    ),
  );

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> runWithFakeHttp(
  FakeHttpClient client,
  Future<void> Function() body,
) async {
  await HttpOverrides.runZoned(
    body,
    createHttpClient: (_) => client,
  );
}

Future<void> finishCenteredMessageTimer(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

class TestNavigatorObserver extends NavigatorObserver {
  int popCount = 0;
  int pushCount = 0;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    popCount++;
    super.didPop(route, previousRoute);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushCount++;
    super.didPush(route, previousRoute);
  }
}

void main() {
  UserModel buildUserModel() {
    final userModel = UserModel();
    userModel.setToken('fake-token');
    userModel.setProfile(
      newUsername: 'OldUser',
      newEmail: 'old@test.com',
      newCity: 'OldCity',
      newLanguage: 'ca',
      newLastEntry: '',
      newNumPlantsCollected: 0,
      newMonedes: 0,
      newGardens: const [],
    );
    return userModel;
  }

  testWidgets('mostra loading inicial mentre carrega ciutats', (tester) async {
    final client = FakeHttpClient();
    final userModel = buildUserModel();

    await runWithFakeHttp(client, () async {
      await tester.pumpWidget(
        makeTestableWidget(
          profile: fakeProfile(),
          userModel: userModel,
        ),
      );

      expect(find.byType(PerfilEditPage), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 300));
    });
  });

  testWidgets('carrega PerfilEditPage i mostra el username inicial', (
    tester,
  ) async {
    final client = FakeHttpClient();
    final userModel = buildUserModel();

    await runWithFakeHttp(client, () async {
      await pumpPerfilEditPage(
        tester,
        profile: fakeProfile(username: 'JardineroFiel'),
        userModel: userModel,
      );

      expect(find.byKey(const Key('edit_profile_page')), findsOneWidget);
      expect(find.byKey(const Key('edit_profile_username_field')), findsOneWidget);
      expect(find.text('JardineroFiel'), findsOneWidget);
    });
  });

  testWidgets('carrega les ciutats i selecciona la ciutat del perfil', (
    tester,
  ) async {
    final client = FakeHttpClient();
    final userModel = buildUserModel();

    await runWithFakeHttp(client, () async {
      await pumpPerfilEditPage(
        tester,
        profile: fakeProfile(city: 'Barcelona'),
        userModel: userModel,
      );

      final stationRequests = client.requests.where(
        (request) => request.url.path.endsWith('/api/stations/'),
      );

      expect(stationRequests.length, 1);
      expect(find.byType(DropdownMenu<City>), findsOneWidget);
      expect(find.text('Barcelona'), findsWidgets);
    });
  });

  testWidgets('carrega ciutats però no selecciona cap si la ciutat no coincideix', (
    tester,
  ) async {
    final client = FakeHttpClient();
    final userModel = buildUserModel();

    await runWithFakeHttp(client, () async {
      await pumpPerfilEditPage(
        tester,
        profile: fakeProfile(city: 'Tarragona'),
        userModel: userModel,
      );

      expect(find.byType(DropdownMenu<City>), findsOneWidget);
      expect(find.text('Tarragona'), findsNothing);
    });
  });

  testWidgets('si fetchCities retorna error deixa de mostrar loading', (
    tester,
  ) async {
    final client = FakeHttpClient()..stationsStatusCode = 500;
    final userModel = buildUserModel();

    await runWithFakeHttp(client, () async {
      await pumpPerfilEditPage(
        tester,
        profile: fakeProfile(),
        userModel: userModel,
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(DropdownMenu<City>), findsOneWidget);
    });
  });

  testWidgets('si fetchCities llença excepció deixa de mostrar loading', (
    tester,
  ) async {
    final client = FakeHttpClient()..throwOnStations = true;
    final userModel = buildUserModel();

    await runWithFakeHttp(client, () async {
      await pumpPerfilEditPage(
        tester,
        profile: fakeProfile(),
        userModel: userModel,
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(DropdownMenu<City>), findsOneWidget);
    });
  });

  testWidgets('mostra els camps principals i el botó de guardar', (
    tester,
  ) async {
    final client = FakeHttpClient();
    final userModel = buildUserModel();

    await runWithFakeHttp(client, () async {
      await pumpPerfilEditPage(
        tester,
        profile: fakeProfile(),
        userModel: userModel,
      );

      final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

      expect(find.text(l10n.profileEditTitle), findsOneWidget);
      expect(find.text(l10n.profileEditUserDataTitle), findsOneWidget);
      expect(find.text(l10n.loginUsernameLabel), findsOneWidget);
      expect(find.text(l10n.commonCity), findsOneWidget);
      expect(find.text(l10n.commonLanguage), findsOneWidget);
      expect(find.text(l10n.commonSave), findsOneWidget);
      expect(find.byIcon(Icons.save_rounded), findsOneWidget);
    });
  });

  testWidgets('permet editar el username', (tester) async {
    final client = FakeHttpClient();
    final userModel = buildUserModel();

    await runWithFakeHttp(client, () async {
      await pumpPerfilEditPage(
        tester,
        profile: fakeProfile(username: 'JardineroFiel'),
        userModel: userModel,
      );

      await tester.enterText(
        find.byKey(const Key('edit_profile_username_field')),
        'NouNom',
      );
      await tester.pump();

      expect(find.text('NouNom'), findsOneWidget);
      expect(find.text('JardineroFiel'), findsNothing);
    });
  });

  testWidgets('permet obrir el dropdown de ciutats', (tester) async {
    final client = FakeHttpClient();
    final userModel = buildUserModel();

    await runWithFakeHttp(client, () async {
      await pumpPerfilEditPage(
        tester,
        profile: fakeProfile(city: 'Barcelona'),
        userModel: userModel,
      );

      await tester.tap(find.byKey(const Key('edit_profile_city_dropdown')));
      await tester.pumpAndSettle();

      expect(find.text('Barcelona'), findsWidgets);
      expect(find.text('Vic'), findsWidgets);
      expect(find.text('Girona'), findsWidgets);
    });
  });

  testWidgets('permet seleccionar una nova ciutat', (tester) async {
    final client = FakeHttpClient();
    final userModel = buildUserModel();

    await runWithFakeHttp(client, () async {
      await pumpPerfilEditPage(
        tester,
        profile: fakeProfile(city: 'Barcelona'),
        userModel: userModel,
      );

      await tester.tap(find.byKey(const Key('edit_profile_city_dropdown')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Vic').last);
      await tester.pumpAndSettle();

      expect(find.text('Vic'), findsWidgets);
    });
  });

  testWidgets('mostra idioma català normalitzat des de ca', (tester) async {
    final client = FakeHttpClient();
    final userModel = buildUserModel();

    await runWithFakeHttp(client, () async {
      await pumpPerfilEditPage(
        tester,
        profile: fakeProfile(language: 'ca'),
        userModel: userModel,
      );

      final dropdown = tester.widget<DropdownButtonFormField<String>>(
        find.byKey(const Key('edit_profile_language_dropdown')),
      );

      expect(dropdown.initialValue, 'ca');
    });
  });

  testWidgets('normalitza català escrit com Català', (tester) async {
    final client = FakeHttpClient();
    final userModel = buildUserModel();

    await runWithFakeHttp(client, () async {
      await pumpPerfilEditPage(
        tester,
        profile: fakeProfile(language: 'Català'),
        userModel: userModel,
      );

      final dropdown = tester.widget<DropdownButtonFormField<String>>(
        find.byKey(const Key('edit_profile_language_dropdown')),
      );

      expect(dropdown.initialValue, 'ca');
    });
  });

  testWidgets('normalitza castellà a es', (tester) async {
    final client = FakeHttpClient();
    final userModel = buildUserModel();

    await runWithFakeHttp(client, () async {
      await pumpPerfilEditPage(
        tester,
        profile: fakeProfile(language: 'Español'),
        userModel: userModel,
      );

      final dropdown = tester.widget<DropdownButtonFormField<String>>(
        find.byKey(const Key('edit_profile_language_dropdown')),
      );

      expect(dropdown.initialValue, 'es');
    });
  });

  testWidgets('normalitza english a en', (tester) async {
    final client = FakeHttpClient();
    final userModel = buildUserModel();

    await runWithFakeHttp(client, () async {
      await pumpPerfilEditPage(
        tester,
        profile: fakeProfile(language: 'English'),
        userModel: userModel,
      );

      final dropdown = tester.widget<DropdownButtonFormField<String>>(
        find.byKey(const Key('edit_profile_language_dropdown')),
      );

      expect(dropdown.initialValue, 'en');
    });
  });

  testWidgets('idioma desconegut queda sense valor inicial', (tester) async {
    final client = FakeHttpClient();
    final userModel = buildUserModel();

    await runWithFakeHttp(client, () async {
      await pumpPerfilEditPage(
        tester,
        profile: fakeProfile(language: 'Italiano'),
        userModel: userModel,
      );

      final dropdown = tester.widget<DropdownButtonFormField<String>>(
        find.byKey(const Key('edit_profile_language_dropdown')),
      );

      expect(dropdown.initialValue, null);
    });
  });

  testWidgets('permet canviar idioma a espanyol', (tester) async {
    final client = FakeHttpClient();
    final userModel = buildUserModel();
    final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

    await runWithFakeHttp(client, () async {
      await pumpPerfilEditPage(
        tester,
        profile: fakeProfile(language: 'ca'),
        userModel: userModel,
      );

      await tester.tap(find.byKey(const Key('edit_profile_language_dropdown')));
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.languageSpanish).last);
      await tester.pumpAndSettle();

      expect(find.text(l10n.languageSpanish), findsWidgets);
    });
  });

  testWidgets('permet canviar idioma a anglès', (tester) async {
    final client = FakeHttpClient();
    final userModel = buildUserModel();
    final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

    await runWithFakeHttp(client, () async {
      await pumpPerfilEditPage(
        tester,
        profile: fakeProfile(language: 'ca'),
        userModel: userModel,
      );

      await tester.tap(find.byKey(const Key('edit_profile_language_dropdown')));
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.languageEnglish).last);
      await tester.pumpAndSettle();

      expect(find.text(l10n.languageEnglish), findsWidgets);
    });
  });

  testWidgets('actualitzar perfil correcte envia POST i actualitza UserModel', (
    tester,
  ) async {
    final client = FakeHttpClient();
    final userModel = buildUserModel();

    await runWithFakeHttp(client, () async {
      await pumpPerfilEditPage(
        tester,
        profile: fakeProfile(username: 'JardineroFiel', city: 'Barcelona'),
        userModel: userModel,
      );

      await tester.enterText(
        find.byKey(const Key('edit_profile_username_field')),
        'NouNom',
      );

      await tester.tap(find.byKey(const Key('edit_profile_city_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Vic').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('edit_profile_language_dropdown')));
      await tester.pumpAndSettle();

      final l10n = await AppLocalizations.delegate.load(const Locale('ca'));
      await tester.tap(find.text(l10n.languageSpanish).last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('save_profile_button')));
      await tester.pump();

      await tester.tap(find.byKey(const Key('save_profile_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final editRequests = client.requests.where(
        (request) => request.url.path.endsWith('/api/edit_profile/'),
      );

      expect(editRequests.length, 1);
      expect(editRequests.first.method, 'POST');
      expect(editRequests.first.headers['authorization']?.first, 'Token fake-token');
      expect(editRequests.first.body, contains('"username":"NouNom"'));
      expect(editRequests.first.body, contains('"city":"Vic"'));
      expect(editRequests.first.body, contains('"language":"es"'));
      expect(editRequests.first.body, contains('"stationCode":"08298"'));

      expect(userModel.username, 'NouNom');
      expect(userModel.city, 'Vic');
      expect(userModel.language, 'es');
    });
  });

  testWidgets('actualitzar perfil amb error mostra CenteredMessage', (
    tester,
  ) async {
    final client = FakeHttpClient()
      ..editProfileStatusCode = 400
      ..editProfileBody = {'error': 'invalid profile'};

    final userModel = buildUserModel();

    await runWithFakeHttp(client, () async {
      await pumpPerfilEditPage(
        tester,
        profile: fakeProfile(username: 'JardineroFiel', city: 'Barcelona'),
        userModel: userModel,
      );

      await tester.ensureVisible(find.byKey(const Key('save_profile_button')));
      await tester.pump();

      await tester.tap(find.byKey(const Key('save_profile_button')));
      await tester.pump();

      final editRequests = client.requests.where(
        (request) => request.url.path.endsWith('/api/edit_profile/'),
      );

      expect(editRequests.length, 1);
      expect(userModel.username, 'OldUser');

      await finishCenteredMessageTimer(tester);
    });
  });

  testWidgets('actualitzar perfil envia ciutat null si no hi ha ciutat seleccionada', (
    tester,
  ) async {
    final client = FakeHttpClient();
    final userModel = buildUserModel();

    await runWithFakeHttp(client, () async {
      await pumpPerfilEditPage(
        tester,
        profile: fakeProfile(city: 'NoExisteix', language: 'ca'),
        userModel: userModel,
      );

      await tester.enterText(
        find.byKey(const Key('edit_profile_username_field')),
        'SenseCiutat',
      );

      await tester.ensureVisible(find.byKey(const Key('save_profile_button')));
      await tester.pump();

      await tester.tap(find.byKey(const Key('save_profile_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final editRequests = client.requests.where(
        (request) => request.url.path.endsWith('/api/edit_profile/'),
      );

      expect(editRequests.length, 1);
      expect(editRequests.first.body, contains('"username":"SenseCiutat"'));
      expect(editRequests.first.body, contains('"city":null'));
      expect(editRequests.first.body, contains('"stationCode":null'));
    });
  });

  testWidgets('City.fromJson crea una ciutat correctament', (tester) async {
    final city = City.fromJson({'code': '08019', 'name': 'Barcelona'});

    expect(city.code, '08019');
    expect(city.name, 'Barcelona');
  });

  testWidgets('City compara igualtat per code', (tester) async {
    final cityA = City(code: '001', name: 'Barcelona');
    final cityB = City(code: '001', name: 'BCN');
    final cityC = City(code: '002', name: 'Vic');

    expect(cityA, cityB);
    expect(cityA == cityC, false);
    expect(cityA.hashCode, cityB.hashCode);
  });

  testWidgets('City no és igual a un objecte d’un altre tipus', (tester) async {
    final city = City(code: '001', name: 'Barcelona');

    expect(city == 'Barcelona', false);
  });
}
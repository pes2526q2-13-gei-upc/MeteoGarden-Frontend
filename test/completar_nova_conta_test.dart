import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_garden/generated/app_localizations.dart';
import 'package:meteo_garden/models/avatar_user.dart';
import 'package:meteo_garden/models/dades_usr.dart';
import 'package:meteo_garden/models/plantes_desbl.dart';
import 'package:meteo_garden/screens/completar_nova_conta.dart';
import 'package:provider/provider.dart';

class FakeHttpClient implements HttpClient {
  int stationsStatusCode = 200;
  Object stationsBody = [
    {'code': '08019', 'name': 'Barcelona'},
    {'code': '08298', 'name': 'Vic'},
    {'code': '17079', 'name': 'Girona'},
  ];

  int registerStatusCode = 400;
  Object registerBody = {'error': 'google register failed'};

  int profileStatusCode = 200;
  Object profileBody = {
    'username': 'jana',
    'email': 'jana@test.com',
    'city': 'Barcelona',
    'language': 'ca',
    'lastEntry': '2026-05-20',
    'numPlantsCollected': 4,
    'numCoins': 30,
    'gardens': [
      {'gardenName': 'JardiJana'},
    ],
  };

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
      return FakeHttpClientResponse(
        statusCode: stationsStatusCode,
        body: jsonEncode(stationsBody),
      );
    }

    if (url.path.endsWith('/api/auth/google/register')) {
      return FakeHttpClientResponse(
        statusCode: registerStatusCode,
        body: jsonEncode(registerBody),
      );
    }

    if (url.path.endsWith('/api/get_profile/')) {
      return FakeHttpClientResponse(
        statusCode: profileStatusCode,
        body: jsonEncode(profileBody),
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
  FakeHttpClientRequest(this.client, String method, this.url) : _method = method;

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

Widget makeTestableWidget({UserModel? userModel}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<UserModel>.value(
        value: userModel ?? UserModel(),
      ),
      ChangeNotifierProvider<AvatarUser>(
        create: (_) => AvatarUser(),
      ),
      ChangeNotifierProvider<PlantProvider>(
        create: (_) => PlantProvider(),
      ),
    ],
    child: const MaterialApp(
      locale: Locale('ca'),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: CompleteGoogleProfilePage(
        googleToken: 'fake-google-token',
        email: 'jana@test.com',
      ),
    ),
  );
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

Future<void> pumpCompleteGoogleProfilePage(
  WidgetTester tester, {
  UserModel? userModel,
}) async {
  tester.view.physicalSize = const Size(1200, 2200);
  tester.view.devicePixelRatio = 1.0;

  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(makeTestableWidget(userModel: userModel));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> fillRequiredFields(WidgetTester tester) async {
  final textFields = find.byType(TextField);

  await tester.enterText(textFields.at(0), 'jana');
  await tester.enterText(textFields.at(2), '123456');
  await tester.enterText(textFields.at(3), 'JardiJana');

  await tester.pump();
}

Finder continueButton(AppLocalizations l10n) {
  return find.widgetWithText(FilledButton, l10n.commonContinue);
}

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets('mostra loading inicial mentre carrega ciutats', (tester) async {
    final client = FakeHttpClient();

    await runWithFakeHttp(client, () async {
      tester.view.physicalSize = const Size(1200, 2200);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(makeTestableWidget());

      expect(find.byType(CompleteGoogleProfilePage), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 300));
    });
  });

  testWidgets('mostra la pantalla de completar perfil de Google', (
    tester,
  ) async {
    final client = FakeHttpClient();

    await runWithFakeHttp(client, () async {
      await pumpCompleteGoogleProfilePage(tester);

      expect(find.byType(CompleteGoogleProfilePage), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  testWidgets('fetchCities fa GET a stations i carrega les ciutats', (
    tester,
  ) async {
    final client = FakeHttpClient();

    await runWithFakeHttp(client, () async {
      await pumpCompleteGoogleProfilePage(tester);

      final stationRequests = client.requests.where(
        (request) => request.url.path.endsWith('/api/stations/'),
      );

      expect(stationRequests.length, 1);
      expect(stationRequests.first.method, 'GET');
      expect(find.byType(DropdownMenu<City>), findsOneWidget);
    });
  });

  testWidgets('si fetchCities retorna error igual deixa de carregar', (
    tester,
  ) async {
    final client = FakeHttpClient()..stationsStatusCode = 500;

    await runWithFakeHttp(client, () async {
      await pumpCompleteGoogleProfilePage(tester);

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(DropdownMenu<City>), findsOneWidget);
    });
  });

  testWidgets('permet obrir el dropdown de ciutats carregades', (tester) async {
    final client = FakeHttpClient();

    await runWithFakeHttp(client, () async {
      await pumpCompleteGoogleProfilePage(tester);

      await tester.tap(find.byType(DropdownMenu<City>));
      await tester.pumpAndSettle();

      expect(find.text('Barcelona'), findsWidgets);
      expect(find.text('Vic'), findsWidgets);
      expect(find.text('Girona'), findsWidgets);
    });
  });

  testWidgets('permet seleccionar una ciutat', (tester) async {
    final client = FakeHttpClient();

    await runWithFakeHttp(client, () async {
      await pumpCompleteGoogleProfilePage(tester);

      await tester.tap(find.byType(DropdownMenu<City>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Vic').last);
      await tester.pumpAndSettle();

      expect(find.text('Vic'), findsWidgets);
    });
  });

  testWidgets('mostra el títol i textos principals', (tester) async {
    final client = FakeHttpClient();

    await runWithFakeHttp(client, () async {
      await pumpCompleteGoogleProfilePage(tester);

      final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text(l10n.completeProfileTitle), findsOneWidget);
      expect(find.text(l10n.completeProfileHeading), findsOneWidget);
      expect(find.text(l10n.completeProfileSubtitle), findsOneWidget);
    });
  });

  testWidgets('mostra els camps principals del formulari', (tester) async {
    final client = FakeHttpClient();

    await runWithFakeHttp(client, () async {
      await pumpCompleteGoogleProfilePage(tester);

      final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

      expect(find.text(l10n.loginUsernameLabel), findsOneWidget);
      expect(find.text(l10n.commonCity), findsOneWidget);
      expect(find.text(l10n.completeProfilePasswordOptional), findsOneWidget);
      expect(find.text(l10n.commonLanguage), findsOneWidget);
      expect(find.text(l10n.createAccountGardenNameLabel), findsOneWidget);
    });
  });

  testWidgets('mostra les icones dels camps del formulari', (tester) async {
    final client = FakeHttpClient();

    await runWithFakeHttp(client, () async {
      await pumpCompleteGoogleProfilePage(tester);

      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.location_city_rounded), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.language_rounded), findsOneWidget);
      expect(find.byIcon(Icons.local_florist_outlined), findsOneWidget);
    });
  });

  testWidgets('permet escriure username, password i nom del jardí', (
    tester,
  ) async {
    final client = FakeHttpClient();

    await runWithFakeHttp(client, () async {
      await pumpCompleteGoogleProfilePage(tester);

      await fillRequiredFields(tester);

      expect(find.text('jana'), findsOneWidget);
      expect(find.text('123456'), findsOneWidget);
      expect(find.text('JardiJana'), findsOneWidget);
    });
  });

  testWidgets('el camp password és obscureText', (tester) async {
    final client = FakeHttpClient();

    await runWithFakeHttp(client, () async {
      await pumpCompleteGoogleProfilePage(tester);

      final textFields = find.byType(TextField);
      final passwordTextField = tester.widget<TextField>(textFields.at(2));

      expect(passwordTextField.obscureText, true);
    });
  });

  testWidgets('el camp username no és obscureText', (tester) async {
    final client = FakeHttpClient();

    await runWithFakeHttp(client, () async {
      await pumpCompleteGoogleProfilePage(tester);

      final textFields = find.byType(TextField);
      final usernameTextField = tester.widget<TextField>(textFields.at(0));

      expect(usernameTextField.obscureText, false);
    });
  });

  testWidgets('mostra el dropdown de llengua', (tester) async {
    final client = FakeHttpClient();

    await runWithFakeHttp(client, () async {
      await pumpCompleteGoogleProfilePage(tester);

      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });
  });

  testWidgets('obre el dropdown de llengua', (tester) async {
    final client = FakeHttpClient();

    await runWithFakeHttp(client, () async {
      await pumpCompleteGoogleProfilePage(tester);

      final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      expect(find.text(l10n.languageCatalan), findsOneWidget);
      expect(find.text(l10n.languageSpanish), findsOneWidget);
      expect(find.text(l10n.languageEnglish), findsOneWidget);
    });
  });

  testWidgets('permet seleccionar llengua catalana', (tester) async {
    final client = FakeHttpClient();

    await runWithFakeHttp(client, () async {
      await pumpCompleteGoogleProfilePage(tester);

      final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.languageCatalan).last);
      await tester.pumpAndSettle();

      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });
  });

  testWidgets('permet seleccionar llengua espanyola', (tester) async {
    final client = FakeHttpClient();

    await runWithFakeHttp(client, () async {
      await pumpCompleteGoogleProfilePage(tester);

      final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.languageSpanish).last);
      await tester.pumpAndSettle();

      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });
  });

  testWidgets('permet seleccionar llengua anglesa', (tester) async {
    final client = FakeHttpClient();

    await runWithFakeHttp(client, () async {
      await pumpCompleteGoogleProfilePage(tester);

      final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.languageEnglish).last);
      await tester.pumpAndSettle();

      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });
  });

  testWidgets('mostra el botó de continuar', (tester) async {
    final client = FakeHttpClient();

    await runWithFakeHttp(client, () async {
      await pumpCompleteGoogleProfilePage(tester);

      final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

      expect(find.text(l10n.commonContinue), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
    });
  });

  testWidgets('registre Google amb error mostra SnackBar d’error', (
    tester,
  ) async {
    final client = FakeHttpClient()
      ..registerStatusCode = 400
      ..registerBody = {'error': 'invalid google token'};

    await runWithFakeHttp(client, () async {
      await pumpCompleteGoogleProfilePage(tester);

      final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

      await fillRequiredFields(tester);

      await tester.ensureVisible(continueButton(l10n));
      await tester.pump();

      await tester.tap(continueButton(l10n));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final registerRequests = client.requests.where(
        (request) => request.url.path.endsWith('/api/auth/google/register'),
      );

      expect(registerRequests.length, 1);
      expect(registerRequests.first.method, 'POST');
      expect(registerRequests.first.body, contains('"id_token":"fake-google-token"'));
      expect(registerRequests.first.body, contains('"username":"jana"'));
      expect(registerRequests.first.body, contains('"password":"123456"'));
      expect(registerRequests.first.body, contains('"email":"jana@test.com"'));
      expect(registerRequests.first.body, contains('"gardenName":"JardiJana"'));

      expect(find.text(l10n.completeProfileError), findsOneWidget);
    });
  });

  testWidgets('registre Google correcte desa perfil i token', (tester) async {
    final client = FakeHttpClient()
      ..registerStatusCode = 200
      ..registerBody = {'token': 'fake-auth-token'};

    final userModel = UserModel();

    await runWithFakeHttp(client, () async {
      await pumpCompleteGoogleProfilePage(tester, userModel: userModel);

      final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

      await fillRequiredFields(tester);

      await tester.tap(find.byType(DropdownMenu<City>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Barcelona').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.languageCatalan).last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(continueButton(l10n));
      await tester.pump();

      await tester.tap(continueButton(l10n));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final registerRequests = client.requests.where(
        (request) => request.url.path.endsWith('/api/auth/google/register'),
      );

      final profileRequests = client.requests.where(
        (request) => request.url.path.endsWith('/api/get_profile/'),
      );

      expect(registerRequests.length, 1);
      expect(profileRequests.length, 1);

      expect(profileRequests.first.headers['authorization']?.first, 'Token fake-auth-token');

      expect(userModel.username, 'jana');
      expect(userModel.email, 'jana@test.com');
      expect(userModel.city, 'Barcelona');
      expect(userModel.language, 'ca');
      expect(userModel.monedes, 30);
      expect(userModel.gardens, contains('JardiJana'));
    });
  });

  testWidgets('registre correcte però error carregant perfil mostra SnackBar', (
    tester,
  ) async {
    final client = FakeHttpClient()
      ..registerStatusCode = 200
      ..registerBody = {'token': 'fake-auth-token'}
      ..profileStatusCode = 500
      ..profileBody = {'error': 'profile failed'};

    final userModel = UserModel();

    await runWithFakeHttp(client, () async {
      await pumpCompleteGoogleProfilePage(tester, userModel: userModel);

      final l10n = await AppLocalizations.delegate.load(const Locale('ca'));

      await fillRequiredFields(tester);

      await tester.ensureVisible(continueButton(l10n));
      await tester.pump();

      await tester.tap(continueButton(l10n));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final registerRequests = client.requests.where(
        (request) => request.url.path.endsWith('/api/auth/google/register'),
      );

      final profileRequests = client.requests.where(
        (request) => request.url.path.endsWith('/api/get_profile/'),
      );

      expect(registerRequests.length, 1);
      expect(profileRequests.length, 1);
      expect(userModel.username, '');

      expect(find.text(l10n.profileLoadError), findsWidgets);
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

  testWidgets('City no és igual a un objecte diferent', (tester) async {
    final city = City(code: '001', name: 'Barcelona');

    expect(city == 'Barcelona', false);
  });
}
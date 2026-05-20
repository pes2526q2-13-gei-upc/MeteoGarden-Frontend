import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:meteo_garden/generated/app_localizations.dart';
import 'package:meteo_garden/models/avatar_user.dart';
import 'package:meteo_garden/models/dades_usr.dart';
import 'package:meteo_garden/models/plantes_desbl.dart';
import 'package:meteo_garden/models/weather_provider.dart';
import 'package:meteo_garden/screens/login_page.dart';
import 'package:provider/provider.dart';

Widget buildLoginPage({http.Client? client}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => UserModel()),
      ChangeNotifierProvider(create: (_) => AvatarUser()),
      ChangeNotifierProvider(create: (_) => PlantProvider()),
      ChangeNotifierProvider(create: (_) => WeatherProvider()),
    ],
    child: MaterialApp(
      locale: const Locale('ca'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: LoginPage(client: client),
    ),
  );
}

http.Client emptyClient() {
  return MockClient((request) async {
    return http.Response('{}', 404);
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets('mostra la pantalla de login correctament', (tester) async {
    await tester.pumpWidget(buildLoginPage(client: emptyClient()));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login_username_field')), findsOneWidget);
    expect(find.byKey(const Key('login_password_field')), findsOneWidget);
    expect(find.byKey(const Key('login_button')), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
  });

  testWidgets('canvia idioma des del selector', (tester) async {
    await tester.pumpWidget(buildLoginPage(client: emptyClient()));
    await tester.pumpAndSettle();

    expect(find.text('CA'), findsOneWidget);

    await tester.tap(find.text('CA'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();

    expect(find.text('ES'), findsOneWidget);
  });

  testWidgets('mostra error si els camps estan buits', (tester) async {
    await tester.pumpWidget(buildLoginPage(client: emptyClient()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
  });

  testWidgets('neteja un error anterior quan es torna a intentar login', (
    tester,
  ) async {
    final client = MockClient((request) async {
      if (request.url.path.endsWith('/api/login/')) {
        return http.Response(
          jsonEncode({'error': 'Invalid credentials'}),
          401,
          headers: {'content-type': 'application/json'},
        );
      }

      return http.Response('{}', 404);
    });

    await tester.pumpWidget(buildLoginPage(client: client));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('login_username_field')),
      'jana',
    );
    await tester.enterText(
      find.byKey(const Key('login_password_field')),
      'wrong-password',
    );

    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
  });

  testWidgets('mostra error si les credencials són incorrectes amb status 401', (
    tester,
  ) async {
    final client = MockClient((request) async {
      if (request.url.path.endsWith('/api/login/')) {
        return http.Response(
          jsonEncode({'error': 'Invalid credentials'}),
          401,
          headers: {'content-type': 'application/json'},
        );
      }

      return http.Response('{}', 404);
    });

    await tester.pumpWidget(buildLoginPage(client: client));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('login_username_field')),
      'jana',
    );
    await tester.enterText(
      find.byKey(const Key('login_password_field')),
      'wrong-password',
    );

    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
  });

  testWidgets('mostra error si les credencials són incorrectes amb status 400', (
    tester,
  ) async {
    final client = MockClient((request) async {
      if (request.url.path.endsWith('/api/login/')) {
        return http.Response(
          jsonEncode({'error': 'Bad request'}),
          400,
          headers: {'content-type': 'application/json'},
        );
      }

      return http.Response('{}', 404);
    });

    await tester.pumpWidget(buildLoginPage(client: client));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('login_username_field')),
      'jana',
    );
    await tester.enterText(
      find.byKey(const Key('login_password_field')),
      'wrong-password',
    );

    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
  });

  testWidgets('mostra error de servidor si el login retorna 500', (tester) async {
    final client = MockClient((request) async {
      if (request.url.path.endsWith('/api/login/')) {
        return http.Response('Server error', 500);
      }

      return http.Response('{}', 404);
    });

    await tester.pumpWidget(buildLoginPage(client: client));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('login_username_field')),
      'jana',
    );
    await tester.enterText(
      find.byKey(const Key('login_password_field')),
      'password',
    );

    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
  });

  testWidgets('mostra error de connexió si falla la petició', (tester) async {
    final client = MockClient((request) async {
      throw Exception('connection failed');
    });

    await tester.pumpWidget(buildLoginPage(client: client));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('login_username_field')),
      'jana',
    );
    await tester.enterText(
      find.byKey(const Key('login_password_field')),
      'password',
    );

    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
  });

  testWidgets(
    'fa login correcte, carrega perfil i mostra error si falla avatar',
    (tester) async {
      final client = MockClient((request) async {
        if (request.method == 'POST' &&
            request.url.path.endsWith('/api/login/')) {
          return http.Response(
            jsonEncode({'token': 'fake-token'}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        if (request.method == 'GET' &&
            request.url.path.endsWith('/api/get_profile/')) {
          return http.Response(
            jsonEncode({
              'username': 'jana',
              'email': 'jana@test.com',
              'city': '',
              'language': 'ca',
              'lastEntry': '2026-05-20',
              'numPlantsCollected': 3,
              'numCoins': 10,
              'gardens': [
                {'gardenName': 'Principal'},
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        if (request.method == 'GET' &&
            request.url.path.endsWith('/api/users/jana/avatar')) {
          return http.Response(
            jsonEncode({'error': 'Avatar error'}),
            500,
            headers: {'content-type': 'application/json'},
          );
        }

        return http.Response('{}', 404);
      });

      await tester.pumpWidget(buildLoginPage(client: client));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('login_username_field')),
        'jana',
      );
      await tester.enterText(
        find.byKey(const Key('login_password_field')),
        'password',
      );

      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    },
  );

  testWidgets(
    'fa login correcte però mostra error si falla la càrrega del perfil',
    (tester) async {
      final client = MockClient((request) async {
        if (request.method == 'POST' &&
            request.url.path.endsWith('/api/login/')) {
          return http.Response(
            jsonEncode({'token': 'fake-token'}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        if (request.method == 'GET' &&
            request.url.path.endsWith('/api/get_profile/')) {
          return http.Response(
            jsonEncode({'error': 'Profile error'}),
            500,
            headers: {'content-type': 'application/json'},
          );
        }

        if (request.method == 'GET' &&
            request.url.path.contains('/api/users/')) {
          return http.Response(
            jsonEncode({'error': 'Avatar error'}),
            500,
            headers: {'content-type': 'application/json'},
          );
        }

        return http.Response('{}', 404);
      });

      await tester.pumpWidget(buildLoginPage(client: client));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('login_username_field')),
        'jana',
      );
      await tester.enterText(
        find.byKey(const Key('login_password_field')),
        'password',
      );

      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(SnackBar), findsWidgets);
    },
  );
}
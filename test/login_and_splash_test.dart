import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

// =====================================================================
// 1. SIMULAMOS LAS FUNCIONES DE TU APP (Para poder inyectar el MockClient)
// =====================================================================

// Simula la llamada de _login() en LoginPage
Future<String?> apiLogin(
  http.Client client,
  String username,
  String password,
) async {
  final response = await client.post(
    Uri.parse(
      'https://midominio.com/api/login/',
    ), // Sustituye por tu ApiConfig.baseUrl
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"username": username, "password": password}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['token']; // Retorna el token si hay éxito
  }
  return null; // Retorna nulo si falla
}

// Simula la llamada _fetchAndSaveProfile() del SplashScreen
Future<Map<String, dynamic>?> apiGetProfile(
  http.Client client,
  String token,
) async {
  final response = await client.get(
    Uri.parse('https://midominio.com/api/get_profile/'),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Token $token",
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body); // Retorna los datos del perfil
  } else {
    throw Exception('Error 401: Token inválido');
  }
}

// =====================================================================
// 2. AQUÍ EMPIEZAN LOS TESTS
// =====================================================================
void main() {
  group('Tests de Login API', () {
    test(
      'Debe devolver un token cuando las credenciales son correctas (200 OK)',
      () async {
        // 1. PREPARAR: Creamos el servidor falso
        final mockClient = MockClient((request) async {
          // Verificamos que se envía el body correcto
          final bodyCuerpo = jsonDecode(request.body);
          expect(bodyCuerpo['username'], 'admin');
          expect(bodyCuerpo['password'], '1234');

          // Simulamos la respuesta de tu backend
          return http.Response('{"token": "token_valido_123"}', 200);
        });

        // 2. EJECUTAR
        final tokenDevuelto = await apiLogin(mockClient, 'admin', '1234');

        // 3. COMPROBAR
        expect(tokenDevuelto, 'token_valido_123'); // El login tuvo éxito
      },
    );

    test(
      'Debe devolver NULL cuando el login falla (ej. contraseña incorrecta)',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response('{"error": "Credenciales inválidas"}', 400);
        });

        final tokenDevuelto = await apiLogin(mockClient, 'admin', 'mala_pass');

        expect(tokenDevuelto, isNull); // Comprueba que falla correctamente
      },
    );
  });

  group('Tests de SplashScreen API (Persistencia)', () {
    test(
      'Debe devolver los datos del usuario si el token guardado es válido',
      () async {
        final mockClient = MockClient((request) async {
          // Comprobamos que el token se está enviando en la cabecera
          expect(request.headers['Authorization'], 'Token token_guardado_123');

          // Simulamos la respuesta de tu get_profile
          return http.Response('''
        {
          "username": "Jardinero",
          "email": "jardinero@test.com",
          "city": "Barcelona",
          "gardens": [{"gardenName": "Mi Huerto"}]
        }
        ''', 200);
        });

        final perfil = await apiGetProfile(mockClient, 'token_guardado_123');

        expect(perfil, isNotNull);
        expect(perfil!['username'], 'Jardinero');
        expect(perfil['gardens'][0]['gardenName'], 'Mi Huerto');
      },
    );

    test(
      'Debe lanzar una Excepción si el backend devuelve un 401 (Token Expirado)',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response('{"detail": "Invalid token."}', 401);
        });

        // Comprobamos que lanzar esta función con un mal servidor tira la Excepción esperada
        // Esto simula lo que luego captura tu bloque "catch" en el SplashScreen
        expect(
          () async => await apiGetProfile(mockClient, 'token_caducado'),
          throwsException,
        );
      },
    );
  });
}

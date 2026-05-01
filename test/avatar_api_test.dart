import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

// Imagina que esta es la función que usas para guardar el avatar.
// NOTA: Le pasamos el http.Client como parámetro para poder inyectar el Mock.
Future<bool> saveAvatarToBackend(
  http.Client client,
  String token,
  Map<String, String> avatarOptions,
) async {
  final response = await client.post(
    Uri.parse('https://midominio.com/api/save_avatar/'),
    headers: {
      "Authorization": "Token $token",
      "Content-Type": "application/json",
    },
    body: jsonEncode(avatarOptions),
  );

  return response.statusCode == 200;
}

void main() {
  group('Pruebas de Guardar Avatar (API)', () {
    final avatarSimulado = {
      'body': 'body_1',
      'eye': 'eye_blue',
      'hair': 'hair_short_brown',
    };

    test('Debe devolver TRUE si el servidor responde con 200 OK', () async {
      // 1. Preparar el Mock
      final mockClient = MockClient((request) async {
        // Comprobamos que envía los datos correctos
        expect(request.headers['Authorization'], 'Token fake_token');
        expect(request.body.contains('body_1'), isTrue);

        // Simulamos respuesta exitosa
        return http.Response('{"message": "Avatar guardado"}', 200);
      });

      // 2. Ejecutar
      final result = await saveAvatarToBackend(
        mockClient,
        'fake_token',
        avatarSimulado,
      );

      // 3. Comprobar
      expect(result, isTrue);
    });

    test(
      'Debe devolver FALSE si el servidor da error (ej. 400 o 500)',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            '{"error": "Faltan datos"}',
            400,
          ); // Simulamos un error del backend
        });

        final result = await saveAvatarToBackend(
          mockClient,
          'fake_token',
          avatarSimulado,
        );

        expect(result, isFalse);
      },
    );
  });
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:meteo_garden/services/plant_service.dart';

class FakePlantClient extends http.BaseClient {
  FakePlantClient(this.handler);

  final Future<http.StreamedResponse> Function(http.BaseRequest request) handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return handler(request);
  }
}

http.StreamedResponse streamedJsonResponse(
  Map<String, dynamic> body,
  int statusCode,
) {
  return http.StreamedResponse(
    Stream<List<int>>.fromIterable([
      utf8.encode(jsonEncode(body)),
    ]),
    statusCode,
    headers: {
      'content-type': 'application/json',
    },
  );
}

http.StreamedResponse streamedTextResponse(
  String body,
  int statusCode,
) {
  return http.StreamedResponse(
    Stream<List<int>>.fromIterable([
      utf8.encode(body),
    ]),
    statusCode,
  );
}

void main() {
  group('PlantService', () {
    late File tempImage;

    setUp(() async {
      tempImage = File('${Directory.systemTemp.path}/test_plant_image.jpg');
      await tempImage.writeAsBytes([1, 2, 3, 4, 5]);
    });

    tearDown(() async {
      if (await tempImage.exists()) {
        await tempImage.delete();
      }
    });

    test('identifyPlant envia una MultipartRequest amb username, organ i image', () async {
      final service = PlantService(
        client: FakePlantClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, contains('/api/plants/identify'));
          expect(request, isA<http.MultipartRequest>());

          final multipartRequest = request as http.MultipartRequest;

          expect(multipartRequest.fields['username'], 'jana');
          expect(multipartRequest.fields['organ'], 'leaf');
          expect(multipartRequest.files.length, 1);
          expect(multipartRequest.files.first.field, 'image');

          return streamedJsonResponse({
            'plant': {
              'scientificName': 'Mentha spicata',
              'commonName': 'Menta',
              'family': 'Lamiaceae',
            },
            'image': {
              'id': 1,
              'url': 'https://example.com/menta.png',
              'width': 800,
              'height': 600,
            },
            'plantnet': {
              'score': 0.95,
            },
          }, 201);
        }),
      );

      final result = await service.identifyPlant(
        username: 'jana',
        imagePath: tempImage.path,
      );

      expect(result.plant.scientificName, 'Mentha spicata');
      expect(result.plant.commonName, 'Menta');
      expect(result.plant.family, 'Lamiaceae');

      expect(result.image.id, 1);
      expect(result.image.url, 'https://example.com/menta.png');
      expect(result.image.width, 800);
      expect(result.image.height, 600);

      expect(result.plantnet.score, 0.95);
    });

    test('identifyPlant envia organ personalitzat', () async {
      final service = PlantService(
        client: FakePlantClient((request) async {
          expect(request.method, 'POST');
          expect(request, isA<http.MultipartRequest>());

          final multipartRequest = request as http.MultipartRequest;

          expect(multipartRequest.fields['username'], 'jana');
          expect(multipartRequest.fields['organ'], 'flower');
          expect(multipartRequest.files.length, 1);
          expect(multipartRequest.files.first.field, 'image');

          return streamedJsonResponse({
            'plant': {
              'scientificName': 'Rosa rubiginosa',
              'commonName': 'Rosa',
              'family': 'Rosaceae',
            },
            'image': {
              'id': 2,
              'url': 'https://example.com/rosa.png',
              'width': 1024,
              'height': 768,
            },
            'plantnet': {
              'score': 0.90,
            },
          }, 201);
        }),
      );

      final result = await service.identifyPlant(
        username: 'jana',
        imagePath: tempImage.path,
        organ: 'flower',
      );

      expect(result.plant.scientificName, 'Rosa rubiginosa');
      expect(result.plant.commonName, 'Rosa');
      expect(result.plant.family, 'Rosaceae');

      expect(result.image.id, 2);
      expect(result.image.url, 'https://example.com/rosa.png');
      expect(result.image.width, 1024);
      expect(result.image.height, 768);

      expect(result.plantnet.score, 0.90);
    });

    test('identifyPlant llença PlantIdentificationException amb error 400 detail', () async {
      final service = PlantService(
        client: FakePlantClient((request) async {
          return streamedJsonResponse({
            'detail': 'Imatge obligatòria',
          }, 400);
        }),
      );

      expect(
        () => service.identifyPlant(
          username: 'jana',
          imagePath: tempImage.path,
        ),
        throwsA(
          predicate(
            (e) =>
                e is PlantIdentificationException &&
                e.statusCode == 400 &&
                e.message == 'Imatge obligatòria',
          ),
        ),
      );
    });

    test('identifyPlant llença PlantIdentificationException amb error 400 error', () async {
      final service = PlantService(
        client: FakePlantClient((request) async {
          return streamedJsonResponse({
            'error': 'Error de validació',
          }, 400);
        }),
      );

      expect(
        () => service.identifyPlant(
          username: 'jana',
          imagePath: tempImage.path,
        ),
        throwsA(
          predicate(
            (e) =>
                e is PlantIdentificationException &&
                e.statusCode == 400 &&
                e.message == 'Error de validació',
          ),
        ),
      );
    });

    test('identifyPlant llença PlantIdentificationException amb error 400 image', () async {
      final service = PlantService(
        client: FakePlantClient((request) async {
          return streamedJsonResponse({
            'image': 'La imatge no és vàlida',
          }, 400);
        }),
      );

      expect(
        () => service.identifyPlant(
          username: 'jana',
          imagePath: tempImage.path,
        ),
        throwsA(
          predicate(
            (e) =>
                e is PlantIdentificationException &&
                e.statusCode == 400 &&
                e.message == 'La imatge no és vàlida',
          ),
        ),
      );
    });

    test('identifyPlant llença PlantIdentificationException amb error 400 username', () async {
      final service = PlantService(
        client: FakePlantClient((request) async {
          return streamedJsonResponse({
            'username': 'Username obligatori',
          }, 400);
        }),
      );

      expect(
        () => service.identifyPlant(
          username: 'jana',
          imagePath: tempImage.path,
        ),
        throwsA(
          predicate(
            (e) =>
                e is PlantIdentificationException &&
                e.statusCode == 400 &&
                e.message == 'Username obligatori',
          ),
        ),
      );
    });

    test('identifyPlant llença PlantIdentificationException amb error 400 organ', () async {
      final service = PlantService(
        client: FakePlantClient((request) async {
          return streamedJsonResponse({
            'organ': 'Òrgan no vàlid',
          }, 400);
        }),
      );

      expect(
        () => service.identifyPlant(
          username: 'jana',
          imagePath: tempImage.path,
        ),
        throwsA(
          predicate(
            (e) =>
                e is PlantIdentificationException &&
                e.statusCode == 400 &&
                e.message == 'Òrgan no vàlid',
          ),
        ),
      );
    });

    test('identifyPlant llença PlantIdentificationException amb error 400 organs', () async {
      final service = PlantService(
        client: FakePlantClient((request) async {
          return streamedJsonResponse({
            'organs': 'Òrgans no vàlids',
          }, 400);
        }),
      );

      expect(
        () => service.identifyPlant(
          username: 'jana',
          imagePath: tempImage.path,
        ),
        throwsA(
          predicate(
            (e) =>
                e is PlantIdentificationException &&
                e.statusCode == 400 &&
                e.message == 'Òrgans no vàlids',
          ),
        ),
      );
    });

    test('identifyPlant llença PlantIdentificationException amb error 400 per defecte', () async {
      final service = PlantService(
        client: FakePlantClient((request) async {
          return streamedJsonResponse({}, 400);
        }),
      );

      expect(
        () => service.identifyPlant(
          username: 'jana',
          imagePath: tempImage.path,
        ),
        throwsA(
          predicate(
            (e) =>
                e is PlantIdentificationException &&
                e.statusCode == 400 &&
                e.message == 'La petició no és correcta.',
          ),
        ),
      );
    });

    test('identifyPlant llença PlantIdentificationException amb error 404 username', () async {
      final service = PlantService(
        client: FakePlantClient((request) async {
          return streamedJsonResponse({
            'username': 'Usuari no trobat',
          }, 404);
        }),
      );

      expect(
        () => service.identifyPlant(
          username: 'jana',
          imagePath: tempImage.path,
        ),
        throwsA(
          predicate(
            (e) =>
                e is PlantIdentificationException &&
                e.statusCode == 404 &&
                e.message == 'Usuari no trobat',
          ),
        ),
      );
    });

    test('identifyPlant llença PlantIdentificationException amb error 404 per defecte', () async {
      final service = PlantService(
        client: FakePlantClient((request) async {
          return streamedJsonResponse({}, 404);
        }),
      );

      expect(
        () => service.identifyPlant(
          username: 'jana',
          imagePath: tempImage.path,
        ),
        throwsA(
          predicate(
            (e) =>
                e is PlantIdentificationException &&
                e.statusCode == 404 &&
                e.message == 'No s’ha trobat el recurs demanat.',
          ),
        ),
      );
    });

    test('identifyPlant llença PlantIdentificationException amb error 422 detail', () async {
      final service = PlantService(
        client: FakePlantClient((request) async {
          return streamedJsonResponse({
            'detail': 'No identificada',
          }, 422);
        }),
      );

      expect(
        () => service.identifyPlant(
          username: 'jana',
          imagePath: tempImage.path,
        ),
        throwsA(
          predicate(
            (e) =>
                e is PlantIdentificationException &&
                e.statusCode == 422 &&
                e.message == 'No identificada',
          ),
        ),
      );
    });

    test('identifyPlant llença PlantIdentificationException amb error 422 per defecte', () async {
      final service = PlantService(
        client: FakePlantClient((request) async {
          return streamedJsonResponse({}, 422);
        }),
      );

      expect(
        () => service.identifyPlant(
          username: 'jana',
          imagePath: tempImage.path,
        ),
        throwsA(
          predicate(
            (e) =>
                e is PlantIdentificationException &&
                e.statusCode == 422 &&
                e.message == 'No s’ha pogut identificar la planta.',
          ),
        ),
      );
    });

    test('identifyPlant llença PlantIdentificationException amb error 502 detail', () async {
      final service = PlantService(
        client: FakePlantClient((request) async {
          return streamedJsonResponse({
            'detail': 'PlantNet ha fallat',
          }, 502);
        }),
      );

      expect(
        () => service.identifyPlant(
          username: 'jana',
          imagePath: tempImage.path,
        ),
        throwsA(
          predicate(
            (e) =>
                e is PlantIdentificationException &&
                e.statusCode == 502 &&
                e.message == 'PlantNet ha fallat',
          ),
        ),
      );
    });

    test('identifyPlant llença PlantIdentificationException amb error 502 per defecte', () async {
      final service = PlantService(
        client: FakePlantClient((request) async {
          return streamedJsonResponse({}, 502);
        }),
      );

      expect(
        () => service.identifyPlant(
          username: 'jana',
          imagePath: tempImage.path,
        ),
        throwsA(
          predicate(
            (e) =>
                e is PlantIdentificationException &&
                e.statusCode == 502 &&
                e.message == 'El servei d’identificació ha fallat.',
          ),
        ),
      );
    });

    test('identifyPlant llença PlantIdentificationException amb error 500 detail', () async {
      final service = PlantService(
        client: FakePlantClient((request) async {
          return streamedJsonResponse({
            'detail': 'Error del servidor',
          }, 500);
        }),
      );

      expect(
        () => service.identifyPlant(
          username: 'jana',
          imagePath: tempImage.path,
        ),
        throwsA(
          predicate(
            (e) =>
                e is PlantIdentificationException &&
                e.statusCode == 500 &&
                e.message == 'Error del servidor',
          ),
        ),
      );
    });

    test('identifyPlant llença PlantIdentificationException amb error 500 per defecte', () async {
      final service = PlantService(
        client: FakePlantClient((request) async {
          return streamedJsonResponse({}, 500);
        }),
      );

      expect(
        () => service.identifyPlant(
          username: 'jana',
          imagePath: tempImage.path,
        ),
        throwsA(
          predicate(
            (e) =>
                e is PlantIdentificationException &&
                e.statusCode == 500 &&
                e.message == 'Error intern del servidor.',
          ),
        ),
      );
    });

    test('identifyPlant llença PlantIdentificationException amb error genèric si statusCode no està contemplat', () async {
      final service = PlantService(
        client: FakePlantClient((request) async {
          return streamedTextResponse('Forbidden', 403);
        }),
      );

      expect(
        () => service.identifyPlant(
          username: 'jana',
          imagePath: tempImage.path,
        ),
        throwsA(
          predicate(
            (e) =>
                e is PlantIdentificationException &&
                e.statusCode == 403 &&
                e.message == 'Error 403: Forbidden',
          ),
        ),
      );
    });

    test('identifyPlant gestiona error body no JSON correctament', () async {
      final service = PlantService(
        client: FakePlantClient((request) async {
          return streamedTextResponse('Bad request no json', 400);
        }),
      );

      expect(
        () => service.identifyPlant(
          username: 'jana',
          imagePath: tempImage.path,
        ),
        throwsA(
          predicate(
            (e) =>
                e is PlantIdentificationException &&
                e.statusCode == 400 &&
                e.message == 'La petició no és correcta.',
          ),
        ),
      );
    });

    test('identifyPlant gestiona SocketException', () async {
      final service = PlantService(
        client: FakePlantClient((request) async {
          throw const SocketException('Sense connexió');
        }),
      );

      expect(
        () => service.identifyPlant(
          username: 'jana',
          imagePath: tempImage.path,
        ),
        throwsA(
          predicate(
            (e) =>
                e is PlantIdentificationException &&
                e.message == 'No hi ha connexió amb el servidor.',
          ),
        ),
      );
    });

    test('identifyPlant gestiona HttpException', () async {
      final service = PlantService(
        client: FakePlantClient((request) async {
          throw const HttpException('Error HTTP');
        }),
      );

      expect(
        () => service.identifyPlant(
          username: 'jana',
          imagePath: tempImage.path,
        ),
        throwsA(
          predicate(
            (e) =>
                e is PlantIdentificationException &&
                e.message == 'Error de comunicació amb el servidor.',
          ),
        ),
      );
    });

    test('identifyPlant llença error inesperat si la imatge no existeix', () async {
      final service = PlantService(
        client: FakePlantClient((request) async {
          return streamedJsonResponse({}, 201);
        }),
      );

      expect(
        () => service.identifyPlant(
          username: 'jana',
          imagePath: 'imatge_inexistent.jpg',
        ),
        throwsA(
          predicate(
            (e) =>
                e is PlantIdentificationException &&
                e.message ==
                    'S’ha produït un error inesperat durant la identificació.',
          ),
        ),
      );
    });
  });

  group('PlantIdentificationException', () {
    test('toString retorna el missatge', () {
      const exception = PlantIdentificationException(
        'Error de prova',
        statusCode: 400,
      );

      expect(exception.toString(), 'Error de prova');
      expect(exception.message, 'Error de prova');
      expect(exception.statusCode, 400);
    });

    test('accepta statusCode null', () {
      const exception = PlantIdentificationException('Error sense codi');

      expect(exception.toString(), 'Error sense codi');
      expect(exception.message, 'Error sense codi');
      expect(exception.statusCode, isNull);
    });
  });
}
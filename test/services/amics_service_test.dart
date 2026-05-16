import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:meteo_garden/services/amics_service.dart';

void main() {
  group('AmicsService', () {
    const token = 'token123';

    test('searchUsers retorna una llista dusuaris', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, contains('/api/search/'));
          expect(request.url.queryParameters['q'], 'jan');
          expect(request.headers['Authorization'], 'Token token123');
          expect(request.headers['Content-Type'], 'application/json');

          return http.Response(
            jsonEncode([
              {
                'username': 'jana',
                'avatar': 'avatar1.png',
              },
              {
                'username': 'janet',
                'avatar': 'avatar2.png',
              },
            ]),
            200,
          );
        }),
      );

      final result = await service.searchUsers(
        query: 'jan',
        token: token,
      );

      expect(result.length, 2);
      expect(result[0]['username'], 'jana');
      expect(result[0]['avatar'], 'avatar1.png');
      expect(result[1]['username'], 'janet');
      expect(result[1]['avatar'], 'avatar2.png');
    });

    test('searchUsers llença excepció si la resposta no és 200', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({'error': 'No autoritzat'}),
            401,
          );
        }),
      );

      expect(
        () => service.searchUsers(query: 'jana', token: token),
        throwsException,
      );
    });

    test('fetchFriends retorna friends quan la resposta és un map amb friends', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, contains('/api/friends/'));

          return http.Response(
            jsonEncode({
              'friends': [
                {
                  'username': 'laia',
                  'garden_name': 'Jardí Laia',
                },
                {
                  'username': 'oriol',
                  'garden': 'Jardí Oriol',
                },
              ],
            }),
            200,
          );
        }),
      );

      final result = await service.fetchFriends(token: token);

      expect(result.length, 2);

      expect(result[0]['username'], 'laia');
      expect(result[0]['garden_name'], 'Jardí Laia');

      expect(result[1]['username'], 'oriol');
      expect(result[1]['garden_name'], 'Jardí Oriol');
    });

    test('fetchFriends retorna friends quan la resposta és una llista', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode([
              {
                'username': 'albert',
              },
            ]),
            200,
          );
        }),
      );

      final result = await service.fetchFriends(token: token);

      expect(result.length, 1);
      expect(result[0]['username'], 'albert');
      expect(result[0]['garden_name'], 'albert');
    });

    test('fetchFriends retorna llista buida si la resposta no és map ni llista', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode('resposta incorrecta'),
            200,
          );
        }),
      );

      final result = await service.fetchFriends(token: token);

      expect(result, isEmpty);
    });

    test('fetchFriends llença excepció si la resposta no és 200', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({'error': 'Error carregant amics'}),
            500,
          );
        }),
      );

      expect(
        () => service.fetchFriends(token: token),
        throwsException,
      );
    });

    test('sendFriendRequest retorna missatge si statusCode és 200', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, contains('/api/friends/send_request/'));

          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['requested'], 'laia');

          return http.Response(
            jsonEncode({'message': 'Sol·licitud enviada'}),
            200,
          );
        }),
      );

      final result = await service.sendFriendRequest(
        requestedUsername: 'laia',
        token: token,
      );

      expect(result, 'Sol·licitud enviada');
    });

    test('sendFriendRequest retorna string buit si statusCode és 200 però body no és map', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode(['ok']),
            200,
          );
        }),
      );

      final result = await service.sendFriendRequest(
        requestedUsername: 'laia',
        token: token,
      );

      expect(result, '');
    });

    test('sendFriendRequest llença error del camp error', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({'error': 'Ja sou amics'}),
            400,
          );
        }),
      );

      expect(
        () => service.sendFriendRequest(
          requestedUsername: 'laia',
          token: token,
        ),
        throwsA(
          predicate(
            (e) => e is Exception && e.toString().contains('Ja sou amics'),
          ),
        ),
      );
    });

    test('sendFriendRequest llença error del camp detail', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({'detail': 'Token invàlid'}),
            401,
          );
        }),
      );

      expect(
        () => service.sendFriendRequest(
          requestedUsername: 'laia',
          token: token,
        ),
        throwsA(
          predicate(
            (e) => e is Exception && e.toString().contains('Token invàlid'),
          ),
        ),
      );
    });

    test('sendFriendRequest llença error si el body és una llista', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode(['Error de validació']),
            400,
          );
        }),
      );

      expect(
        () => service.sendFriendRequest(
          requestedUsername: 'laia',
          token: token,
        ),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains('Error de validació'),
          ),
        ),
      );
    });

    test('sendFriendRequest llença error si el body és string', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode('Error textual'),
            400,
          );
        }),
      );

      expect(
        () => service.sendFriendRequest(
          requestedUsername: 'laia',
          token: token,
        ),
        throwsA(
          predicate(
            (e) => e is Exception && e.toString().contains('Error textual'),
          ),
        ),
      );
    });

    test('sendFriendRequest neteja prefix Error del missatge', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({'error': 'Error: Usuari no trobat'}),
            404,
          );
        }),
      );

      expect(
        () => service.sendFriendRequest(
          requestedUsername: 'desconegut',
          token: token,
        ),
        throwsA(
          predicate(
            (e) =>
                e is Exception && e.toString().contains('Usuari no trobat'),
          ),
        ),
      );
    });

    test('answerFriendRequest retorna missatge si statusCode és 200', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, contains('/api/friends/answer_request/'));

          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['requester'], 'laia');
          expect(body['action'], 'accept');

          return http.Response(
            jsonEncode({'message': 'Sol·licitud acceptada'}),
            200,
          );
        }),
      );

      final result = await service.answerFriendRequest(
        requesterUsername: 'laia',
        action: 'accept',
        token: token,
      );

      expect(result, 'Sol·licitud acceptada');
    });

    test('answerFriendRequest retorna missatge per defecte si el body no és map', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode(['ok']),
            200,
          );
        }),
      );

      final result = await service.answerFriendRequest(
        requesterUsername: 'laia',
        action: 'reject',
        token: token,
      );

      expect(result, 'Sol·licitud resposta correctament');
    });

    test('answerFriendRequest retorna missatge per defecte si map no té message', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({'ok': true}),
            200,
          );
        }),
      );

      final result = await service.answerFriendRequest(
        requesterUsername: 'laia',
        action: 'accept',
        token: token,
      );

      expect(result, 'Sol·licitud resposta correctament');
    });

    test('answerFriendRequest llença excepció si statusCode no és 200', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({'error': 'Sol·licitud no trobada'}),
            404,
          );
        }),
      );

      expect(
        () => service.answerFriendRequest(
          requesterUsername: 'laia',
          action: 'accept',
          token: token,
        ),
        throwsException,
      );
    });

    test('answerFriendRequest llença excepció genèrica si error body no és map', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode(['error']),
            500,
          );
        }),
      );

      expect(
        () => service.answerFriendRequest(
          requesterUsername: 'laia',
          action: 'accept',
          token: token,
        ),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains('Error 500'),
          ),
        ),
      );
    });

    test('cancelFriendRequest retorna missatge si statusCode és 200', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, contains('/api/friends/cancel_request/'));

          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['requested'], 'laia');

          return http.Response(
            jsonEncode({'message': 'Sol·licitud cancel·lada'}),
            200,
          );
        }),
      );

      final result = await service.cancelFriendRequest(
        requestedUsername: 'laia',
        token: token,
      );

      expect(result, 'Sol·licitud cancel·lada');
    });

    test('cancelFriendRequest retorna missatge per defecte si el body no és map', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode(['ok']),
            200,
          );
        }),
      );

      final result = await service.cancelFriendRequest(
        requestedUsername: 'laia',
        token: token,
      );

      expect(result, 'Sol·licitud cancel·lada correctament');
    });

    test('cancelFriendRequest retorna missatge per defecte si map no té message', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({'ok': true}),
            200,
          );
        }),
      );

      final result = await service.cancelFriendRequest(
        requestedUsername: 'laia',
        token: token,
      );

      expect(result, 'Sol·licitud cancel·lada correctament');
    });

    test('cancelFriendRequest llença excepció si statusCode no és 200', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({'detail': 'No existeix la sol·licitud'}),
            400,
          );
        }),
      );

      expect(
        () => service.cancelFriendRequest(
          requestedUsername: 'laia',
          token: token,
        ),
        throwsException,
      );
    });

    test('cancelFriendRequest llença excepció genèrica si error body no és map', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode(['error']),
            500,
          );
        }),
      );

      expect(
        () => service.cancelFriendRequest(
          requestedUsername: 'laia',
          token: token,
        ),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains('Error 500'),
          ),
        ),
      );
    });

    test('fetchFriendRequests retorna sol·licituds enviades', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, contains('/api/friends/requests/'));

          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['action'], 'sent');

          return http.Response(
            jsonEncode({
              'requests_sent_to': ['laia', 'oriol'],
            }),
            200,
          );
        }),
      );

      final result = await service.fetchFriendRequests(
        action: 'sent',
        token: token,
      );

      expect(result, ['laia', 'oriol']);
    });

    test('fetchFriendRequests retorna sol·licituds rebudes', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, contains('/api/friends/requests/'));

          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['action'], 'received');

          return http.Response(
            jsonEncode({
              'requests_received_from': ['albert'],
            }),
            200,
          );
        }),
      );

      final result = await service.fetchFriendRequests(
        action: 'received',
        token: token,
      );

      expect(result, ['albert']);
    });

    test('fetchFriendRequests accepta claus antigues amb espai per sent', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'requests_sent to': ['jana'],
            }),
            200,
          );
        }),
      );

      final result = await service.fetchFriendRequests(
        action: 'sent',
        token: token,
      );

      expect(result, ['jana']);
    });

    test('fetchFriendRequests accepta claus antigues amb espai per received', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'requests_received from': ['martina'],
            }),
            200,
          );
        }),
      );

      final result = await service.fetchFriendRequests(
        action: 'received',
        token: token,
      );

      expect(result, ['martina']);
    });

    test('fetchFriendRequests retorna llista buida si no troba cap clau', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({}),
            200,
          );
        }),
      );

      final result = await service.fetchFriendRequests(
        action: 'sent',
        token: token,
      );

      expect(result, isEmpty);
    });

    test('fetchFriendRequests llença excepció si statusCode no és 200', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'error': 'Error obtenint sol·licituds',
            }),
            500,
          );
        }),
      );

      expect(
        () => service.fetchFriendRequests(
          action: 'sent',
          token: token,
        ),
        throwsException,
      );
    });

    test('deleteFriend retorna success si statusCode és 200', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          expect(request.method, 'DELETE');
          expect(request.url.path, contains('/api/friends/laia'));

          return http.Response(
            jsonEncode({'success': 'Amic eliminat'}),
            200,
          );
        }),
      );

      final result = await service.deleteFriend(
        username: 'laia',
        token: token,
      );

      expect(result, 'Amic eliminat');
    });

    test('deleteFriend llença excepció si statusCode no és 200', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({'error': 'No sou amics'}),
            404,
          );
        }),
      );

      expect(
        () => service.deleteFriend(username: 'laia', token: token),
        throwsException,
      );
    });

    test('likeGarden retorna true si state és true', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, contains('/api/friends/likes/laia/'));

          return http.Response(
            jsonEncode({'state': true}),
            200,
          );
        }),
      );

      final result = await service.likeGarden(
        username: 'laia',
        token: token,
      );

      expect(result, isTrue);
    });

    test('likeGarden retorna false si state és false', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({'state': false}),
            200,
          );
        }),
      );

      final result = await service.likeGarden(
        username: 'laia',
        token: token,
      );

      expect(result, isFalse);
    });

    test('likeGarden retorna false si state no és true', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({'state': 'true'}),
            200,
          );
        }),
      );

      final result = await service.likeGarden(
        username: 'laia',
        token: token,
      );

      expect(result, isFalse);
    });

    test('likeGarden llença excepció si statusCode no és 200', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({'error': 'No es pot fer like'}),
            400,
          );
        }),
      );

      expect(
        () => service.likeGarden(username: 'laia', token: token),
        throwsException,
      );
    });

    test('getGardenLikeState retorna true si state és true', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, contains('/api/friends/likes/laia/'));

          return http.Response(
            jsonEncode({'state': true}),
            200,
          );
        }),
      );

      final result = await service.getGardenLikeState(
        username: 'laia',
        token: token,
      );

      expect(result, isTrue);
    });

    test('getGardenLikeState retorna false si state és false', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({'state': false}),
            200,
          );
        }),
      );

      final result = await service.getGardenLikeState(
        username: 'laia',
        token: token,
      );

      expect(result, isFalse);
    });

    test('getGardenLikeState retorna false si state no és true', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({'state': 'true'}),
            200,
          );
        }),
      );

      final result = await service.getGardenLikeState(
        username: 'laia',
        token: token,
      );

      expect(result, isFalse);
    });

    test('getGardenLikeState llença excepció si statusCode no és 200', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({'error': 'Error obtenint like'}),
            500,
          );
        }),
      );

      expect(
        () => service.getGardenLikeState(username: 'laia', token: token),
        throwsException,
      );
    });

    test('fetchAvatar retorna map si statusCode és 200', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, contains('/api/users/laia/avatar'));

          return http.Response(
            jsonEncode({
              'body': 'body1',
              'eye': 'eye1',
              'expression': 'happy',
              'hair': 'hair1',
              'facialHair': null,
              'clothing': 'shirt1',
              'accessories': 'glasses1',
            }),
            200,
          );
        }),
      );

      final result = await service.fetchAvatar(
        username: 'laia',
        token: token,
      );

      expect(result, isNotNull);
      expect(result!['body'], 'body1');
      expect(result['eye'], 'eye1');
      expect(result['expression'], 'happy');
      expect(result['hair'], 'hair1');
      expect(result['facialHair'], isNull);
      expect(result['clothing'], 'shirt1');
      expect(result['accessories'], 'glasses1');
    });

    test('fetchAvatar retorna null si statusCode no és 200', () async {
      final service = AmicsService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({'error': 'Avatar no trobat'}),
            404,
          );
        }),
      );

      final result = await service.fetchAvatar(
        username: 'laia',
        token: token,
      );

      expect(result, isNull);
    });
  });
}
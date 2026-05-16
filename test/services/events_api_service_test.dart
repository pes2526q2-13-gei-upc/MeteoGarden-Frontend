import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:meteo_garden/services/events_api_service.dart';

void main() {
  group('EventCount', () {
    test('fromJson converteix correctament el JSON', () {
      final count = EventCount.fromJson({'day': '2026-05-16', 'total': 4});

      expect(count.day, DateTime.parse('2026-05-16'));
      expect(count.total, 4);
    });
  });

  group('EventCategory', () {
    test('fromJson converteix correctament JSON amb id int', () {
      final category = EventCategory.fromJson({
        'id': 1,
        'name': 'music',
        'display_name': 'Música',
      });

      expect(category.id, 1);
      expect(category.name, 'music');
      expect(category.displayName, 'Música');
    });

    test('fromJson converteix id string a int', () {
      final category = EventCategory.fromJson({
        'id': '2',
        'name': 'theatre',
        'display_name': 'Teatre',
      });

      expect(category.id, 2);
      expect(category.name, 'theatre');
      expect(category.displayName, 'Teatre');
    });

    test('fromJson posa valors per defecte si falten camps', () {
      final category = EventCategory.fromJson({});

      expect(category.id, 0);
      expect(category.name, '');
      expect(category.displayName, '');
    });

    test('fromJson usa name com displayName si no hi ha display_name', () {
      final category = EventCategory.fromJson({'id': 3, 'name': 'sports'});

      expect(category.id, 3);
      expect(category.name, 'sports');
      expect(category.displayName, 'sports');
    });
  });

  group('EventSummary', () {
    test('fromJson converteix correctament un resum d event', () {
      final event = EventSummary.fromJson({
        'id': 12,
        'title': 'Concert',
        'subtitle': 'Concert a la plaça',
        'city': 'Barcelona',
        'end_date': '2026-05-16T20:00:00',
        'price': '0',
        'image': {'url': 'https://example.com/concert.png'},
      });

      expect(event.id, '12');
      expect(event.title, 'Concert');
      expect(event.subtitle, 'Concert a la plaça');
      expect(event.city, 'Barcelona');
      expect(event.endDate, DateTime.parse('2026-05-16T20:00:00'));
      expect(event.price, 0.0);
      expect(event.image, 'https://example.com/concert.png');
      expect(event.isFree, isTrue);
    });

    test('isFree retorna false si el preu no és 0', () {
      final event = EventSummary.fromJson({
        'id': '1',
        'title': 'Festival',
        'subtitle': 'Festival local',
        'city': 'Vic',
        'end_date': '2026-05-16T20:00:00',
        'price': 12.5,
        'image': 'festival.png',
      });

      expect(event.price, 12.5);
      expect(event.isFree, isFalse);
    });
  });

  group('EventDetail helpers', () {
    test('asString gestiona null, string, map i altres valors', () {
      expect(EventDetail.asString(null), '');
      expect(EventDetail.asString('text'), 'text');
      expect(EventDetail.asString({'name': 'Nom'}), 'Nom');
      expect(EventDetail.asString({'url': 'url.png'}), 'url.png');
      expect(EventDetail.asString({'image': 'image.png'}), 'image.png');
      expect(EventDetail.asString({'title': 'Títol'}), 'Títol');
      expect(EventDetail.asString({'unknown': 'x'}), '');
      expect(EventDetail.asString(123), '123');
    });

    test('asCategory gestiona diferents formats', () {
      expect(EventDetail.asCategory(null), '');
      expect(EventDetail.asCategory('music'), 'music');
      expect(EventDetail.asCategory({'name': 'theatre'}), 'theatre');
      expect(EventDetail.asCategory({'id': 1}), '');
      expect(EventDetail.asCategory(5), '5');
    });

    test('asImage gestiona string, map i null', () {
      expect(EventDetail.asImage(null), '');
      expect(EventDetail.asImage('image.png'), 'image.png');
      expect(EventDetail.asImage({'url': 'url.png'}), 'url.png');
      expect(EventDetail.asImage({'image': 'image.png'}), 'image.png');
      expect(EventDetail.asImage({'src': 'src.png'}), 'src.png');
      expect(EventDetail.asImage({'unknown': 'x'}), '');
      expect(EventDetail.asImage(123), '123');
    });

    test('asDouble converteix num, string, null i valor invàlid', () {
      expect(EventDetail.asDouble(null), 0.0);
      expect(EventDetail.asDouble(4), 4.0);
      expect(EventDetail.asDouble(4.5), 4.5);
      expect(EventDetail.asDouble('7.25'), 7.25);
      expect(EventDetail.asDouble('abc'), 0.0);
    });

    test('asDateTime converteix string i altres valors', () {
      expect(
        EventDetail.asDateTime('2026-05-16T10:00:00'),
        DateTime.parse('2026-05-16T10:00:00'),
      );

      expect(
        EventDetail.asDateTime(DateTime.parse('2026-05-16').toIso8601String()),
        DateTime.parse('2026-05-16T00:00:00.000'),
      );
    });

    test('asDateTime amb null retorna una data actual aproximada', () {
      final before = DateTime.now();
      final result = EventDetail.asDateTime(null);
      final after = DateTime.now();

      expect(
        result.isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(result.isBefore(after.add(const Duration(seconds: 1))), isTrue);
    });

    test('asStringList gestiona null, list, string i altres valors', () {
      expect(EventDetail.asStringList(null), isEmpty);
      expect(EventDetail.asStringList(['a', 'b']), ['a', 'b']);
      expect(
        EventDetail.asStringList([
          'a',
          null,
          {'name': 'b'},
        ]),
        ['a', 'b'],
      );
      expect(EventDetail.asStringList('tag'), ['tag']);
      expect(EventDetail.asStringList(''), isEmpty);
      expect(EventDetail.asStringList(123), isEmpty);
    });
  });

  group('EventDetail', () {
    test('fromJson converteix correctament un detall complet', () {
      final detail = EventDetail.fromJson({
        'id': 10,
        'title': 'Obra de teatre',
        'subtitle': 'Sessió de tarda',
        'description': 'Descripció de l event',
        'start_date': '2026-05-16T18:00:00',
        'end_date': '2026-05-16T20:00:00',
        'category': {'name': 'theatre'},
        'price': '0',
        'tags': [
          'cultura',
          {'name': 'familiar'},
        ],
        'image': {'src': 'https://example.com/teatre.png'},
        'city': 'Vic',
        'street': 'Carrer Major',
      });

      expect(detail.id, '10');
      expect(detail.title, 'Obra de teatre');
      expect(detail.subtitle, 'Sessió de tarda');
      expect(detail.description, 'Descripció de l event');
      expect(detail.startDate, DateTime.parse('2026-05-16T18:00:00'));
      expect(detail.endDate, DateTime.parse('2026-05-16T20:00:00'));
      expect(detail.category, 'theatre');
      expect(detail.price, 0.0);
      expect(detail.tags, ['cultura', 'familiar']);
      expect(detail.image, 'https://example.com/teatre.png');
      expect(detail.city, 'Vic');
      expect(detail.street, 'Carrer Major');
      expect(detail.isFree, isTrue);
    });

    test('isFree retorna false si el detall té preu', () {
      final detail = EventDetail.fromJson({
        'id': '1',
        'title': 'Festival',
        'subtitle': '',
        'description': '',
        'start_date': '2026-05-16T18:00:00',
        'end_date': '2026-05-16T20:00:00',
        'category': 'music',
        'price': 10,
        'tags': [],
        'image': '',
        'city': 'Barcelona',
        'street': '',
      });

      expect(detail.price, 10.0);
      expect(detail.isFree, isFalse);
    });
  });

  group('EventsService fetchCategories', () {
    const token = 'token123';

    test(
      'fetchCategories retorna categories quan el body és una llista',
      () async {
        final service = EventsService(
          client: MockClient((request) async {
            expect(request.method, 'GET');
            expect(request.url.path, contains('/api/events/categories'));
            expect(request.headers['Authorization'], 'Token token123');

            return http.Response.bytes(
              utf8.encode(
                jsonEncode([
                  {'id': 1, 'name': 'music', 'display_name': 'Música'},
                  {'id': 2, 'name': 'theatre', 'display_name': 'Teatre'},
                ]),
              ),
              200,
            );
          }),
        );

        final categories = await service.fetchCategories(token: token);

        expect(categories.length, 2);
        expect(categories[0].id, 1);
        expect(categories[0].name, 'music');
        expect(categories[0].displayName, 'Música');
        expect(categories[1].id, 2);
        expect(categories[1].name, 'theatre');
        expect(categories[1].displayName, 'Teatre');
      },
    );

    test(
      'fetchCategories retorna categories quan el body és un map amb categories',
      () async {
        final service = EventsService(
          client: MockClient((request) async {
            return http.Response.bytes(
              utf8.encode(
                jsonEncode({
                  'categories': [
                    {'id': '3', 'name': 'sports', 'display_name': 'Esports'},
                  ],
                }),
              ),
              200,
            );
          }),
        );

        final categories = await service.fetchCategories(token: token);

        expect(categories.length, 1);
        expect(categories.first.id, 3);
        expect(categories.first.name, 'sports');
        expect(categories.first.displayName, 'Esports');
      },
    );

    test('fetchCategories filtra categories sense name', () async {
      final service = EventsService(
        client: MockClient((request) async {
          return http.Response.bytes(
            utf8.encode(
              jsonEncode([
                {'id': 1, 'name': '', 'display_name': 'Buida'},
                {'id': 2, 'name': 'music', 'display_name': 'Música'},
              ]),
            ),
            200,
          );
        }),
      );

      final categories = await service.fetchCategories(token: token);

      expect(categories.length, 1);
      expect(categories.first.name, 'music');
    });

    test(
      'fetchCategories retorna llista buida si el body no és list ni map',
      () async {
        final service = EventsService(
          client: MockClient((request) async {
            return http.Response.bytes(utf8.encode(jsonEncode('invalid')), 200);
          }),
        );

        final categories = await service.fetchCategories(token: token);

        expect(categories, isEmpty);
      },
    );

    test('fetchCategories llença excepció si statusCode no és 200', () async {
      final service = EventsService(
        client: MockClient((request) async {
          return http.Response.bytes(
            utf8.encode(jsonEncode({'error': 'Unauthorized'})),
            401,
          );
        }),
      );

      expect(
        () => service.fetchCategories(token: token),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains('Error carregant categories: 401'),
          ),
        ),
      );
    });
  });

  group('EventsService fetchEventCountByDay', () {
    test('fetchEventCountByDay retorna mapa dia-total', () async {
      final service = EventsService(
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, contains('/api/events/count'));
          expect(request.url.queryParameters['year'], '2026');
          expect(request.url.queryParameters['month'], '05');
          expect(request.url.queryParameters.containsKey('city'), isFalse);
          expect(request.url.queryParameters.containsKey('category'), isFalse);

          return http.Response.bytes(
            utf8.encode(
              jsonEncode({
                'events': [
                  {'day': '2026-05-01', 'total': 2},
                  {'day': '2026-05-16', 'total': 5},
                ],
              }),
            ),
            200,
          );
        }),
      );

      final result = await service.fetchEventCountByDay(year: 2026, month: 5);

      expect(result, {1: 2, 16: 5});
    });

    test(
      'fetchEventCountByDay afegeix city i category si no són buits',
      () async {
        final service = EventsService(
          client: MockClient((request) async {
            expect(request.url.queryParameters['city'], 'Barcelona');
            expect(request.url.queryParameters['category'], 'music');

            return http.Response.bytes(
              utf8.encode(jsonEncode({'events': []})),
              200,
            );
          }),
        );

        final result = await service.fetchEventCountByDay(
          year: 2026,
          month: 5,
          city: ' Barcelona ',
          category: ' music ',
        );

        expect(result, isEmpty);
      },
    );

    test('fetchEventCountByDay ignora city i category si són buits', () async {
      final service = EventsService(
        client: MockClient((request) async {
          expect(request.url.queryParameters.containsKey('city'), isFalse);
          expect(request.url.queryParameters.containsKey('category'), isFalse);

          return http.Response.bytes(
            utf8.encode(jsonEncode({'events': []})),
            200,
          );
        }),
      );

      final result = await service.fetchEventCountByDay(
        year: 2026,
        month: 5,
        city: '   ',
        category: '',
      );

      expect(result, isEmpty);
    });

    test(
      'fetchEventCountByDay llença excepció si statusCode no és 200',
      () async {
        final service = EventsService(
          client: MockClient((request) async {
            return http.Response.bytes(
              utf8.encode(jsonEncode({'error': 'Server error'})),
              500,
            );
          }),
        );

        expect(
          () => service.fetchEventCountByDay(year: 2026, month: 5),
          throwsA(
            predicate(
              (e) =>
                  e is Exception &&
                  e.toString().contains('Error carregant recompte: 500'),
            ),
          ),
        );
      },
    );
  });

  group('EventsService fetchEvents', () {
    test('fetchEvents retorna llista EventSummary', () async {
      final service = EventsService(
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, contains('/api/events/'));
          expect(request.url.queryParameters['date'], '2026-05-16');
          expect(request.url.queryParameters['lang'], 'ca');

          return http.Response.bytes(
            utf8.encode(
              jsonEncode({
                'events': [
                  {
                    'id': 'evt1',
                    'title': 'Concert',
                    'subtitle': 'Concert local',
                    'city': 'Barcelona',
                    'end_date': '2026-05-16T21:00:00',
                    'price': 0,
                    'image': 'concert.png',
                  },
                  {
                    'id': 2,
                    'title': 'Fira',
                    'subtitle': 'Fira artesanal',
                    'city': 'Vic',
                    'end_date': '2026-05-16T18:00:00',
                    'price': '5.5',
                    'image': {'url': 'fira.png'},
                  },
                ],
              }),
            ),
            200,
          );
        }),
      );

      final events = await service.fetchEvents(
        date: DateTime(2026, 5, 16),
        lang: 'ca',
      );

      expect(events.length, 2);

      expect(events[0].id, 'evt1');
      expect(events[0].title, 'Concert');
      expect(events[0].isFree, isTrue);

      expect(events[1].id, '2');
      expect(events[1].title, 'Fira');
      expect(events[1].price, 5.5);
      expect(events[1].image, 'fira.png');
      expect(events[1].isFree, isFalse);
    });

    test('fetchEvents afegeix city i category si existeixen', () async {
      final service = EventsService(
        client: MockClient((request) async {
          expect(request.url.queryParameters['city'], 'Vic');
          expect(request.url.queryParameters['category'], 'theatre');

          return http.Response.bytes(
            utf8.encode(jsonEncode({'events': []})),
            200,
          );
        }),
      );

      final events = await service.fetchEvents(
        date: DateTime(2026, 5, 16),
        lang: 'es',
        city: ' Vic ',
        category: ' theatre ',
      );

      expect(events, isEmpty);
    });

    test('fetchEvents ignora city i category buits', () async {
      final service = EventsService(
        client: MockClient((request) async {
          expect(request.url.queryParameters.containsKey('city'), isFalse);
          expect(request.url.queryParameters.containsKey('category'), isFalse);

          return http.Response.bytes(
            utf8.encode(jsonEncode({'events': []})),
            200,
          );
        }),
      );

      final events = await service.fetchEvents(
        date: DateTime(2026, 5, 16),
        lang: 'en',
        city: '',
        category: '   ',
      );

      expect(events, isEmpty);
    });

    test('fetchEvents llença excepció si statusCode no és 200', () async {
      final service = EventsService(
        client: MockClient((request) async {
          return http.Response.bytes(
            utf8.encode(jsonEncode({'error': 'Error'})),
            404,
          );
        }),
      );

      expect(
        () => service.fetchEvents(date: DateTime(2026, 5, 16), lang: 'ca'),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains('Error carregant events: 404'),
          ),
        ),
      );
    });
  });

  group('EventsService fetchEventDetail', () {
    test('fetchEventDetail retorna EventDetail', () async {
      final service = EventsService(
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, contains('/api/events/detail'));
          expect(request.url.queryParameters['id'], 'evt1');
          expect(request.url.queryParameters['date'], '2026-05-16');
          expect(request.url.queryParameters['lang'], 'ca');

          return http.Response.bytes(
            utf8.encode(
              jsonEncode({
                'events': {
                  'id': 'evt1',
                  'title': 'Concert detallat',
                  'subtitle': 'Subtítol',
                  'description': 'Descripció',
                  'start_date': '2026-05-16T18:00:00',
                  'end_date': '2026-05-16T20:00:00',
                  'category': {'name': 'music'},
                  'price': 0,
                  'tags': ['music', 'outdoor'],
                  'image': {'url': 'concert.png'},
                  'city': 'Barcelona',
                  'street': 'Carrer Major',
                },
              }),
            ),
            200,
          );
        }),
      );

      final detail = await service.fetchEventDetail(
        id: 'evt1',
        date: DateTime(2026, 5, 16),
        lang: 'ca',
      );

      expect(detail.id, 'evt1');
      expect(detail.title, 'Concert detallat');
      expect(detail.subtitle, 'Subtítol');
      expect(detail.description, 'Descripció');
      expect(detail.category, 'music');
      expect(detail.price, 0.0);
      expect(detail.tags, ['music', 'outdoor']);
      expect(detail.image, 'concert.png');
      expect(detail.city, 'Barcelona');
      expect(detail.street, 'Carrer Major');
      expect(detail.isFree, isTrue);
    });

    test('fetchEventDetail llença excepció si statusCode no és 200', () async {
      final service = EventsService(
        client: MockClient((request) async {
          return http.Response.bytes(
            utf8.encode(jsonEncode({'error': 'Not found'})),
            404,
          );
        }),
      );

      expect(
        () => service.fetchEventDetail(
          id: 'evt1',
          date: DateTime(2026, 5, 16),
          lang: 'ca',
        ),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains('Error carregant detall: 404'),
          ),
        ),
      );
    });
  });
}

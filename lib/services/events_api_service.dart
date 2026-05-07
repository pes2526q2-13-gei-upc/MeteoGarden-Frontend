import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/url.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

class EventCount {
  final DateTime day;
  final int total;

  const EventCount({required this.day, required this.total});

  factory EventCount.fromJson(Map<String, dynamic> json) => EventCount(
    day: DateTime.parse(json['day'] as String),
    total: json['total'] as int,
  );
}

class EventSummary {
  final String id;
  final String title;
  final String subtitle;
  final String city;
  final DateTime endDate;
  final double price;
  final String image;

  const EventSummary({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.city,
    required this.endDate,
    required this.price,
    required this.image,
  });

  bool get isFree => price == 0;

  factory EventSummary.fromJson(Map<String, dynamic> json) => EventSummary(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    subtitle: json['subtitle'] as String? ?? '',
    city: json['city'] as String? ?? '',
    endDate: DateTime.parse(json['end_date'] as String),
    price: (json['price'] as num).toDouble(),
    image: json['image'] as String? ?? '',
  );
}

class EventDetail {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String category;
  final double price;
  final List<String> tags;
  final String image;
  final String city;
  final String street;

  const EventDetail({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.category,
    required this.price,
    required this.tags,
    required this.image,
    required this.city,
    required this.street,
  });

  bool get isFree => price == 0;

  factory EventDetail.fromJson(Map<String, dynamic> json) => EventDetail(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    subtitle: json['subtitle'] as String? ?? '',
    description: json['description'] as String? ?? '',
    startDate: DateTime.parse(json['start_date'] as String),
    endDate: DateTime.parse(json['end_date'] as String),
    category: json['category'] as String? ?? '',
    price: (json['price'] as num).toDouble(),
    tags:
        (json['tags'] as List<dynamic>?)?.map((t) => t.toString()).toList() ??
        [],
    image: json['image'] as String? ?? '',
    city: json['city'] as String? ?? '',
    street: json['street'] as String? ?? '',
  );
}

// ─── Service ──────────────────────────────────────────────────────────────────

class EventsService {
  /// GET /api/events/count?year=&month=
  /// Retorna el recompte d'events per dia del mes indicat.
  Future<Map<int, int>> fetchEventCountByDay({
    required int year,
    required int month,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/events/count').replace(
      queryParameters: {
        'year': '$year',
        'month': month.toString().padLeft(2, '0'),
      },
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Error carregant recompte: ${response.statusCode}');
    }

    final body =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final events = body['events'] as List<dynamic>;

    final Map<int, int> result = {};
    for (final item in events) {
      final count = EventCount.fromJson(item as Map<String, dynamic>);
      result[count.day.day] = count.total;
    }
    return result;
  }

  /// GET /api/events/city?city=&date=&lang=
  /// Retorna els events d'una ciutat concreta per a la data indicada.
  Future<List<EventSummary>> fetchEventsByCity({
  required String city,
  required DateTime date,
  required String lang,
}) async {
  final uri = Uri.parse('${ApiConfig.baseUrl}/api/events/city').replace(
    queryParameters: {
      'city': city.toLowerCase(),
      'date': _formatDate(date),
      'lang': lang,
    },
  );

  final response = await http.get(uri);
  if (response.statusCode != 200) {
    throw Exception(
      'Error carregant events de la ciutat: ${response.statusCode}',
    );
  }

  final body =
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  final events = body['events'] as List<dynamic>;
  return events
      .map((e) => EventSummary.fromJson(e as Map<String, dynamic>))
      .toList();
}

  /// GET /api/events/?date=&lang=
  /// Retorna tots els events per a la data indicada (totes les ciutats).
  Future<List<EventSummary>> fetchAllEvents({
    required DateTime date,
    required String lang,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/events/',
    ).replace(queryParameters: {'date': _formatDate(date), 'lang': lang});

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Error carregant events: ${response.statusCode}');
    }

    final body =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final events = body['events'] as List<dynamic>;
    return events
        .map((e) => EventSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/events/detail?id=&date=&lang=
  /// Retorna el detall complet d'un event.
  Future<EventDetail> fetchEventDetail({
    required String id,
    required DateTime date,
    required String lang,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/events/detail').replace(
      queryParameters: {'id': id, 'date': _formatDate(date), 'lang': lang},
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Error carregant detall: ${response.statusCode}');
    }

    final body =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return EventDetail.fromJson(body['events'] as Map<String, dynamic>);
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

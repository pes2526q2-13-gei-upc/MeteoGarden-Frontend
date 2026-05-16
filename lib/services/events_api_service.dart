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

class EventCategory {
  final int id;
  final String name;
  final String displayName;

  const EventCategory({
    required this.id,
    required this.name,
    required this.displayName,
  });

  factory EventCategory.fromJson(Map<String, dynamic> json) {
    final name = json['name']?.toString() ?? '';

    return EventCategory(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      name: name,
      displayName: json['display_name']?.toString() ?? name,
    );
  }
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
    id: EventDetail.asString(json['id']),
    title: EventDetail.asString(json['title']),
    subtitle: EventDetail.asString(json['subtitle']),
    city: EventDetail.asString(json['city']),
    endDate: EventDetail.asDateTime(json['end_date']),
    price: EventDetail.asDouble(json['price']),
    image: EventDetail.asImage(json['image']),
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
    id: asString(json['id']),
    title: asString(json['title']),
    subtitle: asString(json['subtitle']),
    description: asString(json['description']),
    startDate: asDateTime(json['start_date']),
    endDate: asDateTime(json['end_date']),
    category: asCategory(json['category']),
    price: asDouble(json['price']),
    tags: asStringList(json['tags']),
    image: asImage(json['image']),
    city: asString(json['city']),
    street: asString(json['street']),
  );

  static String asString(dynamic value) {
    if (value == null) return '';

    if (value is String) return value;

    if (value is Map) {
      if (value['name'] != null) return value['name'].toString();
      if (value['url'] != null) return value['url'].toString();
      if (value['image'] != null) return value['image'].toString();
      if (value['title'] != null) return value['title'].toString();
      return '';
    }

    return value.toString();
  }

  static String asCategory(dynamic value) {
    if (value == null) return '';

    if (value is String) return value;

    if (value is Map) {
      return value['name']?.toString() ?? '';
    }

    return value.toString();
  }

  static String asImage(dynamic value) {
    if (value == null) return '';

    if (value is String) return value;

    if (value is Map) {
      return value['url']?.toString() ??
          value['image']?.toString() ??
          value['src']?.toString() ??
          '';
    }

    return value.toString();
  }

  static double asDouble(dynamic value) {
    if (value == null) return 0;

    if (value is num) return value.toDouble();

    return double.tryParse(value.toString()) ?? 0;
  }

  static DateTime asDateTime(dynamic value) {
    if (value == null) return DateTime.now();

    if (value is String) return DateTime.parse(value);

    return DateTime.parse(value.toString());
  }

  static List<String> asStringList(dynamic value) {
    if (value == null) return [];

    if (value is List) {
      return value.map(asString).where((e) => e.isNotEmpty).toList();
    }

    if (value is String) {
      return value.isEmpty ? [] : [value];
    }

    return [];
  }
}

// ─── Service ──────────────────────────────────────────────────────────────────

class EventsService {
  /// GET /api/events/categories
  /// Retorna les categories disponibles.
  Future<List<EventCategory>> fetchCategories({required String token}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/events/categories');

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Token $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Error carregant categories: ${response.statusCode}');
    }

    final body = jsonDecode(utf8.decode(response.bodyBytes));

    final List<dynamic> categories;
    if (body is List<dynamic>) {
      categories = body;
    } else if (body is Map<String, dynamic>) {
      categories = body['categories'] as List<dynamic>? ?? [];
    } else {
      categories = [];
    }

    return categories
        .map((c) => EventCategory.fromJson(c as Map<String, dynamic>))
        .where((c) => c.name.isNotEmpty)
        .toList();
  }

  /// GET /api/events/count?year=&month=&city=&category=
  /// Retorna el recompte d'events per dia del mes indicat, aplicant filtres.
  Future<Map<int, int>> fetchEventCountByDay({
    required int year,
    required int month,
    String? city,
    String? category,
  }) async {
    final queryParams = <String, String>{
      'year': '$year',
      'month': month.toString().padLeft(2, '0'),
    };

    _addOptionalParam(queryParams, 'city', city);
    _addOptionalParam(queryParams, 'category', category);

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/events/count',
    ).replace(queryParameters: queryParams);

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

  /// GET /api/events/?date=&lang=&city=&category=
  /// Retorna els events per a la data indicada, aplicant filtres.
  Future<List<EventSummary>> fetchEvents({
    required DateTime date,
    required String lang,
    String? city,
    String? category,
  }) async {
    final queryParams = <String, String>{
      'date': _formatDate(date),
      'lang': lang,
    };

    _addOptionalParam(queryParams, 'city', city);
    _addOptionalParam(queryParams, 'category', category);

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/events/',
    ).replace(queryParameters: queryParams);

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

  void _addOptionalParam(
    Map<String, String> params,
    String key,
    String? value,
  ) {
    final cleanValue = value?.trim();
    if (cleanValue != null && cleanValue.isNotEmpty) {
      params[key] = cleanValue;
    }
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

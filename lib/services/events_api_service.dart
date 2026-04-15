import 'dart:convert';
import 'package:http/http.dart' as http;

// ─── Model ────────────────────────────────────────────────────────────────────

class EventLocation {
  final String county;
  final String city;
  final int postalCode;
  final String street;
  final double latitude;
  final double longitude;

  const EventLocation({
    required this.county,
    required this.city,
    required this.postalCode,
    required this.street,
    required this.latitude,
    required this.longitude,
  });

  factory EventLocation.fromJson(Map<String, dynamic> json) => EventLocation(
    county: json['county'] as String? ?? '',
    city: json['city'] as String? ?? '',
    postalCode: (json['postal_code'] as num?)?.toInt() ?? 0,
    street: json['street'] as String? ?? '',
    latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
    longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
  );
}

class PlantEvent {
  final String id;
  final String sourceType;
  final String title;
  final String subtitle;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String category;
  final double price;
  final String ticketUrl;
  final String phone;
  final EventLocation location;
  final List<String> tags;
  final String imageUrl;
  final double? distanceKm;

  const PlantEvent({
    required this.id,
    required this.sourceType,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.category,
    required this.price,
    required this.ticketUrl,
    required this.phone,
    required this.location,
    required this.tags,
    required this.imageUrl,
    this.distanceKm,
  });

  factory PlantEvent.fromJson(Map<String, dynamic> json) => PlantEvent(
    id: json['id'] as String? ?? '',
    sourceType: json['source_type'] as String? ?? '',
    title: json['title'] as String? ?? '',
    subtitle: json['subtitle'] as String? ?? '',
    description: json['description'] as String? ?? '',
    startDate: DateTime.parse(json['start_date'] as String),
    endDate: DateTime.parse(json['end_date'] as String),
    category: json['category'] as String? ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
    ticketUrl: json['ticket_url'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    location: EventLocation.fromJson(
      json['location'] as Map<String, dynamic>? ?? {},
    ),
    tags:
        (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
        [],
    imageUrl: json['image_url'] as String? ?? '',
    distanceKm: (json['distance_km'] as num?)?.toDouble(),
  );

  bool get isFree => price == 0.0;
}

class EventsPage {
  final int count;
  final int page;
  final int pageSize;
  final int totalPages;
  final List<PlantEvent> results;

  const EventsPage({
    required this.count,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.results,
  });

  factory EventsPage.fromJson(Map<String, dynamic> json) => EventsPage(
    count: json['count'] as int? ?? 0,
    page: json['page'] as int? ?? 1,
    pageSize: json['page_size'] as int? ?? 20,
    totalPages: json['total_pages'] as int? ?? 1,
    results:
        (json['results'] as List<dynamic>?)
            ?.map((e) => PlantEvent.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
  );
}

// ─── Query Params ─────────────────────────────────────────────────────────────

class EventsQueryParams {
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? city;
  final String? county;
  final String? category;
  final String? q;
  final double? lat;
  final double? lng;
  final double? distanceKm;
  final double? minPrice;
  final double? maxPrice;
  final String? source; // 'all', 'party', 'dataset'
  final String? sortBy; // 'start_date', 'price', 'title', 'distance'
  final String? order; // 'asc', 'desc'
  final bool includePast;
  final int page;
  final int pageSize;

  const EventsQueryParams({
    this.dateFrom,
    this.dateTo,
    this.city,
    this.county,
    this.category,
    this.q,
    this.lat,
    this.lng,
    this.distanceKm,
    this.minPrice,
    this.maxPrice,
    this.source,
    this.sortBy,
    this.order,
    this.includePast = false,
    this.page = 1,
    this.pageSize = 100,
  });

  Map<String, String> toQueryMap() {
    final params = <String, String>{};

    if (dateFrom != null) {
      params['date_from'] = dateFrom!.toUtc().toIso8601String();
    }
    if (dateTo != null) {
      params['date_to'] = dateTo!.toUtc().toIso8601String();
    }
    if (city != null && city!.isNotEmpty) params['city'] = city!;
    if (county != null && county!.isNotEmpty) params['county'] = county!;
    if (category != null && category!.isNotEmpty) {
      params['category'] = category!;
    }
    if (q != null && q!.isNotEmpty) params['q'] = q!;
    if (lat != null) params['lat'] = lat!.toString();
    if (lng != null) params['lng'] = lng!.toString();
    if (distanceKm != null) params['distance_km'] = distanceKm!.toString();
    if (minPrice != null) params['min_price'] = minPrice!.toString();
    if (maxPrice != null) params['max_price'] = maxPrice!.toString();
    if (source != null) params['source'] = source!;
    if (sortBy != null) params['sort_by'] = sortBy!;
    if (order != null) params['order'] = order!;
    if (includePast) params['include_past'] = 'true';
    params['page'] = page.toString();
    params['page_size'] = pageSize.toString();

    return params;
  }
}

// ─── Service ──────────────────────────────────────────────────────────────────

class EventsApiService {
  static const String _baseUrl =
      'https://gresca.jaumelopez.dev/api/external/events';

  // Token d'autorització — substitueix pel teu valor real
  static const String _token = 'lBw8w2gZbXebuJ-FxhziSVNCHTli-h6jZj3FuPZ-erU';

  Map<String, String> get _headers => {
    'Authorization': 'Token $_token',
    'Content-Type': 'application/json',
  };

  /// Fetch a single page of events with the given query parameters.
  Future<EventsPage> fetchEvents(EventsQueryParams params) async {
    final uri = Uri.parse(
      _baseUrl,
    ).replace(queryParameters: params.toQueryMap());

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return EventsPage.fromJson(data);
    }

    throw Exception('Error carregant esdeveniments: ${response.statusCode}');
  }

  /// Fetch ALL events for a given month, handling pagination automatically.
  ///
  /// Exemple: fetchEventsForMonth(year: 2026, month: 4, city: 'barcelona')
  /// → crida l'API amb date_from=2026-04-01 i date_to=2026-04-30T23:59:59
  /// → si l'API retorna total_pages > 1, fa les crides successives fins tenir-los tots.
  Future<List<PlantEvent>> fetchEventsForMonth({
    required int year,
    required int month,
    String? city,
    String? county,
    double? lat,
    double? lng,
    double? distanceKm,
    bool includePast = true,
  }) async {
    final dateFrom = DateTime(year, month, 1);
    // Primer dia del mes següent - 1 segon = últim instant del mes actual.
    // Funciona correctament al desembre: DateTime(2026, 13, 1) → Dart ho resol
    // automàticament com DateTime(2027, 1, 1).
    final dateTo = DateTime(
      year,
      month + 1,
      1,
    ).subtract(const Duration(seconds: 1));

    final allEvents = <PlantEvent>[];
    int currentPage = 1;
    int totalPages = 1;

    do {
      final page = await fetchEvents(
        EventsQueryParams(
          dateFrom: dateFrom,
          dateTo: dateTo,
          city: city,
          county: county,
          lat: lat,
          lng: lng,
          distanceKm: distanceKm,
          includePast: includePast,
          sortBy: 'start_date',
          order: 'asc',
          page: currentPage,
          pageSize: 100, // màxim permès per l'API
        ),
      );

      allEvents.addAll(page.results);
      totalPages = page.totalPages;
      currentPage++;
    } while (currentPage <= totalPages);

    return allEvents;
  }

  /// Group events by day-of-month for easy calendar rendering.
  Map<int, List<PlantEvent>> groupEventsByDay(List<PlantEvent> events) {
    final grouped = <int, List<PlantEvent>>{};
    for (final event in events) {
      final day = event.startDate.day;
      grouped.putIfAbsent(day, () => []).add(event);
    }
    return grouped;
  }
}

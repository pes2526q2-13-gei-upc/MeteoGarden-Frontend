import 'events_api_service.dart';

class MockEventsService extends EventsService {
  @override
  Future<Map<int, int>> fetchEventCountByDay({
    required int year,
    required int month,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (year == 2026 && month == 5) {
      return {
        1: 3, // 👈 ara hi ha event a Terrassa + 2 altres
        2: 2,
        5: 1,
        7: 6,
        8: 6,
        9: 3,
      };
    }

    return {};
  }

  @override
  Future<List<EventSummary>> fetchAllEvents({
    required DateTime date,
    String lang = 'en',
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return _eventsByDate(date)
        .map(EventSummary.fromJson)
        .toList();
  }

  @override
  Future<List<EventSummary>> fetchEventsByCity({
    required String city,
    required DateTime date,
    String lang = 'en',
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return _eventsByDate(date)
        .where((e) => e["city"] == city.toLowerCase())
        .map(EventSummary.fromJson)
        .toList();
  }

  @override
  Future<EventDetail> fetchEventDetail({
    required String id,
    required DateTime date,
    String lang = 'en',
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final detail = _details[id];

    if (detail == null) {
      throw Exception("Event no trobat");
    }

    return EventDetail.fromJson(detail);
  }

  // ─────────────────────────────────────────────
  // MOCK DATA
  // ─────────────────────────────────────────────

  List<Map<String, dynamic>> _eventsByDate(DateTime date) {
    final d = date.day;
    final m = date.month;

    if (m == 5 && d == 1) {
      return [
        // 👇 EVENT TERRASSA (IMPORTANT)
        {
          "id": "terrassa-001",
          "title": "Spring Music Festival",
          "subtitle": "Live bands & food trucks",
          "city": "terrassa",
          "end_date": "2026-05-01T22:00:00Z",
          "price": 10,
          "image":
              "https://meteogarden-images.s3.eu-south-2.amazonaws.com/events/terrassa_festival.jpg",
        },
        {
          "id": "dataset-20260325029",
          "title": "The firmament",
          "subtitle": "De Lucy Kirkwood",
          "city": "barcelona",
          "end_date": "2026-06-13T22:00:00Z",
          "price": 0,
          "image":
              "https://meteogarden-images.s3.eu-south-2.amazonaws.com/events/20260506-el-firmament-1.jpg",
        },
        {
          "id": "dataset-20260420025",
          "title": "International New Roses Competition",
          "subtitle": "",
          "city": "barcelona",
          "end_date": "2026-05-09T22:00:00Z",
          "price": 0,
          "image":
              "https://meteogarden-images.s3.eu-south-2.amazonaws.com/events/roses2.jpg",
        },
      ];
    }

    if (m == 5 && d == 7) {
      return [
        {
          "id": "dataset-20260224012",
          "title": "BirdsLAND",
          "subtitle": "Cia. Nadine Gerspacher",
          "city": "tarragona",
          "end_date": "2026-05-07T22:00:00Z",
          "price": 0,
          "image":
              "https://meteogarden-images.s3.eu-south-2.amazonaws.com/events/BirdsLAND.jpg",
        },
        {
          "id": "dataset-20260420012",
          "title": "Girona a cappella festival",
          "subtitle": "",
          "city": "girona",
          "end_date": "2026-05-16T22:00:00Z",
          "price": 0,
          "image":
              "https://meteogarden-images.s3.eu-south-2.amazonaws.com/events/Girona-a-cappella-imatge-darxiu.jpg",
        },
      ];
    }

    return [];
  }

  static final Map<String, Map<String, dynamic>> _details = {
    "terrassa-001": {
      "id": "terrassa-001",
      "title": "Spring Music Festival",
      "subtitle": "Live bands & food trucks",
      "description":
          "A full day outdoor music festival in Terrassa with local bands, food trucks and drinks.",
      "start_date": "2026-05-01T10:00:00Z",
      "end_date": "2026-05-01T22:00:00Z",
      "category": "music",
      "price": 10,
      "tags": ["music", "festival"],
      "image":
          "https://meteogarden-images.s3.eu-south-2.amazonaws.com/events/terrassa_festival.jpg",
      "city": "terrassa",
      "street": "Parc Vallparadís",
    },
    "dataset-20260224012": {
      "id": "dataset-20260224012",
      "title": "BirdsLAND",
      "subtitle": "Cia. Nadine Gerspacher",
      "description": "Dance performance.",
      "start_date": "2026-05-07T22:00:00Z",
      "end_date": "2026-05-07T22:00:00Z",
      "category": "dance",
      "price": 0,
      "tags": [],
      "image":
          "https://meteogarden-images.s3.eu-south-2.amazonaws.com/events/BirdsLAND.jpg",
      "city": "tarragona",
      "street": "C. Reding, 14",
    },
  };
}
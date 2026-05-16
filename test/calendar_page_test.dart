import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_garden/generated/app_localizations.dart';
import 'package:meteo_garden/models/dades_usr.dart';
import 'package:meteo_garden/screens/calendar_page.dart';
import 'package:meteo_garden/services/events_api_service.dart';
import 'package:provider/provider.dart';

class FakeEventsService extends EventsService {
  String? lastCategoriesToken;

  int monthCountsCalls = 0;
  int eventsCalls = 0;
  int detailCalls = 0;

  int? lastCountYear;
  int? lastCountMonth;
  String? lastCountCity;
  String? lastCountCategory;

  DateTime? lastEventsDate;
  String? lastEventsLang;
  String? lastEventsCity;
  String? lastEventsCategory;

  String? lastDetailId;
  DateTime? lastDetailDate;
  String? lastDetailLang;

  bool throwOnCounts = false;
  bool throwOnEvents = false;
  bool throwOnDetail = false;

  @override
  Future<List<EventCategory>> fetchCategories({
    required String token,
  }) async {
    lastCategoriesToken = token;

    return [
      EventCategory(
        id: 1,
        name: 'Música',
        displayName: 'Music',
      ),
      EventCategory(
        id: 2,
        name: 'Teatre',
        displayName: 'Theatre',
      ),
      EventCategory(
        id: 3,
        name: 'Cinema',
        displayName: 'Cinema',
      ),
    ];
  }

  @override
  Future<Map<int, int>> fetchEventCountByDay({
    required int year,
    required int month,
    String? city,
    String? category,
  }) async {
    monthCountsCalls++;
    lastCountYear = year;
    lastCountMonth = month;
    lastCountCity = city;
    lastCountCategory = category;

    if (throwOnCounts) {
      throw Exception('Error carregant recompte');
    }

    return {
      10: 2,
      15: 1,
      20: 3,
    };
  }

  @override
  Future<List<EventSummary>> fetchEvents({
    required DateTime date,
    required String lang,
    String? city,
    String? category,
  }) async {
    eventsCalls++;
    lastEventsDate = date;
    lastEventsLang = lang;
    lastEventsCity = city;
    lastEventsCategory = category;

    if (throwOnEvents) {
      throw Exception('Error carregant events');
    }

    if (date.day == 15) {
      return [];
    }

    return [
      EventSummary(
        id: 'event-1',
        title: 'Concert de prova',
        subtitle: 'Subtítol de prova',
        city: 'Tarragona',
        endDate: DateTime(date.year, date.month, date.day, 20),
        price: 0,
        image: '',
      ),
      EventSummary(
        id: 'event-2',
        title: 'Obra de teatre',
        subtitle: '',
        city: 'Reus',
        endDate: DateTime(date.year, date.month, date.day, 22),
        price: 12,
        image: '',
      ),
    ];
  }

  @override
  Future<EventDetail> fetchEventDetail({
    required String id,
    required DateTime date,
    required String lang,
  }) async {
    detailCalls++;
    lastDetailId = id;
    lastDetailDate = date;
    lastDetailLang = lang;

    if (throwOnDetail) {
      throw Exception('Error carregant detall');
    }

    return EventDetail(
      id: id,
      title: id == 'event-1' ? 'Concert de prova' : 'Obra de teatre',
      subtitle: id == 'event-1' ? 'Subtítol de prova' : '',
      description: 'Descripció completa de l’event',
      startDate: date,
      endDate: DateTime(date.year, date.month, date.day, 20),
      category: 'Música',
      price: id == 'event-1' ? 0 : 12,
      tags: const ['cultura', 'nit'],
      image: '',
      city: 'Tarragona',
      street: 'Carrer Major',
    );
  }
}

Widget buildTestableCalendarPage({
  required FakeEventsService service,
  String language = 'english',
  Locale locale = const Locale('en'),
}) {
  final userModel = UserModel();

  userModel.token = 'fake-token';
  userModel.username = 'jana';
  userModel.language = language;

  return ChangeNotifierProvider<UserModel>.value(
    value: userModel,
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: CalendarPage(
        city: '',
        service: service,
      ),
    ),
  );
}

Future<void> pumpCalendar(
  WidgetTester tester,
  FakeEventsService service, {
  String language = 'english',
  Locale locale = const Locale('en'),
}) async {
  await tester.pumpWidget(
    buildTestableCalendarPage(
      service: service,
      language: language,
      locale: locale,
    ),
  );

  await tester.pumpAndSettle();
}

Future<void> openFilters(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.tune));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('carrega la pantalla principal i crida categories amb token',
      (WidgetTester tester) async {
    final service = FakeEventsService();

    await pumpCalendar(tester, service);

    expect(find.text('MeteoGarden'), findsOneWidget);
    expect(find.byIcon(Icons.tune), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);

    expect(service.lastCategoriesToken, 'fake-token');
    expect(service.monthCountsCalls, 1);
    expect(service.lastCountCity, isNull);
    expect(service.lastCountCategory, isNull);
  });

  testWidgets('mostra el text inicial sense filtres actius',
      (WidgetTester tester) async {
    final service = FakeEventsService();

    await pumpCalendar(tester, service);

    expect(find.text('All cities · All categories'), findsOneWidget);
  });

  testWidgets('obre el panell de filtres i mostra categories traduïdes',
      (WidgetTester tester) async {
    final service = FakeEventsService();

    await pumpCalendar(tester, service);
    await openFilters(tester);

    expect(find.text('Filters'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Music'), findsOneWidget);
    expect(find.text('Theatre'), findsOneWidget);
    expect(find.text('Cinema'), findsOneWidget);
  });

  testWidgets('aplica filtre de ciutat i categoria i envia els paràmetres al servei',
      (WidgetTester tester) async {
    final service = FakeEventsService();

    await pumpCalendar(tester, service);
    await openFilters(tester);

    await tester.enterText(find.byType(TextField), 'Tarragona');
    await tester.tap(find.text('Music'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();

    expect(find.text('Tarragona · Music'), findsOneWidget);

    expect(service.monthCountsCalls, 2);
    expect(service.lastCountCity, 'Tarragona');
    expect(service.lastCountCategory, 'Música');
  });

  testWidgets('neteja filtres i torna a enviar city/category com a null',
      (WidgetTester tester) async {
    final service = FakeEventsService();

    await pumpCalendar(tester, service);
    await openFilters(tester);

    await tester.enterText(find.byType(TextField), 'Tarragona');
    await tester.tap(find.text('Music'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();

    expect(service.lastCountCity, 'Tarragona');
    expect(service.lastCountCategory, 'Música');

    await openFilters(tester);

    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();

    expect(find.text('All cities · All categories'), findsOneWidget);
    expect(service.lastCountCity, isNull);
    expect(service.lastCountCategory, isNull);
  });

  testWidgets('clicar un dia amb events mostra les targetes dels events',
      (WidgetTester tester) async {
    final service = FakeEventsService();

    await pumpCalendar(tester, service);

    await tester.tap(find.text('10').first);
    await tester.pumpAndSettle();

    expect(service.eventsCalls, 1);
    expect(service.lastEventsDate?.day, 10);
    expect(service.lastEventsLang, 'en');

    expect(find.text('Concert de prova'), findsOneWidget);
    expect(find.text('Subtítol de prova'), findsOneWidget);
    expect(find.text('Obra de teatre'), findsOneWidget);
    expect(find.text('Tarragona'), findsWidgets);
    expect(find.text('Reus'), findsOneWidget);
  });

  testWidgets('clicar el mateix dia dues vegades amaga els events',
      (WidgetTester tester) async {
    final service = FakeEventsService();

    await pumpCalendar(tester, service);

    await tester.tap(find.text('10').first);
    await tester.pumpAndSettle();

    expect(find.text('Concert de prova'), findsOneWidget);

    await tester.tap(find.text('10').first);
    await tester.pumpAndSettle();

    expect(find.text('Concert de prova'), findsNothing);
    expect(find.text('Obra de teatre'), findsNothing);
  });

  testWidgets('dia sense events mostra missatge buit',
      (WidgetTester tester) async {
    final service = FakeEventsService();

    await pumpCalendar(tester, service);

    await tester.tap(find.text('15').first);
    await tester.pumpAndSettle();

    expect(service.eventsCalls, 1);
    expect(service.lastEventsDate?.day, 15);

    expect(find.byIcon(Icons.event_busy_outlined), findsOneWidget);
  });

  testWidgets('obre el detall de l’event',
      (WidgetTester tester) async {
    final service = FakeEventsService();

    await pumpCalendar(tester, service);

    await tester.tap(find.text('10').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Concert de prova'));
    await tester.pumpAndSettle();

    expect(service.detailCalls, 1);
    expect(service.lastDetailId, 'event-1');
    expect(service.lastDetailLang, 'en');

    expect(find.text('Descripció completa de l’event'), findsOneWidget);
    expect(find.textContaining('Carrer Major'), findsOneWidget);
    expect(find.text('#cultura'), findsOneWidget);
    expect(find.text('#nit'), findsOneWidget);
  });

  testWidgets('canvia de mes amb les fletxes i recarrega el recompte',
      (WidgetTester tester) async {
    final service = FakeEventsService();

    await pumpCalendar(tester, service);

    final initialMonth = service.lastCountMonth;
    final initialCalls = service.monthCountsCalls;

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    expect(service.monthCountsCalls, initialCalls + 1);
    expect(service.lastCountMonth, isNot(initialMonth));

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();

    expect(service.monthCountsCalls, initialCalls + 2);
  });

  testWidgets('si falla el recompte mensual mostra pantalla d’error',
      (WidgetTester tester) async {
    final service = FakeEventsService();
    service.throwOnCounts = true;

    await pumpCalendar(tester, service);

    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.textContaining('Error carregant recompte'), findsOneWidget);
  });

  testWidgets('si falla carregar events del dia mostra error',
      (WidgetTester tester) async {
    final service = FakeEventsService();

    await pumpCalendar(tester, service);

    service.throwOnEvents = true;

    await tester.tap(find.text('10').first);
    await tester.pumpAndSettle();

    expect(find.textContaining('Error carregant events'), findsOneWidget);
  });

  testWidgets('si falla carregar detall mostra error dins el diàleg',
      (WidgetTester tester) async {
    final service = FakeEventsService();

    await pumpCalendar(tester, service);

    service.throwOnDetail = true;

    await tester.tap(find.text('10').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Concert de prova'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Error carregant detall'), findsOneWidget);
  });

  testWidgets('amb idioma castellà envia lang es quan carrega events',
      (WidgetTester tester) async {
    final service = FakeEventsService();

    await pumpCalendar(
      tester,
      service,
      language: 'es',
      locale: const Locale('es'),
    );

    await tester.tap(find.text('10').first);
    await tester.pumpAndSettle();

    expect(service.lastEventsLang, 'es');
  });

  testWidgets('amb idioma català envia lang ca quan carrega events',
      (WidgetTester tester) async {
    final service = FakeEventsService();

    await pumpCalendar(
      tester,
      service,
      language: 'ca',
      locale: const Locale('ca'),
    );

    await tester.tap(find.text('10').first);
    await tester.pumpAndSettle();

    expect(service.lastEventsLang, 'ca');
  });
}
import 'package:flutter/material.dart';
import 'package:meteo_garden/l10n/app_localizations.dart';
import '../services/events_api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../models/dades_usr.dart';
import '../models/url.dart';

// ─── Filter State ─────────────────────────────────────────────────────────────

class EventFilters {
  final String city;
  final String county;
  final String category;
  final double? maxDistanceKm;
  final double? maxPrice;
  final String q;

  const EventFilters({
    this.city = '',
    this.county = '',
    this.category = '',
    this.maxDistanceKm,
    this.maxPrice,
    this.q = '',
  });

  EventFilters copyWith({
    String? city,
    String? county,
    String? category,
    double? maxDistanceKm,
    bool clearDistance = false,
    double? maxPrice,
    bool clearPrice = false,
    String? q,
  }) => EventFilters(
    city: city ?? this.city,
    county: county ?? this.county,
    category: category ?? this.category,
    maxDistanceKm: clearDistance ? null : (maxDistanceKm ?? this.maxDistanceKm),
    maxPrice: clearPrice ? null : (maxPrice ?? this.maxPrice),
    q: q ?? this.q,
  );

  int get activeCount {
    int count = 0;
    if (city.isNotEmpty) count++;
    if (county.isNotEmpty) count++;
    if (category.isNotEmpty) count++;
    if (maxDistanceKm != null) count++;
    if (maxPrice != null) count++;
    if (q.isNotEmpty) count++;
    return count;
  }

  bool get isEmpty => activeCount == 0;
}

// ─── Localized Event ──────────────────────────────────────────────────────────

class LocalizedPlantEvent {
  final PlantEvent original;
  final String title;
  final String subtitle;
  final String description; // aquí guardarem la descripció ORIGINAL
  final String category;
  final List<String> tags;

  const LocalizedPlantEvent({
    required this.original,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.category,
    required this.tags,
  });

  DateTime get startDate => original.startDate;
  DateTime get endDate => original.endDate;
  double get price => original.price;
  bool get isFree => original.isFree;
  String get imageUrl => original.imageUrl;
  String get phone => original.phone;
  String get ticketUrl => original.ticketUrl;
  dynamic get location => original.location;
}

// ─── Calendar Page ────────────────────────────────────────────────────────────

class CalendarPage extends StatefulWidget {
  final String city;

  const CalendarPage({super.key, required this.city});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final EventsApiService _api = EventsApiService();

  late DateTime _currentMonth;
  late EventFilters _filters;

  List<LocalizedPlantEvent> _events = [];
  Map<int, List<LocalizedPlantEvent>> _eventsByDay = {};
  final Map<String, String> _translationCache = {};

  bool _loading = true;
  String? _error;

  int? _selectedDay;
  List<LocalizedPlantEvent> _selectedDayEvents = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month, 1);
    _filters = EventFilters(city: widget.city);
    _loadEvents();
  }

  String _mapLanguage(String language) {
    switch (language) {
      case 'Català':
        return 'ca';
      case 'Castellano':
        return 'es';
      case 'English':
        return 'en';
      default:
        return 'en';
    }
  }

  Future<String> _translateText(String text, String lang) async {
    if (text.trim().isEmpty || text.trim().length < 2) return text;

    final cacheKey = '$lang|$text';
    if (_translationCache.containsKey(cacheKey)) {
      return _translationCache[cacheKey]!;
    }

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/translate/').replace(
        queryParameters: {
          'text': text,
          'lang': lang,
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes).replaceAll('"', '').trim();
        _translationCache[cacheKey] = decoded;
        return decoded;
      }
    } catch (e) {
      debugPrint('Error traduint');
    }

    _translationCache[cacheKey] = text;
    return text;
  }

  Future<LocalizedPlantEvent> _translateEvent(PlantEvent event, String lang) async {
    final translatedFields = await Future.wait([
      _translateText(event.title, lang),
      _translateText(event.subtitle, lang),
      _translateText(event.category, lang),
      ...event.tags.map((tag) => _translateText(tag, lang)),
    ]);

    return LocalizedPlantEvent(
      original: event,
      title: translatedFields[0],
      subtitle: translatedFields[1],
      description: event.description, // NO la traduïm aquí
      category: translatedFields[2],
      tags: translatedFields.sublist(3),
    );
  }

  Map<int, List<LocalizedPlantEvent>> _groupLocalizedEventsByDay(
    List<LocalizedPlantEvent> events,
  ) {
    final Map<int, List<LocalizedPlantEvent>> grouped = {};

    for (final event in events) {
      final day = event.startDate.day;
      grouped.putIfAbsent(day, () => []);
      grouped[day]!.add(event);
    }

    return grouped;
  }

  Future<void> _loadEvents() async {
    setState(() {
      _loading = true;
      _error = null;
      _selectedDay = null;
      _selectedDayEvents = [];
    });

    try {
      final events = await _api.fetchEventsForMonth(
        year: _currentMonth.year,
        month: _currentMonth.month,
        city: _filters.city.isNotEmpty ? _filters.city : null,
        county: _filters.county.isNotEmpty ? _filters.county : null,
        distanceKm: null,
      );

      final filtered = events.where((e) {
        if (_filters.category.isNotEmpty &&
            !e.category.toLowerCase().contains(_filters.category.toLowerCase())) {
          return false;
        }

        if (_filters.maxPrice != null && e.price > _filters.maxPrice!) {
          return false;
        }

        if (_filters.q.isNotEmpty) {
          final q = _filters.q.toLowerCase();
          if (!e.title.toLowerCase().contains(q) &&
              !e.description.toLowerCase().contains(q)) {
            return false;
          }
        }

        return true;
      }).toList();

      final user = Provider.of<UserModel>(context, listen: false);
      final langCode = _mapLanguage(user.language);

      final localizedEvents = await Future.wait(
        filtered.map((e) => _translateEvent(e, langCode)),
      );

      setState(() {
        _events = localizedEvents;
        _eventsByDay = _groupLocalizedEventsByDay(localizedEvents);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _goToPreviousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
    _loadEvents();
  }

  void _goToNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
    _loadEvents();
  }

  void _onDayTapped(int day) {
    final dayEvents = _eventsByDay[day] ?? [];
    setState(() {
      if (_selectedDay == day) {
        _selectedDay = null;
        _selectedDayEvents = [];
      } else {
        _selectedDay = day;
        _selectedDayEvents = dayEvents;
      }
    });
  }

  void _openEventDetail(LocalizedPlantEvent event) {
    final user = Provider.of<UserModel>(context, listen: false);
    final langCode = _mapLanguage(user.language);

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (_) => _EventDetailDialog(
        event: event,
        langCode: langCode,
        translateText: _translateText,
      ),
    );
  }

  Future<void> _openFilters() async {
    final result = await showModalBottomSheet<EventFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FiltersSheet(current: _filters),
    );

    if (result != null) {
      setState(() => _filters = result);
      _loadEvents();
    }
  }

  int get _daysInMonth =>
      DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;

  int get _firstWeekdayOfMonth {
    final wd = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday;
    return wd - 1;
  }

  String get _monthLabel {
    final l10n = AppLocalizations.of(context)!;
    final months = [
      l10n.monthJanuary,
      l10n.monthFebruary,
      l10n.monthMarch,
      l10n.monthApril,
      l10n.monthMay,
      l10n.monthJune,
      l10n.monthJuly,
      l10n.monthAugust,
      l10n.monthSeptember,
      l10n.monthOctober,
      l10n.monthNovember,
      l10n.monthDecember,
    ];
    return '${months[_currentMonth.month - 1]} ${_currentMonth.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F0),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4CAF50),
                      ),
                    )
                  : _error != null
                      ? _buildError()
                      : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    final filterCount = _filters.activeCount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          height: 28,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.eco,
                            color: Color(0xFF4CAF50),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'MeteoGarden',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (!_loading && _error == null)
                      Text(
                        l10n.calendarEventsCount(_events.length),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF757575),
                        ),
                      ),
                  ],
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: Icon(
                      filterCount > 0
                          ? Icons.filter_alt
                          : Icons.filter_alt_outlined,
                      color: const Color(0xFF4CAF50),
                    ),
                    onPressed: _openFilters,
                  ),
                  if (filterCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2E7D32),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$filterCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          Positioned(
            left: 0,
            top: 0,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF4CAF50)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 12),
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadEvents,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.calendarRetry),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final l10n = AppLocalizations.of(context)!;

    if (_selectedDay != null && _selectedDayEvents.isNotEmpty) {
      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildMonthNavigator(),
                if (!_filters.isEmpty) _buildActiveFilterChips(),
                _buildWeekdayLabels(),
                _buildCalendarGrid(),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
              child: Text(
                l10n.calendarSelectedDaySummary(
                  _selectedDay!,
                  _monthLabel,
                  _selectedDayEvents.length,
                  _selectedDayEvents.length == 1
                      ? l10n.calendarEventSingular
                      : l10n.calendarEventPlural,
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: _EventCard(
                  event: _selectedDayEvents[i],
                  onTap: () => _openEventDetail(_selectedDayEvents[i]),
                ),
              ),
              childCount: _selectedDayEvents.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      );
    }

    if (_selectedDay != null && _selectedDayEvents.isEmpty) {
      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildMonthNavigator(),
                if (!_filters.isEmpty) _buildActiveFilterChips(),
                _buildWeekdayLabels(),
                _buildCalendarGrid(),
              ],
            ),
          ),
          SliverFillRemaining(hasScrollBody: false, child: _buildEmptyDay()),
        ],
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildMonthNavigator(),
              if (!_filters.isEmpty) _buildActiveFilterChips(),
              _buildWeekdayLabels(),
              _buildCalendarGrid(),
            ],
          ),
        ),
        if (_events.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _buildEmptyMonthSummary(),
          )
        else ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
              child: Text(
                l10n.calendarUpcomingEvents,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, i) {
              final preview = _events.take(5).toList();
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: _EventCard(
                  event: preview[i],
                  onTap: () => _openEventDetail(preview[i]),
                ),
              );
            }, childCount: _events.take(5).length),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ],
    );
  }

  Widget _buildEmptyMonthSummary() {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            l10n.calendarNoEventsThisMonth,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          ),
          if (!_filters.isEmpty) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _filters = EventFilters(city: _filters.city);
                });
                _loadEvents();
              },
              child: Text(
                l10n.calendarClearFilters,
                style: const TextStyle(color: Color(0xFF4CAF50)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveFilterChips() {
    final l10n = AppLocalizations.of(context)!;
    final chips = <Widget>[];

    void addChip(String label, VoidCallback onRemove) {
      chips.add(
        Container(
          margin: const EdgeInsets.only(right: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFA5D6A7)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onRemove,
                child: const Icon(
                  Icons.close,
                  size: 13,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_filters.city.isNotEmpty) {
      addChip(_filters.city, () {
        setState(() => _filters = _filters.copyWith(city: ''));
        _loadEvents();
      });
    }

    if (_filters.county.isNotEmpty) {
      addChip(_filters.county, () {
        setState(() => _filters = _filters.copyWith(county: ''));
        _loadEvents();
      });
    }

    if (_filters.category.isNotEmpty) {
      addChip(_filters.category, () {
        setState(() => _filters = _filters.copyWith(category: ''));
        _loadEvents();
      });
    }

    if (_filters.maxDistanceKm != null) {
      addChip(l10n.calendarMaxDistanceChip(_filters.maxDistanceKm!.toInt()), () {
        setState(() => _filters = _filters.copyWith(clearDistance: true));
        _loadEvents();
      });
    }

    if (_filters.maxPrice != null) {
      addChip(l10n.calendarMaxPriceChip(_filters.maxPrice!.toInt()), () {
        setState(() => _filters = _filters.copyWith(clearPrice: true));
        _loadEvents();
      });
    }

    if (_filters.q.isNotEmpty) {
      addChip(l10n.calendarSearchChip(_filters.q), () {
        setState(() => _filters = _filters.copyWith(q: ''));
        _loadEvents();
      });
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: chips),
      ),
    );
  }

  Widget _buildMonthNavigator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(
                Icons.chevron_left,
                color: Color(0xFF4CAF50),
                size: 28,
              ),
              onPressed: _goToPreviousMonth,
            ),
            Text(
              _monthLabel,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1B5E20),
                letterSpacing: 0.3,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.chevron_right,
                color: Color(0xFF4CAF50),
                size: 28,
              ),
              onPressed: _goToNextMonth,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdayLabels() {
    final l10n = AppLocalizations.of(context)!;
    final days = [
      l10n.weekdayMon,
      l10n.weekdayTue,
      l10n.weekdayWed,
      l10n.weekdayThu,
      l10n.weekdayFri,
      l10n.weekdaySat,
      l10n.weekdaySun,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: days
            .map(
              (d) => Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: d == l10n.weekdaySat || d == l10n.weekdaySun
                          ? const Color(0xFF9E9E9E)
                          : const Color(0xFF4CAF50),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final today = DateTime.now();
    final isCurrentMonth =
        today.year == _currentMonth.year && today.month == _currentMonth.month;

    final totalCells = _firstWeekdayOfMonth + _daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(rows, (row) {
          return Row(
            children: List.generate(7, (col) {
              final cellIndex = row * 7 + col;
              final day = cellIndex - _firstWeekdayOfMonth + 1;

              if (day < 1 || day > _daysInMonth) {
                return const Expanded(child: SizedBox(height: 48));
              }

              return Expanded(
                child: _DayCell(
                  day: day,
                  isToday: isCurrentMonth && today.day == day,
                  isSelected: _selectedDay == day,
                  eventCount: _eventsByDay[day]?.length ?? 0,
                  isWeekend: col >= 5,
                  onTap: () => _onDayTapped(day),
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyDay() {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 48,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.calendarNoEventsThisDay,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ─── Filters Bottom Sheet ─────────────────────────────────────────────────────

class _FiltersSheet extends StatefulWidget {
  final EventFilters current;

  const _FiltersSheet({required this.current});

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late TextEditingController _cityCtrl;
  late TextEditingController _countyCtrl;
  late TextEditingController _categoryCtrl;
  late TextEditingController _qCtrl;
  late double _distanceKm;
  late bool _distanceEnabled;
  late double _maxPrice;
  late bool _priceEnabled;

  static const double _maxDistanceSlider = 200.0;
  static const double _maxPriceSlider = 100.0;

  @override
  void initState() {
    super.initState();
    _cityCtrl = TextEditingController(text: widget.current.city);
    _countyCtrl = TextEditingController(text: widget.current.county);
    _categoryCtrl = TextEditingController(text: widget.current.category);
    _qCtrl = TextEditingController(text: widget.current.q);
    _distanceEnabled = widget.current.maxDistanceKm != null;
    _distanceKm = widget.current.maxDistanceKm ?? 25.0;
    _priceEnabled = widget.current.maxPrice != null;
    _maxPrice = widget.current.maxPrice ?? 20.0;
  }

  @override
  void dispose() {
    _cityCtrl.dispose();
    _countyCtrl.dispose();
    _categoryCtrl.dispose();
    _qCtrl.dispose();
    super.dispose();
  }

  void _apply() {
    Navigator.pop(
      context,
      EventFilters(
        city: _cityCtrl.text.trim(),
        county: _countyCtrl.text.trim(),
        category: _categoryCtrl.text.trim(),
        maxDistanceKm: _distanceEnabled ? _distanceKm : null,
        maxPrice: _priceEnabled ? _maxPrice : null,
        q: _qCtrl.text.trim(),
      ),
    );
  }

  void _clear() {
    setState(() {
      _cityCtrl.text = widget.current.city;
      _countyCtrl.clear();
      _categoryCtrl.clear();
      _qCtrl.clear();
      _distanceEnabled = false;
      _distanceKm = 25.0;
      _priceEnabled = false;
      _maxPrice = 20.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF5F9F0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Text(
                    l10n.calendarFiltersTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _clear,
                    child: Text(
                      l10n.calendarClearAll,
                      style: const TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFDCEFDC)),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      controller: _qCtrl,
                      label: l10n.calendarSearchTextLabel,
                      hint: l10n.calendarSearchTextHint,
                      icon: Icons.search,
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: _cityCtrl,
                      label: l10n.calendarCityLabel,
                      hint: l10n.calendarCityHint,
                      icon: Icons.location_city_outlined,
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: _countyCtrl,
                      label: l10n.calendarCountyLabel,
                      hint: l10n.calendarCountyHint,
                      icon: Icons.map_outlined,
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: _categoryCtrl,
                      label: l10n.calendarCategoryLabel,
                      hint: l10n.calendarCategoryHint,
                      icon: Icons.category_outlined,
                    ),
                    const SizedBox(height: 18),
                    _buildSliderField(
                      label: l10n.calendarMaxDistanceLabel,
                      enabled: _distanceEnabled,
                      value: _distanceKm,
                      min: 1,
                      max: _maxDistanceSlider,
                      divisions: 199,
                      displayValue: l10n.calendarDistanceKm(_distanceKm.toInt()),
                      onToggle: (v) => setState(() => _distanceEnabled = v),
                      onChanged: (v) => setState(() => _distanceKm = v),
                      icon: Icons.social_distance_outlined,
                    ),
                    const SizedBox(height: 14),
                    _buildSliderField(
                      label: l10n.calendarMaxPriceLabel,
                      enabled: _priceEnabled,
                      value: _maxPrice,
                      min: 0,
                      max: _maxPriceSlider,
                      divisions: 100,
                      displayValue: _maxPrice == 0
                          ? l10n.calendarFree
                          : l10n.calendarPriceEuros(_maxPrice.toInt()),
                      onToggle: (v) => setState(() => _priceEnabled = v),
                      onChanged: (v) => setState(() => _maxPrice = v),
                      icon: Icons.euro_outlined,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _apply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.calendarApplyFilters,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1B5E20)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon: Icon(icon, color: const Color(0xFF9E9E9E), size: 18),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliderField({
    required String label,
    required bool enabled,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String displayValue,
    required ValueChanged<bool> onToggle,
    required ValueChanged<double> onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF4CAF50)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4CAF50),
              ),
            ),
            const Spacer(),
            Switch(
              value: enabled,
              onChanged: onToggle,
              activeThumbColor: const Color(0xFF4CAF50),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
        if (enabled) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF4CAF50),
                    inactiveTrackColor: const Color(0xFFC8E6C9),
                    thumbColor: const Color(0xFF2E7D32),
                    overlayColor: const Color(0xFF4CAF50).withValues(alpha: 0.12),
                  ),
                  child: Slider(
                    value: value,
                    min: min,
                    max: max,
                    divisions: divisions,
                    onChanged: onChanged,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  displayValue,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ─── Day Cell ─────────────────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isSelected;
  final int eventCount;
  final bool isWeekend;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.eventCount,
    required this.isWeekend,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = Colors.transparent;
    Color textColor = isWeekend
        ? const Color(0xFF9E9E9E)
        : const Color(0xFF424242);
    Color borderColor = Colors.transparent;

    if (isSelected) {
      bg = const Color(0xFF4CAF50);
      textColor = Colors.white;
    } else if (isToday) {
      borderColor = const Color(0xFF4CAF50);
      textColor = const Color(0xFF2E7D32);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        height: 48,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday || isSelected
                    ? FontWeight.w700
                    : FontWeight.w400,
                color: textColor,
              ),
            ),
            if (eventCount > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  eventCount.clamp(0, 3),
                  (_) => Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.only(right: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.85)
                          : const Color(0xFF81C784),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Event Card ───────────────────────────────────────────────────────────────

class _EventCard extends StatelessWidget {
  final LocalizedPlantEvent event;
  final VoidCallback onTap;

  const _EventCard({required this.event, required this.onTap});

  String get _timeLabel {
    final h = event.startDate.hour.toString().padLeft(2, '0');
    final m = event.startDate.minute.toString().padLeft(2, '0');
    if (h == '00' && m == '00') return '';
    return '$h:$m';
  }

  String get _locationLabel {
    final county = event.location.county;
    final street = event.location.street;
    if (street.isNotEmpty && county.isNotEmpty) return '$street · $county';
    if (county.isNotEmpty) return county;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            if (event.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
                child: Image.network(
                  event.imageUrl,
                  width: 80,
                  height: 88,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox(width: 0),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        event.category,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF388E3C),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    if (event.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        event.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (_timeLabel.isNotEmpty) ...[
                          const Icon(
                            Icons.access_time,
                            size: 12,
                            color: Color(0xFF9E9E9E),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            _timeLabel,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF9E9E9E),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (_locationLabel.isNotEmpty)
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 12,
                                  color: Color(0xFF9E9E9E),
                                ),
                                const SizedBox(width: 2),
                                Expanded(
                                  child: Text(
                                    _locationLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF9E9E9E),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                event.isFree
                    ? l10n.calendarFree
                    : l10n.calendarPriceCompact(event.price.toStringAsFixed(0)),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: event.isFree
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFF1B5E20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Event Detail Dialog ──────────────────────────────────────────────────────

class _EventDetailDialog extends StatefulWidget {
  final LocalizedPlantEvent event;
  final String langCode;
  final Future<String> Function(String text, String lang) translateText;

  const _EventDetailDialog({
    //super.key,
    required this.event,
    required this.langCode,
    required this.translateText,
  });

  @override
  State<_EventDetailDialog> createState() => _EventDetailDialogState();
}

class _EventDetailDialogState extends State<_EventDetailDialog> {
  String? _translatedDescription;
  bool _loadingDescription = true;

  @override
  void initState() {
    super.initState();
    _loadTranslatedDescription();
  }

  Future<void> _loadTranslatedDescription() async {
    final translated = await widget.translateText(
      widget.event.description,
      widget.langCode,
    );

    if (!mounted) return;

    setState(() {
      _translatedDescription = translated;
      _loadingDescription = false;
    });
  }

  String _formatDate(DateTime dt) {
    final months = [
      'gen',
      'feb',
      'març',
      'abr',
      'maig',
      'juny',
      'jul',
      'ago',
      'set',
      'oct',
      'nov',
      'des',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String get _dateRange {
    final start = _formatDate(widget.event.startDate);
    final end = _formatDate(widget.event.endDate);
    return start == end ? start : '$start – $end';
  }

  String get _timeLabel {
    final h = widget.event.startDate.hour.toString().padLeft(2, '0');
    final m = widget.event.startDate.minute.toString().padLeft(2, '0');
    if (h == '00' && m == '00') return '';
    return '$h:$m h';
  }

  String get _locationLabel {
    final parts = <String>[];
    if (widget.event.location.street.isNotEmpty) {
      parts.add(widget.event.location.street);
    }
    if (widget.event.location.county.isNotEmpty) {
      parts.add(widget.event.location.county);
    }
    if (widget.event.location.postalCode != 0) {
      parts.add(widget.event.location.postalCode.toString());
    }
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final event = widget.event;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          color: const Color(0xFFF5F9F0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  if (event.imageUrl.isNotEmpty)
                    Image.network(
                      event.imageUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imagePlaceholder(),
                    )
                  else
                    _imagePlaceholder(),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        event.category,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1B5E20),
                          height: 1.2,
                        ),
                      ),
                      if (event.subtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          event.subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _MetaPill(
                            icon: Icons.calendar_today_outlined,
                            label: _dateRange,
                          ),
                          if (_timeLabel.isNotEmpty)
                            _MetaPill(
                              icon: Icons.access_time,
                              label: _timeLabel,
                            ),
                          _MetaPill(
                            icon: Icons.euro,
                            label: event.isFree
                                ? l10n.calendarFreeAccent
                                : l10n.calendarPriceEuros(
                                    event.price.toStringAsFixed(0),
                                  ),
                            highlight: event.isFree,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (_locationLabel.isNotEmpty)
                        _buildInfoRow(Icons.location_on_outlined, _locationLabel),
                      if (event.phone.isNotEmpty && event.phone != '0')
                        _buildInfoRow(Icons.phone_outlined, event.phone),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Divider(color: Color(0xFFDCEFDC), thickness: 1),
                      ),
                      if (_loadingDescription)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: CircularProgressIndicator(
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        )
                      else
                        Text(
                          _translatedDescription ?? event.description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF424242),
                            height: 1.6,
                          ),
                        ),
                      if (event.tags.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: event.tags
                              .map((tag) => _buildTag(tag))
                              .toList(),
                        ),
                      ],
                      if (event.ticketUrl.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              /* Obrir URL */
                            },
                            icon: const Icon(Icons.open_in_new, size: 16),
                            label: Text(l10n.calendarBuyTickets),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() => Container(
        width: double.infinity,
        height: 200,
        color: const Color(0xFFE8F5E9),
        child: const Icon(
          Icons.image_not_supported_outlined,
          color: Colors.green,
          size: 40,
        ),
      );

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF4CAF50)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Color(0xFF424242)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '#$tag',
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF388E3C),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ─── Meta Pill ────────────────────────────────────────────────────────────────

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool highlight;

  const _MetaPill({
    required this.icon,
    required this.label,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFE8F5E9) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: highlight
                ? const Color(0xFF4CAF50)
                : const Color(0xFF757575),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: highlight
                  ? const Color(0xFF388E3C)
                  : const Color(0xFF424242),
            ),
          ),
        ],
      ),
    );
  }
}
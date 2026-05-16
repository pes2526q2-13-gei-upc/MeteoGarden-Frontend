import 'package:flutter/material.dart';
import 'package:meteo_garden/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../models/dades_usr.dart';
import '../services/events_api_service.dart';

// ─── Calendar Page ────────────────────────────────────────────────────────────

class _EventFiltersResult {
  final String city;
  final String category;

  const _EventFiltersResult({required this.city, required this.category});
}

class CalendarPage extends StatefulWidget {
  final String city;
  final EventsService? service;

  const CalendarPage({super.key, required this.city, this.service});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final EventsService _service;

  late DateTime _currentMonth;
  late String _filterCity;
  String _filterCategory = '';

  Map<int, int> _countByDay = {};
  List<EventCategory> _categories = [];
  List<EventSummary> _selectedDayEvents = [];
  int? _selectedDay;
  bool _loadingDay = false;
  bool _loadingMonth = true;
  bool _loadingCategories = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    _service = widget.service ?? EventsService();

    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month, 1);
    _filterCity = '';
    _loadCategories();
    _loadMonthCounts();
  }

  String _langCode(BuildContext context) {
    final user = Provider.of<UserModel>(context, listen: false);

    switch (user.language.toLowerCase()) {
      case 'català':
      case 'catala':
      case 'ca':
        return 'ca';

      case 'castellano':
      case 'castellà':
      case 'español':
      case 'espanyol':
      case 'es':
        return 'es';

      case 'english':
      case 'anglès':
      case 'angles':
      case 'en':
        return 'en';

      default:
        return Localizations.localeOf(context).languageCode;
    }
  }

  // ── Filters ────────────────────────────────────────────────────────────────

  bool get _hasActiveFilters =>
      _filterCity.trim().isNotEmpty || _filterCategory.trim().isNotEmpty;

  String _categoryDisplayName(String categoryName) {
    final cleanName = categoryName.trim();

    for (final category in _categories) {
      if (category.name.trim() == cleanName) {
        return category.displayName;
      }
    }

    return cleanName;
  }

  Widget _buildActiveFiltersText() {
    final l10n = AppLocalizations.of(context)!;

    final activeFilters = <String>[];
    if (_filterCity.trim().isNotEmpty) {
      activeFilters.add(_filterCity.trim());
    }
    if (_filterCategory.trim().isNotEmpty) {
      activeFilters.add(_categoryDisplayName(_filterCategory));
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: Text(
        activeFilters.isEmpty
            ? '${l10n.allCities} · ${l10n.calendarAllCategories}'
            : activeFilters.join(' · '),
        key: ValueKey(activeFilters.join('|')),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: activeFilters.isEmpty
              ? const Color(0xFF757575)
              : const Color(0xFF2E7D32),
        ),
      ),
    );
  }

  Future<void> _showFiltersSheet() async {
    final l10n = AppLocalizations.of(context)!;
    final initialCity = _filterCity.trim();
    final initialCategory = _filterCategory.trim();

    final result = await showModalBottomSheet<_EventFiltersResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final cityController = TextEditingController(text: initialCity);
        String tempCategory = initialCategory;

        return StatefulBuilder(
          builder: (context, setSheetState) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Icon(Icons.tune, color: Color(0xFF4CAF50)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.calendarFilters,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            Navigator.of(sheetContext).pop();
                          },
                          icon: const Icon(Icons.close),
                          color: const Color(0xFF757575),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: cityController,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: l10n.filterByCity,
                        hintText: l10n.writeCity,
                        prefixIcon: const Icon(
                          Icons.location_on_outlined,
                          color: Color(0xFF4CAF50),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F9F0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF4CAF50),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _loadingCategories
                        ? Container(
                            height: 58,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F9F0),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Color(0xFF4CAF50),
                                strokeWidth: 2.4,
                              ),
                            ),
                          )
                        : _buildCategoryChips(
                            tempCategory: tempCategory,
                            setSheetState: setSheetState,
                            onCategoryChanged: (value) {
                              tempCategory = value;
                            },
                          ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              cityController.clear();
                              setSheetState(() {
                                tempCategory = '';
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            label: Text(l10n.calendarClear),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF4CAF50),
                              side: const BorderSide(color: Color(0xFF4CAF50)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final newCity = cityController.text.trim();
                              final newCategory = tempCategory.trim();

                              FocusManager.instance.primaryFocus?.unfocus();
                              Navigator.of(sheetContext).pop(
                                _EventFiltersResult(
                                  city: newCity,
                                  category: newCategory,
                                ),
                              );
                            },
                            icon: const Icon(Icons.check),
                            label: Text(l10n.commonApply),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (!mounted || result == null) return;

    final newCity = result.city.trim();
    final newCategory = result.category.trim();

    if (newCity == _filterCity.trim() &&
        newCategory == _filterCategory.trim()) {
      return;
    }

    setState(() {
      _filterCity = newCity;
      _filterCategory = newCategory;
      _selectedDay = null;
      _selectedDayEvents = [];
    });

    await _loadMonthCounts();
  }

  Widget _buildCategoryChips({
    required String tempCategory,
    required StateSetter setSheetState,
    required ValueChanged<String> onCategoryChanged,
  }) {
    final categories = <EventCategory>[];
    final seenNames = <String>{};
    final l10n = AppLocalizations.of(context)!;

    for (final category in _categories) {
      final name = category.name.trim();
      if (name.isEmpty || seenNames.contains(name)) {
        continue;
      }

      seenNames.add(name);
      categories.add(category);
    }

    categories.sort(
      (a, b) =>
          a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
    );

    final selectedCategory =
        categories.any(
          (category) => category.name.trim() == tempCategory.trim(),
        )
        ? tempCategory.trim()
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.category_outlined, color: Color(0xFF4CAF50), size: 20),
            SizedBox(width: 8),
            Text(
              l10n.calendarCategory,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: 150),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F9F0),
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: Text(l10n.calendarAll),
                  selected: selectedCategory.isEmpty,
                  selectedColor: const Color(
                    0xFF4CAF50,
                  ).withValues(alpha: 0.18),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: selectedCategory.isEmpty
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFF424242),
                    fontWeight: selectedCategory.isEmpty
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: selectedCategory.isEmpty
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFD6D6D6),
                    ),
                  ),
                  onSelected: (_) {
                    setSheetState(() {
                      onCategoryChanged('');
                    });
                  },
                ),
                ...categories.map((category) {
                  final categoryName = category.name.trim();
                  final isSelected = selectedCategory == categoryName;

                  return ChoiceChip(
                    label: Text(category.displayName),
                    selected: isSelected,
                    selectedColor: const Color(
                      0xFF4CAF50,
                    ).withValues(alpha: 0.18),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFF424242),
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFD6D6D6),
                      ),
                    ),
                    onSelected: (_) {
                      setSheetState(() {
                        onCategoryChanged(categoryName);
                      });
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Data loading ────────────────────────────────────────────────────────────

  Future<void> _loadCategories() async {
    setState(() {
      _loadingCategories = true;
    });

    try {
      final token = Provider.of<UserModel>(context, listen: false).token;

      final categories = await _service.fetchCategories(token: token);

      if (!mounted) return;

      setState(() {
        _categories = categories;
        _loadingCategories = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _categories = [];
        _loadingCategories = false;
      });
    }
  }

  Future<void> _loadMonthCounts() async {
    setState(() {
      _loadingMonth = true;
      _error = null;
      _selectedDay = null;
      _selectedDayEvents = [];
    });

    try {
      final counts = await _service.fetchEventCountByDay(
        year: _currentMonth.year,
        month: _currentMonth.month,
        city: _filterCity.trim().isEmpty ? null : _filterCity.trim(),
        category: _filterCategory.trim().isEmpty
            ? null
            : _filterCategory.trim(),
      );
      if (!mounted) return;
      setState(() {
        _countByDay = counts;
        _loadingMonth = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loadingMonth = false;
      });
    }
  }

  Future<void> _onDayTapped(int day) async {
    if (_selectedDay == day) {
      setState(() {
        _selectedDay = null;
        _selectedDayEvents = [];
      });
      return;
    }

    final date = DateTime(_currentMonth.year, _currentMonth.month, day);
    final lang = _langCode(context);

    setState(() {
      _selectedDay = day;
      _selectedDayEvents = [];
      _loadingDay = true;
    });

    try {
      final events = await _service.fetchEvents(
        date: date,
        lang: lang,
        city: _filterCity.trim().isEmpty ? null : _filterCity.trim(),
        category: _filterCategory.trim().isEmpty
            ? null
            : _filterCategory.trim(),
      );

      if (!mounted) return;
      setState(() {
        _selectedDayEvents = events;
        _loadingDay = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingDay = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _openEventDetail(EventSummary event) async {
    final date = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      _selectedDay!,
    );
    final lang = _langCode(context);

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (_) => _EventDetailDialog(
        eventId: event.id,
        date: date,
        lang: lang,
        service: _service,
      ),
    );
  }

  // ── Navigation ──────────────────────────────────────────────────────────────

  void _goToPreviousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
    _loadMonthCounts();
  }

  void _goToNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
    _loadMonthCounts();
  }

  // ── Calendar helpers ────────────────────────────────────────────────────────

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

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F0),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _loadingMonth
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 52),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                _buildActiveFiltersText(),
              ],
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF4CAF50)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  tooltip: AppLocalizations.of(context)!.calendarFiltersTooltip,
                  icon: const Icon(Icons.tune, color: Color(0xFF4CAF50)),
                  onPressed: _showFiltersSheet,
                ),
                if (_hasActiveFilters)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF7043),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
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
            onPressed: _loadMonthCounts,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.commonRetry),
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
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildMonthNavigator(),
              _buildWeekdayLabels(),
              _buildCalendarGrid(),
            ],
          ),
        ),
        if (_selectedDay != null) ...[
          SliverToBoxAdapter(child: _buildSelectedDayHeader()),
          if (_loadingDay)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
                ),
              ),
            )
          else if (_selectedDayEvents.isEmpty)
            SliverToBoxAdapter(child: _buildEmptyDay())
          else
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
      ],
    );
  }

  Widget _buildSelectedDayHeader() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Text(
        l10n.calendarDayTitle(_selectedDay!, _monthLabel),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1B5E20),
        ),
      ),
    );
  }

  Widget _buildEmptyDay() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy_outlined, size: 48, color: Color(0xFFBDBDBD)),
            SizedBox(height: 10),
            Text(
              l10n.noEventsToday,
              style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
            ),
          ],
        ),
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
        children: days.map((d) {
          final isWeekend = d == l10n.weekdaySat || d == l10n.weekdaySun;
          return Expanded(
            child: Center(
              child: Text(
                d,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isWeekend
                      ? const Color(0xFF9E9E9E)
                      : const Color(0xFF4CAF50),
                ),
              ),
            ),
          );
        }).toList(),
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
                  eventCount: _countByDay[day] ?? 0,
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
    Color bgColor = Colors.transparent;
    Color textColor = isWeekend
        ? const Color(0xFF9E9E9E)
        : const Color(0xFF212121);

    if (isSelected) {
      bgColor = const Color(0xFF2E7D32);
      textColor = Colors.white;
    } else if (isToday) {
      bgColor = const Color(0xFFE8F5E9);
      textColor = const Color(0xFF2E7D32);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
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
            if (eventCount > 0) ...[
              const SizedBox(height: 3),
              _buildDots(eventCount, isSelected),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDots(int count, bool isSelected) {
    final dotCount = count.clamp(1, 3);
    final dotColor = isSelected ? Colors.white70 : const Color(0xFF4CAF50);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        dotCount,
        (_) => Container(
          width: 4,
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

// ─── Event Card ───────────────────────────────────────────────────────────────

class _EventCard extends StatelessWidget {
  final EventSummary event;
  final VoidCallback onTap;

  const _EventCard({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
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
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: event.image.isNotEmpty
                  ? Image.network(
                      event.image,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _placeholder(),
                    )
                  : _placeholder(),
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
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
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
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (event.city.isNotEmpty) ...[
                          const Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: Color(0xFF4CAF50),
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              event.city,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF757575),
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: event.isFree
                                ? const Color(0xFFE8F5E9)
                                : const Color(0xFFFFF9C4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            event.isFree
                                ? l10n.calendarFreeAccent
                                : '${event.price.toStringAsFixed(0)} €',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: event.isFree
                                  ? const Color(0xFF388E3C)
                                  : const Color(0xFFF57F17),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(
                Icons.chevron_right,
                color: Color(0xFF4CAF50),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    width: 90,
    height: 90,
    color: const Color(0xFFE8F5E9),
    child: const Icon(
      Icons.image_not_supported_outlined,
      color: Color(0xFF4CAF50),
      size: 28,
    ),
  );
}

// ─── Event Detail Dialog ──────────────────────────────────────────────────────

class _EventDetailDialog extends StatefulWidget {
  final String eventId;
  final DateTime date;
  final String lang;
  final EventsService service;

  const _EventDetailDialog({
    required this.eventId,
    required this.date,
    required this.lang,
    required this.service,
  });

  @override
  State<_EventDetailDialog> createState() => _EventDetailDialogState();
}

class _EventDetailDialogState extends State<_EventDetailDialog> {
  EventDetail? _detail;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final detail = await widget.service.fetchEventDetail(
        id: widget.eventId,
        date: widget.date,
        lang: widget.lang,
      );
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.hardEdge,
      child: _loading
          ? const SizedBox(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
              ),
            )
          : _error != null
          ? SizedBox(
              height: 200,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            )
          : _buildDetail(_detail!),
    );
  }

  Widget _buildDetail(EventDetail event) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            event.image.isNotEmpty
                ? Image.network(
                    event.image,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _imagePlaceholder(),
                  )
                : _imagePlaceholder(),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
            if (event.category.isNotEmpty)
              Positioned(
                bottom: 12,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
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
                      label: _formatDate(event.startDate),
                    ),
                    _MetaPill(
                      icon: Icons.euro,
                      label: event.isFree
                          ? l10n.calendarFreeAccent
                          : '${event.price.toStringAsFixed(0)} €',
                      highlight: event.isFree,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (event.city.isNotEmpty || event.street.isNotEmpty)
                  _buildInfoRow(
                    Icons.location_on_outlined,
                    [
                      event.city,
                      event.street,
                    ].where((s) => s.isNotEmpty).join(', '),
                  ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(color: Color(0xFFDCEFDC), thickness: 1),
                ),
                if (event.description.isNotEmpty)
                  Text(
                    event.description,
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
                    children: event.tags.map((tag) => _buildTag(tag)).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

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

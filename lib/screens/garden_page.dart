import 'package:flutter/material.dart';
import 'package:meteo_garden/generated/app_localizations.dart';
import 'package:meteo_garden/screens/album_page.dart';
import 'package:provider/provider.dart';

import '../../models/garden.dart';
import '../../models/weather_info.dart';
import '../../services/garden_service.dart';
import '../../services/weather_service.dart';
import '../../widgets/pot_info_sheet.dart';
import '../../widgets/pot_widget.dart';
import '../../widgets/potion_selection_sheet.dart';
import '../../widgets/seed_selection_sheet.dart';
import '../../widgets/weather_card.dart';
import '../models/dades_usr.dart';
import '../screens/botiga_page.dart';
import 'calendar_page.dart';
import 'inventory_page.dart';

class GardenPage extends StatefulWidget {
  final String username;
  final String gardenName;

  const GardenPage({
    super.key,
    required this.username,
    required this.gardenName,
  });

  @override
  State<GardenPage> createState() => _GardenPageState();
}

class _GardenPageState extends State<GardenPage> {
  late final GardenService _gardenService;
  Future<WeatherInfo>? _weatherFuture;
  late Future<List<GardenPot>> _potsFuture;

  @override
  void initState() {
    super.initState();

    _gardenService = GardenService();

    _potsFuture = _gardenService.fetchGardenPlants(
      username: widget.username,
      gardenName: widget.gardenName,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final user = Provider.of<UserModel>(context, listen: false);

      setState(() {
        _weatherFuture = WeatherService.fetchCurrent(city: user.city);
      });
    });
  }

  void _refreshWeather() {
    final user = Provider.of<UserModel>(context, listen: false);
    setState(() {
      _weatherFuture = WeatherService.fetchCurrent(city: user.city);
    });
  }

  void _refreshGarden() {
    setState(() {
      _potsFuture = _gardenService.fetchGardenPlants(
        username: widget.username,
        gardenName: widget.gardenName,
      );
    });
  }

  Future<void> onTapPot(GardenPot pot) async {
    final t = AppLocalizations.of(context)!;

    if (!pot.occupied || pot.plant == null) {
      await _showSeedSelection(pot);
      return;
    }

    await precacheImage(
      const AssetImage('assets/images/foto_terra2.png'),
      context,
    );

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PotInfoSheet(
        pot: pot,
        onWater: () async {
          try {
            final missatge = await _gardenService.waterPlant(
              username: widget.username,
              gardenName: widget.gardenName,
              potNumber: pot.potNumber,
            );

            if (!mounted) return;

            Navigator.of(context).pop();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(missatge)));
            _refreshGarden();
          } catch (e) {
            if (!mounted) return;

            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString().replaceFirst('Exception: ', '')),
              ),
            );
          }
        },
        onCollect: () async {
          try {
            final missatge = await _gardenService.collectPlant(
              username: widget.username,
              gardenName: widget.gardenName,
              potNumber: pot.potNumber,
              scientificName: pot.plant!.scientificName,
            );

            if (!mounted) return;

            Navigator.of(context).pop();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(missatge)));
            _refreshGarden();
          } catch (e) {
            if (!mounted) return;

            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString().replaceFirst('Exception: ', '')),
              ),
            );
          }
        },
        onPotion: () async {
          try {
            Navigator.of(context).pop();

            if (!mounted) return;

            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (_) => PotionSelectionSheet(
                pot: pot,
                username: widget.username,
                gardenName: widget.gardenName,
                gardenService: _gardenService,
                onPotionSuccess: _refreshGarden,
              ),
            );
          } catch (e) {
            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString().replaceFirst('Exception: ', '')),
              ),
            );
          }
        },
        onDeletePlant: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (dialogContext) {
              return Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F9F0),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.35),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF4CAF50,
                          ).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_florist,
                          color: Color(0xFF2E7D32),
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t.deletePlant,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.confirmDeletePlant(
                          pot.plant?.commonName ?? t.thisPlant,
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2E7D32),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(false),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF4CAF50),
                                ),
                                foregroundColor: const Color(0xFF2E7D32),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                t.commonCancel,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFDC2626),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                t.commonEliminar,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );

          if (confirm != true) return;

          try {
            final missatge = await _gardenService.deletePlant(
              username: widget.username,
              gardenName: widget.gardenName,
              potNumber: pot.potNumber,
            );

            if (!mounted) return;

            Navigator.of(context).pop();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(missatge)));
            _refreshGarden();
          } catch (e) {
            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString().replaceFirst('Exception: ', '')),
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _showSeedSelection(GardenPot pot) async {
    try {
      final seeds = await _gardenService.fetchSeeds(widget.username);

      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) {
          return SeedSelectionSheet(
            pot: pot,
            seeds: seeds,
            username: widget.username,
            gardenName: widget.gardenName,
            gardenService: _gardenService,
            onPlantingSuccess: _refreshGarden,
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      final t = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${t.gardenLoadingSeedsError}: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    }
  }

  double _horizontalPadding(double width) {
    if (width < 360) return 8;
    if (width < 700) return 12;
    return 16;
  }

  double _gridSpacing(double width) {
    if (width < 360) return 6;
    if (width < 700) return 10;
    return 14;
  }

  Widget _buildWeatherSection() {
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<WeatherInfo>(
      future: _weatherFuture,
      builder: (context, snap) {
        if (_weatherFuture == null ||
            snap.connectionState == ConnectionState.waiting) {
          return WeatherCard(
            nomEstacio: "",
            title: l10n.gardenLoadingWeather,
            subtitle: l10n.gardenWaitMoment,
            trailing: const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            onRefresh: _refreshWeather,
          );
        }

        if (snap.hasError) {
          return WeatherCard(
            nomEstacio: "",
            title: l10n.gardenWeatherLoadError,
            subtitle: l10n.gardenTapToRetry,
            trailing: const Icon(Icons.warning_amber_rounded),
            onRefresh: _refreshWeather,
          );
        }

        final w = snap.data!;
        return WeatherCard(
          nomEstacio: w.stationName,
          title: l10n.gardenWeatherSummary(
            w.temp.toStringAsFixed(1),
            w.precipitation,
          ),
          subtitle: l10n.gardenWindSummary(w.wind.toStringAsFixed(1)),
          precipitation: double.tryParse(w.precipitation),
          wind: w.wind,
          trailing: const Icon(Icons.refresh),
          onRefresh: _refreshWeather,
        );
      },
    );
  }

  Widget _buildCoinsChip(int monedes, double width, double height) {
    final iconSize = width < 360 ? 18.0 : 22.0;
    final textSize = width < 360 ? 14.0 : 16.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.03,
        vertical: height * 0.008,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/coin.png',
            width: iconSize,
            height: iconSize,
            errorBuilder: (_, _, _) => Icon(
              Icons.monetization_on,
              color: Colors.amber,
              size: iconSize,
            ),
          ),
          SizedBox(width: width * 0.015),
          Text(
            '$monedes',
            style: TextStyle(
              fontSize: textSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5D4037),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionArea({
    required double width,
    required double height,
    required String username,
    required int monedes,
    required String city,
  }) {
    final sideBoxSize = width < 360 ? width * 0.16 : width * 0.14;
    final shopWidth = width < 360 ? width * 0.40 : width * 0.36;

    return Padding(
      padding: EdgeInsets.only(
        left: width * 0.01,
        right: width * 0.01,
        bottom: height * 0.005,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => InventoryPage(username: username),
                    ),
                  );
                },
                child: SizedBox(
                  width: sideBoxSize,
                  height: sideBoxSize,
                  child: Image.asset(
                    'assets/images/inventory_imagen.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: height * 0.008),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const AlbumPage()));
                },
                child: SizedBox(
                  width: sideBoxSize,
                  height: sideBoxSize,
                  child: Image.asset(
                    'assets/images/album_image.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: height * 0.008),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => CalendarPage(city: city)),
                  );
                },
                child: SizedBox(
                  width: sideBoxSize,
                  height: sideBoxSize,
                  child: Image.asset(
                    'assets/images/calendar_image.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCoinsChip(monedes, width, height),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (_) => const ShopPage()));
                  },
                  child: SizedBox(
                    width: shopWidth,
                    child: Image.asset(
                      'assets/images/botiga.png',
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomCenter,
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

  Widget _buildPotsGrid(double width) {
    final padding = _horizontalPadding(width);
    final spacing = _gridSpacing(width);

    return FutureBuilder<List<GardenPot>>(
      future: _potsFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '${AppLocalizations.of(context)!.gardenLoadingPotsError}\n${snap.error}',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final pots = snap.data ?? [];

        if (pots.isEmpty) {
          return Center(
            child: Text(
              AppLocalizations.of(context)!.gardenNoPotsAvailable,
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        const crossAxisCount = 4;
        final rowCount = (pots.length / crossAxisCount).ceil();

        return LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final totalHeight = constraints.maxHeight;

            final usableWidth = totalWidth - (padding * 2);
            final usableHeight = totalHeight;

            final itemWidth =
                (usableWidth - (spacing * (crossAxisCount - 1))) /
                crossAxisCount;

            final itemHeight =
                (usableHeight - (spacing * (rowCount - 1))) / rowCount;

            final aspectRatio = itemHeight > 0 ? itemWidth / itemHeight : 1.0;

            return GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(padding, 0, padding, 0),
              itemCount: pots.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: aspectRatio,
              ),
              itemBuilder: (context, index) {
                final pot = pots[index];
                return PotWidget(pot: pot, onTap: () => onTapPot(pot));
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context);
    final username = user.username;
    final monedes = user.monedes;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/imatge_fondo1.png',
                  fit: BoxFit.cover,
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: _horizontalPadding(width),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 23,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(height: height * 0.015),
                            _buildWeatherSection(),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 37,
                        child: _buildActionArea(
                          width: width,
                          height: height,
                          username: username,
                          monedes: monedes,
                          city: user.city,
                        ),
                      ),
                      SizedBox(height: height * 0.02),
                      Expanded(flex: 50, child: _buildPotsGrid(width)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

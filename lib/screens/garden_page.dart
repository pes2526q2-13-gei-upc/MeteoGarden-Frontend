import 'package:flutter/material.dart';
import 'package:meteo_garden/generated/app_localizations.dart';
import 'package:meteo_garden/screens/album_page.dart';
import 'package:provider/provider.dart';

import '../../models/garden.dart';
//import '../../models/weather_info.dart';
import '../../services/garden_service.dart';
import '../../widgets/pot_info_sheet.dart';
import '../../widgets/pot_widget.dart';
import '../../widgets/potion_selection_sheet.dart';
import '../../widgets/seed_selection_sheet.dart';
import '../../widgets/weather_card.dart';
import '../models/dades_usr.dart';
import '../screens/botiga_page.dart';
import 'calendar_page.dart';
import 'inventory_page.dart';
import '../../widgets/centered_message.dart';

import '../models/weather_provider.dart';
import 'weather_details_page.dart';

class GardenPage extends StatefulWidget {
  final String username;
  final String gardenName;
  final GardenService? gardenService;

  const GardenPage({
    super.key,
    required this.username,
    required this.gardenName,
    this.gardenService,
  });

  @override
  State<GardenPage> createState() => _GardenPageState();
}

class _GardenPageState extends State<GardenPage> {
  late final GardenService _gardenService;
  late Future<List<GardenPot>> _potsFuture;

  @override
  void initState() {
    super.initState();

    _gardenService = widget.gardenService ?? GardenService();

    _potsFuture = _loadPots();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final user = Provider.of<UserModel>(context, listen: false);

      Provider.of<WeatherProvider>(
        context,
        listen: false,
      ).fetchWeather(user.city, forceRefresh: true, token: user.token);
    });
  }

  Future<List<GardenPot>> _loadPots() async {
    final user = Provider.of<UserModel>(context, listen: false);
    final token = user.token;

    if (token.isEmpty) {
      throw Exception('No hi ha token guardat');
    }

    return _gardenService.fetchGardenPlants(
      username: widget.username,
      gardenName: widget.gardenName,
    );
  }

  void _refreshWeather() {
    final user = Provider.of<UserModel>(context, listen: false);
    // Forzamos la recarga desde el provider
    Provider.of<WeatherProvider>(
      context,
      listen: false,
    ).fetchWeather(user.city, forceRefresh: true, token: user.token);
  }

  Future<void> _refreshSinglePot(int potNumber) async {
    final updatedPot = await _gardenService.fetchPotStatus(
      username: widget.username,
      gardenName: widget.gardenName,
      potNumber: potNumber,
    );

    final currentPots = await _potsFuture;

    final updatedPots = currentPots.map((pot) {
      if (pot.potNumber == updatedPot.potNumber) {
        return updatedPot;
      }
      return pot;
    }).toList();

    if (!mounted) return;

    setState(() {
      _potsFuture = Future.value(updatedPots);
    });
  }

  Future<void> _showCollectSuccessDialog(CollectPlantResult result) async {
  if (!mounted) return;

  final t = AppLocalizations.of(context)!;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F9F0),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFDFF3DF),
                ),
                child: const Icon(
                  Icons.eco,
                  color: Color(0xFF2E7D32),
                  size: 34,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                t.collectPlantDialogTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                result.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF355E3B),
                ),
              ),

              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.18),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: Color(0xFFD6A300),
                      size: 26,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        t.collectPlantCoinsReward(10),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2F4F2F),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    t.commonOk,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
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
            final user = Provider.of<UserModel>(context, listen: false);
            final token = user.token;

            if (token.isEmpty) {
              throw Exception('No hi ha token guardat');
            }
            await _gardenService.waterPlant(
              username: widget.username,
              gardenName: widget.gardenName,
              potNumber: pot.potNumber,
              token: token,
            );

            if (!mounted) return;

            Navigator.of(context).pop();
            CenteredMessage.show(
              context,
              t.plantWateredSuccess,
              type: CenteredMessageType.success,
            );
            await _refreshSinglePot(pot.potNumber);
          } catch (e) {
            if (!mounted) return;

            Navigator.of(context).pop();
            CenteredMessage.show(
              context,
              e.toString().replaceFirst('Exception: ', ''),
              type: CenteredMessageType.error,
            );
          }
        },
        onCollect: () async {
            try {
              final navigator = Navigator.of(context);

              final result = await _gardenService.collectPlant(
                username: widget.username,
                gardenName: widget.gardenName,
                potNumber: pot.potNumber,
                scientificName: pot.plant!.scientificName,
              );

              if (!mounted) return;

              final user = Provider.of<UserModel>(context, listen: false);
              user.setCoins(result.newBalance);

              navigator.pop();

              await _showCollectSuccessDialog(result);

              await _refreshSinglePot(pot.potNumber);
            } catch (e) {
              if (!mounted) return;

              Navigator.of(context).pop();

              CenteredMessage.show(
                context,
                e.toString().replaceFirst('Exception: ', ''),
                type: CenteredMessageType.error,
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
                onPotionSuccess: _refreshSinglePot,
              ),
            );
          } catch (e) {
            if (!mounted) return;

            CenteredMessage.show(
              context,
              e.toString().replaceFirst('Exception: ', ''),
              type: CenteredMessageType.error,
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
          if (!mounted) return;

          try {
            final user = Provider.of<UserModel>(context, listen: false);
            final token = user.token;
            final navigator = Navigator.of(context);

            if (token.isEmpty) {
              throw Exception('No hi ha token guardat');
            }
            await _gardenService.deletePlant(
              username: widget.username,
              gardenName: widget.gardenName,
              potNumber: pot.potNumber,
              token: token,
            );

            if (!mounted) return;

            navigator.pop();

            CenteredMessage.show(
              context,
              t.plantDeletedSuccess,
              type: CenteredMessageType.success,
            );
            await _refreshSinglePot(pot.potNumber);
          } catch (e) {
            if (!mounted) return;

            CenteredMessage.show(
              context,
              e.toString().replaceFirst('Exception: ', ''),
              type: CenteredMessageType.error,
            );
          }
        },
      ),
    );
  }

  Future<void> _showSeedSelection(GardenPot pot) async {
    try {
      final user = Provider.of<UserModel>(context, listen: false);
      final token = user.token;

      if (token.isEmpty) {
        throw Exception('No hi ha token guardat');
      }
      final seeds = await _gardenService.fetchSeeds(widget.username);

      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => SeedSelectionSheet(
          pot: pot,
          seeds: seeds,
          username: widget.username,
          gardenName: widget.gardenName,
          token: token,
          gardenService: _gardenService,
          onPlantingSuccess: _refreshSinglePot,
        ),
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

  // --- SECCIÓN DEL TIEMPO ACTUALIZADA ---
  Widget _buildWeatherSection() {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        // 1. Estado de carga (mientras busca los datos)
        if (weatherProvider.isLoading &&
            weatherProvider.currentWeather == null) {
          return WeatherCard(
            nomEstacio: "",
            title: l10n.gardenLoadingWeather,
            subtitle: l10n.gardenWaitMoment,
            trailing: const SizedBox(
              // 👈 trailing requerido
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            onRefresh: _refreshWeather,
          );
        }

        // 2. Estado de error (si falla la llamada)
        if (weatherProvider.error != null &&
            weatherProvider.currentWeather == null) {
          return WeatherCard(
            nomEstacio: "",
            title: l10n.gardenWeatherLoadError,
            subtitle: l10n.gardenTapToRetry,
            trailing: const Icon(
              Icons.warning_amber_rounded,
            ), // 👈 trailing requerido
            onRefresh: _refreshWeather,
          );
        }

        // 3. ¡AQUÍ DECLARAMOS 'w'! Justo antes de usarla
        final w = weatherProvider.currentWeather;

        // Si 'w' todavía es null por alguna razón, no mostramos nada y evitamos errores
        if (w == null) {
          return const SizedBox.shrink();
        }

        // 4. Devolvemos la tarjeta con todos sus datos y parámetros
        return WeatherCard(
          nomEstacio: w.stationName,
          title: l10n.gardenWeatherSummary(
            w.temp.toStringAsFixed(1),
            w.precipitation,
          ),
          subtitle: l10n.gardenWindSummary(w.wind.toStringAsFixed(1)),
          precipitation: double.tryParse(w.precipitation),
          wind: w.wind,
          trailing: const Icon(
            Icons.refresh,
          ), // 👈 AQUÍ SOLUCIONAMOS EL ERROR DEL TRAILING
          onRefresh: _refreshWeather,
          onTap: () {
            // Navegación limpia al hacer clic en la tarjeta
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const WeatherDetailsPage()),
            );
          },
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
                key: const Key('garden_inventory_button'),
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
                key: const Key('garden_album_button'),
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
                key: const Key('garden_calendar_button'),
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
                  key: const Key('garden_shop_button'),
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

import 'package:flutter/material.dart';
import 'package:meteo_garden/screens/album_page.dart';

import '../../models/garden.dart';
import '../../models/weather_info.dart';
import '../../services/garden_service.dart';
import '../../services/weather_service.dart';
import '../../widgets/pot_widget.dart';
import '../../widgets/weather_card.dart';
import 'botiga_page.dart';
import 'inventory_page.dart';
import '../../widgets/pot_info_sheet.dart';
import '../../widgets/seed_selection_sheet.dart';
import '../../models/seed_option.dart';

import 'package:provider/provider.dart';
import '../models/dades_usr.dart';

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

  void onTapPot(GardenPot pot) {
    if (!pot.occupied || pot.plant == null) {
      _showSeedSelection(pot);
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
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
            Navigator.pop(context);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(missatge)));
            _refreshGarden();
          } catch (e) {
            if (!mounted) return;
            Navigator.pop(context);
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
            Navigator.pop(context);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(missatge)));
            _refreshGarden();
          } catch (e) {
            if (!mounted) return;
            Navigator.pop(context);
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

  void _showSeedSelection(GardenPot pot) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return FutureBuilder<List<SeedOption>>(
          future: _gardenService.fetchSeeds(widget.username),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return Container(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 40),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            if (snap.hasError) {
              return Container(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 40),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Text(
                  "Error carregant llavors:\n${snap.error}",
                  textAlign: TextAlign.center,
                ),
              );
            }

            final seeds = snap.data ?? [];

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
      },
    );
  }

  int _gridColumns(double width) {
    if (width < 420) return 4;
    if (width < 900) return 4;
    return 5;
  }

  double _horizontalPadding(double width) {
    if (width < 360) return 8;
    if (width < 700) return 10;
    return 16;
  }

  double _gridSpacing(double width) {
    if (width < 360) return 8;
    if (width < 700) return 10;
    return 14;
  }

 double _sideIconWidth(double width) {
  if (width < 360) return 64;
  if (width < 700) return 78;
  return 90;
}

double _shopWidth(double width) {
  if (width < 360) return 130;
  if (width < 700) return 155;
  return 175;
}

  Widget _buildWeatherSection() {
    return FutureBuilder<WeatherInfo>(
      future: _weatherFuture,
      builder: (context, snap) {
        if (_weatherFuture == null ||
            snap.connectionState == ConnectionState.waiting) {
          return WeatherCard(
            nomEstacio: "",
            title: "Carregant meteo...",
            subtitle: "Espera un moment",
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
            title: "No s'ha pogut carregar la meteo",
            subtitle: "Toca per tornar-ho a provar",
            trailing: const Icon(Icons.warning_amber_rounded),
            onRefresh: _refreshWeather,
          );
        }

        final w = snap.data!;
        return WeatherCard(
          nomEstacio: w.stationName,
          title:
              "Temperatura: ${w.temp.toStringAsFixed(1)}°C | Precipitació: ${w.precipitation}",
          subtitle: "Vent: ${w.wind.toStringAsFixed(1)} m/s",
          trailing: const Icon(Icons.refresh),
          onRefresh: _refreshWeather,
        );
      },
    );
  }

  Widget _buildCoinsChip(int monedes) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            width: 22,
            height: 22,
            errorBuilder: (_, _, _) => const Icon(
              Icons.monetization_on,
              color: Colors.amber,
              size: 22,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$monedes',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D4037),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionArea({
  required double width,
  required String username,
}) {
  final sideBoxSize = width < 360 ? 50.0 : 58.0;
  final shopWidth = width < 360 ? 165.0 : 200.0;
  final shopHeight = width < 360 ? 115.0 : 135.0;

  return SizedBox(
     height: width < 360 ? 115 : 135,
    child: Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 2),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AlbumPage()),
                  );
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
            ],
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topRight,
              child: Transform.translate(
                offset: const Offset(16, 0),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const BotigaPage(),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: shopWidth,
                      height: shopHeight,
                      child: Image.asset(
                        'assets/images/botiga.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
              "Error carregant els tests:\n${snap.error}",
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }

      final pots = snap.data ?? [];

      if (pots.isEmpty) {
        return const Center(
          child: Text(
            "No hi ha tests disponibles",
            style: TextStyle(color: Colors.white),
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
          final usableHeight = totalHeight - 8;

          final itemWidth =
              (usableWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;

          final itemHeight =
              (usableHeight - (spacing * (rowCount - 1))) / rowCount;

          final aspectRatio = itemWidth / itemHeight;

          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(padding, 4, padding, 4),
            itemCount: pots.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: aspectRatio,
            ),
            itemBuilder: (context, index) {
              final pot = pots[index];
              return PotWidget(
                pot: pot,
                onTap: () => onTapPot(pot),
              );
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

        return Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/imatge_fondo1.png',
                fit: BoxFit.cover,
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      _horizontalPadding(width),
                      8,
                      _horizontalPadding(width),
                      4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildWeatherSection(),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: _buildCoinsChip(monedes),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildActionArea(
                   width: width,
                    username: username,
                  ),
                  const SizedBox(height: 25),
                  Expanded(
                    child: _buildPotsGrid(width),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );
}
}
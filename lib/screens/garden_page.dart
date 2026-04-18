import 'package:flutter/material.dart';
import 'package:meteo_garden/screens/album_page.dart';

import '../../models/garden.dart';
import '../../models/weather_info.dart';
import '../../services/garden_service.dart';
import '../../services/weather_service.dart';
import '../../widgets/pot_widget.dart';
import '../../widgets/weather_card.dart';
//import 'botiga_page.dart';
import 'inventory_page.dart';
import '../../widgets/pot_info_sheet.dart';
import '../../widgets/seed_selection_sheet.dart';
//import '../../models/seed_option.dart';
import '../../widgets/potion_selection_sheet.dart';
import 'calendar_page.dart';

import 'package:provider/provider.dart';
import '../models/dades_usr.dart';

import '../screens/botiga_page.dart';

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

  Future<void> onTapPot(GardenPot pot) async {
    if (!pot.occupied || pot.plant == null) {
      _showSeedSelection(pot);
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
        onPotion: () async {
          try {
            Navigator.pop(context);
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error carregant llavors: ${e.toString().replaceFirst('Exception: ', '')}",
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
        // 1. CAMBIAR A STRETCH: Fuerza a la fila a tener un límite de altura exacto
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ESQUERRA: icones a dalt
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

          const Spacer(), // Este Spacer horizontal está bien, separa izquierda de derecha.
          // DRETA: monedes a dalt, botiga a baix
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              // 2. AÑADIR SPACE BETWEEN: Empuja las monedas arriba y la tienda abajo automáticamente
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCoinsChip(monedes, width, height),

                // ¡BORRAMOS EL const Spacer() QUE HABÍA AQUÍ!
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

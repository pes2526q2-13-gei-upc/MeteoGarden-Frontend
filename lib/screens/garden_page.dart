import 'package:flutter/material.dart';

import '../../models/weather_info.dart';
import '../../services/weather_service.dart';
import '../../widgets/pot_widget.dart';
import '../../widgets/weather_card.dart';
import 'botiga_page.dart';

enum PotState { locked, readyToPlant, empty }

class GardenPage extends StatefulWidget {
  const GardenPage({super.key});

  @override
  State<GardenPage> createState() => _GardenPageState();
}

class _GardenPageState extends State<GardenPage> {
  late List<PotState> potStates;
  late Future<WeatherInfo> _weatherFuture;

  @override
  void initState() {
    super.initState();
    potStates = List.generate(16, (_) => PotState.empty);
    _weatherFuture = WeatherService.fetchCurrent(city: 'Òdena');
  }

  void _refreshWeather() {
    setState(() {
      _weatherFuture = WeatherService.fetchCurrent(city: 'Òdena');
    });
  }

  void onTapPot(int index) {
    final state = potStates[index];

    if (state == PotState.locked) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("🔒 Test bloquejat")));
      return;
    }

    setState(() {
      if (state == PotState.readyToPlant) {
        potStates[index] = PotState.empty;
      } else if (state == PotState.empty) {
        potStates[index] = PotState.readyToPlant;
      }
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Has pressionat el test $index")));
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        // Fons
        Positioned.fill(
          child: Image.asset(
            'assets/images/imatge_fondo1.png',
            fit: BoxFit.cover,
          ),
        ),

        // Targeta meteo a dalt
        Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          left: 12,
          right: 12,
          child: FutureBuilder<WeatherInfo>(
            future: _weatherFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return WeatherCard(
                  title: "Carregant meteo...",
                  subtitle: "Un moment 😄",
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
                  title: "No s'ha pogut carregar la meteo",
                  subtitle: "Toca per reintentar",
                  trailing: const Icon(Icons.warning_amber_rounded),
                  onRefresh: _refreshWeather,
                );
              }

              final w = snap.data!;
              return WeatherCard(
                title: "${w.temp.toStringAsFixed(1)}°C · ${w.condition}",
                subtitle: "Vent: ${w.wind.toStringAsFixed(1)} m/s",
                trailing: const Icon(Icons.refresh),
                onRefresh: _refreshWeather,
              );
            },
          ),
        ),

        // Grid de tests a baix
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SizedBox(
            height: h * 0.50,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 32,
                mainAxisSpacing: 32,
                childAspectRatio: 1,
              ),
              itemCount: 16,
              itemBuilder: (context, index) {
                return PotWidget(
                  index: index,
                  state: potStates[index],
                  onTap: () => onTapPot(index),
                );
              },
            ),
          ),
        ),

        // Botó imatge Botiga
        Positioned(
          right: 0,
          top: MediaQuery.of(context).size.height * 0.24,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const BotigaPage()));
              },
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Image.asset('assets/images/botiga.png', width: 150),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

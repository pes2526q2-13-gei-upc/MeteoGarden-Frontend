import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/plantes_desbl.dart';

class AlbumPage extends StatefulWidget {
  const AlbumPage({super.key});

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PlantProvider>().loadPlants();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlantProvider>();

    if (provider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Àlbum de plantes')),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: provider.plants.length,
        itemBuilder: (context, index) {
          final plant = provider.plants[index];

          return GestureDetector(
            onTap: plant.unlocked
                ? () => _openPlantDetail(plant)
                : null,
            child: Opacity(
              opacity: plant.unlocked ? 1.0 : 0.4,
              child: Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(plant.image, height: 80),
                    Text(plant.name),
                    if (!plant.unlocked)
                      const Icon(Icons.lock),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openPlantDetail(Plant plant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(plant.name),
        content: Image.network(plant.image),
      ),
    );
  }
}
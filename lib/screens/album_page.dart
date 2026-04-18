import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../models/dades_usr.dart';
import '../models/plantes_desbl.dart';
import '../models/url.dart';

class AlbumPage extends StatefulWidget {
  const AlbumPage({super.key});

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  String mapLanguage(String language) {
    switch (language) {
      case 'Català':
        return 'ca';
      case 'Español':
        return 'es';
      case 'English':
        return 'en';
      default:
        return 'en';
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<PlantProvider>().loadPlants(
          Provider.of<UserModel>(context, listen: false),
        );
      }
    });
  }

  Future<Map<String, dynamic>> _fetchDetallesPlanta(
      String scientificName,
      String lang,
      ) async {
    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/plants/info?scientificName=$scientificName&lang=$lang',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        "scientificName": data['scientificName'],
        "commonName": data['commonName'],
        "family": data['family'],
        "canFlower": data['canFlower'],
        "minTemperature": data['minTemperature'],
        "maxTemperature": data['maxTemperature'],
        "description": data['description'],
      };
    } else {
      throw Exception('Error carregant la informació de la planta');
    }
  }

  void _mostrarPopupDetalles(BuildContext context, String scientificName) {
    final user = Provider.of<UserModel>(context, listen:false);
    final lang = mapLanguage(user.language);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: FutureBuilder<Map<String, dynamic>>(
            future: _fetchDetallesPlanta(scientificName, lang),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Consultant enciclopèdia...'),
                    ],
                  ),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text('Error carregant detalls: ${snapshot.error}'),
                );
              }

              final data = snapshot.data!;
              final commonName = data['commonName'] ?? 'Desconeguda';
              final desc =
                  data['description'] ?? 'No hi ha descripció disponible.';
              final family = data['family'] ?? '-';
              final minTemp = data['minTemperature'];
              final maxTemp = data['maxTemperature'];
              final canFlower = data['canFlower'] == true;

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        commonName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$scientificName • Família: $family',
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[700],
                        ),
                      ),
                      const Divider(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (minTemp != null && maxTemp != null)
                            Column(
                              children: [
                                const Icon(
                                  Icons.thermostat,
                                  color: Colors.orange,
                                ),
                                const SizedBox(height: 4),
                                Text('$minTempº - $maxTempº'),
                              ],
                            ),
                          Column(
                            children: [
                              Icon(
                                canFlower ? Icons.local_florist : Icons.grass,
                                color: canFlower ? Colors.pink : Colors.green,
                              ),
                              const SizedBox(height: 4),
                              Text(canFlower ? 'Floreix' : 'No floreix'),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Descripció',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(desc),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Tancar'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _reloadPlants() async {
    await context.read<PlantProvider>().loadPlants(
      Provider.of<UserModel>(context, listen: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('El meu àlbum de plantes'),
      ),
      body: Consumer<PlantProvider>(
        builder: (context, plantProvider, child) {
          if (plantProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (plantProvider.plants.isEmpty) {
            return RefreshIndicator(
              onRefresh: _reloadPlants,
              child: ListView(
                children: const [
                  SizedBox(height: 180),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Encara no has descobert cap planta 🌱\nContinua explorant!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _reloadPlants,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: plantProvider.plants.length,
              itemBuilder: (context, index) {
                final planta = plantProvider.plants[index];
                final imageUrl = planta.image;
                final nombreCientifico = planta.name;

                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    _mostrarPopupDetalles(context, nombreCientifico);
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.green.withValues(alpha: 0.1),
                                child: const Icon(
                                  Icons.local_florist,
                                  size: 50,
                                  color: Colors.green,
                                ),
                              );
                            },
                          )
                              : Container(
                            color: Colors.green.withValues(alpha: 0.1),
                            child: const Icon(
                              Icons.local_florist,
                              size: 50,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            nombreCientifico,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
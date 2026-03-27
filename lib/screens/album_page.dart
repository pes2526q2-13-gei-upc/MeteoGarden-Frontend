import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dades_usr.dart'; 
import 'package:meteo_garden/models/plantes_desbl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/url.dart';

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
      if (mounted) {
        context.read<PlantProvider>().loadPlants(
          Provider.of<UserModel>(context, listen: false),
        );
      }
    });
  }

  // --- FUNCIÓN QUE SIMULA LA LLAMADA AL BACKEND DE PYTHON ---
  Future<Map<String, dynamic>> _fetchDetallesPlanta(String scientificName) async {
    // eliminar quan es puguin agafar noms cintifics del backend
    await Future.delayed(const Duration(seconds: 1));
    return {
      "scientificName": scientificName,
      "commonName": "Lavanda", // Simulando commonName.capitalize()
      "family": "Lamiaceae",
      "canFlower": true,
      "minTemperature": -5.0,
      "maxTemperature": 30.0,
      "description": "Planta aromática muy popular, conocida por su característico color morado y su uso en perfumería e infusiones.",
    };

/*  descomentar quan es puguin agafar noms cintifics del backend
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/plants/info?scientificName=$scientificName'),
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
    */
    
  }

  // --- FUNCIÓN PARA MOSTRAR EL POP-UP CON LOS DETALLES ---
  void _mostrarPopupDetalles(BuildContext context, String scientificName) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: FutureBuilder<Map<String, dynamic>>(
            future: _fetchDetallesPlanta(scientificName),
            builder: (context, snapshot) {
              // 1. Mientras carga...
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Consultando enciclopedia...'),
                    ],
                  ),
                );
              }

              // 2. Si hay un error...
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text('Error al cargar detalles: ${snapshot.error}'),
                );
              }

              // 3. Si los datos llegan correctamente...
              final data = snapshot.data!;
              final commonName = data['commonName'] ?? 'Desconocido';
              final desc = data['description'] ?? 'No hay descripción disponible.';
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
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$scientificName • Familia: $family',
                        style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey[700]),
                      ),
                      const Divider(height: 32),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (minTemp != null && maxTemp != null)
                            Column(
                              children: [
                                const Icon(Icons.thermostat, color: Colors.orange),
                                const SizedBox(height: 4),
                                Text('$minTempº - $maxTempº'),
                              ],
                            ),
                          Column(
                            children: [
                              Icon(
                                canFlower ? Icons.local_florist : Icons.grass, 
                                color: canFlower ? Colors.pink : Colors.green
                              ),
                              const SizedBox(height: 4),
                              Text(canFlower ? 'Florece' : 'No florece'),
                            ],
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      const Text(
                        'Descripción',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(desc),
                      
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cerrar'),
                        ),
                      )
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

  // --- CONSTRUCCIÓN DE LA PANTALLA PRINCIPAL ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Álbum de Plantas'),
      ),
      body: Consumer<PlantProvider>(
        builder: (context, plantProvider, child) {
          // Si está cargando la lista inicial de plantas
          if (plantProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Si la lista está vacía (como se ve en la captura de pantalla que pasaste)
          if (plantProvider.plants.isEmpty) {
            return const Center(
              child: Text(
                'Aún no has descubierto ninguna planta.\n¡Sigue explorando!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // Cuadrícula de plantas
          return GridView.builder(
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
              
              // AHORA SÍ: Accedemos como atributos de objeto
              final imageUrl = planta.image;
              final nombreCientifico = planta.name;

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  // Abrimos el popup con el nombre científico de ESTA planta
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
                        child: Image.network(
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
          );
        },
      ),
    );
  }
}
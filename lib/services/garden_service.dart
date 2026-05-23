import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/garden.dart';
import '../models/seed_option.dart';
import '../models/url.dart';
import 'package:flutter/foundation.dart';

class PlantingResult {
  final String message;
  final int potNumber;
  final String scientificName;
  final String commonName;
  final String growthPhase;
  final double healthLevel;
  final double waterLevel;
  final String plantedAt;
  final int remainingSeeds;

  PlantingResult({
    required this.message,
    required this.potNumber,
    required this.scientificName,
    required this.commonName,
    required this.growthPhase,
    required this.healthLevel,
    required this.waterLevel,
    required this.plantedAt,
    required this.remainingSeeds,
  });

  factory PlantingResult.fromJson(Map<String, dynamic> json) => PlantingResult(
    message: json['message'] as String,
    potNumber: json['pot_number'] as int,
    scientificName: json['plant']['scientificName'] as String,
    commonName: json['plant']['commonName'] as String,
    growthPhase: json['growthPhase'] as String,
    healthLevel: (json['healthLevel'] as num).toDouble(),
    waterLevel: (json['waterLevel'] as num).toDouble(),
    plantedAt: json['plantedAt'] as String,
    remainingSeeds: json['remainingSeeds'] as int,
  );
}

class GardenService {
  GardenService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Map<String, String> _headers(String token) => {
    'Authorization': 'Token $token',
    'Content-Type': 'application/json',
  };

  Future<List<GardenPot>> fetchGardenPlants({
    required String username,
    required String gardenName,
  }) async {
    final response = await _client.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/users/$username/gardens/$gardenName/plants/',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => GardenPot.fromJson(e)).toList();
    }
    throw Exception('Error carregant els tests: ${response.statusCode}');
  }

  Future<GardenPot> fetchPotStatus({
    required String username,
    required String gardenName,
    required int potNumber,
  }) async {
    final response = await _client.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/users/$username/gardens/$gardenName/pots/$potNumber/plant/',
      ),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return GardenPot.fromJson(data);
    }

    throw Exception(
      data['message'] ?? data['error'] ?? 'Error carregant el test.',
    );
  }

  Future<String> waterPlant({
    required String username,
    required String gardenName,
    required int potNumber,
    required String token,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/users/$username/gardens/$gardenName/pots/$potNumber/water/',
    );

    final response = await _client.patch(url, headers: _headers(token));

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['message'] ?? 'Plant watered successfully.';
    } else {
      throw Exception(
        data['message'] ?? data['error'] ?? 'Error watering plant.',
      );
    }
  }

  Future<List<SeedOption>> fetchSeeds(String username) async {
    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/api/users/$username/seeds/'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => SeedOption.fromJson(e)).toList();
    }

    throw Exception('Error carregant llavors: ${response.statusCode}');
  }
Future<List<ProductItem>> fetchProducts(String username) async {
  final url = Uri.parse('${ApiConfig.baseUrl}/api/users/$username/products/');

  debugPrint('INVENTORY REQUEST URL: $url');

  final response = await _client.get(url);

  debugPrint('INVENTORY STATUS CODE: ${response.statusCode}');
  debugPrint('INVENTORY RAW BODY: ${response.body}');

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);

    debugPrint('INVENTORY DECODED DATA: $data');

    for (final item in data) {
      debugPrint('PRODUCT ITEM FROM BACK: $item');
      debugPrint('productName: ${item['productName']}');
      debugPrint('displayName: ${item['displayName']}');
      debugPrint('display_name: ${item['display_name']}');
      debugPrint('description: ${item['description']}');
      debugPrint('displayDescription: ${item['displayDescription']}');
      debugPrint('display_description: ${item['display_description']}');
    }

    return data.map((e) => ProductItem.fromJson(e)).toList();
  }

  throw Exception('Error carregant pocions: ${response.statusCode}');
}

  Future<String> applyPotion({
  required String username,
  required String gardenName,
  required int potNumber,
  required String productName,
  required String token,
}) async {
  final url = Uri.parse('${ApiConfig.baseUrl}/api/use_product/');

  final response = await _client.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
    },
    body: jsonEncode({
      'pot_number': potNumber,
      'product_name': productName,
      'username': username,
      'garden_name': gardenName,
    }),
  );

  final data = jsonDecode(utf8.decode(response.bodyBytes));

  if (response.statusCode != 200 || data['error'] != null) {
    throw Exception(data['error'] ?? 'Error aplicant la poció');
  }

  final isInstant = data['isInstant'] == true;

  final product =
      data['displayName'] ??
      data['display_name'] ??
      data['product'] ??
      productName;

  if (isInstant) {
    return 'Poció $product aplicada correctament';
  } else {
    return 'Efecte $product activat';
  }
}

  Future<PlantingResult> plantSeed({
    required String username,
    required String gardenName,
    required int potNumber,
    required String scientificName,
    required String token,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/users/$username/gardens/$gardenName/pots/$potNumber/planting/',
    );

    final response = await _client.post(
      url,
      headers: _headers(token),
      body: jsonEncode({'scientificName': scientificName}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return PlantingResult.fromJson(data);
    } else {
      throw Exception(
        data['message'] ?? data['error'] ?? 'Error plantant la llavor.',
      );
    }
  }

  Future<String> collectPlant({
    required String username,
    required String gardenName,
    required int potNumber,
    required String scientificName,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/users/$username/gardens/$gardenName/pots/$potNumber/collect/',
    );

    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'plant': scientificName}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['message'] ?? 'Planta recollida correctament.';
    } else {
      throw Exception(
        data['message'] ?? data['error'] ?? 'Error recollint la planta.',
      );
    }
  }

  Future<String> deletePlant({
    required String username,
    required String gardenName,
    required int potNumber,
    required String token,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/users/$username/gardens/$gardenName/pots/$potNumber/delete/',
    );

    final response = await _client.delete(url, headers: _headers(token));

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['message'] ?? 'Plant deleted successfully.';
    } else {
      throw Exception(data['error'] ?? 'Error deleting plant.');
    }
  }

  Future<Map<String, dynamic>> fetchPlantDetails(
    String scientificName,
    String lang,
  ) async {
    final response = await _client.get(
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
      throw Exception('plant_info_load_error');
    }
  }
}

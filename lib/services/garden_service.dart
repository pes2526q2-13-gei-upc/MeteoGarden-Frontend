import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/garden.dart';
import '../models/seed_option.dart';
import '../models/url.dart';

class ProductItem {
  final String productName;
  final int amount;

  ProductItem({required this.productName, required this.amount});

  factory ProductItem.fromJson(Map<String, dynamic> json) => ProductItem(
    productName: json['productName'] as String,
    amount: json['amount'] as int,
  );
}

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
  GardenService();

  Future<List<GardenPot>> fetchGardenPlants({
    required String username,
    required String gardenName,
  }) async {
    final response = await http.get(
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

  Future<String> waterPlant({
    required String username,
    required String gardenName,
    required int potNumber,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/users/$username/gardens/$gardenName/pots/$potNumber/water/',
    );

    final response = await http.patch(url);
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
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/users/$username/seeds/'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => SeedOption.fromJson(e)).toList();
    }

    throw Exception('Error carregant llavors: ${response.statusCode}');
  }

  Future<List<ProductItem>> fetchProducts(String username) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/users/$username/products/'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ProductItem.fromJson(e)).toList();
    }

    throw Exception('Error carregant pocions: ${response.statusCode}');
  }

  Future<PlantingResult> plantSeed({
    required String username,
    required String gardenName,
    required int potNumber,
    required String scientificName,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/users/$username/gardens/$gardenName/pots/$potNumber/planting/',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
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

    final response = await http.post(
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
}

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/garden.dart';
import '../models/seed_option.dart';

class ProductItem {
  final String productName;
  final int amount;

  ProductItem({
    required this.productName,
    required this.amount,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) => ProductItem(
        productName: json['productName'] as String,
        amount: json['amount'] as int,
      );
}

class GardenService {
  final String baseUrl;

  GardenService({required this.baseUrl});

  Future<List<GardenPot>> fetchGardenPlants({
    required String username,
    required String gardenName,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/$username/gardens/$gardenName/plants/'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => GardenPot.fromJson(e)).toList();
    }

    throw Exception('Error carregant els tests: ${response.statusCode}');
  }

  Future<void> waterPlant({
    required String username,
    required String gardenName,
    required int potNumber,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/api/users/$username/gardens/$gardenName/pots/$potNumber/water/',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Error regant la planta: ${response.statusCode}');
    }
  }

  Future<List<SeedOption>> fetchSeeds(String username) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/$username/seeds/'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => SeedOption.fromJson(e)).toList();
    }

    throw Exception('Error carregant llavors: ${response.statusCode}');
  }

  Future<List<ProductItem>> fetchProducts(String username) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/$username/products/'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ProductItem.fromJson(e)).toList();
    }

    throw Exception('Error carregant pocions: ${response.statusCode}');
  }
}
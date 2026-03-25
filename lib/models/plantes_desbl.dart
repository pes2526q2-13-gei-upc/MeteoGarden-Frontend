import 'package:flutter/material.dart';
import '../models/url.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class Plant {
  final String id;
  final String name;
  final String image;
  bool unlocked;

  Plant({
    required this.id,
    required this.name,
    required this.image,
    this.unlocked = false,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'].toString(),
      name: json['name'],
      image: json['image'],
      unlocked: json['unlocked'] ?? false,
    );
  }
}

class PlantProvider extends ChangeNotifier {

  Future<List<Plant>> fetchPlants() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/album/'));
    // de moment aquesta ult retorna una llista de url a img de les plantes desbloquejades

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data as List)
          .map((e) => Plant.fromJson(e))
          .toList();
    } else {
      throw Exception('Error carregant plantes');
    }
  }

  List<Plant> plants = [];
  bool isLoading = false;

  Future<void> loadPlants() async {
    isLoading = true;
    notifyListeners();

    try {
      plants = await fetchPlants();
    } catch (e) {
      print(e);
    }

    isLoading = false;
    notifyListeners();
  }

  void unlockPlant(String id) {
    final plant = plants.firstWhere((p) => p.id == id);
    plant.unlocked = true;
    notifyListeners();
  }
}
import 'package:flutter/material.dart';
import '../models/url.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:meteo_garden/models/dades_usr.dart';


class Plant {
  final String name;
  final String image;

  Plant({
    required this.name,
    required this.image,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      name: json['name'],
      image: json['image'],
    );
  }
}

class PlantProvider extends ChangeNotifier {

  Future<List<Plant>> fetchPlants(UserModel user) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/users/${user.username}/album/'),
      headers: { 'Authorization': 'Token ${user.token}' },
    );

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

  Future<void> loadPlants(UserModel user) async {
    isLoading = true;
    notifyListeners();
    /*crida a l'endpoint de les plantes del album
    try {
      plants = await fetchPlants(user);
    } catch (e) {
      print(e);
    }
    */
    
    plants = _mockPlants();

    isLoading = false;
    notifyListeners();
  }

  List<Plant> _mockPlants() {
    return [
      Plant(name: "Monstera", image: "https://..."),
      Plant(name: "Cactus", image: "https://..."),
      Plant(name: "Ficus", image: "https://..."),
      Plant(name: "Monstera", image: "https://..."),
      Plant(name: "Cactus", image: "https://..."),
      Plant(name: "Ficus", image: "https://..."),
    ];
  }
}
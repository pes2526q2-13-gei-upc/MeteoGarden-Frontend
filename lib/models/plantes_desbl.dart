import 'package:flutter/material.dart';
import '../models/url.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:meteo_garden/models/dades_usr.dart';

class Plant {
  final String name;
  final String image;

  Plant({required this.name, required this.image});

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(name: json['name'], image: json['image']);
  }
}

class PlantProvider extends ChangeNotifier {
  PlantProvider({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _notifyIfActive() {
    if (!_disposed) notifyListeners();
  }

  Future<List<Plant>> fetchPlants(UserModel user) async {
    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/api/users/${user.username}/album/'),
      headers: {'Authorization': 'Token ${user.token}'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data is List ? data : (data['results'] as List? ?? []);

      return items.map((e) => Plant.fromJson(e)).toList();
    } else {
      throw Exception('Error carregant plantes');
    }
  }

  List<Plant> plants = [];
  bool isLoading = false;

  Future<void> loadPlants(UserModel user) async {
    isLoading = true;
    _notifyIfActive();

    try {
      plants = await fetchPlants(user);
    } catch (e) {
      plants = [];
    }

    isLoading = false;
    _notifyIfActive();
  }
}

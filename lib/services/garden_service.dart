import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/garden.dart';

class GardenService {
  static const String baseUrl = "http://10.0.2.2:8000/api";

  static Future<List<GardenPot>> fetchGardenPlants({
    required String username,
    required String gardenName,
  }) async {
    final url = "$baseUrl/users/$username/gardens/$gardenName/plants/";
    print("URL -> $url");

    final response = await http.get(Uri.parse(url));

    print("STATUS -> ${response.statusCode}");
    print("BODY -> ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Error ${response.statusCode}: ${response.body}");
    }

    try {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => GardenPot.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Error parsejant JSON: $e");
    }
  }

  static Future<Map<String, dynamic>> waterPlant({
    required String username,
    required String gardenName,
    required int potNumber,
  }) async {
    final url =
        "$baseUrl/users/$username/gardens/$gardenName/pots/$potNumber/water/";

    final response = await http.patch(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception(
        "Error regant planta: ${response.statusCode} ${response.body}",
      );
    }

    return jsonDecode(response.body);
  }
}

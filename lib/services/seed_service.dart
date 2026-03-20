//import 'dart:convert';
//import 'package:http/http.dart' as http;
import '../models/seed_option.dart';

class SeedService {
  //static const String baseUrl = "http://10.0.2.2:8000/api";
  // si algun dia proves a web/Windows: 127.0.0.1 en lloc de 10.0.2.2

  static Future<List<SeedOption>> fetchSeeds({required String username}) async {
    /*
    final url = "$baseUrl/users/$username/seeds/";
    print("SEEDS URL -> $url");

    final response = await http.get(Uri.parse(url));

    print("SEEDS STATUS -> ${response.statusCode}");
    print("SEEDS BODY -> ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Error carregant llavors: ${response.statusCode}");
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => SeedOption.fromJson(e)).toList();
    */
    return [
      SeedOption(scientificName: "Rosa canina", amount: 3),
      SeedOption(scientificName: "Lavandula angustifolia", amount: 5),
      SeedOption(scientificName: "Helianthus annuus", amount: 2),
    ];
  }
}

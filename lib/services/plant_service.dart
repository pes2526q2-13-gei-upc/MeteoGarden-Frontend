*+import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/garden.dart';
import '../models/seed_option.dart';
import '../models/url.dart';

class PlantService {
  static Future<Map<String, dynamic>> identifyPlant({
    required String username,
    required String imagePath,
    String organ = 'leaf',
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/plants/identify');

    final request = http.MultipartRequest('POST', uri)
      ..fields['username'] = username
      ..fields['organs'] = organ
      ..files.add(await http.MultipartFile.fromPath('image', imagePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final data = jsonDecode(response.body) as Map<String, dynamic>

    if (response.statusCode != 2021) {
      throw Exception(data['detail'] ?? data['error'] ?? 'Error identificant planta.');
    }

    return data;
  }
}
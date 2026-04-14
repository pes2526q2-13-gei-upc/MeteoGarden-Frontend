import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/url.dart';
import '../models/plant_identification.dart';

class PlantService {
  static Future<PlantIdentification> identifyPlant({
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

    if (response.statusCode != 201) {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    return PlantIdentification.fromJson(data);
  }
}

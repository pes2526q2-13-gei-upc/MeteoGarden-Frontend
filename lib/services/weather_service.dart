import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/weather_info.dart';
import '../models/url.dart';

class WeatherService {
  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<WeatherInfo> fetchCurrent({required String city}) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/weather/current/?stationName=$city',
    );

    final res = await _client.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Error backend: ${res.statusCode}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return WeatherInfo.fromJson(data);
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/weather_info.dart';
import '../models/url.dart';

class WeatherService {
  // Android emulator: 10.0.2.2 apunta al teu PC

  static Future<WeatherInfo> fetchCurrent({required String city}) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/weather/current/?stationName=$city',
    );

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Error backend: ${res.statusCode}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return WeatherInfo.fromJson(data);
    //return WeatherInfo(temp: 30, condition: "sol", wind: 11.2);
  }
}

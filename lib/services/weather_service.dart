//import 'dart:convert';
//import 'package:http/http.dart' as http;

import '../models/weather_info.dart';

class WeatherService {
  
  // Android emulator: 10.0.2.2 apunta al teu PC
<<<<<<< Updated upstream
  //static const String _baseUrl = 'http://10.0.2.2:8000';
=======
  // En local: 127.0.0.1:8000
  static const String _baseUrl = 'http://127.0.0.1:8000';
>>>>>>> Stashed changes

  static Future<WeatherInfo> fetchCurrent({required String city}) async {
    /*
    final uri = Uri.parse('$_baseUrl/api/weather/current/?city=$city');

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Error backend: ${res.statusCode}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return WeatherInfo.fromJson(data);
    */
    return WeatherInfo(temp: 30, condition: "sol", wind: 11.2);
  }
}

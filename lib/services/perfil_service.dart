//import 'dart:convert';
//import 'package:http/http.dart' as http;

import '../models/perfil_info.dart';

class PerfilService {
  //static const String _baseUrl = 'http://10.0.2.2:8000';

  static Future<PerfilInfo> fetchMe() async {
    /*
    final uri = Uri.parse('$_baseUrl/api/profile/me/');

    // Si tens token, aquí és on l’afegeixes:
    // final res = await http.get(uri, headers: {'Authorization': 'Bearer $token'});
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Error backend: ${res.statusCode}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return PerfilInfo.fromJson(data);
    */
    return PerfilInfo(
        username: 'Jana',
        email: 'jana@meteogarden.cat',
        city: 'Òdena',
        level: 6,
        coins: 245,
        plantsDiscovered: 17,
      );
  }
}
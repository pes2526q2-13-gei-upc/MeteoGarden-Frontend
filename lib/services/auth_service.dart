import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
/*
  static Future<bool> login(String username, String password) async {

    final url = Uri.parse("https://api.tuservidor.com/login"); // posar la URL del backend

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "username": username,
        "password": password
      }),
    );

    if (response.statusCode == 200) {
      // aqui s'ha de guardar tots els 
      final data = jsonDecode(response.body);

      print(data["token"]);

      return true;

    } else {
      return false;
    }
  }
  */
}
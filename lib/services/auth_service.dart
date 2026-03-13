import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class AuthService {

  static Future<bool> login(String username, String password) async {

    final url = Uri.parse("http://127.0.0.1:8000/api/login/"); // url del endpoint de login al backend

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
      debugPrint("Error: ${response.body}");
      return false;
    }
  }

}
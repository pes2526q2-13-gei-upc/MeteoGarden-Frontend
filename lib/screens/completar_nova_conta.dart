import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:meteo_garden/models/dades_usr.dart';
import '../models/url.dart';
import 'home_shell.dart';

class City {
  final String code;
  final String name;

  City({required this.code, required this.name});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(code: json['code'], name: json['name']);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is City && runtimeType == other.runtimeType && code == other.code;

  @override
  int get hashCode => code.hashCode;
}

class CompleteGoogleProfilePage extends StatefulWidget {
  const CompleteGoogleProfilePage({super.key});

  @override
  State<CompleteGoogleProfilePage> createState() =>
      _CompleteGoogleProfilePageState();
}

class _CompleteGoogleProfilePageState
    extends State<CompleteGoogleProfilePage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController gardenController = TextEditingController();
  final TextEditingController citySearchController = TextEditingController();

  List<City> cities = [];
  City? selectedCity;
  String? language;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCities();
  }

  Future<void> fetchCities() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/stations/'), // potser s'ha de canviar la ruta
    );

    if (response.statusCode == 200) {
      setState(() {
        cities = (jsonDecode(response.body) as List)
            .map((e) => City.fromJson(e))
            .toList();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  void _submit() async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/complete-profile/");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization":
            "Token ${Provider.of<UserModel>(context, listen: false).token}",
      },
      body: jsonEncode({
        'username': usernameController.text,
        'password': passwordController.text,
        'city': selectedCity?.name,
        'language': language,
        'stationCode': selectedCity?.code,
        'gardenName': gardenController.text,
      }),
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeShell()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error completant perfil')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final decoration = InputDecoration(
      filled: true,
      fillColor: Colors.green.withValues(alpha: 0.04),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Completar perfil')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // USERNAME
                  TextField(
                    controller: usernameController,
                    decoration:
                        decoration.copyWith(labelText: 'Nom d\'usuari'),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: passwordController,
                    decoration:
                        decoration.copyWith(labelText: 'Contrasenya'),
                  ),
                  const SizedBox(height: 16),

                  // CIUDAD (con buscador 🔥)
                  DropdownMenu<City>(
                    controller: citySearchController,
                    enableFilter: true,
                    requestFocusOnTap: true,
                    label: const Text('Ciutat'),
                    inputDecorationTheme: InputDecorationTheme(
                      filled: true,
                      fillColor: Colors.green.withValues(alpha: 0.04),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    dropdownMenuEntries: cities.map((city) {
                      return DropdownMenuEntry<City>(
                        value: city,
                        label: city.name,
                      );
                    }).toList(),
                    onSelected: (city) {
                      setState(() {
                        selectedCity = city;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // IDIOMA
                  DropdownButtonFormField<String>(
                    value: language,
                    decoration: decoration.copyWith(labelText: 'Idioma'),
                    items: ['Català', 'Castellano', 'English']
                        .map((lang) =>
                            DropdownMenuItem(value: lang, child: Text(lang)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        language = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // JARDÍN
                  TextField(
                    controller: gardenController,
                    decoration:
                        decoration.copyWith(labelText: 'Nom del jardí'),
                  ),

                  const Spacer(),

                  FilledButton(
                    onPressed: _submit,
                    child: const Text('Continuar'),
                  ),
                ],
              ),
            ),
    );
  }
}
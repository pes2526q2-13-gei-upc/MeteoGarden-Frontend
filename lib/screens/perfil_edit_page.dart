import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/perfil_info.dart';
import 'package:provider/provider.dart';
import 'package:meteo_garden/models/dades_usr.dart';
import '../models/url.dart';

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

class PerfilEditPage extends StatefulWidget {
  final PerfilInfo profile;

  const PerfilEditPage({super.key, required this.profile});

  @override
  State<PerfilEditPage> createState() => _PerfilEditPageState();
}

class _PerfilEditPageState extends State<PerfilEditPage> {
  late TextEditingController usernameController;
  final TextEditingController ciutatSearchController = TextEditingController();

  List<City> cities = [];
  City? selectedCity;
  bool isLoading = true;
  String? language;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController(text: widget.profile.username);
    const validLanguages = ['Català', 'Castellano', 'English'];
    if (validLanguages.contains(widget.profile.language)) {
      language = widget.profile.language;
    } else {
      language = null;
    }
    fetchCities();
  }

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  Future<void> fetchCities() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/stations/'),
      );

      if (response.statusCode == 200) {
        final List<City> fetchedCities = (jsonDecode(response.body) as List)
            .map((e) => City.fromJson(e))
            .toList();

        setState(() {
          cities = fetchedCities;
          selectedCity = null;
          for (var c in cities) {
            if (c.name == widget.profile.city) {
              selectedCity = c;
              ciutatSearchController.text = c.name;
              break;
            }
          }
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        debugPrint("Error a l'API: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error carregant ciutats: $e");
    }
  }

  void _actualitzar() async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/edit_profile/");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization":
            "Token ${Provider.of<UserModel>(context, listen: false).token}",
      },
      body: jsonEncode({
        'username': usernameController.text,
        'city': selectedCity?.name,
        'language': language,
        'stationCode': selectedCity?.code,
      }),
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      debugPrint("perfil actualitzat");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualitzat')),
      );

      Provider.of<UserModel>(context, listen: false).updateProfile(
        newUsername: usernameController.text,
        newCity: selectedCity?.name,
        newLanguage: language,
      );

      Navigator.pop(context);
    } else {
      debugPrint("Error: ${response.body}");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error actualitzant el perfil')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Estil refinat per als camps de text
    final defaultDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.grey.withValues(alpha: 0.08),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF166534), width: 1.5),
      ),
      labelStyle: TextStyle(color: Colors.black.withValues(alpha: 0.6)),
    );

    return Scaffold(
      extendBodyBehindAppBar: true, // Permet que el fons pugi fins a dalt
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Modificar perfil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
      ),
      body: Stack(
        children: [
          // 1. Fons d'imatge (MATEIX QUE A PERFIL)
          Positioned.fill(
            child: Image.asset(
              'assets/images/imatge_fondo1.png',
              fit: BoxFit.cover,
            ),
          ),
          // 2. Degradat (MATEIX QUE A PERFIL)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.50), // Més fosc a dalt per llegir el títol
                    Colors.green.withValues(alpha: 0.10),
                    Colors.white.withValues(alpha: 0.95),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // 3. Contingut principal
          SafeArea(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF166534)),
                  )
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                            color: Colors.black.withValues(alpha: 0.08),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.edit_note_rounded, color: Color(0xFF166534), size: 28),
                              const SizedBox(width: 8),
                              Text(
                                "Dades d'usuari",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // CAMP 1: USUARI
                          TextField(
                            controller: usernameController,
                            decoration: defaultDecoration.copyWith(
                              labelText: 'Nom d\'usuari',
                              prefixIcon: const Icon(Icons.person_outline_rounded),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // CAMP 2: CIUTAT
                          DropdownMenu<City>(
                            initialSelection: selectedCity,
                            controller: ciutatSearchController,
                            requestFocusOnTap: true,
                            enableFilter: true,
                            expandedInsets: EdgeInsets.zero, // Ocupa tot l'ample
                            label: const Text('Ciutat'),
                            leadingIcon: const Icon(Icons.location_city_rounded),
                            inputDecorationTheme: InputDecorationTheme(
                              filled: true,
                              fillColor: Colors.grey.withValues(alpha: 0.08),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            dropdownMenuEntries: cities.map<DropdownMenuEntry<City>>((City city) {
                              return DropdownMenuEntry<City>(
                                value: city,
                                label: city.name,
                              );
                            }).toList(),
                            onSelected: (City? city) {
                              setState(() {
                                selectedCity = city;
                              });
                            },
                          ),
                          const SizedBox(height: 20),

                          // CAMP 3: IDIOMA
                          DropdownButtonFormField<String>(
                            value: language,
                            decoration: defaultDecoration.copyWith(
                              labelText: 'Idioma',
                              prefixIcon: const Icon(Icons.language_rounded),
                            ),
                            icon: const Icon(Icons.arrow_drop_down_rounded),
                            items: ['Català', 'Castellano', 'English']
                                .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                language = value;
                              });
                            },
                          ),
                          
                          const SizedBox(height: 40),

                          // BOTÓ GUARDAR
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _actualitzar,
                              icon: const Icon(Icons.save_rounded),
                              label: const Text(
                                'Guardar canvis',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF166534), // Verd fosc
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
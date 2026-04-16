import 'package:flutter/material.dart';
import 'package:meteo_garden/screens/home_shell.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:meteo_garden/models/dades_usr.dart';
import '../models/url.dart';

class CreaNovaConta extends StatefulWidget {
  const CreaNovaConta({super.key});

  @override
  State<CreaNovaConta> createState() => _CreaNovaContaState();
}

class City {
  final String code;
  final String name;

  City({required this.code, required this.name});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(code: json['code'], name: json['name']);
  }

  // MOLT IMPORTANT: Perquè el Dropdown sàpiga comparar les ciutats
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is City && runtimeType == other.runtimeType && code == other.code;

  @override
  int get hashCode => code.hashCode;
}

class _CreaNovaContaState extends State<CreaNovaConta> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nomjardiController = TextEditingController();

  // Afegim aquest controlador pel buscador del DropdownMenu
  final TextEditingController ciutatSearchController = TextEditingController();

  String? language;
  List<City> cities = [];
  City? selectedCity;
  bool isLoadingCities = true;

  @override
  void initState() {
    super.initState();
    fetchCities();
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    nomjardiController.dispose();
    ciutatSearchController.dispose();
    super.dispose();
  }

  Future<void> fetchCities() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/stations/'),
      );

      if (response.statusCode == 200) {
        setState(() {
          cities = (jsonDecode(response.body) as List)
              .map((e) => City.fromJson(e))
              .toList();
          isLoadingCities = false;
        });
      } else {
        setState(() => isLoadingCities = false);
      }
    } catch (e) {
      setState(() => isLoadingCities = false);
      debugPrint("Error carregant ciutats: $e");
    }
  }

  void _submit() async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/register/");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'username': usernameController.text,
        'password': passwordController.text,
        'email': emailController.text,
        'city': selectedCity?.name,
        'language': language,
        'stationCode': selectedCity?.code,
        'gardenName': nomjardiController.text,
      }),
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      debugPrint("Cuenta creada");

      final data = jsonDecode(response.body);
      final token = data['token'];

      Provider.of<UserModel>(context, listen: false).setToken(token);

      await _fetchAndSaveProfile(token);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compte creat correctament!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeShell()),
      );
    } else {
      debugPrint("Error: ${response.body}");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error creant el compte')));
    }
  }

  Future<void> _fetchAndSaveProfile(String token) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/get_profile/');

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List<String> gardenNames = (data['gardens'] as List<dynamic>)
          .map((g) => g['gardenName'] as String)
          .toList();

      Provider.of<UserModel>(context, listen: false).setProfile(
        newUsername: data['username'] ?? '',
        newEmail: data['email'] ?? '',
        newCity: data['city'] ?? '',
        newLanguage: data['language'] ?? '',
        newLastEntry: data['lastEntry'] ?? '',
        newNumPlantsCollected: data['numPlantsCollected'] ?? 0,
        newMonedes: data['numCoins'] ?? 0,
        newGardens: gardenNames,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No s\'ha pogut carregar el perfil')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Estil refinat per als camps de text (Mateix que PerfilEditPage)
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
      extendBodyBehindAppBar: true, // El fons puja fins a dalt
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Crear compte',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
      ),
      body: Stack(
        children: [
          // 1. Fons d'imatge
          Positioned.fill(
            child: Image.asset(
              'assets/images/imatge_fondo1.png', // Assegura't de tenir aquesta imatge
              fit: BoxFit.cover,
            ),
          ),
          // 2. Degradat fosc a dalt, clar a baix
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.60),
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
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Benvingut a Meteo Garden",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF166534),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Omple les teves dades per començar",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // CAMP 1: USUARI
                        TextField(
                          controller: usernameController,
                          decoration: defaultDecoration.copyWith(
                            labelText: 'Nom d\'usuari',
                            prefixIcon: const Icon(
                              Icons.person_outline_rounded,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // CAMP 2: EMAIL
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: defaultDecoration.copyWith(
                            labelText: 'Correu electrònic',
                            prefixIcon: const Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // CAMP 3: CIUTAT (Ara amb DropdownMenu i menuHeight controlat)
                        isLoadingCities
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF166534),
                                ),
                              )
                            : DropdownMenu<City>(
                                initialSelection: selectedCity,
                                controller: ciutatSearchController,
                                requestFocusOnTap: true,
                                enableFilter: true,
                                expandedInsets: EdgeInsets.zero,
                                menuHeight:
                                    250, // <-- Això evita que ocupi tota la pantalla
                                label: const Text('Ciutat'),
                                leadingIcon: const Icon(
                                  Icons.location_city_rounded,
                                ),
                                inputDecorationTheme: InputDecorationTheme(
                                  filled: true,
                                  fillColor: Colors.grey.withValues(
                                    alpha: 0.08,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                dropdownMenuEntries: cities
                                    .map<DropdownMenuEntry<City>>((City city) {
                                      return DropdownMenuEntry<City>(
                                        value: city,
                                        label: city.name,
                                      );
                                    })
                                    .toList(),
                                onSelected: (City? city) {
                                  setState(() {
                                    selectedCity = city;
                                  });
                                },
                              ),
                        const SizedBox(height: 16),

                        // CAMP 4: CONTRASENYA
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: defaultDecoration.copyWith(
                            labelText: 'Contrasenya',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // CAMP 5: IDIOMA
                        DropdownButtonFormField<String>(
                          value: language,
                          decoration: defaultDecoration.copyWith(
                            labelText: 'Idioma',
                            prefixIcon: const Icon(Icons.language_rounded),
                          ),
                          icon: const Icon(Icons.arrow_drop_down_rounded),
                          items: ['Català', 'Castellano', 'English']
                              .map(
                                (lang) => DropdownMenuItem(
                                  value: lang,
                                  child: Text(lang),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              language = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // CAMP 6: NOM DEL JARDÍ
                        TextField(
                          controller: nomjardiController,
                          decoration: defaultDecoration.copyWith(
                            labelText: 'Nom del teu jardí',
                            prefixIcon: const Icon(
                              Icons.local_florist_outlined,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // BOTÓ CREAR COMPTE
                        FilledButton.icon(
                          onPressed: _submit,
                          icon: const Icon(Icons.check_circle_outline_rounded),
                          label: const Text(
                            'Crear compte',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF166534,
                            ), // Verd fosc
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

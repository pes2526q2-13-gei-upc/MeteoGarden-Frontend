import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../models/dades_usr.dart';
import 'package:meteo_garden/screens/home_shell.dart';
import 'login_page.dart';
import 'package:http/http.dart' as http;
import '../models/url.dart';
import 'dart:convert';
import 'package:meteo_garden/l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Leemos el token guardado
    String? token = await storage.read(key: 'auth_token');

    if (token != null) {
      if (mounted) {
        Provider.of<UserModel>(context, listen: false).setToken(token);

        await _fetchAndSaveProfile(token);
        if (!mounted) return;
        // Vamos a la Home y borramos la Splash del historial
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeShell()),
        );
      }
    } else {
      // No hay token, vamos al Login
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
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

      // gardens és List, extreim només els noms
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
        SnackBar(content: Text(AppLocalizations.of(context)!.profileLoadError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mientras piensa, mostramos un logo o un indicador de carga
    return const Scaffold(
      backgroundColor: Color(0xFF166534), // Tu verde principal
      body: Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}
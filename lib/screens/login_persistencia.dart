import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../models/dades_usr.dart';
import 'package:meteo_garden/screens/home_shell.dart';
import 'login_page.dart';
import 'package:http/http.dart' as http;
import '../models/url.dart';
import 'dart:convert';
import 'package:meteo_garden/generated/app_localizations.dart';

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
    try {
      String? token = await storage.read(key: 'auth_token');

      if (token != null) {
        if (mounted) {
          Provider.of<UserModel>(context, listen: false).setToken(token);
          await _fetchAndSaveProfile(token);
        }
      } else {
        _navigateToLogin();
      }
    } catch (e) {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  Future<void> _fetchAndSaveProfile(String token) async {
    final localizations = AppLocalizations.of(context);
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/get_profile/');

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $token",
        },
      ).timeout(const Duration(seconds: 10)); // Added timeout to prevent infinite loading

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

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeShell()),
        );
      } else {
        await storage.delete(key: 'auth_token');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations?.profileLoadError ?? 'Error de sesión')),
          );
          _navigateToLogin();
        }
      }
    } catch (e) {
      if (!mounted) return;
      await storage.delete(key: 'auth_token');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations?.connectionError ?? 'Error de conexión')),
      );
      _navigateToLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF166534),
      body: Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}

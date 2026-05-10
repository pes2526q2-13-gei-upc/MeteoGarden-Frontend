import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../models/dades_usr.dart';
import 'package:meteo_garden/screens/home_shell.dart';
import 'login_page.dart';
import 'package:http/http.dart' as http;
import '../models/url.dart';
import 'dart:convert';
//import 'package:meteo_garden/l10n/app_localizations.dart';
import 'package:meteo_garden/generated/app_localizations.dart';
import '../models/avatar_user.dart';

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
        // await and save profile el encarregat de la navegació
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
    final localizations = AppLocalizations.of(context);
    try {
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

        await _checkAvatar();
      } else {
        // ERROR 401 u otros: El token es inválido o expiró.
        // 1. Borramos el token para evitar bucles infinitos en futuros arranques.
        await storage.delete(key: 'auth_token');

        if (mounted) {
          // 2. Intentamos obtener las traducciones de forma segura sin forzar el nulo (!)

          final errorMessageSession =
              localizations?.profileLoadError ??
              'Error de sesión. Vuelve a iniciar sesión.';

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMessageSession)));

          // 3. Redirigimos al Login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
      }
    } catch (e) {
      // Si falla la red (SocketException) o hay cualquier otro error inesperado
      if (!mounted) return;

      // Por seguridad, si no podemos validar, es mejor mandarlos al login
      await storage.delete(key: 'auth_token');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // El '?' comprueba si es nulo. El '??' pone el texto alternativo si lo es.
          content: Text(localizations?.connectionError ?? 'Error de conexión'),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  Future<void> _checkAvatar() async {
    final localizations = AppLocalizations.of(context);
    final user = Provider.of<UserModel>(context, listen: false);
    String username = user.username;

    final avatarResponse = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/users/$username/avatar'),
    );

    if (!mounted) return;

    if (avatarResponse.statusCode == 200) {
      final avatar = jsonDecode(avatarResponse.body);
      Provider.of<AvatarUser>(context, listen: false).setAvatar(
        newBody: cleanAvatarUrl(avatar['body']),
        newEye: cleanAvatarUrl(avatar['eye']),
        newExpression: cleanAvatarUrl(avatar['expression']),
        newHair: cleanAvatarUrl(avatar['hair'] ?? ''),
        newFacialHair: cleanAvatarUrl(avatar['facial_hair'] ?? ''),
        newClothing: cleanAvatarUrl(avatar['clothing']),
        newAccessories: cleanAvatarUrl(avatar['accessories'] ?? ''),
      );
      _goToHome();
    } else if (avatarResponse.statusCode == 404) {
      _goToHome();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizations?.avatarLoadErrorPersist ??
                'Error al cargar el avatar',
          ),
        ),
      );
    }
  }

  String cleanAvatarUrl(String url) {
    if (url.isEmpty) return url;
    return url.replaceAll('.com//', '.com/');
  }

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeShell()),
    );
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

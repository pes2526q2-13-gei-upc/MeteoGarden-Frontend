import 'package:flutter/material.dart';
import 'package:meteo_garden/screens/completar_nova_conta.dart';
import 'package:meteo_garden/screens/home_shell.dart';
import 'package:meteo_garden/screens/crea_nova_conta.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:meteo_garden/models/dades_usr.dart';
import 'dart:convert';
import '../models/url.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeShell()),
    );
  }

  void _login() async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/login/',
    ); // url del endpoint de login al backend

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": usernameController.text,
        "password": passwordController.text,
      }),
    );
    if (!mounted) return;
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      Provider.of<UserModel>(context, listen: false).setToken(data['token']);
      await _fetchAndSaveProfile(data['token']);
      if (!mounted) return;
      _goToHome();
    } else {
      debugPrint("Error: ${response.body}");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error de login')));
    }
  }

  final GoogleSignIn _googleSignIn = kIsWeb
      ? GoogleSignIn(
          // CONFIGURACIÓN PARA WEB
          clientId:
              "413098408136-jci0fe83maj5uonf6s9v065cnobktrmt.apps.googleusercontent.com",
          scopes: ['email', 'profile', 'openid'],
        )
      : GoogleSignIn(
          // CONFIGURACIÓN PARA ANDROID/iOS
          // Aquí NO se usa clientId. Se usa serverClientId con el ID de la WEB.
          serverClientId:
              "413098408136-jci0fe83maj5uonf6s9v065cnobktrmt.apps.googleusercontent.com",
          scopes: ['email', 'profile', 'openid'],
        );

  Future<void> loginWithGoogle(BuildContext context) async {
    try {
      // 1. Login con Google
      // per que funcioni amb web s'ha de forçar el port 62057
      // flutter run -d chrome --web-port=62057
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // Usuario canceló
        return;
      }

      // 2. Obtener tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      final String tokenToSend = idToken ?? accessToken ?? "";

      if (tokenToSend.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error obteniendo token de Google")),
        );
        return;
      }

      // 3. Enviar a backend
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/api/auth/google/verify"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id_token": tokenToSend}),
      );

      if (!context.mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 5. Navegación
        if (data["exists"] == false) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CompleteGoogleProfilePage(
                googleToken: tokenToSend, // <-- Pasamos el token de Google
                email: data["email"] ?? "", // <-- Pasamos el email
              ),
            ),
          );
        } else {
          Provider.of<UserModel>(
            context,
            listen: false,
          ).setToken(data["token"]);

          await _fetchAndSaveProfile(data['token']);
          _goToHome();
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Error login Google")));
      }
    } catch (e) {
      debugPrint("Error Google Sign-In: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    padding: const EdgeInsets.all(28),
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
                        const _LoginHeader(),
                        const SizedBox(height: 32),

                        _InputField(
                          controller: usernameController,
                          label: "Nom d'usuari",
                          hint: "Introdueix el teu nom d'usuari",
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 16),

                        _InputField(
                          controller: passwordController,
                          label: "Contrasenya",
                          hint: "Introdueix la teva contrasenya",
                          icon: Icons.lock_outline_rounded,
                          obscureText: true,
                        ),
                        const SizedBox(height: 28),

                        // BOTÓ INICIAR SESSIÓ
                        FilledButton.icon(
                          onPressed: _login,
                          icon: const Icon(Icons.login_rounded),
                          label: const Text(
                            "Iniciar sessió",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF166534,
                            ), // Verd fosc unificat
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // DIVISOR
                        Row(
                          children: [
                            Expanded(
                              child: Divider(color: Colors.grey.shade300),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                'o continuar amb',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(color: Colors.grey.shade300),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // BOTÓ GOOGLE
                        OutlinedButton.icon(
                          onPressed: () => loginWithGoogle(context),
                          icon: const Icon(
                            Icons.g_mobiledata,
                            size: 28,
                            color: Colors.black87,
                          ),
                          label: const Text(
                            'Google',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ENLLAÇ CREAR COMPTE
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "No tens compte?",
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CreaNovaConta(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF166534),
                              ),
                              child: const Text(
                                'Crear compte',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
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

    debugPrint("PROFILE STATUS: ${response.statusCode}");
    debugPrint("PROFILE BODY: ${response.body}");

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
        const SnackBar(content: Text('No s\'ha pogut carregar el perfil')),
      );
    }
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(5),
          child: Image.asset('assets/images/logo.png', width: 120),
        ),
        const SizedBox(height: 18),
        const Text(
          "Benvinguda a MeteoGarden",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF166534), // Toc de color al títol
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Inicia sessió per continuar cuidant el teu jardí.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(icon, color: Colors.grey.shade500),
            filled: true,
            fillColor: Colors.grey.withValues(alpha: 0.08),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.black.withValues(alpha: 0.05),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF166534),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

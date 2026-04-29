import 'package:flutter/material.dart';
import 'package:meteo_garden/models/avatar_user.dart';
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
import 'package:meteo_garden/generated/app_localizations.dart';
import 'avatar_editor_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Locale _loginLocale = const Locale('ca');

  AppLocalizations get _t => lookupAppLocalizations(_loginLocale);

  final GoogleSignIn _googleSignIn = kIsWeb
      ? GoogleSignIn(
          clientId:
              "413098408136-jci0fe83maj5uonf6s9v065cnobktrmt.apps.googleusercontent.com",
          scopes: ['email', 'profile', 'openid'],
        )
      : GoogleSignIn(
          serverClientId:
              "413098408136-jci0fe83maj5uonf6s9v065cnobktrmt.apps.googleusercontent.com",
          scopes: ['email', 'profile', 'openid'],
        );

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

  Widget _buildLanguageSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: PopupMenuButton<String>(
        initialValue: _loginLocale.languageCode,
        onSelected: (value) {
          setState(() {
            _loginLocale = Locale(value);
          });
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        itemBuilder: (context) => const [
          PopupMenuItem(value: 'ca', child: Text('Català')),
          PopupMenuItem(value: 'es', child: Text('Español')),
          PopupMenuItem(value: 'en', child: Text('English')),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.language, color: Color(0xFF166534), size: 20),
              const SizedBox(width: 8),
              Text(
                _loginLocale.languageCode.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF166534),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down, color: Color(0xFF166534)),
            ],
          ),
        ),
      ),
    );
  }

  void _login() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/login/');

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
      if (!context.mounted) return;
      await _checkAvatar();
      // el go to home es fa a la funcio de checkavatar, per que no es sobreposin el canvis de pantalla
    } else {
      debugPrint("Error: ${response.body}");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_t.loginError)));
    }
  }

  Future<void> loginWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return;
      }

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

      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/api/auth/google/verify"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id_token": tokenToSend}),
      );

      if (!context.mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["exists"] == false) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CompleteGoogleProfilePage(
                googleToken: tokenToSend,
                email: data["email"] ?? "",
              ),
            ),
          );
        } else {
          Provider.of<UserModel>(
            context,
            listen: false,
          ).setToken(data["token"]);
          await _fetchAndSaveProfile(data['token']);
          if (!context.mounted) return;
          await _checkAvatar();
          // el go to home es fa a la funcio de checkavatar, per que no es sobreposin el canvis de pantalla
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
    final t = _t;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/imatge_fondo1.png',
              fit: BoxFit.cover,
            ),
          ),
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
          Positioned(
            top: 3,
            right: 16,
            child: SafeArea(child: _buildLanguageSelector()),
          ),
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
                        _LoginHeader(t: t),
                        const SizedBox(height: 32),
                        _InputField(
                          controller: usernameController,
                          label: t.loginUsernameLabel,
                          hint: t.loginUsernameHint,
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 16),
                        _InputField(
                          controller: passwordController,
                          label: t.loginPasswordLabel,
                          hint: t.loginPasswordHint,
                          icon: Icons.lock_outline_rounded,
                          obscureText: true,
                        ),
                        const SizedBox(height: 28),
                        FilledButton.icon(
                          onPressed: _login,
                          icon: const Icon(Icons.login_rounded),
                          label: Text(
                            t.loginButton,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF166534),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                        ),
                        const SizedBox(height: 24),
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
                                t.loginContinueWith,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              t.loginNoAccount,
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
                              child: Text(
                                t.loginCreateAccount,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_t.profileLoadError)));
    }
  }

  Future<void> _checkAvatar() async {
    final user = Provider.of<UserModel>(context, listen: false);
    String username = user.username;

    final avatarResponse = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/users/$username/avatar/'),
    );

    if (!mounted) return;

    if (avatarResponse.statusCode == 200) {
      final avatar = jsonDecode(avatarResponse.body);
      Provider.of<AvatarUser>(context, listen: false).setAvatar(
        newBody: avatar['body'],
        newEye: avatar['eye'],
        newExpression: avatar['expression'],
        newHair: avatar['hair'],
        newFacialHair: avatar['facial_hair'],
        newClothing: avatar['clothing'],
        newAccessories: avatar['accessories'],
      );
      _goToHome();
    } else if (avatarResponse.statusCode == 404) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AvatarEditorPage(isNewUser: true),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_t.avatarLoadError)));
    }
  }
}

class _LoginHeader extends StatelessWidget {
  final AppLocalizations t;

  const _LoginHeader({required this.t});

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
        Text(
          t.loginWelcomeTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF166534),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          t.loginWelcomeSubtitle,
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

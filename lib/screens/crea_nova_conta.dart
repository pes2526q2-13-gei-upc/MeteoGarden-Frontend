import 'package:flutter/material.dart';
import 'package:meteo_garden/generated/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:meteo_garden/models/dades_usr.dart';
import '../models/url.dart';
import 'avatar_editor_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../widgets/centered_message.dart';

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
  final TextEditingController ciutatSearchController = TextEditingController();
  final storage = const FlutterSecureStorage();

  Locale _pageLocale = const Locale('ca');
  AppLocalizations get _t => lookupAppLocalizations(_pageLocale);

  String? language = 'ca';
  List<City> cities = [];
  City? selectedCity;
  bool isLoadingCities = true;
  String? usernameError;
  String? emailError;
  String? cityError;
  String? passwordError;
  String? gardenError;
  String? languageError;

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
        initialValue: _pageLocale.languageCode,
        onSelected: (value) {
          setState(() {
            _pageLocale = Locale(value);
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
                _pageLocale.languageCode.toUpperCase(),
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

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

    return emailRegex.hasMatch(email.trim());
  }

  String _invalidEmailMessage() {
    switch (_pageLocale.languageCode) {
      case 'es':
        return 'Introduce un correo electrónico válido.';
      case 'en':
        return 'Enter a valid email address.';
      case 'ca':
      default:
        return 'Introdueix un correu electrònic vàlid.';
    }
  }

  String _requiredFieldMessage() {
    switch (_pageLocale.languageCode) {
      case 'es':
        return 'Este campo es obligatorio.';
      case 'en':
        return 'This field is required.';
      case 'ca':
      default:
        return 'Aquest camp és obligatori.';
    }
  }

  Future<void> fetchCities() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/stations/'),
      );

      if (!mounted) return;

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
      if (!mounted) return;
      setState(() => isLoadingCities = false);
      debugPrint("Error carregant ciutats: $e");
    }
  }

  void _submit() async {
    final l10n = _t;
    final url = Uri.parse("${ApiConfig.baseUrl}/api/register/");
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final gardenName = nomjardiController.text.trim();

    final requiredMessage = _requiredFieldMessage();

    setState(() {
      usernameError = username.isEmpty ? requiredMessage : null;
      emailError = email.isEmpty
          ? requiredMessage
          : !_isValidEmail(email)
          ? _invalidEmailMessage()
          : null;
      cityError = selectedCity == null ? requiredMessage : null;
      passwordError = password.isEmpty ? requiredMessage : null;
      languageError = language == null ? requiredMessage : null;
      gardenError = gardenName.isEmpty ? requiredMessage : null;
    });

    final hasErrors =
        usernameError != null ||
        emailError != null ||
        cityError != null ||
        passwordError != null ||
        languageError != null ||
        gardenError != null;

    if (hasErrors) {
      return;
    }

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'username': username,
        'password': password,
        'email': email,
        'city': selectedCity?.name,
        'language': language,
        'stationCode': selectedCity?.code,
        'gardenName': gardenName,
      }),
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];

      Provider.of<UserModel>(context, listen: false).setToken(token);

      await storage.write(key: 'auth_token', value: data['token']);
      await _fetchAndSaveProfile(token);

      if (!mounted) return;

      CenteredMessage.show(
        context,
        l10n.createAccountSuccess,
        type: CenteredMessageType.success,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AvatarEditorPage(isNewUser: true),
        ),
      );
    } else {
      debugPrint("Error: ${response.body}");
      CenteredMessage.show(
        context,
        l10n.createAccountError,
        type: CenteredMessageType.error,
      );
    }
  }

  Future<void> _fetchAndSaveProfile(String token) async {
    final l10n = _t;
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
      CenteredMessage.show(
        context,
        l10n.profileLoadError,
        type: CenteredMessageType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = _t;

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
    );

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildLanguageSelector(),

                      const SizedBox(height: 16),

                      Container(
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
                            Text(
                              l10n.createAccountWelcome,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF166534),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.createAccountSubtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 24),

                            TextField(
                              controller: usernameController,
                              onChanged: (_) {
                                if (usernameError != null) {
                                  setState(() {
                                    usernameError = null;
                                  });
                                }
                              },
                              decoration: defaultDecoration.copyWith(
                                labelText: l10n.loginUsernameLabel,
                                prefixIcon: const Icon(
                                  Icons.person_outline_rounded,
                                ),
                                errorText: usernameError,
                              ),
                            ),
                            const SizedBox(height: 16),

                            TextField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              enableSuggestions: false,
                              onChanged: (_) {
                                if (emailError != null) {
                                  setState(() {
                                    emailError = null;
                                  });
                                }
                              },
                              decoration: defaultDecoration.copyWith(
                                labelText: l10n.createAccountEmailLabel,
                                prefixIcon: const Icon(Icons.email_outlined),
                                errorText: emailError,
                              ),
                            ),
                            const SizedBox(height: 16),

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
                                    menuHeight: 250,
                                    label: Text(l10n.commonCity),
                                    leadingIcon: const Icon(
                                      Icons.location_city_rounded,
                                    ),
                                    inputDecorationTheme: InputDecorationTheme(
                                      filled: true,
                                      fillColor: Colors.grey.withValues(
                                        alpha: 0.08,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    dropdownMenuEntries: cities
                                        .map<DropdownMenuEntry<City>>((
                                          City city,
                                        ) {
                                          return DropdownMenuEntry<City>(
                                            value: city,
                                            label: city.name,
                                          );
                                        })
                                        .toList(),
                                    onSelected: (City? city) {
                                      setState(() {
                                        selectedCity = city;
                                        cityError = null;
                                      });
                                    },
                                  ),
                            if (cityError != null) ...[
                              const SizedBox(height: 6),
                              Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: Text(
                                  cityError!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),

                            TextField(
                              controller: passwordController,
                              obscureText: true,
                              onChanged: (_) {
                                if (passwordError != null) {
                                  setState(() {
                                    passwordError = null;
                                  });
                                }
                              },
                              decoration: defaultDecoration.copyWith(
                                labelText: l10n.loginPasswordLabel,
                                prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                ),
                                errorText: passwordError,
                              ),
                            ),
                            const SizedBox(height: 16),

                            DropdownButtonFormField<String>(
                              initialValue: language,
                              decoration: defaultDecoration.copyWith(
                                labelText: l10n.commonLanguage,
                                prefixIcon: const Icon(Icons.language_rounded),
                                errorText: languageError,
                              ),
                              icon: const Icon(Icons.arrow_drop_down_rounded),
                              items: [
                                DropdownMenuItem(
                                  value: 'ca',
                                  child: Text(l10n.languageCatalan),
                                ),
                                DropdownMenuItem(
                                  value: 'es',
                                  child: Text(l10n.languageSpanish),
                                ),
                                DropdownMenuItem(
                                  value: 'en',
                                  child: Text(l10n.languageEnglish),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  language = value;
                                  _pageLocale = Locale(value ?? 'ca');
                                  languageError = null;
                                });
                              },
                            ),
                            const SizedBox(height: 16),

                            TextField(
                              controller: nomjardiController,
                              onChanged: (_) {
                                if (gardenError != null) {
                                  setState(() {
                                    gardenError = null;
                                  });
                                }
                              },
                              decoration: defaultDecoration.copyWith(
                                labelText: l10n.createAccountGardenNameLabel,
                                prefixIcon: const Icon(
                                  Icons.local_florist_outlined,
                                ),
                                errorText: gardenError,
                              ),
                            ),
                            const SizedBox(height: 32),

                            FilledButton.icon(
                              onPressed: _submit,
                              icon: const Icon(
                                Icons.check_circle_outline_rounded,
                              ),
                              label: Text(
                                l10n.loginCreateAccount,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF166534),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

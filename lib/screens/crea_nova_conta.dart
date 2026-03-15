import 'package:flutter/material.dart';
import 'package:meteo_gareden/screens/home_shell.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:meteo_gareden/services/dades_usr.dart';

class CreaNovaConta extends StatefulWidget {
  const CreaNovaConta({super.key});

  @override
  State<CreaNovaConta> createState() => _CreaNovaContaState();
}

class _CreaNovaContaState extends State<CreaNovaConta> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController languageController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    emailController.dispose();
    cityController.dispose();
    languageController.dispose();
    super.dispose();
  }

  void _submit() async {
    final url = Uri.parse("http://127.0.0.1:8000/api/register/");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'username': usernameController.text,
        'password': passwordController.text,
        'email': emailController.text,
        'city': cityController.text,
        'language': languageController.text,
      }),
    );

    if (response.statusCode == 200) {
      debugPrint("Cuenta creada");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Compte creat')));

      Provider.of<UserModel>(
        context,
        listen: false,
      ).setToken(jsonDecode(response.body)['token']);

      Navigator.pop(context);
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

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.green.withOpacity(0.04),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.green.withOpacity(0.6), width: 1.4),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear compte')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: usernameController,
                    decoration: _inputDecoration('Nom d\'usuari'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration('Email'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: _inputDecoration('Contrasenya'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: cityController,
                    decoration: _inputDecoration('Ciutat'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: languageController,
                    decoration: _inputDecoration('Idioma'),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _submit,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                      child: Text(
                        'Crear compte',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

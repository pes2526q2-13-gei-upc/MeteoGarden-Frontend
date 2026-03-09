import 'package:flutter/material.dart';

class BotigaPage extends StatelessWidget {
  const BotigaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Botiga 🛒')),
      body: const Center(
        child: Text(
          'Aquí hi haurà els productes de la botiga',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
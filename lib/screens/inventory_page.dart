import 'package:flutter/material.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('InventoryPage')),
      body: const Center(
        child: Text(
          'Aquí hi haurà els productes de la botiga',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/perfil_info.dart';

class PerfilEditPage extends StatelessWidget {
  final PerfilInfo profile;

  const PerfilEditPage({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modificar perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Usuari'),
              controller: TextEditingController(text: profile.username),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(labelText: 'Ciutat'),
              controller: TextEditingController(text: profile.city),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () {
                // Aquí després faràs PUT/PATCH a la API
                Navigator.pop(context);
              },
              child: const Text('Guardar canvis'),
            ),
          ],
        ),
      ),
    );
  }
}

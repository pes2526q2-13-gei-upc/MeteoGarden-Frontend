import 'package:flutter/material.dart';

class PhotoPage extends StatelessWidget {
  const PhotoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('fotografiar')),
      body: const Center(
        child: Text(
          'aqui hi ha la programació de fer fotogarfies',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
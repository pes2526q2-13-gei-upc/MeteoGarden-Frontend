import 'package:flutter/material.dart';

class AvatarStack extends StatelessWidget {
  final String body;
  final String eye;
  final String expression;
  final String hair;
  final String facialHair;
  final String clothing;
  final String accessories;

  const AvatarStack({
    super.key,
    required this.body,
    required this.eye,
    required this.expression,
    required this.hair,
    required this.facialHair,
    required this.clothing,
    required this.accessories,
  });

  @override
  Widget build(BuildContext context) {
    // Definimos una función de ayuda para cargar las rutas de las imágenes
    // Asume que tienes tus imágenes en assets/avatar/categoria/nombre_archivo.png
    Widget buildLayer(String category, String item) {
      if (item.isEmpty || item == 'none') return const SizedBox.shrink();
      return Image.asset(
        'assets/avatar/$category/$item.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(), // Evita errores si falta la imagen
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        buildLayer('body', body),
        buildLayer('eye', eye),
        buildLayer('expression', expression),
        buildLayer('hair', hair),
        buildLayer('facial_hair', facialHair),
        buildLayer('clothing', clothing),
        buildLayer('accessories', accessories),
      ],
    );
  }
}
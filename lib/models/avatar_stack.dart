import 'package:flutter/material.dart';

class AvatarStack extends StatelessWidget {
  // Definimos los parámetros que recibirá el widget
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
    // Usamos un Stack para encimar las imágenes una sobre otra
    return Stack(
      alignment: Alignment.center,
      children: [
        // El orden importa: lo que va abajo en el código se ve "encima" en la pantalla
        _buildImage(body),
        _buildImage(clothing),
        _buildImage(eye),
        _buildImage(expression),
        _buildImage(hair),
        _buildImage(facialHair),
        _buildImage(accessories),
      ],
    );
  }

  // Función auxiliar para evitar errores si la ruta está vacía
  // Cambiamos el nombre de la función para que tenga más sentido
  Widget _buildImage(String path) {
    if (path.isEmpty) return const SizedBox.shrink();

    // Si la ruta empieza con http, es de internet. Usamos Image.network
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.contain,
        // Volvemos a activar el errorBuilder por si falla la conexión a internet
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
      );
    }
    // mantenemos esto como plan B.
    return Image.asset(
      path,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
    );
  }
}

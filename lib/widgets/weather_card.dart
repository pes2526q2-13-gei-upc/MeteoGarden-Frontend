import 'package:flutter/material.dart';

class WeatherCard extends StatelessWidget {
  final String nomEstacio;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback onRefresh;
  final VoidCallback? onTap; // 👈 AÑADIMOS ESTO para la navegación
  final double? precipitation;
  final double? wind;

  const WeatherCard({
    super.key,
    required this.nomEstacio,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onRefresh,
    this.onTap, // 👈 Lo pedimos en el constructor
    this.precipitation,
    this.wind,
  });

  IconData _weatherIcon() {
    try {
      final precipitationValue = precipitation ?? 0.0;
      final windValue = wind ?? 0.0;

      if (precipitationValue > 0) return Icons.water_drop_rounded;
      if (windValue >= 8) return Icons.air_rounded;
      return Icons.wb_sunny_rounded;
    } catch (_) {
      return Icons.cloud_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap:
            onTap, // 👈 CAMBIAMOS ESTO: Ahora la tarjeta entera navega a detalles
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(_weatherIcon(), color: Colors.white, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nomEstacio,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.90),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // 👇 CAMBIAMOS ESTO: Envolvemos el icono en un IconButton para que refresque al pulsar solo el icono
              Center(
                child: IconButton(
                  icon: trailing,
                  color: Colors.white,
                  iconSize: 24,
                  onPressed:
                      onRefresh, // 👈 El botón de refrescar ahora hace el onRefresh
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(), // Minimiza el padding extra del botón
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

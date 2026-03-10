import 'package:flutter/material.dart';

class WeatherCard extends StatelessWidget {
  final String nomEstacio;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback onRefresh;

  const WeatherCard({
    super.key,
    required this.nomEstacio,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onRefresh,
  });

  //MODIFICAR SEGONS ELS ATRIBUTS DE LA PRECIPITACIO 
  IconData _weatherIcon() {
  try {
    final parts = title.split('·');
    final precipitation = parts.length > 1
        ? double.tryParse(parts[1].trim()) ?? 0.0
        : 0.0;

    final windText = subtitle.replaceAll('Vent:', '').replaceAll('m/s', '').trim();
    final wind = double.tryParse(windText) ?? 0.0;

    if (precipitation > 0) {
      return Icons.grain; // pluja
    }

    if (wind >= 8) {
      return Icons.air; // vent fort
    }

    return Icons.wb_sunny; // sol
  } catch (_) {
    return Icons.cloud;
  }
}

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onRefresh,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              Icon(
                _weatherIcon(),
                color: Colors.white,
                size: 28,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // NOM ESTACIÓ
                    Text(
                      nomEstacio,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 2),

                    // TEMPERATURA + PRECIPITACIÓ
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 2),

                    // VENT
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              IconTheme(
                data: const IconThemeData(color: Colors.white),
                child: trailing,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
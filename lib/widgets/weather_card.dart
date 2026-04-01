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

  IconData _weatherIcon() {
    try {
      final parts = title.split('·');
      final precipitation = parts.length > 1
          ? double.tryParse(parts[1].trim()) ?? 0.0
          : 0.0;

      final windText = subtitle
          .replaceAll('Vent:', '')
          .replaceAll('m/s', '')
          .trim();
      final wind = double.tryParse(windText) ?? 0.0;

      if (precipitation > 0) return Icons.water_drop_rounded;
      if (wind >= 8) return Icons.air_rounded;
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
        onTap: onRefresh,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.28), // 👈 FONS ORIGINAL
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.14),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //  ICONA
              Icon(
                _weatherIcon(),
                color: Colors.white,
                size: 26,
              ),

              const SizedBox(width: 10),

              //  TEXTOS
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

              // 🔄 REFRESH CENTRAT
              Center(
                child: IconTheme(
                  data: const IconThemeData(
                    color: Colors.white,
                    size: 24,
                  ),
                  child: trailing,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
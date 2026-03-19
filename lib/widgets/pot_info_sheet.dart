import 'package:flutter/material.dart';
import '../models/garden.dart';

class PotInfoSheet extends StatelessWidget {
  final GardenPot pot;
  final Future<void> Function() onWater;
  final Future<void> Function()? onCollect;

  const PotInfoSheet({
    super.key,
    required this.pot,
    required this.onWater,
    this.onCollect,
  });

  @override
  Widget build(BuildContext context) {
    final plant = pot.plant;
    final isMature = pot.growthPhase == 'mature';
    final waterValue = (pot.waterLevel ?? 0) / 100;
    final healthValue = (pot.healthLevel ?? 0) / 100;

    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: Image.asset(
              'assets/images/foto_terra2.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Overlay fosc per llegibilitat
        Positioned.fill(
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: Container(color: Colors.black.withValues(alpha: 0.65)),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            color: Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plant?.commonName ??
                              plant?.scientificName ??
                              "Planta",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(blurRadius: 6, color: Colors.black54),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        _PhaseBadge(phase: pot.growthPhase ?? '-'),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              _StatBar(
                label: "Nivell d'Aigua",
                value: waterValue,
                percent: pot.waterLevel?.toStringAsFixed(0) ?? '0',
                color: const Color(0xFF38bdf8),
                backgroundColor: Colors.white.withValues(alpha: 0.2),
              ),

              const SizedBox(height: 14),

              _StatBar(
                label: "Salut",
                value: healthValue,
                percent: pot.healthLevel?.toStringAsFixed(0) ?? '0',
                color: const Color(0xFF4ade80),
                backgroundColor: Colors.white.withValues(alpha: 0.2),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Últim reg: ${pot.lastWateredAt ?? '-'}",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              if ((pot.waterLevel ?? 0) < 100) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onWater,
                    icon: const Icon(Icons.water_drop),
                    label: const Text("Regar planta"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0ea5e9),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],

              if (isMature && onCollect != null) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onCollect,
                    icon: const Icon(Icons.agriculture),
                    label: const Text("Recollir planta"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16a34a),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StatBar extends StatelessWidget {
  final String label;
  final double value;
  final String percent;
  final Color color;
  final Color backgroundColor;

  const _StatBar({
    required this.label,
    required this.value,
    required this.percent,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.white,
                shadows: [Shadow(blurRadius: 4, color: Colors.black45)],
              ),
            ),
            Text(
              "$percent%",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 14,
            backgroundColor: backgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _PhaseBadge extends StatelessWidget {
  final String phase;

  const _PhaseBadge({required this.phase});

  @override
  Widget build(BuildContext context) {
    final Map<String, (String, Color)> phaseInfo = {
      'seed': ('Llavor', Color(0xFFfbbf24)),
      'sprout': ('Brot', Color(0xFF34d399)),
      'growing': ('Creixent', Color(0xFF4ade80)),
      'mature': ('Madura', Color(0xFFfcd34d)),
      'dead': ('Morta', Color(0xFF9ca3af)),
    };

    final info = phaseInfo[phase] ?? ('❓ $phase', const Color(0xFF9ca3af));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: info.$2.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: info.$2.withValues(alpha: 0.7)),
      ),
      child: Text(
        info.$1,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: info.$2,
        ),
      ),
    );
  }
}

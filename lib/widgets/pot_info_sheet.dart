import 'package:flutter/material.dart';
import '../models/garden.dart';

class PotInfoSheet extends StatelessWidget {
  final GardenPot pot;
  final Future<void> Function() onWater;

  const PotInfoSheet({
    super.key,
    required this.pot,
    required this.onWater,
  });

  @override
  Widget build(BuildContext context) {
    final plant = pot.plant;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plant?.commonName ?? plant?.scientificName ?? "Planta",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          Text("Fase: ${pot.growthPhase ?? '-'}"),
          const SizedBox(height: 12),

const Text(
  "Aigua",
  style: TextStyle(fontWeight: FontWeight.bold),
),

const SizedBox(height: 6),

LinearProgressIndicator(
  value: (pot.waterLevel ?? 0) / 100,
  minHeight: 10,
  backgroundColor: Colors.grey.shade300,
  color: Colors.blue,
),

Text("${pot.waterLevel?.toStringAsFixed(0) ?? 0}%"),
const SizedBox(height: 16),
const Text(
  "Salut",
  style: TextStyle(fontWeight: FontWeight.bold),
),

const SizedBox(height: 6),
LinearProgressIndicator(
  value: (pot.healthLevel ?? 0) / 100,
  minHeight: 10,
  backgroundColor: Colors.grey.shade300,
  color: Colors.green,
),
Text("${pot.healthLevel?.toStringAsFixed(0) ?? 0}%"),
          Text("Últim reg: ${pot.lastWateredAt ?? '-'}"),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onWater,
              icon: const Icon(Icons.water_drop),
              label: const Text("Regar planta"),
            ),
          ),
        ],
      ),
    );
  }
}
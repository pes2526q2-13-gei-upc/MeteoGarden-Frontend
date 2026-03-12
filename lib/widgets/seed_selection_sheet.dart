import 'package:flutter/material.dart';
import '../models/garden.dart';
import '../models/seed_option.dart';

class SeedSelectionSheet extends StatelessWidget {
  final GardenPot pot;
  final List<SeedOption> seeds;
  final Function(SeedOption) onSeedSelected;

  const SeedSelectionSheet({
    super.key,
    required this.pot,
    required this.seeds,
    required this.onSeedSelected,
  });

  @override
  Widget build(BuildContext context) {
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
          const Text(
            "Test buit",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text("Selecciona una llavor pel test ${pot.potNumber}"),
          const SizedBox(height: 20),
          if (seeds.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text("No tens llavors disponibles."),
            )
          else
            ...seeds.map(
              (seed) => Card(
                child: ListTile(
                  leading: const Icon(Icons.eco),
                  title: Text(seed.scientificName),
                  subtitle: Text(
                    "${seed.scientificName}\nQuantitat: ${seed.amount}",
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => onSeedSelected(seed),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
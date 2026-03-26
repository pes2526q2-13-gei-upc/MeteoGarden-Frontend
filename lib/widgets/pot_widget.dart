import 'package:flutter/material.dart';
import '../models/garden.dart';

class PotWidget extends StatelessWidget {
  final GardenPot pot;
  final VoidCallback onTap;

  const PotWidget({super.key, required this.pot, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasPlant = pot.occupied && pot.plant != null;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset('assets/images/test3.png', fit: BoxFit.contain),

          if (hasPlant)
            Positioned(
              top: 6,
              child: Column(
                children: [
                  if (pot.plant!.imageUrl != null && pot.plant!.imageUrl!.isNotEmpty)
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.network(
                          pot.plant!.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Si falla carregar, mostra icon per defecte
                            return const Icon(
                              Icons.local_florist,
                              size: 30,
                              color: Colors.red,
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  else
                    // Si no hi ha imageUrl, mostra icon de planta
                    const Icon(
                      Icons.local_florist,
                      size: 30,
                      color: Colors.yellow,
                    ),
                  Text(
                    pot.plant!.commonName,
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

          Positioned(
            bottom: 6,
            child: Column(
              children: [
                const SizedBox(height: 4),

                if (hasPlant && pot.waterLevel != null)
                  SizedBox(
                    width: 42,
                    child: LinearProgressIndicator(
                      value: (pot.waterLevel!.clamp(0, 100)) / 100,
                      minHeight: 5,
                      backgroundColor: Colors.white30,
                      color: Colors.blue,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

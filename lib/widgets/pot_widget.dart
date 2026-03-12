import 'package:flutter/material.dart';
import '../models/garden.dart';

class PotWidget extends StatelessWidget {
  final GardenPot pot;
  final VoidCallback onTap;

  const PotWidget({
    super.key,
    required this.pot,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasPlant = pot.occupied && pot.plant != null;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/images/test3.png',
            fit: BoxFit.contain,
          ),

          if (hasPlant)
            Positioned(
              top: 6,
              child: Column(
                children: [
                  const Icon(
                    //AQUI POSEM LA FOTO DE 
                    Icons.local_florist,
                    size: 30,
                    color: Colors.green,
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
                      color: Colors.blue
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
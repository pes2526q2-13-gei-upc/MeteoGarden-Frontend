import 'package:flutter/material.dart';
import '../models/garden.dart';

class PotWidget extends StatelessWidget {
  final GardenPot pot;
  final VoidCallback onTap;

  const PotWidget({super.key, required this.pot, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasPlant = pot.occupied && pot.plant != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final boxSize = constraints.biggest.shortestSide;

        final imageSize = boxSize * 0.62;
        final plantTop = -boxSize * 0.38;
        final progressWidth = boxSize * 0.48;
        final progressHeight = boxSize * 0.05;
        final iconSize = (boxSize * 0.28).clamp(20.0, 34.0);
        final shieldSize = (boxSize * 0.28).clamp(18.0, 30.0);

        return GestureDetector(
          key: Key(
            'garden_pot_${pot.potNumber}_${hasPlant ? 'occupied' : 'empty'}',
          ),
          onTap: onTap,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Test — igual de gran que abans
              Positioned.fill(
                child: Image.asset(
                  'assets/images/test3.png',
                  fit: BoxFit.contain,
                ),
              ),

              if (hasPlant)
                Positioned(
                  top: plantTop,
                  left: boxSize * 0.08,
                  right: boxSize * 0.08,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (pot.plant!.imageUrl != null &&
                          pot.plant!.imageUrl!.isNotEmpty)
                        SizedBox(
                          width: imageSize,
                          height: imageSize,
                          child: Image.network(
                            pot.plant!.imageUrl!,
                            fit: BoxFit.contain,
                            alignment: Alignment.bottomCenter,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.local_florist,
                                size: iconSize,
                                color: Colors.red,
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: SizedBox(
                                  width: iconSize * 0.7,
                                  height: iconSize * 0.7,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      else
                        Icon(
                          Icons.local_florist,
                          size: iconSize,
                          color: Colors.yellow,
                        ),
                    ],
                  ),
                ),

              // Barra d'aigua
              if (hasPlant && pot.waterLevel != null)
                Positioned(
                  bottom: boxSize * 0.10,
                  child: SizedBox(
                    width: progressWidth,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: (pot.waterLevel!.clamp(0, 100)) / 100,
                        minHeight: progressHeight,
                        backgroundColor: Colors.white30,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),

              // Escut / buff
              if (pot.hasBuff)
                Positioned(
                  top: boxSize * 0.12,
                  right: boxSize * 0.04,
                  child: Image.asset(
                    'assets/images/escut.png',
                    width: shieldSize,
                    height: shieldSize,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

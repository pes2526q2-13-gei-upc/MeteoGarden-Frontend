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

        final imageSize = boxSize * 0.42;
        final plantTop = boxSize * 0.10;
        final progressWidth = boxSize * 0.48;
        final progressHeight = boxSize * 0.05;
        final nameFontSize = (boxSize * 0.10).clamp(8.0, 12.0);
        final iconSize = (boxSize * 0.28).clamp(20.0, 34.0);
        final borderRadius = boxSize * 0.18;
        final shieldSize = (boxSize * 0.28).clamp(18.0, 30.0);

        return GestureDetector(
          onTap: onTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
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
                        Container(
                          width: imageSize,
                          height: imageSize,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(borderRadius),
                            border: Border.all(
                              color: Colors.green,
                              width: (boxSize * 0.02).clamp(1.5, 3.0),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              borderRadius - 2,
                            ),
                            child: Image.network(
                              pot.plant!.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.local_florist,
                                  size: iconSize,
                                  color: Colors.red,
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: SizedBox(
                                        width: iconSize * 0.7,
                                        height: iconSize * 0.7,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          value:
                                              loadingProgress
                                                      .expectedTotalBytes !=
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
                          ),
                        )
                      else
                        Icon(
                          Icons.local_florist,
                          size: iconSize,
                          color: Colors.yellow,
                        ),

                      SizedBox(height: boxSize * 0.03),

                      Text(
                        pot.plant!.commonName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: nameFontSize,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                          shadows: const [
                            Shadow(
                              blurRadius: 3,
                              color: Colors.black54,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

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

              if (pot.hasBuff)
                Positioned(
                  top: boxSize * 0.04,
                  right: boxSize * 0.04,
                  child: Image.asset(
                    'assets/images/escut.png', // canvia pel nom del teu fitxer
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

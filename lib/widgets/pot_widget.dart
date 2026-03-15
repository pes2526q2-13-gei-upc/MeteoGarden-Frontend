import 'package:flutter/material.dart';
import '../screens/garden_page.dart';

class PotWidget extends StatelessWidget {
  final int index;
  final PotState state;
  final VoidCallback onTap;

  const PotWidget({
    super.key,
    required this.index,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset('assets/images/test3.png', fit: BoxFit.contain),
          if (state == PotState.locked)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          if (state == PotState.locked)
            const Icon(Icons.lock, color: Colors.white, size: 28),
          if (state == PotState.readyToPlant)
            const Icon(Icons.add_circle, color: Colors.white, size: 30),
        ],
      ),
    );
  }
}

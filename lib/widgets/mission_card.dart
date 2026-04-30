import 'package:flutter/material.dart';
import '../models/missions.dart';

class MissionCard extends StatelessWidget {
  final Mission mission;

  const MissionCard({super.key, required this.mission});

  @override
  Widget build(BuildContext context) {
    final progress = mission.progress / mission.goal;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: mission.isCompleted ? Colors.green : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE
          Text(
            mission.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          // DESCRIPTION
          Text(
            mission.description,
            style: TextStyle(color: Colors.grey.shade700),
          ),

          const SizedBox(height: 12),

          // PROGRESS BAR
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
          ),

          const SizedBox(height: 8),

          // TEXT PROGRESS
          Text("${mission.progress} / ${mission.goal}"),

          const SizedBox(height: 10),

          // REWARD
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Recompensa: ${mission.reward} 🪙"),

              if (mission.isCompleted)
                const Icon(Icons.check_circle, color: Colors.green)
            ],
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../models/missions.dart';
import '../generated/app_localizations.dart';

class MissionCard extends StatelessWidget {
  final Mission mission;
  final VoidCallback? onClaim;

  const MissionCard({super.key, required this.mission, this.onClaim});

  IconData get _actionIcon {
    switch (mission.action) {
      case 'PLANT':
        return Icons.local_florist;
      case 'WATER':
        return Icons.water_drop;
      case 'COLLECT':
        return Icons.eco;
      case 'FLOWER':
        return Icons.yard;
      case 'DIE':
        return Icons.sentiment_dissatisfied;
      default:
        return Icons.flag;
    }
  }

  Color get _borderColor {
    if (mission.isClaimed) return const Color(0xFF9E9E9E);
    if (mission.isCompleted) return const Color(0xFF2F6B43);
    return const Color(0xFFCDE7C4);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: mission.isClaimed
            ? Colors.grey.shade100
            : Colors.white.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: icono + nombre + action badge
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: mission.isClaimed
                      ? Colors.grey.shade200
                      : const Color(0xFFDDF3D8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _actionIcon,
                  color: mission.isClaimed
                      ? Colors.grey
                      : const Color(0xFF237A3B),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mission.displayName,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: mission.isClaimed
                            ? Colors.grey
                            : const Color(0xFF163D25),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      mission.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: mission.isClaimed
                            ? Colors.grey.shade400
                            : const Color(0xFF5F6F52),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StateBadge(state: mission.missionState),
            ],
          ),

          const SizedBox(height: 14),

          // Barra de progreso
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${mission.currentNumber} / ${mission.goal}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: mission.isClaimed
                          ? Colors.grey
                          : const Color(0xFF2F6B43),
                    ),
                  ),
                  Text(
                    '${(mission.percentage * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: mission.isClaimed
                          ? Colors.grey.shade400
                          : const Color(0xFF5F6F52),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: mission.percentage,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    mission.isClaimed
                        ? Colors.grey.shade400
                        : mission.isCompleted
                        ? const Color(0xFF2F6B43)
                        : const Color(0xFF5BAF78),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Footer: recompensa + botón claim
          Row(
            children: [
              const Icon(
                Icons.monetization_on,
                color: Color(0xFFE0A100),
                size: 18,
              ),
              const SizedBox(width: 4),
              // En el Row del footer, reemplaza el Text de monedas:
              Text(
                '+${mission.rewardCoins} ${AppLocalizations.of(context)!.missionsRewardCoins}',
                style: const TextStyle(
                  color: Color(0xFFC28B00),
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
              if (mission.plantRewardCommonName != null) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.local_florist,
                  color: Color(0xFF2F6B43),
                  size: 16,
                ),
                const SizedBox(width: 3),
                Text(
                  mission.plantRewardCommonName!,
                  style: const TextStyle(
                    color: Color(0xFF2F6B43),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
              const Spacer(),
              if (mission.isCompleted && onClaim != null)
                ElevatedButton(
                  onPressed: onClaim,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F6B43),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)!.missionsClaim),
                ),
              if (mission.isClaimed)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF9E9E9E),
                  size: 22,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StateBadge extends StatelessWidget {
  final String state;
  const _StateBadge({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final config = switch (state) {
      'COMPLETED' => (
        label: l10n.missionsTagCompleted,
        bg: const Color(0xFFDDF3D8),
        fg: const Color(0xFF237A3B),
      ),
      'CLAIMED' => (
        label: l10n.missionsTagClaimed,
        bg: Colors.grey.shade200,
        fg: Colors.grey.shade600,
      ),
      _ => (
        label: l10n.missionsInProgress,
        bg: const Color(0xFFFFF0C7),
        fg: const Color(0xFFB77900),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: config.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: config.fg,
        ),
      ),
    );
  }
}

class Mission {
  final String name;
  final String description;
  final int goal;
  final String action;
  final String? plantNeeded;
  final String? productNeeded;
  final String? plantRewardCommonName;
  final String? plantRewardScientificName;
  final int rewardCoins;
  final String? productReward;
  final String missionState;
  final int currentNumber;
  final DateTime? acquiredAt;

  Mission({
    required this.name,
    required this.description,
    required this.goal,
    required this.action,
    this.plantNeeded,
    this.productNeeded,
    this.plantRewardCommonName,
    this.plantRewardScientificName,
    required this.rewardCoins,
    this.productReward,
    required this.missionState,
    required this.currentNumber,
    this.acquiredAt,
  });

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      name: json['Name'] ?? '',
      description: json['Description'] ?? '',
      goal: json['Goal'] ?? 0,
      action: json['Action'] ?? '',
      plantNeeded: json['Plant needed scientific name'],
      productNeeded: json['Product needed'],
      plantRewardCommonName: json['Plant reward common name'],
      plantRewardScientificName: json['Plant reward scientific name'],
      rewardCoins: json['Reward coins'] ?? 0,
      productReward: json['Product reward'],
      missionState: (json['Mission state'] ?? 'in progress')
          .toString()
          .trim()
          .toUpperCase()
          .replaceAll(' ', '_'),
      currentNumber: json['Current number'] ?? 0,
      acquiredAt: json['acquired at'] != null
          ? DateTime.tryParse(json['acquired at'])
          : null,
    );
  }

  double get percentage =>
      goal > 0 ? (currentNumber / goal).clamp(0.0, 1.0) : 0.0;

  bool get isCompleted => missionState == 'COMPLETED';

  bool get isClaimed => missionState == 'CLAIMED';

  bool get isInProgress => missionState == 'IN_PROGRESS';
}

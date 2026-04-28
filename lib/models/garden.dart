class GardenPot {
  final int potNumber;
  final bool occupied;
  final PlantData? plant;
  final String? growthPhase;
  final double? healthLevel;
  final double? waterLevel;
  final DateTime? plantedAt;
  final DateTime? lastWateredAt;

  // Buff actiu (poció no instantània)
  final String? activeBuffName;
  final DateTime? buffExpiresAt;

  bool get hasBuff =>
      activeBuffName != null &&
      buffExpiresAt != null &&
      DateTime.now().isBefore(buffExpiresAt!);

  GardenPot({
    required this.potNumber,
    required this.occupied,
    required this.plant,
    required this.growthPhase,
    required this.healthLevel,
    required this.waterLevel,
    required this.plantedAt,
    required this.lastWateredAt,
    this.activeBuffName,
    this.buffExpiresAt,
  });

  factory GardenPot.fromJson(Map<String, dynamic> json) {
    return GardenPot(
      potNumber: json['pot_number'],
      occupied: json['occupied'],
      plant: json['plant'] != null ? PlantData.fromJson(json['plant']) : null,
      growthPhase: json['growth_phase'],
      healthLevel: json['health_level'] != null
          ? (json['health_level'] as num).toDouble()
          : null,
      waterLevel: json['water_level'] != null
          ? (json['water_level'] as num).toDouble()
          : null,
      plantedAt: json['planted_at'] != null
          ? DateTime.parse(json['planted_at'])
          : null,
      lastWateredAt: json['last_watered_at'] != null
          ? DateTime.parse(json['last_watered_at'])
          : null,
      activeBuffName: json['active_buff'] as String?,
      buffExpiresAt: json['buff_expires_at'] != null
          ? DateTime.parse(json['buff_expires_at'])
          : null,
    );
  }
}

class PlantData {
  final String scientificName;
  final String commonName;
  final String family;
  final bool canFlower;
  final double minTemperature;
  final double maxTemperature;
  final String? imageUrl;

  PlantData({
    required this.scientificName,
    required this.commonName,
    required this.family,
    required this.canFlower,
    required this.minTemperature,
    required this.maxTemperature,
    this.imageUrl,
  });

  factory PlantData.fromJson(Map<String, dynamic> json) {
    return PlantData(
      scientificName: json['scientific_name'],
      commonName: json['common_name'],
      family: json['family'],
      canFlower: json['can_flower'],
      minTemperature: (json['min_temperature'] as num).toDouble(),
      maxTemperature: (json['max_temperature'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
    );
  }
}

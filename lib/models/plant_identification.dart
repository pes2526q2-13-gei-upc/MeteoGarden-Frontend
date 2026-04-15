class PlantIdentification {
  final PlantData plant;
  final PlantImage image;
  final PlantNetData plantnet;

  PlantIdentification({
    required this.plant,
    required this.image,
    required this.plantnet,
  });

  factory PlantIdentification.fromJson(Map<String, dynamic> json) {
    return PlantIdentification(
      plant: PlantData.fromJson(json['plant'] ?? {}),
      image: PlantImage.fromJson(json['image'] ?? {}),
      plantnet: PlantNetData.fromJson(json['plantnet'] ?? {}),
    );
  }
}

class PlantData {
  final String scientificName;
  final String commonName;
  final String family;

  PlantData({
    required this.scientificName,
    required this.commonName,
    required this.family,
  });

  factory PlantData.fromJson(Map<String, dynamic> json) {
    return PlantData(
      scientificName: json['scientificName'] ?? '',
      commonName: json['commonName'] ?? '',
      family: json['family'] ?? '',
    );
  }
}

class PlantImage {
  final int? id;
  final String? url;
  final dynamic width;
  final dynamic height;

  PlantImage({
    required this.id,
    required this.url,
    required this.width,
    required this.height,
  });

  factory PlantImage.fromJson(Map<String, dynamic> json) {
    return PlantImage(
      id: json['id'],
      url: json['url'],
      width: json['width'],
      height: json['height'],
    );
  }
}

class PlantNetData {
  final double? score;

  PlantNetData({required this.score});

  factory PlantNetData.fromJson(Map<String, dynamic> json) {
    return PlantNetData(score: (json['score'] as num?)?.toDouble());
  }
}

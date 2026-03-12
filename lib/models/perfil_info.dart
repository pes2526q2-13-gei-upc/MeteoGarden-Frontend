class PerfilInfo {
  final String username;
  final String email;
  final String city;
  final int level;
  final int coins;
  final int plantsDiscovered;

  PerfilInfo({
    required this.username,
    required this.email,
    required this.city,
    required this.level,
    required this.coins,
    required this.plantsDiscovered,
  });

  factory PerfilInfo.fromJson(Map<String, dynamic> json) {
    return PerfilInfo(
      username: (json['username'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      city: (json['city'] ?? '') as String,
      level: (json['level'] as num? ?? 1).toInt(),
      coins: (json['coins'] as num? ?? 0).toInt(),
      plantsDiscovered: (json['plants_discovered'] as num? ?? 0).toInt(),
    );
  }
}

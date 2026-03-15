class WeatherInfo {
  final double temp;
  final String condition;
  final double wind;

  WeatherInfo({
    required this.temp,
    required this.condition,
    required this.wind,
  });

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    return WeatherInfo(
      temp: (json['temp'] as num).toDouble(),
      condition: json['condition'] as String,
      wind: (json['wind'] as num).toDouble(),
    );
  }
}

class WeatherInfo {
  final String stationName;
  final double temp;
  final String precipitation;
  final double wind;

  WeatherInfo({
    required this.stationName,
    required this.temp,
    required this.precipitation,
    required this.wind,
  });

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    return WeatherInfo(
      stationName: json['stationName']?.toString() ?? '',
      temp: double.tryParse(json['temperature'].toString()) ?? 0.0,
      precipitation: json['precipitation']?.toString() ?? '',
      wind: double.tryParse(json['wind']?.toString() ?? '0') ?? 0.0,
    );
  }
}

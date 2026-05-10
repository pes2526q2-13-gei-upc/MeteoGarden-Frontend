class WeatherInfo {
  final String stationName;
  final double temp;
  final String precipitation;
  final double wind;
  final double solarIrradiance;
  final double relativeHumidity;

  WeatherInfo({
    required this.stationName,
    required this.temp,
    required this.precipitation,
    required this.wind,
    required this.solarIrradiance,
    required this.relativeHumidity,
  });

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    return WeatherInfo(
      stationName: json['stationName']?.toString() ?? '',
      temp: double.tryParse(json['temperature'].toString()) ?? 0.0,
      precipitation: json['precipitation']?.toString() ?? '0',
      wind: double.tryParse(json['wind']?.toString() ?? '0') ?? 0.0,
      solarIrradiance:
          double.tryParse(json['solarIrradiance']?.toString() ?? '0') ?? 0.0,
      relativeHumidity:
          double.tryParse(json['relativeHumidity']?.toString() ?? '0') ?? 0.0,
    );
  }
}

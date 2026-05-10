import 'package:flutter/material.dart';
import '../models/weather_info.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  // Aquí se guarda TODO el objeto con sus nuevos campos
  WeatherInfo? _currentWeather;
  bool _isLoading = false;
  String? _error;

  WeatherInfo? get currentWeather => _currentWeather;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Obtiene el tiempo. Si `forceRefresh` es true, ignora la caché y llama a la API.
  Future<void> fetchWeather(String city, {bool forceRefresh = false}) async {
    // Si ya tenemos datos y no estamos forzando la recarga, evitamos la llamada a la API
    if (_currentWeather != null && !forceRefresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Al llamar al servicio, este devolverá el WeatherInfo actualizado con todos los datos
      _currentWeather = await WeatherService.fetchCurrent(city: city);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

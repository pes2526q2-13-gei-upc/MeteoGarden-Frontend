import 'package:flutter/material.dart';
import '../models/weather_info.dart';
import '../services/weather_service.dart';

typedef FetchWeatherFunction =
    Future<WeatherInfo> Function({required String city, required String token});

class WeatherProvider extends ChangeNotifier {
  WeatherProvider({FetchWeatherFunction? fetchWeatherFunction})
    : _fetchWeatherFunction =
          fetchWeatherFunction ?? WeatherService().fetchCurrent;

  final FetchWeatherFunction _fetchWeatherFunction;

  bool _disposed = false;

  WeatherInfo? _currentWeather;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _notifyIfActive() {
    if (!_disposed) notifyListeners();
  }

  WeatherInfo? get currentWeather => _currentWeather;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchWeather(
    String city, {
    required String token,
    bool forceRefresh = false,
  }) async {
    if (_currentWeather != null && !forceRefresh) return;

    _isLoading = true;
    _error = null;
    _notifyIfActive();

    try {
      _currentWeather = await _fetchWeatherFunction(city: city, token: token);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _notifyIfActive();
    }
  }
}

import 'package:flutter/material.dart';
import '../models/weather_info.dart';
import '../services/weather_service.dart';

typedef FetchWeatherFunction = Future<WeatherInfo> Function({required String city});

class WeatherProvider extends ChangeNotifier {
  WeatherProvider({
    FetchWeatherFunction? fetchWeatherFunction,
  }) : _fetchWeatherFunction =
            fetchWeatherFunction ?? WeatherService().fetchCurrent;

  final FetchWeatherFunction _fetchWeatherFunction;

  WeatherInfo? _currentWeather;
  bool _isLoading = false;
  String? _error;

  WeatherInfo? get currentWeather => _currentWeather;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchWeather(String city, {bool forceRefresh = false}) async {
    if (_currentWeather != null && !forceRefresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentWeather = await _fetchWeatherFunction(city: city);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
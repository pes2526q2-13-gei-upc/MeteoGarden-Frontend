import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather_provider.dart'; // Revisa si es models o providers según tu proyecto
import '../widgets/app_header.dart';
import '../models/weather_info.dart';
import 'package:meteo_garden/generated/app_localizations.dart';

class WeatherDetailsPage extends StatelessWidget {
  const WeatherDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final w = weatherProvider.currentWeather;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F0),
      body: Column(
        children: [
          // QUITAMOS EL CONST AQUÍ porque l10n es dinámico
          AppHeader(title: l10n.weatherDetailsTitle),

          Expanded(
            child: w == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Pasamos l10n como parámetro a los métodos
                        _buildHeaderCard(w.stationName, l10n),
                        const SizedBox(height: 24),
                        _buildMetricsGrid(w, l10n),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // Añadimos AppLocalizations l10n a los parámetros
  Widget _buildHeaderCard(String stationName, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF4CAF50).withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on,
              color: Color(0xFF2E7D32),
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          // QUITAMOS EL CONST del Text, pero se lo dejamos al TextStyle
          Text(
            l10n.weatherStationLabel,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stationName.isNotEmpty
                ? stationName
                : 'Desconocida', // Si tienes 'unknown' en l10n, cámbialo aquí también
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1B5E20),
            ),
          ),
        ],
      ),
    );
  }

  // Añadimos AppLocalizations l10n a los parámetros
  Widget _buildMetricsGrid(WeatherInfo w, AppLocalizations l10n) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.1,
      children: [
        _buildMetricCard(
          icon: Icons.thermostat,
          title: l10n.temperatureLabel,
          value: '${w.temp.toStringAsFixed(1)} °C',
          color: Colors.orange,
        ),
        _buildMetricCard(
          icon: Icons.water_drop,
          title: l10n.humidityLabel,
          value: '${w.relativeHumidity.toStringAsFixed(0)} %',
          color: Colors.blue,
        ),
        _buildMetricCard(
          icon: Icons.air,
          title: l10n.windLabel,
          value: '${w.wind.toStringAsFixed(1)} km/h',
          color: Colors.teal,
        ),
        _buildMetricCard(
          icon: Icons.umbrella,
          title: l10n.precipitationLabel,
          value: '${w.precipitation} mm',
          color: Colors.indigo,
        ),
        _buildMetricCard(
          icon: Icons.wb_sunny,
          title: l10n.solarIrradianceLabel,
          value: '${w.solarIrradiance.toStringAsFixed(1)} W/m²',
          color: Colors.amber.shade700,
        ),
      ],
    );
  }

  // Este método no necesita l10n porque los textos ya le llegan traducidos en el parámetro "title"
  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }
}

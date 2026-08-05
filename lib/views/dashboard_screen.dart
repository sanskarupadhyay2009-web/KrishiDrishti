// lib/views/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/crop_health_provider.dart';
import '../providers/language_provider.dart';
import '../providers/sensor_provider.dart';
import '../services/recommendation_service.dart';
import '../services/weather_service.dart';
import '../widgets/recommendation_card.dart';
import '../widgets/simple_line_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic> _weather = {'temp': 30.2, 'description': 'Partly Cloudy', 'rain_prob': '20%'};
  bool _isLoadingWeather = true;
  bool _isLoadingRecommendations = true;
  bool _hasLoadedRecommendations = false;
  List<Recommendation> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedRecommendations) {
      _hasLoadedRecommendations = true;
      _loadRecommendations();
    }
  }

  Future<void> _loadWeather() async {
    final service = WeatherService();
    final weather = await service.fetchCurrentWeather(22.0, 78.0);
    if (mounted) {
      setState(() {
        _weather = weather;
        _isLoadingWeather = false;
      });
    }
  }

  Future<void> _loadRecommendations() async {
    final sensorProvider = Provider.of<SensorProvider>(context, listen: false);
    final cropProvider = Provider.of<CropHealthProvider>(context, listen: false);
    final service = RecommendationService();

    setState(() {
      _isLoadingRecommendations = true;
    });

    final results = await service.generateRecommendations(
      sensorData: sensorProvider.currentData,
      cropHealthSummary: cropProvider.lastDiagnosis,
      weatherData: _weather,
      languageCode: Provider.of<LanguageProvider>(context, listen: false).languageCode,
    );

    if (!mounted) return;
    setState(() {
      _recommendations = results;
      _isLoadingRecommendations = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LanguageProvider>().strings;
    final sensorProvider = context.watch<SensorProvider>();
    final sensor = sensorProvider.currentData;
    final statusLabel = sensorProvider.isDebugMode ? strings.mockingActive : strings.bleConnected;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.dashboard),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(child: Text(statusLabel)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings.hardwareStatus, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: Text(statusLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(strings.hardwareSummary),
                leading: Icon(
                  sensorProvider.isDebugMode ? Icons.developer_mode : Icons.bluetooth,
                  color: sensorProvider.isDebugMode ? Colors.orange : Colors.green,
                ),
                trailing: Text(sensorProvider.statusMessage),
              ),
            ),
            const SizedBox(height: 16),
            Text(strings.weather, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _isLoadingWeather
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${strings.temperature}: ${_weather['temp'].toString()}°C', style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('${strings.weather}: ${_weather['description']}', style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('${strings.rainProbability}: ${_weather['rain_prob']}', style: const TextStyle(fontSize: 16)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Text(strings.soilMoisture, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _buildGaugeCard('${sensor.moisture.toStringAsFixed(1)}%', sensor.moisture, 20, 50, Colors.blue),
            const SizedBox(height: 12),
            _buildGaugeCard(sensor.ph.toStringAsFixed(1), sensor.ph, 6.0, 7.5, Colors.green),
            const SizedBox(height: 12),
            _buildGaugeCard(
              '${sensor.nitrogen.toStringAsFixed(0)} / ${sensor.phosphorus.toStringAsFixed(0)} / ${sensor.potassium.toStringAsFixed(0)}',
              (sensor.nitrogen + sensor.phosphorus + sensor.potassium) / 3,
              10,
              60,
              Colors.brown,
            ),
            const SizedBox(height: 20),
            if (sensorProvider.history.isNotEmpty) ...[
              Text('Sensor Trends', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              SimpleLineChart(
                title: 'Moisture',
                values: sensorProvider.history.map((reading) => reading.moisture).toList().reversed.toList(),
                color: Colors.blue,
                unit: '%',
              ),
              const SizedBox(height: 12),
              SimpleLineChart(
                title: 'Temperature',
                values: sensorProvider.history.map((reading) => reading.temperature).toList().reversed.toList(),
                color: Colors.orange,
                unit: '°C',
              ),
              const SizedBox(height: 12),
              SimpleLineChart(
                title: 'pH',
                values: sensorProvider.history.map((reading) => reading.ph).toList().reversed.toList(),
                color: Colors.green,
                unit: '',
              ),
            ],
            const SizedBox(height: 20),
            Text('Recommendations', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (_isLoadingRecommendations)
              const Center(child: CircularProgressIndicator())
            else if (_recommendations.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('No recommendations available yet.'),
                ),
              )
            else
              ..._recommendations.map((recommendation) => RecommendationCard(recommendation: recommendation)),
            const SizedBox(height: 20),
            _buildRuleEngineBanner(sensor, strings),
          ],
        ),
      ),
    );
  }

  Widget _buildGaugeCard(String label, double value, double min, double max, Color color) {
    final normalized = ((value - min) / (max - min)).clamp(0.0, 1.0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: normalized, color: color, backgroundColor: color.withValues(alpha: 0.2)),
            const SizedBox(height: 8),
            Text(value.toStringAsFixed(1), style: const TextStyle(fontSize: 14, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleEngineBanner(dynamic sensor, dynamic strings) {
    final shouldAlert = sensor.moisture < 30;
    return Card(
      color: shouldAlert ? Colors.red.shade600 : Colors.green.shade600,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          shouldAlert ? strings.criticalMoistureAlert : strings.normalSoil,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

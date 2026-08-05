// lib/views/history_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/crop_health_provider.dart';
import '../providers/language_provider.dart';
import '../providers/sensor_provider.dart';
import '../services/recommendation_service.dart';
import '../widgets/recommendation_card.dart';
import '../widgets/simple_line_chart.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isLoadingRecommendations = true;
  bool _hasLoadedRecommendations = false;
  List<Recommendation> _recommendations = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedRecommendations) {
      _hasLoadedRecommendations = true;
      _loadRecommendations();
    }
  }

  Future<void> _loadRecommendations() async {
    final sensorProvider = context.read<SensorProvider>();
    final cropHealthProvider = context.read<CropHealthProvider>();
    final service = RecommendationService();

    setState(() {
      _isLoadingRecommendations = true;
    });

    final results = await service.generateRecommendations(
      sensorData: sensorProvider.currentData,
      cropHealthSummary: cropHealthProvider.lastDiagnosis,
      weatherData: {'temp': 30.2, 'description': 'Partly Cloudy', 'rain_prob': '20%'},
      languageCode: context.read<LanguageProvider>().languageCode,
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
    final history = context.watch<SensorProvider>().history;

    return Scaffold(
      appBar: AppBar(title: Text(strings.history)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: history.isEmpty
            ? Center(child: Text('No history available yet.'))
            : SingleChildScrollView(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(strings.history, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  ...history.map((reading) {
                    return Card(
                      child: ListTile(
                        title: Text('Moisture: ${reading.moisture.toStringAsFixed(1)}% • pH: ${reading.ph.toStringAsFixed(1)}'),
                        subtitle: Text('Temp: ${reading.temperature.toStringAsFixed(1)}°C • ${reading.timestamp.toLocal()}'),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  Text('Trend Charts', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  SimpleLineChart(
                    title: 'Moisture over time',
                    values: history.map((reading) => reading.moisture).toList().reversed.toList(),
                    color: Colors.blue,
                    unit: '%',
                  ),
                  const SizedBox(height: 12),
                  SimpleLineChart(
                    title: 'pH over time',
                    values: history.map((reading) => reading.ph).toList().reversed.toList(),
                    color: Colors.green,
                    unit: '',
                  ),
                  const SizedBox(height: 12),
                  SimpleLineChart(
                    title: 'Temperature over time',
                    values: history.map((reading) => reading.temperature).toList().reversed.toList(),
                    color: Colors.orange,
                    unit: '°C',
                  ),
                  const SizedBox(height: 16),
                  Text('AI Recommendations', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  if (_isLoadingRecommendations)
                    const Center(child: CircularProgressIndicator())
                  else if (_recommendations.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('No recommendations available.'),
                      ),
                    )
                  else
                    ..._recommendations.map((recommendation) => RecommendationCard(recommendation: recommendation)),
                ]),
              ),
      ),
    );
  }
}

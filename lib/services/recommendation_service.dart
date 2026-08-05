import 'package:flutter/foundation.dart';
import '../models/sensor_data.dart';
import 'gemini_service.dart';

class Recommendation {
  final String title;
  final String detail;

  Recommendation({required this.title, required this.detail});
}

class RecommendationService {
  final GeminiService _geminiService;

  RecommendationService({GeminiService? geminiService})
      : _geminiService = geminiService ?? GeminiService();

  Future<List<Recommendation>> generateRecommendations({
    required SensorData sensorData,
    required String cropHealthSummary,
    required Map<String, dynamic> weatherData,
    required String languageCode,
  }) async {
    if (!_geminiService.isAvailable) {
      return [
        Recommendation(
          title: 'Gemini unavailable',
          detail: 'Add GEMINI_API_KEY to .env to enable smart recommendations.',
        ),
      ];
    }

    final prompt = '''You are an agricultural advisor. Analyze the current sensor telemetry and crop health status to generate a concise action plan in ${_geminiService.languageName(languageCode)}.

Current farm status:
- Soil moisture: ${sensorData.moisture.toStringAsFixed(1)}%
- Soil pH: ${sensorData.ph.toStringAsFixed(2)}
- Nitrogen: ${sensorData.nitrogen.toStringAsFixed(1)} mg/kg
- Phosphorus: ${sensorData.phosphorus.toStringAsFixed(1)} mg/kg
- Potassium: ${sensorData.potassium.toStringAsFixed(1)} mg/kg
- Ambient temperature: ${sensorData.temperature.toStringAsFixed(1)}°C
- Weather: ${weatherData['description'] ?? 'Unknown'}, temperature ${weatherData['temp']?.toString() ?? 'N/A'}°C, rain chance ${weatherData['rain_prob'] ?? 'N/A'}.
- Crop health summary: ${cropHealthSummary.isEmpty ? 'No scan available' : cropHealthSummary}

Provide clear recommendations in three sections: Irrigation Schedule, Fertilizer/NPK Adjustment, Pest and Disease Prevention. Use actionable bullets and mention water duration/volume, fertilizer type, and preventive measures.
''';

    try {
      final result = await _geminiService.generateText(prompt, languageCode);
      return _parseRecommendations(result);
    } catch (e, stackTrace) {
      debugPrint('Recommendation generation failed: $e');
      debugPrint(stackTrace.toString());
      return [
        Recommendation(
          title: 'Recommendation unavailable',
          detail: 'The AI engine could not generate guidance right now. Please try again later.',
        ),
      ];
    }
  }

  List<Recommendation> _parseRecommendations(String text) {
    final lines = text.replaceAll('\r', '').split('\n');
    final List<Recommendation> recommendations = [];
    String currentTitle = 'Action Plan';
    final currentLines = <String>[];

    void saveCurrent() {
      if (currentLines.isNotEmpty) {
        final detail = currentLines.join(' ').trim();
        if (detail.isNotEmpty) {
          recommendations.add(Recommendation(title: currentTitle, detail: detail));
        }
        currentLines.clear();
      }
    }

    for (var rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) {
        continue;
      }
      if (line.toLowerCase().startsWith('irrigation')) {
        saveCurrent();
        currentTitle = 'Irrigation Schedule';
        final headingText = line.replaceFirst(RegExp(r'^[^:]+:?\s*', caseSensitive: false), '');
        if (headingText.isNotEmpty) {
          currentLines.add(headingText);
        }
        continue;
      }
      if (line.toLowerCase().contains('fertilizer') || line.toLowerCase().contains('npk')) {
        saveCurrent();
        currentTitle = 'Fertilizer / NPK Adjustment';
        final headingText = line.replaceFirst(RegExp(r'^[^:]+:?\s*', caseSensitive: false), '');
        if (headingText.isNotEmpty) {
          currentLines.add(headingText);
        }
        continue;
      }
      if (line.toLowerCase().contains('pest') || line.toLowerCase().contains('disease')) {
        saveCurrent();
        currentTitle = 'Pest and Disease Prevention';
        final headingText = line.replaceFirst(RegExp(r'^[^:]+:?\s*', caseSensitive: false), '');
        if (headingText.isNotEmpty) {
          currentLines.add(headingText);
        }
        continue;
      }
      currentLines.add(line.replaceFirst(RegExp(r'^[-*\d\.\)\s]+'), '- ').trim());
    }
    saveCurrent();

    if (recommendations.isEmpty) {
      recommendations.add(Recommendation(title: 'Action Plan', detail: text.trim()));
    }
    return recommendations;
  }
}

// lib/services/gemini_service.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import '../models/sensor_data.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService({String? apiKey}) {
    final key = apiKey ?? dotenv.env['GEMINI_API_KEY'] ?? '';
    if (key.isEmpty) {
      throw Exception('GEMINI_API_KEY is not set. Please add it to your .env file.');
    }
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: key);
  }

  Future<String> diagnoseCropImage(XFile imageFile, String languageCode) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final promptText = '''Please examine this leaf image and provide the following information in ${_languageName(languageCode)}:

1. Disease Name
2. Primary Cause
3. Organic or chemical treatment recommendations
''';
      final response = await _model.generateContent([
        Content.multi([
          TextPart(promptText),
          DataPart('image/jpeg', bytes),
        ])
      ]);

      return response.text ?? _defaultErrorMessage(languageCode);
    } catch (_) {
      return _defaultErrorMessage(languageCode);
    }
  }

  Future<String> askContextAwareAdvice({
    required SensorData sensorData,
    required Map<String, dynamic> weatherData,
    required String userQuestion,
    required String languageCode,
  }) async {
    final prompt = '''You are a farming assistant. Respond strictly in the user's language: $languageCode.
Use the latest sensor readings and weather details when answering.

Sensor readings:
- Nitrogen: ${sensorData.nitrogen.toStringAsFixed(1)} mg/kg
- Phosphorus: ${sensorData.phosphorus.toStringAsFixed(1)} mg/kg
- Potassium: ${sensorData.potassium.toStringAsFixed(1)} mg/kg
- Moisture: ${sensorData.moisture.toStringAsFixed(1)}%
- pH: ${sensorData.ph.toStringAsFixed(1)}
Weather details:
- Temperature: ${weatherData['temp']?.toString() ?? 'N/A'}°C
- Conditions: ${weatherData['description'] ?? 'N/A'}
- Rain probability: ${weatherData['rain_prob'] ?? 'N/A'}
User question: $userQuestion
''';

    try {
      final response = await _model.generateContent([
        Content.text(prompt),
      ]);
      return response.text ?? _defaultErrorMessage(languageCode);
    } catch (_) {
      return _defaultErrorMessage(languageCode);
    }
  }

  String _languageName(String languageCode) {
    switch (languageCode) {
      case 'hi':
        return 'Hindi';
      case 'mr':
        return 'Marathi';
      default:
        return 'English';
    }
  }

  String _defaultErrorMessage(String languageCode) {
    switch (languageCode) {
      case 'hi':
        return 'चित्र का विश्लेषण करने में समस्या आ रही है। कृपया बाद में पुनः प्रयास करें।';
      case 'mr':
        return 'प्रतिमा विश्लेषित करण्यात अडचण येत आहे. कृपया नंतर पुन्हा प्रयत्न करा.';
      default:
        return 'Unable to analyze the image right now. Please try again later.';
    }
  }
}

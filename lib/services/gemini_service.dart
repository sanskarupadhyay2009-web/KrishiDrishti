// lib/services/gemini_service.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

import '../models/sensor_data.dart';

class GeminiService {
  final GenerativeModel? _model;

  GeminiService({String? apiKey}) : _model = _createModel(apiKey);

  static GenerativeModel? _createModel(String? apiKey) {
    final key = apiKey ?? dotenv.get('GEMINI_API_KEY', fallback: '');
    debugPrint('GeminiService setup: key loaded=${key.isNotEmpty}, length=${key.length}');
    if (key.isEmpty) {
      debugPrint('Gemini API key is missing.');
      return null;
    }
    return GenerativeModel(model: 'gemini-pro', apiKey: key);
  }

  bool get isAvailable => _model != null;

  String languageName(String languageCode) {
    switch (languageCode) {
      case 'hi':
        return 'Hindi';
      case 'mr':
        return 'Marathi';
      default:
        return 'English';
    }
  }

  Future<String> generateText(String prompt, String languageCode) async {
    if (_model == null) {
      return languageCode == 'hi'
          ? 'जीमिनी एपीआई कुंजी उपलब्ध नहीं है। कृपया .env फ़ाइल में GEMINI_API_KEY जोड़ें।'
          : languageCode == 'mr'
              ? 'Gemini API की अनुपलब्ध आहे. कृपया .env फाइलमध्ये GEMINI_API_KEY जोडा.'
              : 'Gemini API key is unavailable. Please add GEMINI_API_KEY to your .env file.';
    }

    try {
      final response = await _model.generateContent([
        Content.text(prompt),
      ]);
      return _responseText(response) ?? _defaultErrorMessage(languageCode);
    } catch (e, stackTrace) {
      debugPrint('Gemini generateText failed: $e');
      debugPrint(stackTrace.toString());
      return _defaultErrorMessage(languageCode);
    }
  }

  Future<String> diagnoseCropImage(XFile imageFile, String languageCode) async {
    final bytes = await imageFile.readAsBytes();
    if (bytes.isEmpty) {
      return languageCode == 'hi'
          ? 'चयनित छवि अमान्य है। कृपया फिर से प्रयास करें।'
          : languageCode == 'mr'
              ? 'निवडलेली प्रतिमा अवैध आहे. कृपया पुन्हा प्रयत्न करा.'
              : 'Selected image is invalid. Please try again.';
    }

    if (_model == null) {
      return languageCode == 'hi'
          ? 'जीमिनी एपीआई कुंजी उपलब्ध नहीं है। कृपया .env फ़ाइल में GEMINI_API_KEY जोड़ें।'
          : languageCode == 'mr'
              ? 'Gemini API की अनुपलब्ध आहे. कृपया .env फाइलमध्ये GEMINI_API_KEY जोडा.'
              : 'Gemini API key is unavailable. Please add GEMINI_API_KEY to your .env file.';
    }

    try {
      final promptText = '''Please examine this leaf image and provide the following information in ${languageName(languageCode)}:

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

      return _responseText(response) ?? _defaultErrorMessage(languageCode);
    } catch (e, stackTrace) {
      debugPrint('Gemini Error: $e');
      debugPrint(stackTrace.toString());
      return _defaultErrorMessage(languageCode);
    }
  }

  Future<String> askContextAwareAdvice({
    required SensorData sensorData,
    required Map<String, dynamic> weatherData,
    required String userQuestion,
    required String languageCode,
  }) async {
    if (_model == null) {
      return languageCode == 'hi'
          ? 'जीमिनी एपीआई कुंजी उपलब्ध नहीं है। कृपया .env फ़ाइल में GEMINI_API_KEY जोड़ें।'
          : languageCode == 'mr'
              ? 'Gemini API की अनुपलब्ध आहे. कृपया .env फाइलमध्ये GEMINI_API_KEY जोडा.'
              : 'Gemini API key is unavailable. Please add GEMINI_API_KEY to your .env file.';
    }

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
      return _responseText(response) ?? _defaultErrorMessage(languageCode);
    } catch (e, stackTrace) {
      debugPrint('Gemini Error: $e');
      debugPrint(stackTrace.toString());
      return _defaultErrorMessage(languageCode);
    }
  }

  String? _responseText(GenerateContentResponse response) {
    try {
      final text = response.text;
      if (text != null && text.isNotEmpty) {
        return text;
      }
    } catch (e) {
      debugPrint('response.text threw: $e');
    }

    for (final candidate in response.candidates) {
      for (final part in candidate.content.parts) {
        if (part is TextPart && part.text.isNotEmpty) {
          return part.text;
        }
      }
    }
    return null;
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

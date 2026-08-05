import 'dart:io';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

/// Enhanced Gemini Service for multi-modal AI interactions
/// Supports: Text, Voice transcription, Image analysis
class GeminiService {
  late GenerativeModel _model;
  final String _apiKey;
  bool _isInitialized = false;
  String _lastError = '';

  // Singleton pattern
  static final GeminiService _instance = GeminiService._internal();

  factory GeminiService({required String apiKey}) {
    _instance._apiKey = apiKey;
    return _instance;
  }

  GeminiService._internal() : _apiKey = '';

  /// Initialize the Gemini model
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
      );
      _isInitialized = true;
      debugPrint('[Gemini] Service initialized successfully');
    } catch (e) {
      _lastError = 'Failed to initialize Gemini: $e';
      debugPrint('[Gemini Error] $_lastError');
      rethrow;
    }
  }

  /// Analyze crop health from image
  /// Returns: {disease, cause, treatment_organic, treatment_chemical}
  Future<Map<String, String>> analyzeCropHealth(File imageFile) async {
    if (!_isInitialized) await initialize();

    try {
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final prompt = '''
Analyze this crop/plant image and provide detailed information in JSON format.
Return ONLY valid JSON with these exact keys:

{
  "disease": "Name of detected disease or 'Healthy'",
  "disease_description": "Brief description of the condition",
  "cause": "Root cause of the issue",
  "confidence": "Confidence level (High/Medium/Low)",
  "treatment_organic": "Organic treatment recommendations",
  "treatment_chemical": "Chemical treatment recommendations",
  "prevention": "Prevention tips for future",
  "severity": "Severity level (Critical/High/Medium/Low)",
  "action_needed": "Immediate action required or monitoring needed"
}

Be precise and farmer-friendly in your recommendations.
''';

      final response = await _model.generateContent([
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ]);

      if (response.text == null || response.text!.isEmpty) {
        return {
          'error': 'No response from AI',
          'disease': 'Unable to analyze',
          'cause': 'Please try again',
          'treatment_organic': 'Contact agricultural expert',
          'treatment_chemical': 'Contact agricultural expert',
        };
      }

      // Parse JSON response
      String jsonText = response.text!;

      // Remove markdown code blocks if present
      if (jsonText.contains('```json')) {
        jsonText = jsonText.replaceAll('```json', '').replaceAll('```', '');
      }
      if (jsonText.contains('```')) {
        jsonText = jsonText.replaceAll('```', '');
      }

      jsonText = jsonText.trim();

      final parsedResponse = jsonDecode(jsonText) as Map<String, dynamic>;

      return {
        'disease': parsedResponse['disease'] ?? 'Unknown',
        'cause': parsedResponse['cause'] ?? 'Unable to determine',
        'treatment_organic': parsedResponse['treatment_organic'] ??
            'Consult local agricultural expert',
        'treatment_chemical': parsedResponse['treatment_chemical'] ??
            'Consult local agricultural expert',
        'disease_description': parsedResponse['disease_description'] ?? '',
        'confidence': parsedResponse['confidence'] ?? 'Medium',
        'prevention': parsedResponse['prevention'] ?? '',
        'severity': parsedResponse['severity'] ?? 'Unknown',
        'action_needed': parsedResponse['action_needed'] ?? 'Monitor closely',
      };
    } catch (e) {
      _lastError = 'Error analyzing crop: $e';
      debugPrint('[Gemini Error] $_lastError');
      return {
        'error': _lastError,
        'disease': 'Analysis Failed',
        'cause': 'Technical error occurred',
        'treatment_organic': 'Please try again or contact support',
        'treatment_chemical': 'Please try again or contact support',
      };
    }
  }

  /// Get agricultural advice based on sensor data and user question
  /// sensorData format: {moisture: %, pH: value, temperature: celsius}
  /// weatherData format: {temp: celsius, description: string, humidity: %}
  Future<String> getAgriculturalAdvice({
    required Map<String, double> sensorData,
    required Map<String, dynamic> weatherData,
    required String cropName,
    required String userQuestion,
    required String language, // 'en' or 'hi'
  }) async {
    if (!_isInitialized) await initialize();

    try {
      final languageInstruction =
          language == 'hi' ? 'हिंदी में उत्तर दें' : 'Answer in English';

      final prompt = '''
You are an expert agricultural advisor. Analyze the following data and answer the farmer's question.

Current Soil Conditions:
- Moisture: ${sensorData['moisture']?.toStringAsFixed(1)}%
- pH Level: ${sensorData['ph']?.toStringAsFixed(1)}
- Temperature: ${sensorData['temperature']?.toStringAsFixed(1)}°C

Weather Conditions:
- Temperature: ${weatherData['temp']}°C
- Conditions: ${weatherData['description']}
- Humidity: ${weatherData['humidity'] ?? 'N/A'}%

Crop: $cropName
Farmer's Question: $userQuestion

Provide practical, actionable advice that is:
1. Specific to the current conditions
2. Farmer-friendly and easy to understand
3. Considering both soil and weather data
4. Including any urgent actions needed

$languageInstruction
''';

      final response = await _model.generateContent([
        Content.multi([TextPart(prompt)])
      ]);

      if (response.text == null || response.text!.isEmpty) {
        return 'Unable to generate advice. Please try again.';
      }

      return response.text!;
    } catch (e) {
      _lastError = 'Error generating advice: $e';
      debugPrint('[Gemini Error] $_lastError');
      return 'Error: Could not generate advice. Please try again.';
    }
  }

  /// Chat with AI about farming topics
  Future<String> chat({
    required String message,
    required String language, // 'en' or 'hi'
    List<ChatMessage> conversationHistory = const [],
  }) async {
    if (!_isInitialized) await initialize();

    try {
      final languageInstruction =
          language == 'hi' ? 'हिंदी में उत्तर दें' : 'Answer in English';

      final systemPrompt = '''
You are KrishiDrishti, an expert agricultural advisor AI assistant.
Your role is to help farmers with:
- Crop health issues
- Soil management
- Water and irrigation advice
- Pest and disease management
- Seasonal farming recommendations
- Weather-based farming decisions
- Sustainable farming practices

Always provide:
1. Clear, practical advice
2. Local context when possible
3. Safety warnings when needed
4. Simple explanations suitable for farmers of all literacy levels

$languageInstruction
''';

      // Build conversation history
      final contents = <Content>[];

      // Add conversation history
      for (var msg in conversationHistory) {
        if (msg.isUser) {
          contents.add(Content.text(msg.text));
        } else {
          contents.add(Content.model([TextPart(msg.text)]));
        }
      }

      // Add current message
      contents.add(Content.text('$systemPrompt\n\n$message'));

      final response = await _model.generateContent(contents);

      if (response.text == null || response.text!.isEmpty) {
        return 'I could not generate a response. Please try again.';
      }

      return response.text!;
    } catch (e) {
      _lastError = 'Error in chat: $e';
      debugPrint('[Gemini Error] $_lastError');
      return 'Error: Could not process your message. Please try again.';
    }
  }

  /// Process voice input text and generate response
  /// voiceText: Transcribed text from speech-to-text
  Future<String> processVoiceInput({
    required String voiceText,
    required String language,
    required Map<String, double>? sensorData,
    required Map<String, dynamic>? weatherData,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      String contextPrompt = '';

      if (sensorData != null && weatherData != null) {
        contextPrompt = '''
User's current environment context:
- Soil Moisture: ${sensorData['moisture']?.toStringAsFixed(1)}%
- Soil pH: ${sensorData['ph']?.toStringAsFixed(1)}
- Soil Temperature: ${sensorData['temperature']?.toStringAsFixed(1)}°C
- Weather: ${weatherData['description']}
- Air Temperature: ${weatherData['temp']}°C
''';
      }

      final languageInstruction =
          language == 'hi' ? 'हिंदी में उत्तर दें' : 'Answer in English';

      final prompt = '''
$contextPrompt

The farmer said (via voice): "$voiceText"

Respond as an agricultural advisor. Keep your response concise (2-3 sentences) and farmer-friendly.
$languageInstruction
''';

      final response = await _model.generateContent([
        Content.multi([TextPart(prompt)])
      ]);

      if (response.text == null || response.text!.isEmpty) {
        return 'I did not understand. Could you please repeat?';
      }

      return response.text!;
    } catch (e) {
      _lastError = 'Error processing voice: $e';
      debugPrint('[Gemini Error] $_lastError');
      return 'Error processing voice input. Please try again.';
    }
  }

  /// Generate fertilizer recommendations
  Future<String> getFertilizerRecommendation({
    required String cropName,
    required Map<String, double> soilData, // {ph, moisture, nitrogen, phosphorus, potassium}
    required String language,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      final languageInstruction =
          language == 'hi' ? 'हिंदी में उत्तर दें' : 'Answer in English';

      final prompt = '''
Based on the following soil analysis, recommend appropriate fertilizers for growing $cropName:

Soil Data:
- pH: ${soilData['ph']?.toStringAsFixed(1)}
- Moisture: ${soilData['moisture']?.toStringAsFixed(1)}%
- Nitrogen (N): ${soilData['nitrogen']?.toStringAsFixed(1)} mg/kg
- Phosphorus (P): ${soilData['phosphorus']?.toStringAsFixed(1)} mg/kg
- Potassium (K): ${soilData['potassium']?.toStringAsFixed(1)} mg/kg

Provide recommendations in JSON format:
{
  "organic_fertilizers": ["list", "of", "recommendations"],
  "chemical_fertilizers": ["list", "with", "quantities"],
  "application_schedule": "timing and frequency",
  "precautions": "safety and environmental considerations",
  "expected_results": "expected improvements"
}

$languageInstruction
''';

      final response = await _model.generateContent([
        Content.multi([TextPart(prompt)])
      ]);

      if (response.text == null || response.text!.isEmpty) {
        return 'Unable to generate fertilizer recommendation. Please try again.';
      }

      return response.text!;
    } catch (e) {
      _lastError = 'Error generating fertilizer recommendation: $e';
      debugPrint('[Gemini Error] $_lastError');
      return 'Error: Could not generate recommendation. Please try again.';
    }
  }

  String get lastError => _lastError;
  bool get isInitialized => _isInitialized;
}

/// Chat message model for conversation history
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}


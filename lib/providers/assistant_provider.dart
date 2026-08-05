// lib/providers/assistant_provider.dart

import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/sensor_data.dart';
import '../services/gemini_service.dart';

class AssistantProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  final GeminiService _geminiService = GeminiService();
  bool _isLoading = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  void addUserMessage(String content) {
    _messages.add(ChatMessage(content: content, isUser: true));
    notifyListeners();
  }

  void addAiMessage(String content) {
    _messages.add(ChatMessage(content: content, isUser: false));
    notifyListeners();
  }

  Future<void> sendMessage(
    String userQuestion,
    SensorData currentData,
    Map<String, dynamic> weather,
    String languageCode,
  ) async {
    if (userQuestion.trim().isEmpty) {
      return;
    }
    addUserMessage(userQuestion.trim());
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _geminiService.askContextAwareAdvice(
        sensorData: currentData,
        weatherData: weather,
        userQuestion: userQuestion.trim(),
        languageCode: languageCode,
      );
      addAiMessage(response);
    } catch (_) {
      addAiMessage(
        languageCode == 'hi'
            ? 'मुझे अभी उत्तर देने में समस्या आ रही है। कृपया बाद में पुनः प्रयास करें।'
            : languageCode == 'mr'
                ? 'सध्याच्या क्षणी उत्तर देण्यात अडचण येत आहे. कृपया नंतर पुन्हा प्रयत्न करा.'
                : 'I am having trouble answering right now. Please try again later.',
      );
    }

    _isLoading = false;
    notifyListeners();
  }
}

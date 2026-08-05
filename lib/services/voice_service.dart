// lib/services/voice_service.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;

  bool get isListening => _isListening;

  Future<bool> initializeSpeech() async {
    try {
      return await _speechToText.initialize();
    } catch (_) {
      return false;
    }
  }

  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> listen(String localeId, void Function(String) onResult) async {
    if (_isListening) {
      return;
    }
    final granted = await requestMicrophonePermission();
    if (!granted) {
      return;
    }
    final available = await initializeSpeech();
    if (!available) {
      debugPrint('Speech recognition failed to initialize.');
      return;
    }

    debugPrint('VoiceService: starting speech recognition.');
    _isListening = true;
    await _speechToText.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
        }
      },
      listenOptions: SpeechListenOptions(
        localeId: localeId,
        listenFor: const Duration(seconds: 60),
      ),
    );
  }

  Future<void> stopListening() async {
    if (!_isListening) {
      return;
    }
    _isListening = false;
    debugPrint('VoiceService: stopping speech recognition.');
    await _speechToText.stop();
  }

  Future<void> speak(String text, String languageCode) async {
    try {
      await _flutterTts.setLanguage(languageCode);
      await _flutterTts.setSpeechRate(0.45);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.speak(text);
    } catch (_) {
      // ignore text-to-speech failure at runtime
    }
  }
}

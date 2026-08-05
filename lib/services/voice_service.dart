import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/foundation.dart';
import 'dart:async';

/// Enhanced Voice Service for speech-to-text and text-to-speech
/// Supports English and Hindi with automatic language detection
class VoiceService extends ChangeNotifier {
  late FlutterTts _tts;
  late stt.SpeechToText _speechToText;

  bool _isListening = false;
  bool _isSpeaking = false;
  String _lastWords = '';
  String _currentLanguage = 'en_US'; // Default: English (US)
  double _speechRate = 0.8;
  double _pitch = 1.0;
  double _volume = 1.0;

  // Stream controllers for real-time updates
  final StreamController<String> _recognitionStream =
      StreamController<String>.broadcast();
  final StreamController<bool> _listeningStream =
      StreamController<bool>.broadcast();

  // Error handling
  String _lastError = '';

  // Singleton
  static final VoiceService _instance = VoiceService._internal();

  factory VoiceService() {
    return _instance;
  }

  VoiceService._internal() {
    _initializeServices();
  }

  /// Initialize TTS and STT services
  void _initializeServices() {
    _tts = FlutterTts();
    _speechToText = stt.SpeechToText();
    _configureServices();
  }

  /// Configure TTS and STT parameters
  void _configureServices() {
    // TTS Configuration
    _tts.setLanguage(_currentLanguage);
    _tts.setSpeechRate(_speechRate);
    _tts.setPitch(_pitch);
    _tts.setVolume(_volume);

    // STT Configuration
    _speechToText.initialize(
      onStatus: _onSpeechStatus,
      onError: _onSpeechError,
      debugLogging: false,
    );
  }

  /// Callback for speech status changes
  void _onSpeechStatus(String status) {
    debugPrint('[Voice] Speech status: $status');
    if (status == 'listening') {
      _isListening = true;
      _listeningStream.add(true);
      notifyListeners();
    } else if (status == 'done' || status == 'notListening') {
      _isListening = false;
      _listeningStream.add(false);
      notifyListeners();
    }
  }

  /// Callback for speech errors
  void _onSpeechError(dynamic error) {
    _lastError = 'Speech Error: ${error.toString()}';
    debugPrint('[Voice Error] $_lastError');
    _isListening = false;
    _listeningStream.add(false);
    notifyListeners();
  }

  /// Set language for voice input/output
  /// Supported: 'en', 'hi', 'en_US', 'hi_IN'
  Future<void> setLanguage(String languageCode) async {
    try {
      switch (languageCode.toLowerCase()) {
        case 'en':
        case 'en_us':
        case 'en-us':
          _currentLanguage = 'en_US';
          break;
        case 'hi':
        case 'hi_in':
        case 'hi-in':
          _currentLanguage = 'hi_IN';
          break;
        default:
          _currentLanguage = 'en_US';
      }

      await _tts.setLanguage(_currentLanguage);
      debugPrint('[Voice] Language set to: $_currentLanguage');
      notifyListeners();
    } catch (e) {
      _lastError = 'Error setting language: $e';
      debugPrint('[Voice Error] $_lastError');
    }
  }

  /// Start listening to speech input
  /// Returns recognized text through stream
  Future<void> startListening() async {
    if (_isListening || !_speechToText.isAvailable) {
      _lastError = 'Speech recognition not available or already listening';
      return;
    }

    try {
      _isListening = true;
      _lastWords = '';
      _listeningStream.add(true);
      notifyListeners();

      await _speechToText.listen(
        onResult: (result) {
          _lastWords = result.recognizedWords;
          _recognitionStream.add(_lastWords);
          notifyListeners();

          debugPrint('[Voice] Recognized: $_lastWords (isFinal: ${result.finalResult})');
        },
        localeId: _currentLanguage,
        cancelOnError: true,
        partialResults: true,
      );
    } catch (e) {
      _lastError = 'Error starting listening: $e';
      debugPrint('[Voice Error] $_lastError');
      _isListening = false;
      _listeningStream.add(false);
      notifyListeners();
    }
  }

  /// Stop listening to speech
  Future<void> stopListening() async {
    try {
      if (_speechToText.isListening) {
        await _speechToText.stop();
      }
      _isListening = false;
      _listeningStream.add(false);
      notifyListeners();
    } catch (e) {
      _lastError = 'Error stopping listening: $e';
      debugPrint('[Voice Error] $_lastError');
    }
  }

  /// Cancel ongoing speech recognition
  Future<void> cancelListening() async {
    try {
      if (_speechToText.isListening) {
        await _speechToText.cancel();
      }
      _isListening = false;
      _lastWords = '';
      _listeningStream.add(false);
      _recognitionStream.add('');
      notifyListeners();
    } catch (e) {
      _lastError = 'Error canceling listening: $e';
      debugPrint('[Voice Error] $_lastError');
    }
  }

  /// Speak text using text-to-speech
  /// text: Text to speak
  /// language: Optional language override
  Future<void> speak(String text, {String? language}) async {
    if (_isSpeaking) {
      await stop();
    }

    try {
      _isSpeaking = true;
      notifyListeners();

      if (language != null) {
        await setLanguage(language);
      }

      await _tts.speak(text);

      // Add delay for speaking to complete
      Future.delayed(Duration(milliseconds: text.length * 50), () {
        _isSpeaking = false;
        notifyListeners();
      });

      debugPrint('[Voice] Speaking: "$text"');
    } catch (e) {
      _lastError = 'Error speaking: $e';
      debugPrint('[Voice Error] $_lastError');
      _isSpeaking = false;
      notifyListeners();
    }
  }

  /// Stop speaking
  Future<void> stop() async {
    try {
      await _tts.stop();
      _isSpeaking = false;
      notifyListeners();
    } catch (e) {
      _lastError = 'Error stopping speech: $e';
      debugPrint('[Voice Error] $_lastError');
    }
  }

  /// Pause speaking
  Future<void> pause() async {
    try {
      await _tts.pause();
    } catch (e) {
      _lastError = 'Error pausing speech: $e';
      debugPrint('[Voice Error] $_lastError');
    }
  }

  /// Resume speaking
  Future<void> resume() async {
    try {
      await _tts.resume();
    } catch (e) {
      _lastError = 'Error resuming speech: $e';
      debugPrint('[Voice Error] $_lastError');
    }
  }

  /// Set speech rate (0.0 - 2.0, default: 0.8)
  Future<void> setSpeechRate(double rate) async {
    try {
      _speechRate = rate.clamp(0.0, 2.0);
      await _tts.setSpeechRate(_speechRate);
      notifyListeners();
    } catch (e) {
      _lastError = 'Error setting speech rate: $e';
      debugPrint('[Voice Error] $_lastError');
    }
  }

  /// Set pitch (0.5 - 2.0, default: 1.0)
  Future<void> setPitch(double pitch) async {
    try {
      _pitch = pitch.clamp(0.5, 2.0);
      await _tts.setPitch(_pitch);
      notifyListeners();
    } catch (e) {
      _lastError = 'Error setting pitch: $e';
      debugPrint('[Voice Error] $_lastError');
    }
  }

  /// Set volume (0.0 - 1.0, default: 1.0)
  Future<void> setVolume(double volume) async {
    try {
      _volume = volume.clamp(0.0, 1.0);
      await _tts.setVolume(_volume);
      notifyListeners();
    } catch (e) {
      _lastError = 'Error setting volume: $e';
      debugPrint('[Voice Error] $_lastError');
    }
  }

  /// Get available voices
  Future<List<Map>> getAvailableVoices() async {
    try {
      final voices = await _tts.getVoices;
      return List<Map>.from(voices ?? []);
    } catch (e) {
      _lastError = 'Error getting voices: $e';
      debugPrint('[Voice Error] $_lastError');
      return [];
    }
  }

  /// Get available languages for recognition
  Future<List<stt.LocaleName>> getAvailableLanguages() async {
    try {
      return await _speechToText.locales();
    } catch (e) {
      _lastError = 'Error getting languages: $e';
      debugPrint('[Voice Error] $_lastError');
      return [];
    }
  }

  // Getters
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  String get lastWords => _lastWords;
  String get currentLanguage => _currentLanguage;
  String get lastError => _lastError;
  bool get speechAvailable => _speechToText.isAvailable;

  // Streams
  Stream<String> get recognitionStream => _recognitionStream.stream;
  Stream<bool> get listeningStream => _listeningStream.stream;

  @override
  void dispose() {
    _recognitionStream.close();
    _listeningStream.close();
    _tts.stop();
    super.dispose();
  }
}

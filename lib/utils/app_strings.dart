import 'package:flutter/material.dart';

class AppStrings {
  final Locale locale;

  AppStrings(this.locale);

  static const supportedLanguageCodes = ['en', 'hi', 'mr'];

  static const Map<String, Map<String, String>> _translations = {
    'en': {
      'appName': 'KrishiDrishti',
      'tagline': 'Smart Soil Analysis',
      'dashboard': 'Dashboard',
      'cropHealth': 'Crop Health',
      'assistant': 'AI Assistant',
      'settings': 'Settings',
      'hardwareStatus': 'Hardware Status',
      'bleConnected': 'BLE Connected',
      'mockingActive': 'Mocking Active',
      'weather': 'Weather',
      'temperature': 'Temperature',
      'rainProbability': 'Rain Probability',
      'soilMoisture': 'Soil Moisture',
      'soilPh': 'Soil pH',
      'npkLevels': 'NPK Levels',
      'criticalMoistureAlert': 'Critically Low Moisture: Irrigate within 24 Hours',
      'normalSoil': 'Soil conditions are stable.',
      'analyzeCropHealth': 'Analyze Crop Health',
      'selectImage': 'Select Crop Image',
      'takePhoto': 'Take Photo',
      'chooseFromGallery': 'Choose From Gallery',
      'diagnosis': 'Diagnosis',
      'noImageSelected': 'No image selected yet.',
      'analyzing': 'Analyzing crop health…',
      'analysisResultReady': 'Analysis result is ready.',
      'chatHint': 'Ask about irrigation, pests, fertilizer…',
      'send': 'Send',
      'mic': 'Mic',
      'tts': 'Listen',
      'chatGreeting': 'Namaste! Ask me about crops, soil, irrigation or pests, and I\'ll do my best to help.',
      'language': 'Language',
      'english': 'English',
      'hindi': 'Hindi',
      'marathi': 'Marathi',
      'debugMode': 'Debug Mode',
      'liveBleMode': 'Live BLE Mode',
      'scanForSensor': 'Scan for KrishiDrishti Sensor',
      'scanButton': 'Scan Sensor',
      'selectSensor': 'Select Sensor',
      'history': 'History',
      'selectLanguagePrompt': 'Select your preferred language',
      'about': 'About KrishiDrishti',
      'aboutBody': 'KrishiDrishti helps farmers understand their soil and crops with simple, actionable advice — no lab visit required.',
      'version': 'Version',
      'waitForResponse': 'Waiting for AI response…',
      'connected': 'Connected',
      'disconnected': 'Disconnected',
      'analysisError': 'Unable to analyze image right now.',
      'sensorError': 'Unable to connect to sensor.',
      'updateLanguage': 'Update Language',
      'switchMode': 'Switch Mode',
      'hardwareSummary': 'Tap scan to locate your field sensor or keep mock mode active for demo data.',
      'currentLanguage': 'Current Language',
      'selectLanguage': 'Select Language',
      'mockModeEnabled': 'Simulated sensor data is active.',
    },
    'hi': {
      'appName': 'कृषिदृष्टि',
      'tagline': 'स्मार्ट मिट्टी विश्लेषण',
      'dashboard': 'डैशबोर्ड',
      'cropHealth': 'फसल स्वास्थ्य',
      'assistant': 'एआई सहायक',
      'settings': 'सेटिंग्स',
      'hardwareStatus': 'हार्डवेयर स्थिति',
      'bleConnected': 'BLE जुड़ा हुआ',
      'mockingActive': 'मॉक मोड सक्रिय है',
      'weather': 'मौसम',
      'temperature': 'तापमान',
      'rainProbability': 'बारिश की संभावना',
      'soilMoisture': 'मिट्टी की नमी',
      'soilPh': 'मिट्टी का पीएच',
      'npkLevels': 'एनपीके स्तर',
      'criticalMoistureAlert': 'नमीयता बहुत कम है: 24 घंटे में सिंचाई करें',
      'normalSoil': 'मिट्टी की स्थिति स्थिर है।',
      'analyzeCropHealth': 'फसल स्वास्थ्य विश्लेषण करें',
      'selectImage': 'फसल की छवि चुनें',
      'takePhoto': 'फोटो लें',
      'chooseFromGallery': 'गैलरी से चुनें',
      'diagnosis': 'निदान',
      'noImageSelected': 'अभी तक कोई छवि चयनित नहीं है।',
      'analyzing': 'फसल स्वास्थ्य का विश्लेषण किया जा रहा है…',
      'analysisResultReady': 'विश्लेषण परिणाम तैयार है।',
      'chatHint': 'सिंचाई, कीट, उर्वरक के बारे में पूछें…',
      'send': 'भेजें',
      'mic': 'माइक',
      'tts': 'सुनें',
      'chatGreeting': 'नमस्ते! फसल, मिट्टी, सिंचाई या कीटों के बारे में मुझसे पूछें, मैं मदद करने की पूरी कोशिश करूँगा।',
      'language': 'भाषा',
      'english': 'अंग्रेज़ी',
      'hindi': 'हिन्दी',
      'marathi': 'मराठी',
      'debugMode': 'डिबग मोड',
      'liveBleMode': 'लाइव BLE मोड',
      'scanForSensor': 'KrishiDrishti सेंसर स्कैन करें',
      'scanButton': 'सेंसर स्कैन करें',
      'selectSensor': 'सेंसर चुनें',
      'history': 'इतिहास',
      'selectLanguagePrompt': 'अपनी पसंदीदा भाषा चुनें',
      'about': 'KrishiDrishti के बारे में',
      'aboutBody': 'KrishiDrishti किसानों को उनकी मिट्टी और फसलों को सरल, व्यावहारिक सलाह के साथ समझने में मदद करता है — कोई लेब टेस्ट आवश्यक नहीं।',
      'version': 'संस्करण',
      'waitForResponse': 'एआई प्रतिक्रिया का इंतजार किया जा रहा है…',
      'connected': 'जुड़ा हुआ',
      'disconnected': 'अवायिक',
      'analysisError': 'चित्र का विश्लेषण अभी संभव नहीं है।',
      'sensorError': 'सेंसर से कनेक्ट करना संभव नहीं है।',
      'updateLanguage': 'भाषा बदलें',
      'switchMode': 'मोड बदलें',
      'hardwareSummary': 'अपने फ़ील्ड सेंसर को खोजने के लिए स्कैन करें या डेमो डेटा के लिए मॉक मोड चालू रखें।',
      'currentLanguage': 'वर्तमान भाषा',
      'selectLanguage': 'भाषा चुनें',
      'mockModeEnabled': 'अनुकरणीय सेंसर डेटा सक्रिय है।',
    },
    'mr': {
      'appName': 'कृषिदृष्टी',
      'tagline': 'स्मार्ट माती विश्लेषण',
      'dashboard': 'डॅशबोर्ड',
      'cropHealth': 'पीक आरोग्य',
      'assistant': 'एआय सहाय्यक',
      'settings': 'सेटींग्ज',
      'hardwareStatus': 'हार्डवेअर स्थिती',
      'bleConnected': 'BLE जोडलेले',
      'mockingActive': 'मॉक मोड सक्रिय आहे',
      'weather': 'हवामान',
      'temperature': 'तापमान',
      'rainProbability': 'पाऊसाची शक्यता',
      'soilMoisture': 'मातीची आर्द्रता',
      'soilPh': 'मातीचे पीएच',
      'npkLevels': 'एनपीके पातळ्या',
      'criticalMoistureAlert': 'आर्द्रता खूप कमी आहे: 24 तासांत पाणी द्या',
      'normalSoil': 'मातीची स्थिती स्थिर आहे.',
      'analyzeCropHealth': 'पीक आरोग्याचे विश्लेषण करा',
      'selectImage': 'पीक प्रतिमा निवडा',
      'takePhoto': 'फोटो घ्या',
      'chooseFromGallery': 'गॅलरी मधून निवडा',
      'diagnosis': 'निदान',
      'noImageSelected': 'अजून कोणतीही प्रतिमा निवडलेली नाही.',
      'analyzing': 'पीक आरोग्याचे विश्लेषण केले जात आहे…',
      'analysisResultReady': 'विश्लेषण परिणाम तयार आहे.',
      'chatHint': 'पाण्याबाबत, कीडबाबत, खताबाबत विचारा…',
      'send': 'पाठवा',
      'mic': 'माइक',
      'tts': 'ऐका',
      'chatGreeting': 'नमस्कार! पीक, माती, पाणी किंवा कीडबद्दल विचारा, मी मदत करण्याचा प्रयत्न करीन.',
      'language': 'भाषा',
      'english': 'इंग्रजी',
      'hindi': 'हिंदी',
      'marathi': 'मराठी',
      'debugMode': 'डिबग मोड',
      'liveBleMode': 'लाइव्ह BLE मोड',
      'scanForSensor': 'KrishiDrishti सेन्सर शोधा',
      'scanButton': 'सेन्सर स्कॅन करा',
      'selectSensor': 'सेन्सर निवडा',
      'history': 'इतिहास',
      'selectLanguagePrompt': 'आपली पसंतीची भाषा निवडा',
      'about': 'KrishiDrishti बद्दल',
      'aboutBody': 'KrishiDrishti शेतकऱ्यांना त्यांच्या माती आणि पीकाबद्दल साधे, कृतीशील सल्ले देऊन मदत करते — कोणतीही प्रयोगशाळा चाचणी आवश्यक नाही.',
      'version': 'आवृत्ती',
      'waitForResponse': 'एआय प्रतिसादाची प्रतक्षा करत आहे…',
      'connected': 'जोडलेले',
      'disconnected': 'जोडलेले नाही',
      'analysisError': 'अत्ता प्रतिमेचे विश्लेषण करता येत नाही.',
      'sensorError': 'सेन्सरशी कनेक्ट करता येत नाही.',
      'updateLanguage': 'भाषा बदला',
      'switchMode': 'मोड बदला',
      'hardwareSummary': 'आपला फील्ड सेन्सर शोधण्यासाठी स्कॅन करा किंवा डेमो डेटासाठी मॉक मोड सक्रिय ठेवा.',
      'currentLanguage': 'सध्याची भाषा',
      'selectLanguage': 'भाषा निवडा',
      'mockModeEnabled': 'अनुकरणीय सेन्सर डेटा सक्रिय आहे.',
    },
  };

  String _text(String key) {
    final languageMap = _translations[locale.languageCode] ?? _translations['en']!;
    return languageMap[key] ?? _translations['en']![key] ?? key;
  }

  String get appName => _text('appName');
  String get tagline => _text('tagline');
  String get dashboard => _text('dashboard');
  String get cropHealth => _text('cropHealth');
  String get assistant => _text('assistant');
  String get settings => _text('settings');
  String get hardwareStatus => _text('hardwareStatus');
  String get bleConnected => _text('bleConnected');
  String get mockingActive => _text('mockingActive');
  String get weather => _text('weather');
  String get temperature => _text('temperature');
  String get rainProbability => _text('rainProbability');
  String get soilMoisture => _text('soilMoisture');
  String get soilPh => _text('soilPh');
  String get npkLevels => _text('npkLevels');
  String get criticalMoistureAlert => _text('criticalMoistureAlert');
  String get normalSoil => _text('normalSoil');
  String get analyzeCropHealth => _text('analyzeCropHealth');
  String get selectImage => _text('selectImage');
  String get takePhoto => _text('takePhoto');
  String get chooseFromGallery => _text('chooseFromGallery');
  String get diagnosis => _text('diagnosis');
  String get noImageSelected => _text('noImageSelected');
  String get analyzing => _text('analyzing');
  String get analysisResultReady => _text('analysisResultReady');
  String get chatHint => _text('chatHint');
  String get send => _text('send');
  String get mic => _text('mic');
  String get tts => _text('tts');
  String get chatGreeting => _text('chatGreeting');
  String get language => _text('language');
  String get english => _text('english');
  String get hindi => _text('hindi');
  String get marathi => _text('marathi');
  String get debugMode => _text('debugMode');
  String get liveBleMode => _text('liveBleMode');
  String get scanForSensor => _text('scanForSensor');
  String get scanButton => _text('scanButton');
  String get selectSensor => _text('selectSensor');
  String get history => _text('history');
  String get selectLanguagePrompt => _text('selectLanguagePrompt');
  String get about => _text('about');
  String get aboutBody => _text('aboutBody');
  String get version => _text('version');
  String get waitForResponse => _text('waitForResponse');
  String get connected => _text('connected');
  String get disconnected => _text('disconnected');
  String get analysisError => _text('analysisError');
  String get sensorError => _text('sensorError');
  String get updateLanguage => _text('updateLanguage');
  String get switchMode => _text('switchMode');
  String get hardwareSummary => _text('hardwareSummary');
  String get currentLanguage => _text('currentLanguage');
  String get selectLanguage => _text('selectLanguage');
  String get mockModeEnabled => _text('mockModeEnabled');
}

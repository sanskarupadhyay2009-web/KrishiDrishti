/// Central place for every piece of user-facing text.
///
/// The MVP only ships English and Hindi (as scoped in the project brief),
/// but keeping every string behind this one class means adding a third
/// language later is a matter of adding one more branch here, not hunting
/// through every page.
class AppStrings {
  final bool isHindi;
  const AppStrings(this.isHindi);

  String _t(String en, String hi) => isHindi ? hi : en;

  // Splash
  String get appName => 'KrishiDrishti';
  String get tagline => _t('Smart Soil Analysis', 'स्मार्ट मृदा विश्लेषण');

  // Language page
  String get chooseLanguage => _t('Choose Language', 'भाषा चुनें');
  String get chooseLanguageSub =>
      _t('अपनी भाषा चुनें', 'Choose your language');

  // Home page
  String get welcome => _t('Welcome Farmer!', 'स्वागत है, किसान भाई!');
  String get homeSubtitle =>
      _t('Know your soil. Improve your crops.', 'अपनी मिट्टी को जानें। अपनी फसल सुधारें।');
  String get deviceStatus => _t('Device Status', 'डिवाइस स्थिति');
  String get connected => _t('Connected', 'जुड़ा हुआ');
  String get notConnected => _t('Not Connected', 'जुड़ा नहीं है');
  String get connect => _t('Connect', 'जोड़ें');
  String get disconnect => _t('Disconnect', 'हटाएं');
  String get startScan => _t('Start Soil Scan', 'मिट्टी की जांच शुरू करें');
  String get lastScan => _t('Last Scan', 'पिछली जांच');
  String get noScansYet =>
      _t('No scans yet. Run your first soil scan!', 'अभी तक कोई जांच नहीं हुई। पहली जांच शुरू करें!');
  String get viewHistory => _t('View History', 'इतिहास देखें');
  String get askAssistant => _t('Ask the Assistant', 'सहायक से पूछें');
  String get moisture => _t('Moisture', 'नमी');
  String get soilHealth => _t('Soil Health', 'मिट्टी का स्वास्थ्य');
  String get temperature => _t('Temperature', 'तापमान');

  // Scan page
  String get scanning => _t('Reading soil sensors…', 'मिट्टी सेंसर पढ़ रहे हैं…');
  String get scanningSub => _t(
      'Keep the probe steady in the soil.', 'जांच यंत्र को मिट्टी में स्थिर रखें।');
  String get connectFirst => _t(
      'Please connect the soil analyzer device first.',
      'कृपया पहले मिट्टी विश्लेषक डिवाइस को जोड़ें।');

  // Result page
  String get scanResult => _t('Scan Result', 'जांच परिणाम');
  String get recommendations => _t('Recommendations', 'सुझाव');
  String get healthy => _t('Healthy', 'स्वस्थ');
  String get needsAttention => _t('Needs Attention', 'ध्यान देने की आवश्यकता');
  String get poor => _t('Poor', 'खराब');
  String get backToHome => _t('Back to Home', 'होम पर वापस जाएं');
  String get savedToHistory =>
      _t('Saved to your scan history', 'आपके जांच इतिहास में सहेजा गया');

  // History page
  String get scanHistory => _t('Scan History', 'जांच इतिहास');
  String get noHistory => _t('No scans recorded yet.', 'अभी तक कोई जांच दर्ज नहीं हुई।');
  String get clearHistory => _t('Clear History', 'इतिहास मिटाएं');
  String get clearHistoryConfirm => _t(
      'This will permanently delete all saved scans. Continue?',
      'इससे सभी सहेजी गई जांच स्थायी रूप से हट जाएंगी। जारी रखें?');
  String get cancel => _t('Cancel', 'रद्द करें');
  String get delete => _t('Delete', 'हटाएं');
  String get moistureTrend => _t('Moisture Trend', 'नमी का रुझान');

  // Chat assistant
  String get chatTitle => _t('Farm Assistant', 'कृषि सहायक');
  String get chatHint => _t(
      'Ask about irrigation, pests, fertilizer…', 'सिंचाई, कीट, उर्वरक के बारे में पूछें…');
  String get chatGreeting => _t(
      'Namaste! Ask me about crops, soil, irrigation or pests, and I\'ll do my best to help.',
      'नमस्ते! फसल, मिट्टी, सिंचाई या कीटों के बारे में मुझसे पूछें, मैं मदद करने की पूरी कोशिश करूँगा।');

  // Settings
  String get settings => _t('Settings', 'सेटिंग्स');
  String get language => _t('Language', 'भाषा');
  String get english => _t('English', 'अंग्रेज़ी');
  String get hindi => _t('Hindi', 'हिन्दी');
  String get about => _t('About KrishiDrishti', 'KrishiDrishti के बारे में');
  String get aboutBody => _t(
      'KrishiDrishti helps farmers understand their soil and crops with simple, actionable advice — no lab visit required.',
      'KrishiDrishti किसानों को उनकी मिट्टी और फसलों को समझने में सरल, व्यावहारिक सलाह के साथ मदद करता है — बिना प्रयोगशाला गए।');
  String get version => _t('Version', 'संस्करण');
}

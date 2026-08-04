/// A small, fully offline keyword-matching assistant.
///
/// The long-term plan (Phase 5 of the roadmap) is to route these questions
/// to a real AI service. For the MVP — and so the app works with zero
/// internet connection and zero API keys — this gives farmers instant,
/// useful answers to the most common questions. Swapping this out for a
/// real AI backend later only means replacing [ChatAssistant.reply].
class ChatAssistant {
  static String reply(String question, bool isHindi) {
    final q = question.toLowerCase();

    bool has(List<String> words) => words.any((w) => q.contains(w));

    if (has(['yellow', 'पीली', 'पीले'])) {
      return isHindi
          ? 'पत्तियों का पीला पड़ना अक्सर नाइट्रोजन की कमी या अधिक पानी देने के कारण होता है। मिट्टी की नमी जांचें और यूरिया या जैविक खाद की हल्की मात्रा डालने पर विचार करें।'
          : 'Yellowing leaves are usually a sign of nitrogen deficiency or overwatering. Check soil moisture first, and consider a light dose of urea or organic compost if the soil isn\'t waterlogged.';
    }

    if (has(['irrigat', 'water', 'सिंचाई', 'पानी'])) {
      return isHindi
          ? 'ज़्यादातर फसलों के लिए, जब ऊपरी मिट्टी (2-3 सेमी) सूखी लगे तब सिंचाई करें। सुबह जल्दी या शाम को सिंचाई करना वाष्पीकरण कम करता है।'
          : 'For most crops, irrigate when the top 2-3 cm of soil feels dry. Watering early morning or evening reduces evaporation loss.';
    }

    if (has(['pest', 'insect', 'कीट', 'कीड़े'])) {
      return isHindi
          ? 'कीट प्रबंधन के लिए पहले प्रभावित पत्तियों की पहचान करें। हल्के संक्रमण के लिए नीम के तेल का छिड़काव कारगर है। गंभीर मामलों में स्थानीय कृषि विशेषज्ञ से सलाह लें।'
          : 'For pest management, first identify the affected leaves or fruit. Neem oil spray works well for mild infestations. For severe outbreaks, consult your local agricultural officer.';
    }

    if (has(['fertiliz', 'khad', 'खाद', 'उर्वरक'])) {
      return isHindi
          ? 'उर्वरक डालने से पहले मिट्टी की जांच करें। संतुलित NPK उर्वरक अधिकांश फसलों के लिए उपयुक्त है, लेकिन अधिक मात्रा से बचें — यह मिट्टी को नुकसान पहुंचा सकता है।'
          : 'Test your soil before applying fertilizer if possible. A balanced NPK mix suits most crops, but avoid over-application — it can damage soil health over time.';
    }

    if (has(['ph', 'acidic', 'alkaline', 'अम्लीय', 'क्षारीय'])) {
      return isHindi
          ? 'अधिकांश फसलों के लिए 6.0 से 7.5 के बीच pH आदर्श है। अम्लीय मिट्टी के लिए चूना और क्षारीय मिट्टी के लिए जिप्सम या जैविक पदार्थ मिलाएं।'
          : 'A pH between 6.0 and 7.5 is ideal for most crops. Add lime to raise pH in acidic soil, or gypsum/organic matter to lower it in alkaline soil.';
    }

    if (has(['crop', 'sow', 'plant', 'फसल', 'बुवाई'])) {
      return isHindi
          ? 'फसल चुनते समय मिट्टी का प्रकार, मौसम और उपलब्ध सिंचाई पर विचार करें। स्थानीय मौसम के अनुसार बुवाई का समय महत्वपूर्ण है।'
          : 'When choosing a crop, consider your soil type, the season, and available irrigation. Sowing at the right time for your local climate matters more than almost anything else.';
    }

    return isHindi
        ? 'मुझे यकीन नहीं है कि मैं इसका सटीक उत्तर दे सकूं। कृपया सिंचाई, कीट, उर्वरक, फसल या pH के बारे में पूछ के देखें, या स्थानीय कृषि विशेषज्ञ से संपर्क करें।'
        : 'I\'m not fully sure how to answer that yet. Try asking about irrigation, pests, fertilizer, crops, or soil pH — or check with your local agricultural officer for anything specific.';
  }
}

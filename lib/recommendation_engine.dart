/// Rule-based recommendation engine (Phase 4 of the roadmap).
///
/// This intentionally does NOT call any AI model — the brief calls for a
/// fast, fully-offline prototype first, with AI layered on top later. Every
/// rule here is a simple, explainable threshold so it's easy for a
/// non-technical reviewer (or a future contributor) to see exactly why a
/// given piece of advice was produced.
class RecommendationResult {
  final String healthStatus; // Healthy | Needs Attention | Poor
  final List<String> recommendations;

  RecommendationResult(this.healthStatus, this.recommendations);
}

class RecommendationEngine {
  static RecommendationResult generate({
    required double moisture,
    required double ph,
    required double temperature,
    required bool isHindi,
  }) {
    final issues = <String>[];
    final tips = <String>[];

    // --- Moisture ---
    if (moisture < 20) {
      issues.add('moisture');
      tips.add(isHindi
          ? '💧 मिट्टी बहुत सूखी है। जल्द ही सिंचाई करें।'
          : '💧 Soil is very dry. Irrigate soon.');
    } else if (moisture > 65) {
      issues.add('moisture');
      tips.add(isHindi
          ? '💧 मिट्टी में अधिक नमी है। जलभराव से बचने के लिए सिंचाई रोकें।'
          : '💧 Soil moisture is too high. Hold off on irrigation to avoid waterlogging.');
    } else {
      tips.add(isHindi
          ? '💧 नमी का स्तर फसल के लिए उपयुक्त है।'
          : '💧 Moisture level is suitable for most crops.');
    }

    // --- pH ---
    if (ph < 5.5) {
      issues.add('ph');
      tips.add(isHindi
          ? '🧪 मिट्टी अधिक अम्लीय है। चूना (lime) या जैविक खाद मिलाएं।'
          : '🧪 Soil is quite acidic. Add agricultural lime or organic compost to raise pH.');
    } else if (ph > 7.8) {
      issues.add('ph');
      tips.add(isHindi
          ? '🧪 मिट्टी क्षारीय है। जिप्सम या जैविक पदार्थ मिलाएं।'
          : '🧪 Soil is alkaline. Add gypsum or organic matter to help lower pH over time.');
    } else {
      tips.add(isHindi
          ? '🧪 pH स्तर अधिकांश फसलों के लिए ठीक है।'
          : '🧪 pH level is in a healthy range for most crops.');
    }

    // --- Temperature ---
    if (temperature < 15) {
      issues.add('temperature');
      tips.add(isHindi
          ? '🌡️ मिट्टी ठंडी है, जिससे जड़ों की वृद्धि धीमी हो सकती है। मल्चिंग पर विचार करें।'
          : '🌡️ Soil is cold, which can slow root growth. Consider mulching to retain warmth.');
    } else if (temperature > 35) {
      issues.add('temperature');
      tips.add(isHindi
          ? '🌡️ मिट्टी गर्म है। सिंचाई की आवृत्ति बढ़ाएं और मल्च का उपयोग करें।'
          : '🌡️ Soil temperature is high. Increase irrigation frequency and use mulch to reduce heat stress.');
    } else {
      tips.add(isHindi
          ? '🌡️ तापमान सामान्य वृद्धि के लिए उपयुक्त है।'
          : '🌡️ Temperature is favorable for normal crop growth.');
    }

    String status;
    if (issues.isEmpty) {
      status = isHindi ? 'स्वस्थ' : 'Healthy';
    } else if (issues.length == 1) {
      status = isHindi ? 'ध्यान देने की आवश्यकता' : 'Needs Attention';
    } else {
      status = isHindi ? 'खराब' : 'Poor';
    }

    return RecommendationResult(status, tips);
  }
}

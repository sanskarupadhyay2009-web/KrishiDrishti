import 'package:flutter/foundation.dart';

/// Comprehensive Recommendation Engine for smart farming
/// Provides intelligent recommendations based on sensor data, weather, and crop type
class RecommendationService {
  // Singleton
  static final RecommendationService _instance =
      RecommendationService._internal();

  factory RecommendationService() {
    return _instance;
  }

  RecommendationService._internal();

  /// Generate irrigation recommendation
  Map<String, dynamic> getIrrigationRecommendation({
    required double moistureLevel,
    required double temperature,
    required double humidity,
    required String cropType,
    required String soilType,
  }) {
    String recommendation = '';
    String urgency = 'Low';
    String action = '';
    int waterAmount = 0; // in mm

    // Critical thresholds
    if (moistureLevel < 20) {
      recommendation =
          'CRITICAL: Soil is severely dry. Irrigate immediately!';
      urgency = 'Critical';
      action = 'Start irrigation now';
      waterAmount = 40;
    } else if (moistureLevel < 30) {
      recommendation = 'Soil moisture is low. Plan irrigation within 24 hours';
      urgency = 'High';
      action = 'Prepare irrigation system';
      waterAmount = 30;
    } else if (moistureLevel < 40) {
      recommendation =
          'Soil moisture is acceptable but decreasing. Irrigate within 2-3 days';
      urgency = 'Medium';
      action = 'Schedule irrigation';
      waterAmount = 25;
    } else if (moistureLevel > 70) {
      recommendation = 'Soil moisture is high. Avoid irrigation for now';
      urgency = 'Low';
      action = 'Wait and monitor';
      waterAmount = 0;
    } else {
      recommendation = 'Soil moisture is optimal. Continue normal watering';
      urgency = 'Low';
      action = 'Routine maintenance';
      waterAmount = 15;
    }

    // Adjust based on temperature
    if (temperature > 35) {
      waterAmount = (waterAmount * 1.3).toInt(); // Increase by 30%
      recommendation += '. High temperature increases evaporation.';
    } else if (temperature < 15) {
      waterAmount = (waterAmount * 0.7).toInt(); // Decrease by 30%
      recommendation += '. Low temperature reduces water needs.';
    }

    // Adjust based on humidity
    if (humidity > 80) {
      waterAmount = (waterAmount * 0.8).toInt(); // Decrease by 20%
    }

    // Crop-specific adjustments
    final cropWaterNeeds = _getCropWaterNeeds(cropType);
    waterAmount = (waterAmount * cropWaterNeeds).toInt();

    return {
      'recommendation': recommendation,
      'urgency': urgency,
      'action': action,
      'water_amount_mm': waterAmount,
      'next_check_hours':
          _getNextCheckTime(moistureLevel, temperature, cropType),
      'irrigation_method': _getIrrigationMethod(soilType),
      'time_of_day': _getBestIrrigationTime(temperature),
    };
  }

  /// Generate fertilizer recommendation
  Map<String, dynamic> getFertilizerRecommendation({
    required double phLevel,
    required double moisture,
    required String cropType,
    required int daysInCycle,
  }) {
    String recommendation = '';
    Map<String, dynamic> nutrients = {'N': 0, 'P': 0, 'K': 0};
    String urgency = 'Low';

    // Crop-specific nutrient needs
    final cropNeeds = _getCropNutrientNeeds(cropType, daysInCycle);

    // pH check
    if (phLevel < 5.5) {
      recommendation =
          'Soil is too acidic. Apply lime to increase pH before fertilizing';
      urgency = 'High';
    } else if (phLevel > 8.0) {
      recommendation =
          'Soil is too alkaline. Consider sulfur application to reduce pH';
      urgency = 'High';
    } else if (phLevel >= 6.0 && phLevel <= 7.5) {
      recommendation =
          'pH is optimal. Ready for nutrient application at recommended levels';
      urgency = 'Low';
      nutrients = cropNeeds;
    } else {
      recommendation = 'pH needs adjustment for optimal nutrient availability';
      urgency = 'Medium';
      nutrients = {
        'N': (cropNeeds['N'] * 0.8).toInt(),
        'P': (cropNeeds['P'] * 0.8).toInt(),
        'K': (cropNeeds['K'] * 0.8).toInt(),
      };
    }

    // Moisture check
    if (moisture < 30) {
      recommendation +=
          '. Increase soil moisture before fertilizing for better nutrient uptake';
    }

    // Organic vs chemical options
    final organicOptions = _getOrganicFertilizers(cropType);
    final chemicalOptions = _getChemicalFertilizers(cropType);

    return {
      'recommendation': recommendation,
      'urgency': urgency,
      'npk_ratio': nutrients,
      'organic_options': organicOptions,
      'chemical_options': chemicalOptions,
      'application_timing': _getFertilizerTiming(cropType, daysInCycle),
      'ph_target': 6.5,
      'application_frequency': _getFertilizerFrequency(cropType),
    };
  }

  /// Generate pest and disease prevention recommendations
  Map<String, dynamic> getPestManagementRecommendation({
    required String cropType,
    required double temperature,
    required double humidity,
    required double moisture,
  }) {
    List<String> commonPests = [];
    List<String> preventionMeasures = [];
    String riskLevel = 'Low';

    // Pest susceptibility based on conditions
    if (humidity > 70 && temperature > 25 && temperature < 32) {
      riskLevel = 'High';
      commonPests = _getCommonPests(cropType, 'humid');
    } else if (temperature > 32) {
      riskLevel = 'Medium';
      commonPests = _getCommonPests(cropType, 'hot');
    } else if (moisture > 60 && humidity > 75) {
      riskLevel = 'High';
      commonPests = _getCommonPests(cropType, 'wet');
    } else {
      riskLevel = 'Low';
      commonPests = _getCommonPests(cropType, 'normal');
    }

    // Prevention measures
    preventionMeasures = [
      'Remove dead plant material regularly',
      'Maintain proper spacing between plants',
      'Monitor plants daily for signs of pests',
      'Ensure good drainage to prevent fungal diseases',
      'Use crop rotation practices',
      'Keep farm tools clean and disinfected',
    ];

    // Add crop-specific measures
    preventionMeasures.addAll(_getCropSpecificPrevention(cropType));

    // Treatment options
    final organicTreatment = _getOrganicPestControl(cropType, commonPests);
    final chemicalTreatment = _getChemicalPestControl(cropType, commonPests);

    return {
      'risk_level': riskLevel,
      'common_pests': commonPests,
      'prevention_measures': preventionMeasures,
      'organic_treatment': organicTreatment,
      'chemical_treatment': chemicalTreatment,
      'monitoring_frequency':
          riskLevel == 'High' ? 'Daily' : riskLevel == 'Medium' ? '2-3 times a week' : 'Weekly',
      'optimal_treatment_time': _getOptimalTreatmentTime(temperature),
    };
  }

  /// Generate harvest readiness assessment
  Map<String, dynamic> getHarvestAssessment({
    required String cropType,
    required int daysPlanted,
    required double moisture,
    required double temperature,
  }) {
    final cycleInfo = _getCropCycleInfo(cropType);
    final daysRemaining = cycleInfo['days_to_maturity'] - daysPlanted;
    String readiness = 'Not Ready';
    String recommendation = '';

    if (daysRemaining <= 0) {
      readiness = 'Ready Now';
      recommendation =
          'Crop has reached maturity. Optimal harvest window is open.';
    } else if (daysRemaining <= 5) {
      readiness = 'Very Soon';
      recommendation =
          'Crop will be ready in ${daysRemaining} days. Prepare equipment.';
    } else if (daysRemaining <= 14) {
      readiness = 'Getting Close';
      recommendation =
          'Approximately ${daysRemaining} days until harvest. Monitor maturity indicators.';
    } else {
      readiness = 'Early Stage';
      recommendation =
          'Still ${daysRemaining} days until estimated harvest. Focus on crop health.';
    }

    // Moisture check for harvest
    if (readiness == 'Ready Now' || readiness == 'Very Soon') {
      if (moisture > 60) {
        recommendation +=
            ' Consider allowing soil to dry slightly for easier harvesting.';
      }
    }

    return {
      'readiness': readiness,
      'days_until_harvest': daysRemaining.clamp(0, daysRemaining),
      'estimated_yield_quality':
          _estimateYieldQuality(moisture, temperature, daysPlanted, cycleInfo),
      'recommendation': recommendation,
      'pre_harvest_tasks': _getPreHarvestTasks(cropType),
      'harvest_tips': _getHarvestTips(cropType),
      'post_harvest_storage': _getStorageRecommendation(cropType),
    };
  }

  /// Generate weather-based recommendations
  Map<String, dynamic> getWeatherBasedRecommendation({
    required String weatherCondition,
    required double temperature,
    required String cropType,
    required double currentMoisture,
  }) {
    String recommendation = '';
    List<String> actions = [];

    switch (weatherCondition.toLowerCase()) {
      case 'rainy':
      case 'rain':
        recommendation =
            'Rain expected: Irrigation can be skipped. Focus on drainage.';
        actions = [
          'Check drainage systems',
          'Avoid additional irrigation',
          'Monitor for waterlogging',
          'Be vigilant for fungal diseases',
        ];
        break;

      case 'sunny':
      case 'clear':
        recommendation =
            'Sunny weather: Monitor soil moisture closely. Increase irrigation if needed.';
        actions = [
          'Increase watering frequency',
          'Apply mulch to reduce evaporation',
          'Check for heat stress symptoms',
          'Provide shade for sensitive crops if necessary',
        ];
        break;

      case 'cloudy':
      case 'overcast':
        recommendation = 'Cloudy weather: Reduced evaporation. Water as normal.';
        actions = [
          'Monitor moisture levels',
          'Reduce irrigation slightly',
          'Watch for fungal issues in humidity',
        ];
        break;

      case 'windy':
        recommendation =
            'Windy conditions: High evaporation risk. Increase irrigation.';
        actions = [
          'Increase watering frequency by 20%',
          'Check for wind damage',
          'Ensure staking for tall crops',
        ];
        break;

      case 'frost':
      case 'cold':
        recommendation = 'Cold weather: Reduce watering. Protect sensitive crops.';
        actions = [
          'Reduce irrigation significantly',
          'Cover sensitive plants if frost expected',
          'Delay fertilizer application',
        ];
        break;

      default:
        recommendation = 'Check local weather updates for detailed guidance.';
        actions = ['Monitor weather forecast regularly'];
    }

    return {
      'weather_condition': weatherCondition,
      'recommendation': recommendation,
      'immediate_actions': actions,
      'irrigation_adjustment': _getIrrigationAdjustment(weatherCondition),
      'pest_risk_increase': _getPestRiskIncrease(weatherCondition),
      'disease_risk_increase': _getDiseaseRiskIncrease(weatherCondition),
    };
  }

  // Helper methods for recommendations

  double _getCropWaterNeeds(String cropType) {
    const waterNeeds = {
      'rice': 1.2,
      'wheat': 0.9,
      'corn': 1.1,
      'sugarcane': 1.3,
      'cotton': 0.8,
      'potato': 1.0,
      'tomato': 1.1,
      'onion': 0.9,
      'chili': 0.95,
      'default': 1.0,
    };
    return waterNeeds[cropType.toLowerCase()] ?? waterNeeds['default']!;
  }

  Map<String, int> _getCropNutrientNeeds(String cropType, int daysInCycle) {
    // Returns N, P, K in kg/hectare
    const nutrientNeeds = {
      'rice': {'N': 120, 'P': 60, 'K': 40},
      'wheat': {'N': 100, 'P': 50, 'K': 40},
      'corn': {'N': 150, 'P': 70, 'K': 60},
      'tomato': {'N': 200, 'P': 100, 'K': 150},
      'chili': {'N': 150, 'P': 80, 'K': 100},
      'onion': {'N': 120, 'P': 60, 'K': 120},
      'potato': {'N': 200, 'P': 100, 'K': 200},
    };

    final baseNeeds =
        nutrientNeeds[cropType.toLowerCase()] ?? {'N': 100, 'P': 50, 'K': 50};

    // Adjust based on days in cycle (reduce if already matured)
    double factor = 1.0;
    if (daysInCycle > 80) factor = 0.5;
    if (daysInCycle > 100) factor = 0.3;

    return {
      'N': (baseNeeds['N']! * factor).toInt(),
      'P': (baseNeeds['P']! * factor).toInt(),
      'K': (baseNeeds['K']! * factor).toInt(),
    };
  }

  int _getNextCheckTime(double moisture, double temperature, String cropType) {
    int hours = 24;

    if (moisture < 30) {
      hours = 6;
    } else if (moisture < 40) {
      hours = 12;
    } else if (moisture < 50) {
      hours = 18;
    }

    if (temperature > 30) {
      hours = (hours * 0.8).toInt();
    }

    return hours;
  }

  String _getIrrigationMethod(String soilType) {
    switch (soilType.toLowerCase()) {
      case 'clay':
        return 'Drip irrigation (prevents waterlogging)';
      case 'sand':
        return 'Frequent light watering or drip system';
      case 'loam':
        return 'Flood or drip irrigation';
      default:
        return 'Drip irrigation recommended';
    }
  }

  String _getBestIrrigationTime(double temperature) {
    if (temperature > 35) {
      return 'Early morning (4-6 AM) to prevent evaporation';
    } else if (temperature > 30) {
      return 'Early morning or late evening';
    } else {
      return 'Morning or evening';
    }
  }

  List<String> _getOrganicFertilizers(String cropType) {
    return [
      'Cow manure (aged): 5-10 tons/hectare',
      'Compost: 3-5 tons/hectare',
      'Green manure/legume crops',
      'Neem cake: 1-2 tons/hectare',
      'Vermicompost: 2-3 tons/hectare',
      'Fish emulsion: 500-1000 L/hectare',
    ];
  }

  List<String> _getChemicalFertilizers(String cropType) {
    return [
      'Urea (46% N): Apply in splits',
      'DAP (Diammonium Phosphate): 18% N, 46% P',
      'Potassium Chloride (60% K)',
      'Complex fertilizers: NPK 10:26:26',
      'Micro-nutrients: Zinc, Boron, Iron as needed',
    ];
  }

  String _getFertilizerTiming(String cropType, int daysInCycle) {
    if (daysInCycle < 30) {
      return 'Basal application at planting + first split at 30 days';
    } else if (daysInCycle < 60) {
      return 'Two more splits at 30-day intervals';
    } else {
      return 'Late season fertilizer for grain filling';
    }
  }

  String _getFertilizerFrequency(String cropType) {
    switch (cropType.toLowerCase()) {
      case 'rice':
      case 'wheat':
        return '2-3 splits';
      case 'tomato':
      case 'chili':
        return '4-5 splits (continuous light applications)';
      default:
        return '2-3 splits';
    }
  }

  List<String> _getCommonPests(String cropType, String condition) {
    // Simplified pest list based on crop and condition
    if (condition == 'humid' || condition == 'wet') {
      return ['Fungal diseases', 'Bacterial leaf spot', 'Root rot', 'Slugs'];
    }
    return ['Aphids', 'Spider mites', 'Leaf hoppers', 'Caterpillars'];
  }

  List<String> _getCropSpecificPrevention(String cropType) {
    const preventions = {
      'rice': [
        'Drain water during critical growth stages',
        'Maintain water level at 5-7cm',
      ],
      'tomato': [
        'Prune lower leaves for better air circulation',
        'Stake and support plants',
      ],
      'chili': ['Space plants widely for ventilation', 'Mulch to retain moisture'],
    };
    return preventions[cropType.toLowerCase()] ?? [];
  }

  String _getOrganicPestControl(String cropType, List<String> pests) {
    return '''
- Neem oil spray: 3-5% solution, spray weekly
- Insecticidal soap for soft-bodied insects
- Bacillus thuringiensis (Bt) for caterpillars
- Sulfur dust for mites and powdery mildew
- Remove affected plant parts immediately
- Encourage beneficial insects (ladybugs, wasps)
''';
  }

  String _getChemicalPestControl(String cropType, List<String> pests) {
    return '''
- Chlorpyrifos: 2ml/L, spray weekly
- Carbofuran: Soil application for root feeders
- Carbendazim: For fungal infections
- Follow local pest advisory for specific chemicals
- Always follow label instructions carefully
- Observe harvest interval (minimum 7-14 days before harvest)
''';
  }

  String _getOptimalTreatmentTime(double temperature) {
    if (temperature > 30) {
      return 'Early morning (5-8 AM) when insects are less active';
    } else {
      return 'Evening (4-6 PM) for better results';
    }
  }

  Map<String, dynamic> _getCropCycleInfo(String cropType) {
    const cycles = {
      'rice': {'days_to_maturity': 120, 'critical_stage': 'flowering'},
      'wheat': {'days_to_maturity': 140, 'critical_stage': 'grain-filling'},
      'corn': {'days_to_maturity': 120, 'critical_stage': 'silking'},
      'tomato': {'days_to_maturity': 90, 'critical_stage': 'flowering'},
      'chili': {'days_to_maturity': 120, 'critical_stage': 'flowering'},
      'onion': {'days_to_maturity': 150, 'critical_stage': 'bulking'},
      'potato': {'days_to_maturity': 100, 'critical_stage': 'tuber-filling'},
    };
    return cycles[cropType.toLowerCase()] ?? {'days_to_maturity': 120};
  }

  String _estimateYieldQuality(
    double moisture,
    double temperature,
    int daysPlanted,
    Map<String, dynamic> cycleInfo,
  ) {
    if (moisture < 30 || moisture > 70) return 'Fair (irrigation issues detected)';
    if (temperature > 35 || temperature < 15) return 'Fair (stress conditions)';
    return 'Good to Excellent';
  }

  List<String> _getPreHarvestTasks(String cropType) {
    return [
      'Check grain/fruit moisture content',
      'Ensure harvesting equipment is ready',
      'Arrange labor/machinery for harvest',
      'Plan storage facility',
      'Check weather forecast for optimal harvest window',
    ];
  }

  List<String> _getHarvestTips(String cropType) {
    return [
      'Harvest early morning when moisture is optimal',
      'Handle produce carefully to minimize damage',
      'Keep harvested produce in shade',
      'Ensure clean transportation to storage',
    ];
  }

  String _getStorageRecommendation(String cropType) {
    switch (cropType.toLowerCase()) {
      case 'rice':
      case 'wheat':
        return 'Store in cool, dry place. Target moisture: 12-13%. Use airtight containers.';
      case 'tomato':
      case 'chili':
        return 'Cool storage (10-15°C) with 85-90% humidity.';
      case 'potato':
      case 'onion':
        return 'Cool (4-8°C), dark place. Ensure good ventilation. Avoid light exposure.';
      default:
        return 'Store in cool, dry, well-ventilated area. Check regularly for spoilage.';
    }
  }

  String _getIrrigationAdjustment(String weather) {
    switch (weather.toLowerCase()) {
      case 'rainy':
      case 'rain':
        return 'Reduce by 80-100% (skip irrigation)';
      case 'sunny':
      case 'clear':
        return 'Increase by 30-50%';
      case 'windy':
        return 'Increase by 20-30%';
      case 'cloudy':
        return 'Reduce by 10-20%';
      default:
        return 'No adjustment needed';
    }
  }

  String _getPestRiskIncrease(String weather) {
    if (weather.toLowerCase().contains('rain') ||
        weather.toLowerCase().contains('humid')) {
      return 'High (fungal and bacterial diseases likely)';
    }
    return 'Moderate';
  }

  String _getDiseaseRiskIncrease(String weather) {
    if (weather.toLowerCase().contains('rain')) {
      return 'Critical (high humidity and wet conditions)';
    } else if (weather.toLowerCase().contains('humid')) {
      return 'High';
    }
    return 'Low to Moderate';
  }
}

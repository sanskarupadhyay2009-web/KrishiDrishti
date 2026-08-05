// lib/models/sensor_data.dart

class SensorData {
  final DateTime timestamp;
  final double nitrogen;
  final double phosphorus;
  final double potassium;
  final double moisture;
  final double ph;
  final double temperature;

  const SensorData({
    required this.timestamp,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.moisture,
    required this.ph,
    required this.temperature,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      nitrogen: (json['N'] ?? json['nitrogen'] ?? 0).toDouble(),
      phosphorus: (json['P'] ?? json['phosphorus'] ?? 0).toDouble(),
      potassium: (json['K'] ?? json['potassium'] ?? 0).toDouble(),
      moisture: (json['moisture'] ?? 0).toDouble(),
      ph: (json['ph'] ?? 0).toDouble(),
      temperature: (json['temperature'] ?? json['temp'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'N': nitrogen,
      'P': phosphorus,
      'K': potassium,
      'moisture': moisture,
      'ph': ph,
      'temperature': temperature,
    };
  }
}

// lib/models/sensor_data.dart

class SensorData {
  final double nitrogen;
  final double phosphorus;
  final double potassium;
  final double moisture;
  final double ph;

  const SensorData({
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.moisture,
    required this.ph,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      nitrogen: (json['N'] ?? json['nitrogen'] ?? 0).toDouble(),
      phosphorus: (json['P'] ?? json['phosphorus'] ?? 0).toDouble(),
      potassium: (json['K'] ?? json['potassium'] ?? 0).toDouble(),
      moisture: (json['moisture'] ?? 0).toDouble(),
      ph: (json['ph'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'N': nitrogen,
      'P': phosphorus,
      'K': potassium,
      'moisture': moisture,
      'ph': ph,
    };
  }
}

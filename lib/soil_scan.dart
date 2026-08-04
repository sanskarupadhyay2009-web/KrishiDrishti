/// A single soil scan reading plus the advice generated for it.
///
/// In the MVP the readings come from the [ScanPage] simulator (there is no
/// paired ESP32 device yet). The shape of this model is exactly what the
/// real Bluetooth pipeline will eventually produce, so swapping the
/// simulator for real sensor data later only means changing how a
/// [SoilScan] gets created — nothing else in the app needs to change.
class SoilScan {
  final DateTime timestamp;
  final double moisture; // percent, 0-100
  final double ph; // 0-14
  final double temperature; // Celsius
  final String healthStatus; // Healthy | Needs Attention | Poor
  final List<String> recommendations;

  SoilScan({
    required this.timestamp,
    required this.moisture,
    required this.ph,
    required this.temperature,
    required this.healthStatus,
    required this.recommendations,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'moisture': moisture,
        'ph': ph,
        'temperature': temperature,
        'healthStatus': healthStatus,
        'recommendations': recommendations,
      };

  factory SoilScan.fromJson(Map<String, dynamic> json) {
    return SoilScan(
      timestamp: DateTime.parse(json['timestamp'] as String),
      moisture: (json['moisture'] as num).toDouble(),
      ph: (json['ph'] as num).toDouble(),
      temperature: (json['temperature'] as num).toDouble(),
      healthStatus: json['healthStatus'] as String,
      recommendations: List<String>.from(json['recommendations'] as List),
    );
  }
}

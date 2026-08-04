import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'models/soil_scan.dart';
import 'utils/app_strings.dart';
import 'widgets/primary_button.dart';
import 'home_page.dart';

class ResultPage extends StatelessWidget {
  final SoilScan scan;
  final bool isNewScan;

  const ResultPage({super.key, required this.scan, this.isNewScan = false});

  Color _statusColor(String status) {
    switch (status) {
      case 'Healthy':
      case 'स्वस्थ':
        return Colors.green;
      case 'Poor':
      case 'खराब':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Healthy':
      case 'स्वस्थ':
        return Icons.check_circle;
      case 'Poor':
      case 'खराब':
        return Icons.error;
      default:
        return Icons.warning_amber_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final s = AppStrings(app.isHindi);
    final color = _statusColor(scan.healthStatus);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.scanResult),
        automaticallyImplyLeading: !isNewScan,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: color.withValues(alpha: 0.08),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(_statusIcon(scan.healthStatus), color: color, size: 40),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            scan.healthStatus,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          if (isNewScan)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                s.savedToHistory,
                                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(child: _MetricTile(label: s.moisture, value: '${scan.moisture.toStringAsFixed(0)}%', icon: Icons.water_drop)),
                const SizedBox(width: 12),
                Expanded(child: _MetricTile(label: 'pH', value: scan.ph.toStringAsFixed(1), icon: Icons.science)),
                const SizedBox(width: 12),
                Expanded(child: _MetricTile(label: s.temperature, value: '${scan.temperature.toStringAsFixed(0)}°C', icon: Icons.thermostat)),
              ],
            ),

            const SizedBox(height: 28),

            Text(s.recommendations, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            ...scan.recommendations.map(
              (tip) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(tip, style: const TextStyle(fontSize: 15, height: 1.4)),
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (isNewScan)
              PrimaryButton(
                label: s.backToHome,
                icon: Icons.home,
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                  (route) => false,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF2E7D32)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

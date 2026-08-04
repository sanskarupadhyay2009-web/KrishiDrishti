import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'models/soil_scan.dart';
import 'services/recommendation_engine.dart';
import 'utils/app_strings.dart';
import 'result_page.dart';

/// Simulates a reading from the Smart Soil Analyzer.
///
/// There is no paired ESP32 yet, so this generates plausible sensor values
/// with a short "reading" animation. Once the Bluetooth pipeline
/// (Phase 3 of the roadmap) is wired up, only the body of [_runScan] needs
/// to change — everything downstream (recommendation engine, result page,
/// history) already works off a [SoilScan] object.
class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _runScan();
  }

  Future<void> _runScan() async {
    const steps = 20;
    for (var i = 1; i <= steps; i++) {
      await Future.delayed(const Duration(milliseconds: 90));
      if (!mounted) return;
      setState(() => _progress = i / steps);
    }

    if (!mounted) return;

    final rand = Random();
    final moisture = 10 + rand.nextDouble() * 70; // 10-80 %
    final ph = 4.5 + rand.nextDouble() * 5; // 4.5-9.5
    final temperature = 12 + rand.nextDouble() * 28; // 12-40 °C

    final app = context.read<AppProvider>();
    final result = RecommendationEngine.generate(
      moisture: moisture,
      ph: ph,
      temperature: temperature,
      isHindi: app.isHindi,
    );

    final scan = SoilScan(
      timestamp: DateTime.now(),
      moisture: moisture,
      ph: ph,
      temperature: temperature,
      healthStatus: result.healthStatus,
      recommendations: result.recommendations,
    );

    await app.addScan(scan);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultPage(scan: scan, isNewScan: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final s = AppStrings(app.isHindi);

    return Scaffold(
      backgroundColor: const Color(0xFF2E7D32),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: _progress,
                      color: Colors.white,
                      backgroundColor: Colors.white24,
                      strokeWidth: 5,
                    ),
                    const Icon(Icons.sensors, color: Colors.white, size: 44),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                s.scanning,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                s.scanningSub,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

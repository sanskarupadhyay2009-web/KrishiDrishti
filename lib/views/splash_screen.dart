// lib/views/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/sensor_provider.dart';
import 'navigation_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final navigator = Navigator.of(context);
    final sensorProvider = context.read<SensorProvider>();
    await Future.delayed(const Duration(milliseconds: 500));
    await sensorProvider.scanForSensor();
    if (!mounted) return;
    navigator.pushReplacement(
      MaterialPageRoute(builder: (_) => const NavigationShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LanguageProvider>().strings;
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF81C784)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.grass, size: 96, color: Colors.white),
            const SizedBox(height: 16),
            Text(strings.appName,
                style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(strings.tagline,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

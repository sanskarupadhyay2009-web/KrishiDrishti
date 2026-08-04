import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home_page.dart';
import 'scan_page.dart';
import 'result_page.dart';
import 'settings_page.dart';

void main() {
  runApp(const KrishiDrishtiApp());
}

class KrishiDrishtiApp extends StatelessWidget {
  const KrishiDrishtiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KrishiDrishti',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        scaffoldBackgroundColor: const Color(0xffF5F8F3),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const HomePage(),
      routes: {
        '/scan': (_) => const ScanPage(),
        '/result': (_) => const ResultPage(),
        '/settings': (_) => const SettingsPage(),
      },
    );
  }
}

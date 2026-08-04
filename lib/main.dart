import 'package:flutter/material.dart';
import 'splash_page.dart';

void main() {
  runApp(const KrishiDrishti());
}

class KrishiDrishti extends StatelessWidget {
  const KrishiDrishti({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "KrishiDrishti",
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const SplashPage(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'utils/app_strings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final s = AppStrings(app.isHindi);

    return Scaffold(
      appBar: AppBar(title: Text(s.settings)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(s.language, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                RadioListTile<bool>(
                  title: Text(s.english),
                  value: false,
                  // ignore: deprecated_member_use
                  groupValue: app.isHindi,
                  // ignore: deprecated_member_use
                  onChanged: (v) => context.read<AppProvider>().setLanguage(false),
                ),
                const Divider(height: 1),
                RadioListTile<bool>(
                  title: Text(s.hindi),
                  value: true,
                  // ignore: deprecated_member_use
                  groupValue: app.isHindi,
                  // ignore: deprecated_member_use
                  onChanged: (v) => context.read<AppProvider>().setLanguage(true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(s.about, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.eco, color: Color(0xFF2E7D32)),
                      SizedBox(width: 10),
                      Text('KrishiDrishti', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(s.aboutBody, style: TextStyle(color: Colors.grey.shade700, height: 1.4)),
                  const SizedBox(height: 12),
                  Text('${s.version}: 1.0.0', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

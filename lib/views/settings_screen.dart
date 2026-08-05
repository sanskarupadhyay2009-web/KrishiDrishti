// lib/views/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../providers/language_provider.dart';
import '../providers/sensor_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final strings = languageProvider.strings;
    final sensorProvider = context.watch<SensorProvider>();

    Future<void> showScanModal() async {
      // start scanning (don't await) so results stream into provider
      sensorProvider.scanForSensor();
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (ctx) {
          return SafeArea(
            child: SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.6,
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(strings.selectSensor, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    TextButton(onPressed: () {
                      FlutterBluePlus.stopScan();
                      Navigator.of(ctx).pop();
                    }, child: const Text('Close'))
                  ]),
                ),
                const Divider(height: 1),
                Expanded(
                  child: Consumer<SensorProvider>(builder: (c, prov, _) {
                    final list = prov.discoveredResults;
                    if (list.isEmpty) return const Center(child: Text('Scanning...'));
                    return ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, i) {
                        final r = list[i];
                        final devName = r.device.platformName.toString().isNotEmpty
                          ? r.device.platformName.toString()
                          : r.device.remoteId.toString();
                        return ListTile(
                          title: Text(devName),
                          subtitle: Text('RSSI: ${r.rssi}'),
                          trailing: ElevatedButton(
                            onPressed: () async {
                              FlutterBluePlus.stopScan();
                              Navigator.of(ctx).pop();
                              await prov.connectToDevice(r.device);
                            },
                            child: const Text('Connect'),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ]),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(strings.settings)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(strings.selectLanguagePrompt, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: languageProvider.languageCode,
            items: [
              DropdownMenuItem(value: 'en', child: Text(strings.english)),
              DropdownMenuItem(value: 'hi', child: Text(strings.hindi)),
              DropdownMenuItem(value: 'mr', child: Text(strings.marathi)),
            ],
            onChanged: (value) {
              if (value != null) {
                languageProvider.setLocale(value);
              }
            },
            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: Text(strings.debugMode),
            subtitle: Text(sensorProvider.isDebugMode ? strings.mockModeEnabled : strings.liveBleMode),
            value: sensorProvider.isDebugMode,
            onChanged: (value) => sensorProvider.toggleDebugMode(value),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: showScanModal,
            icon: const Icon(Icons.bluetooth_searching),
            label: Text(strings.scanButton),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(strings.about, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Text(strings.aboutBody, style: const TextStyle(height: 1.5)),
                const SizedBox(height: 12),
                Text('${strings.version}: 1.0.0', style: const TextStyle(color: Colors.black54)),
              ]),
            ),
          ),
        ]),
        ),
      ),
    );
  }
}

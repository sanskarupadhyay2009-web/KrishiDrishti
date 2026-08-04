import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'utils/app_strings.dart';
import 'widgets/primary_button.dart';
import 'scan_page.dart';
import 'result_page.dart';
import 'history_page.dart';
import 'chat_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _connecting = false;

  Future<void> _toggleConnection(AppProvider app) async {
    if (app.isDeviceConnected) {
      app.setDeviceConnected(false);
      return;
    }
    setState(() => _connecting = true);
    // Simulated pairing delay — the real ESP32 handshake will replace this.
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _connecting = false);
    app.setDeviceConnected(true);
  }

  void _startScan(BuildContext context, AppProvider app, AppStrings s) {
    if (!app.isDeviceConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.connectFirst)),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScanPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final s = AppStrings(app.isHindi);
    final lastScan = app.lastScan;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: s.viewHistory,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: s.settings,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🌱 ${s.welcome}',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                s.homeSubtitle,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
              ),
              const SizedBox(height: 22),

              // Device status card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: app.isDeviceConnected
                            ? Colors.green
                            : Colors.redAccent,
                        child: Icon(
                          app.isDeviceConnected
                              ? Icons.bluetooth_connected
                              : Icons.bluetooth_disabled,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.deviceStatus,
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(
                              app.isDeviceConnected ? s.connected : s.notConnected,
                              style: TextStyle(
                                color: app.isDeviceConnected
                                    ? Colors.green.shade700
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 96,
                        child: OutlinedButton(
                          onPressed: _connecting ? null : () => _toggleConnection(app),
                          child: _connecting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(app.isDeviceConnected ? s.disconnect : s.connect),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 22),

              PrimaryButton(
                label: s.startScan,
                icon: Icons.sensors,
                onPressed: () => _startScan(context, app, s),
              ),

              const SizedBox(height: 14),

              PrimaryButton(
                label: s.askAssistant,
                icon: Icons.chat_bubble_outline,
                color: const Color(0xFF558B2F),
                height: 52,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatPage()),
                ),
              ),

              const SizedBox(height: 30),

              Text(
                s.lastScan,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              if (lastScan == null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      s.noScansYet,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                )
              else
                Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ResultPage(scan: lastScan, isNewScan: false),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(s.soilHealth, style: const TextStyle(fontSize: 16)),
                              Text(
                                lastScan.healthStatus,
                                style: TextStyle(
                                  color: _statusColor(lastScan.healthStatus),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 22),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(s.moisture),
                              Text('${lastScan.moisture.toStringAsFixed(0)}%'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('pH'),
                              Text(lastScan.ph.toStringAsFixed(1)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(s.temperature),
                              Text('${lastScan.temperature.toStringAsFixed(0)}°C'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

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
}

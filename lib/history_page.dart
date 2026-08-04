import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'models/soil_scan.dart';
import 'utils/app_strings.dart';
import 'result_page.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

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

  Future<void> _confirmClear(BuildContext context, AppProvider app, AppStrings s) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.clearHistory),
        content: Text(s.clearHistoryConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await app.clearHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final s = AppStrings(app.isHindi);
    final history = app.history;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.scanHistory),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: s.clearHistory,
              onPressed: () => _confirmClear(context, app, s),
            ),
        ],
      ),
      body: history.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  s.noHistory,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (history.length > 1) ...[
                  Text(s.moistureTrend, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 160,
                    child: _MoistureChart(history: history.reversed.toList()),
                  ),
                  const SizedBox(height: 26),
                ],
                ...history.map((scan) => _HistoryTile(
                      scan: scan,
                      color: _statusColor(scan.healthStatus),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ResultPage(scan: scan, isNewScan: false),
                        ),
                      ),
                    )),
              ],
            ),
    );
  }
}

class _MoistureChart extends StatelessWidget {
  final List<SoilScan> history;
  const _MoistureChart({required this.history});

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[
      for (var i = 0; i < history.length; i++) FlSpot(i.toDouble(), history[i].moisture),
    ];

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 100,
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: const FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFF2E7D32),
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final SoilScan scan;
  final Color color;
  final VoidCallback onTap;

  const _HistoryTile({required this.scan, required this.color, required this.onTap});

  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/${dt.year} · $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(Icons.eco, color: color),
        ),
        title: Text(scan.healthStatus, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        subtitle: Text(_formatDate(scan.timestamp)),
        trailing: Text(
          '${scan.moisture.toStringAsFixed(0)}% · pH ${scan.ph.toStringAsFixed(1)}',
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}

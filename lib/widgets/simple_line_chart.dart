// lib/widgets/simple_line_chart.dart

import 'package:flutter/material.dart';

class SimpleLineChart extends StatelessWidget {
  final String title;
  final List<double> values;
  final Color color;
  final String unit;

  const SimpleLineChart({
    super.key,
    required this.title,
    required this.values,
    required this.color,
    this.unit = '',
  });

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('No data available for $title'),
        ),
      );
    }

    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: CustomPaint(
                painter: _LineChartPainter(values: values, color: color, minValue: minValue, maxValue: maxValue),
                child: const SizedBox.expand(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${values.first.toStringAsFixed(1)}$unit', style: const TextStyle(fontSize: 14)),
                Text('${values.last.toStringAsFixed(1)}$unit', style: const TextStyle(fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final Color color;
  final double minValue;
  final double maxValue;

  _LineChartPainter({
    required this.values,
    required this.color,
    required this.minValue,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final path = Path();
    final points = values.asMap().entries.map((entry) {
      final x = size.width * (entry.key / (values.length - 1).clamp(1, double.infinity));
      final y = size.height - ((entry.value - minValue) / (maxValue - minValue)) * size.height;
      return Offset(x, y);
    }).toList();

    if (points.isEmpty) return;
    path.moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.color != color || oldDelegate.minValue != minValue || oldDelegate.maxValue != maxValue;
  }
}

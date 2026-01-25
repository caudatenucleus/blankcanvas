import 'package:flutter/widgets.dart';
import 'dart:math' as math;

/// A data series for the radar chart.
class RadarChartData {
  const RadarChartData({required this.values, required this.color, this.label});
  final List<double> values;
  final Color color;
  final String? label;
}

/// A radar/spider chart visualization.
class RadarChart extends LeafRenderObjectWidget {
  const RadarChart({
    super.key,
    required this.data,
    this.labels = const [],
    this.maxValue,
    this.gridLevels = 5,
    this.showLabels = true,
    this.tag,
  });

  final List<RadarChartData> data;
  final List<String> labels;
  final double? maxValue;
  final int gridLevels;
  final bool showLabels;
  final String? tag;

  @override
  RenderRadarChart createRenderObject(BuildContext context) {
    return RenderRadarChart(
      data: data,
      labels: labels,
      maxValue: maxValue,
      gridLevels: gridLevels,
      showLabels: showLabels,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderRadarChart renderObject) {
    renderObject
      ..data = data
      ..labels = labels
      ..maxValue = maxValue
      ..gridLevels = gridLevels
      ..showLabels = showLabels;
  }
}

class RenderRadarChart extends RenderBox {
  RenderRadarChart({
    required List<RadarChartData> data,
    required List<String> labels,
    double? maxValue,
    required int gridLevels,
    required bool showLabels,
  }) : _data = data,
       _labels = labels,
       _maxValue = maxValue,
       _gridLevels = gridLevels,
       _showLabels = showLabels;

  List<RadarChartData> _data;
  set data(List<RadarChartData> value) {
    _data = value;
    markNeedsPaint();
  }

  List<String> _labels;
  set labels(List<String> value) {
    _labels = value;
    markNeedsPaint();
  }

  double? _maxValue;
  set maxValue(double? value) {
    _maxValue = value;
    markNeedsPaint();
  }

  int _gridLevels;
  set gridLevels(int value) {
    _gridLevels = value;
    markNeedsPaint();
  }

  bool _showLabels;
  set showLabels(bool value) {
    _showLabels = value;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    size = constraints.constrain(
      Size(constraints.maxWidth, constraints.maxWidth),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    if (_data.isEmpty) return;

    final center = offset + Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 40;
    final axes = _data.first.values.length;
    if (axes < 3) return;

    final angleStep = (2 * math.pi) / axes;
    final max =
        _maxValue ??
        _data.fold<double>(
          0,
          (m, d) => math.max(m, d.values.fold<double>(m, math.max)),
        );

    // Grid circles
    final gridPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int level = 1; level <= _gridLevels; level++) {
      final levelRadius = (radius / _gridLevels) * level;
      final gridPath = Path();
      for (int i = 0; i < axes; i++) {
        final angle = -math.pi / 2 + angleStep * i;
        final point =
            center +
            Offset(
              math.cos(angle) * levelRadius,
              math.sin(angle) * levelRadius,
            );
        if (i == 0) {
          gridPath.moveTo(point.dx, point.dy);
        } else {
          gridPath.lineTo(point.dx, point.dy);
        }
      }
      gridPath.close();
      canvas.drawPath(gridPath, gridPaint);
    }

    // Axes lines
    for (int i = 0; i < axes; i++) {
      final angle = -math.pi / 2 + angleStep * i;
      final end =
          center + Offset(math.cos(angle) * radius, math.sin(angle) * radius);
      canvas.drawLine(center, end, gridPaint);

      // Labels
      if (_showLabels && i < _labels.length) {
        final labelPos =
            center +
            Offset(
              math.cos(angle) * (radius + 20),
              math.sin(angle) * (radius + 20),
            );
        textPainter.text = TextSpan(
          text: _labels[i],
          style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          labelPos - Offset(textPainter.width / 2, textPainter.height / 2),
        );
      }
    }

    // Data series
    for (final series in _data) {
      final dataPath = Path();
      for (int i = 0; i < axes; i++) {
        final angle = -math.pi / 2 + angleStep * i;
        final value = i < series.values.length ? series.values[i] : 0;
        final r = (value / max) * radius;
        final point = center + Offset(math.cos(angle) * r, math.sin(angle) * r);
        if (i == 0) {
          dataPath.moveTo(point.dx, point.dy);
        } else {
          dataPath.lineTo(point.dx, point.dy);
        }
      }
      dataPath.close();

      // Fill
      canvas.drawPath(
        dataPath,
        Paint()..color = series.color.withValues(alpha: 0.3),
      );
      // Stroke
      canvas.drawPath(
        dataPath,
        Paint()
          ..color = series.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // Points
      for (int i = 0; i < axes; i++) {
        final angle = -math.pi / 2 + angleStep * i;
        final value = i < series.values.length ? series.values[i] : 0;
        final r = (value / max) * radius;
        final point = center + Offset(math.cos(angle) * r, math.sin(angle) * r);
        canvas.drawCircle(point, 4, Paint()..color = series.color);
        canvas.drawCircle(point, 2, Paint()..color = const Color(0xFFFFFFFF));
      }
    }
  }
}

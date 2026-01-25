import 'package:flutter/widgets.dart';
import 'dart:math' as math;

/// A data point for the area chart.
class AreaChartData {
  const AreaChartData({required this.x, required this.y, this.label});
  final double x;
  final double y;
  final String? label;
}

/// An area chart visualization (filled line chart).
class AreaChart extends LeafRenderObjectWidget {
  const AreaChart({
    super.key,
    required this.data,
    this.fillColor = const Color(0x332196F3),
    this.lineColor = const Color(0xFF2196F3),
    this.showGrid = true,
    this.tag,
  });

  final List<AreaChartData> data;
  final Color fillColor;
  final Color lineColor;
  final bool showGrid;
  final String? tag;

  @override
  RenderAreaChart createRenderObject(BuildContext context) {
    return RenderAreaChart(
      data: data,
      fillColor: fillColor,
      lineColor: lineColor,
      showGrid: showGrid,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderAreaChart renderObject) {
    renderObject
      ..data = data
      ..fillColor = fillColor
      ..lineColor = lineColor
      ..showGrid = showGrid;
  }
}

class RenderAreaChart extends RenderBox {
  RenderAreaChart({
    required List<AreaChartData> data,
    required Color fillColor,
    required Color lineColor,
    required bool showGrid,
  }) : _data = data,
       _fillColor = fillColor,
       _lineColor = lineColor,
       _showGrid = showGrid;

  List<AreaChartData> _data;
  set data(List<AreaChartData> value) {
    _data = value;
    markNeedsPaint();
  }

  Color _fillColor;
  set fillColor(Color value) {
    _fillColor = value;
    markNeedsPaint();
  }

  Color _lineColor;
  set lineColor(Color value) {
    _lineColor = value;
    markNeedsPaint();
  }

  bool _showGrid;
  set showGrid(bool value) {
    _showGrid = value;
    markNeedsPaint();
  }

  static const double _padding = 30.0;

  @override
  void performLayout() {
    size = constraints.constrain(Size(constraints.maxWidth, 200));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    if (_data.isEmpty) return;

    final chartRect = Rect.fromLTWH(
      offset.dx + _padding,
      offset.dy + _padding / 2,
      size.width - _padding * 2,
      size.height - _padding,
    );

    final minX = _data.fold<double>(_data.first.x, (m, d) => math.min(m, d.x));
    final maxX = _data.fold<double>(_data.first.x, (m, d) => math.max(m, d.x));
    final minY = 0.0;
    final maxY =
        _data.fold<double>(_data.first.y, (m, d) => math.max(m, d.y)) * 1.1;

    final xRange = maxX - minX == 0 ? 1 : maxX - minX;
    final yRange = maxY - minY == 0 ? 1 : maxY - minY;

    // Grid
    if (_showGrid) {
      final gridPaint = Paint()
        ..color = const Color(0xFFE0E0E0)
        ..strokeWidth = 1;
      for (int i = 0; i <= 4; i++) {
        final y = chartRect.top + (chartRect.height / 4) * i;
        canvas.drawLine(
          Offset(chartRect.left, y),
          Offset(chartRect.right, y),
          gridPaint,
        );

        final value = maxY - (yRange / 4) * i;
        textPainter.text = TextSpan(
          text: value.toStringAsFixed(0),
          style: const TextStyle(fontSize: 10, color: Color(0xFF999999)),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            chartRect.left - textPainter.width - 4,
            y - textPainter.height / 2,
          ),
        );
      }
    }

    // Points
    final points = <Offset>[];
    for (final d in _data) {
      final x = chartRect.left + ((d.x - minX) / xRange) * chartRect.width;
      final y = chartRect.bottom - ((d.y - minY) / yRange) * chartRect.height;
      points.add(Offset(x, y));
    }

    if (points.length < 2) return;

    // Area fill
    final areaPath = Path()
      ..moveTo(points.first.dx, chartRect.bottom)
      ..lineTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      areaPath.lineTo(p.dx, p.dy);
    }
    areaPath.lineTo(points.last.dx, chartRect.bottom);
    areaPath.close();
    canvas.drawPath(areaPath, Paint()..color = _fillColor);

    // Line
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      linePath.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = _lineColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }
}

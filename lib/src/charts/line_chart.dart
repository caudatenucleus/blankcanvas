import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;

/// A data point for the line chart.
class LineChartData {
  const LineChartData({required this.x, required this.y, this.label});
  final double x;
  final double y;
  final String? label;
}

/// A line chart visualization.
class LineChart extends LeafRenderObjectWidget {
  const LineChart({
    super.key,
    required this.data,
    this.lineColor = const Color(0xFF2196F3),
    this.fillColor,
    this.showPoints = true,
    this.showGrid = true,
    this.curved = false,
    this.onPointTap,
    this.tag,
  });

  final List<LineChartData> data;
  final Color lineColor;
  final Color? fillColor;
  final bool showPoints;
  final bool showGrid;
  final bool curved;
  final void Function(int index)? onPointTap;
  final String? tag;

  @override
  RenderLineChart createRenderObject(BuildContext context) {
    return RenderLineChart(
      data: data,
      lineColor: lineColor,
      fillColor: fillColor,
      showPoints: showPoints,
      showGrid: showGrid,
      curved: curved,
      onPointTap: onPointTap,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderLineChart renderObject) {
    renderObject
      ..data = data
      ..lineColor = lineColor
      ..fillColor = fillColor
      ..showPoints = showPoints
      ..showGrid = showGrid
      ..curved = curved
      ..onPointTap = onPointTap;
  }
}

class RenderLineChart extends RenderBox {
  RenderLineChart({
    required List<LineChartData> data,
    required Color lineColor,
    Color? fillColor,
    required bool showPoints,
    required bool showGrid,
    required bool curved,
    void Function(int index)? onPointTap,
  }) : _data = data,
       _lineColor = lineColor,
       _fillColor = fillColor,
       _showPoints = showPoints,
       _showGrid = showGrid,
       _curved = curved,
       _onPointTap = onPointTap {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  List<LineChartData> _data;
  set data(List<LineChartData> value) {
    _data = value;
    markNeedsPaint();
  }

  Color _lineColor;
  set lineColor(Color value) {
    _lineColor = value;
    markNeedsPaint();
  }

  Color? _fillColor;
  set fillColor(Color? value) {
    _fillColor = value;
    markNeedsPaint();
  }

  bool _showPoints;
  set showPoints(bool value) {
    _showPoints = value;
    markNeedsPaint();
  }

  bool _showGrid;
  set showGrid(bool value) {
    _showGrid = value;
    markNeedsPaint();
  }

  bool _curved;
  set curved(bool value) {
    _curved = value;
    markNeedsPaint();
  }

  void Function(int index)? _onPointTap;
  set onPointTap(void Function(int index)? value) => _onPointTap = value;

  late TapGestureRecognizer _tap;
  int? _hoveredIndex;

  final List<Offset> _pointPositions = [];

  static const double _padding = 30.0;
  static const double _pointRadius = 5.0;

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    size = constraints.constrain(Size(constraints.maxWidth, 200));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    _pointPositions.clear();

    if (_data.isEmpty) return;

    final chartRect = Rect.fromLTWH(
      offset.dx + _padding,
      offset.dy + _padding,
      size.width - _padding * 2,
      size.height - _padding * 2,
    );

    final minX = _data.fold<double>(
      _data.first.x,
      (min, d) => math.min(min, d.x),
    );
    final maxX = _data.fold<double>(
      _data.first.x,
      (max, d) => math.max(max, d.x),
    );
    final minY = _data.fold<double>(
      _data.first.y,
      (min, d) => math.min(min, d.y),
    );
    final maxY = _data.fold<double>(
      _data.first.y,
      (max, d) => math.max(max, d.y),
    );

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

    // Calculate points
    final points = <Offset>[];
    for (final d in _data) {
      final x = chartRect.left + ((d.x - minX) / xRange) * chartRect.width;
      final y = chartRect.bottom - ((d.y - minY) / yRange) * chartRect.height;
      points.add(Offset(x, y));
      _pointPositions.add(Offset(x - offset.dx, y - offset.dy));
    }

    // Fill area
    if (_fillColor != null && points.length >= 2) {
      final fillPath = Path()
        ..moveTo(points.first.dx, chartRect.bottom)
        ..lineTo(points.first.dx, points.first.dy);
      for (final p in points.skip(1)) {
        fillPath.lineTo(p.dx, p.dy);
      }
      fillPath.lineTo(points.last.dx, chartRect.bottom);
      fillPath.close();
      canvas.drawPath(fillPath, Paint()..color = _fillColor!);
    }

    // Line
    if (points.length >= 2) {
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

    // Points
    if (_showPoints) {
      for (int i = 0; i < points.length; i++) {
        final isHovered = _hoveredIndex == i;
        canvas.drawCircle(
          points[i],
          isHovered ? _pointRadius + 2 : _pointRadius,
          Paint()..color = _lineColor,
        );
        canvas.drawCircle(
          points[i],
          isHovered ? _pointRadius : _pointRadius - 2,
          Paint()..color = const Color(0xFFFFFFFF),
        );
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;
    for (int i = 0; i < _pointPositions.length; i++) {
      if ((local - _pointPositions[i]).distance < _pointRadius + 10) {
        _onPointTap?.call(i);
        return;
      }
    }
  }

  void _handleHover(PointerHoverEvent event) {
    final local = event.localPosition;
    int? hovered;
    for (int i = 0; i < _pointPositions.length; i++) {
      if ((local - _pointPositions[i]).distance < _pointRadius + 10) {
        hovered = i;
        break;
      }
    }
    if (_hoveredIndex != hovered) {
      _hoveredIndex = hovered;
      markNeedsPaint();
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
    } else if (event is PointerHoverEvent) {
      _handleHover(event);
    }
  }
}

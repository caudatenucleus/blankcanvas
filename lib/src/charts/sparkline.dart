import 'package:flutter/widgets.dart';

import 'dart:math' as math;

/// A minimal sparkline chart using custom RenderObject.
class Sparkline extends LeafRenderObjectWidget {
  const Sparkline({
    super.key,
    required this.data,
    this.color = const Color(0xFF2196F3),
    this.strokeWidth = 2.0,
    this.fillColor,
    this.showDots = false,
    this.tag,
  });

  final List<double> data;
  final Color color;
  final double strokeWidth;
  final Color? fillColor;
  final bool showDots;
  final String? tag;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSparkline(
      data: data,
      color: color,
      strokeWidth: strokeWidth,
      fillColor: fillColor,
      showDots: showDots,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderSparkline renderObject) {
    renderObject
      ..data = data
      ..color = color
      ..strokeWidth = strokeWidth
      ..fillColor = fillColor
      ..showDots = showDots;
  }
}

class RenderSparkline extends RenderBox {
  RenderSparkline({
    required List<double> data,
    required Color color,
    required double strokeWidth,
    Color? fillColor,
    required bool showDots,
  }) : _data = data,
       _color = color,
       _strokeWidth = strokeWidth,
       _fillColor = fillColor,
       _showDots = showDots;

  List<double> _data;
  List<double> get data => _data;
  set data(List<double> v) {
    if (_data == v) return;
    _data = v;
    markNeedsPaint();
  }

  Color _color;
  Color get color => _color;
  set color(Color v) {
    if (_color == v) return;
    _color = v;
    markNeedsPaint();
  }

  double _strokeWidth;
  double get strokeWidth => _strokeWidth;
  set strokeWidth(double v) {
    if (_strokeWidth == v) return;
    _strokeWidth = v;
    markNeedsPaint();
  }

  Color? _fillColor;
  Color? get fillColor => _fillColor;
  set fillColor(Color? v) {
    if (_fillColor == v) return;
    _fillColor = v;
    markNeedsPaint();
  }

  bool _showDots;
  bool get showDots => _showDots;
  set showDots(bool v) {
    if (_showDots == v) return;
    _showDots = v;
    markNeedsPaint();
  }

  @override
  bool get sizedByParent => false;

  @override
  void performLayout() {
    size = constraints.biggest.isFinite
        ? constraints.biggest
        : const Size(100, 30);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_data.isEmpty) return;

    final canvas = context.canvas;
    final w = size.width;
    final h = size.height;

    final minVal = _data.reduce(math.min);
    final maxVal = _data.reduce(math.max);
    final range = maxVal - minVal;

    List<Offset> points = [];
    for (int i = 0; i < _data.length; i++) {
      final x = offset.dx + (i / (_data.length - 1)) * w;
      final y = range == 0
          ? offset.dy + h / 2
          : offset.dy + h - ((_data[i] - minVal) / range) * h;
      points.add(Offset(x, y));
    }

    // Draw fill
    if (_fillColor != null && points.length > 1) {
      final fillPath = Path()..moveTo(points.first.dx, offset.dy + h);
      for (final p in points) {
        fillPath.lineTo(p.dx, p.dy);
      }
      fillPath.lineTo(points.last.dx, offset.dy + h);
      fillPath.close();

      final fillPaint = Paint()
        ..color = _fillColor!
        ..style = PaintingStyle.fill;
      canvas.drawPath(fillPath, fillPaint);
    }

    // Draw line
    if (points.length > 1) {
      final linePath = Path()..moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        linePath.lineTo(points[i].dx, points[i].dy);
      }

      final linePaint = Paint()
        ..color = _color
        ..strokeWidth = _strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(linePath, linePaint);
    }

    // Draw dots
    if (_showDots) {
      final dotPaint = Paint()
        ..color = _color
        ..style = PaintingStyle.fill;
      for (final p in points) {
        canvas.drawCircle(p, _strokeWidth * 1.5, dotPaint);
      }
    }
  }
}

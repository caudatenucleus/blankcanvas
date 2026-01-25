import 'package:flutter/widgets.dart';

import 'dart:math' as math;

/// A gauge chart widget using custom RenderObject.
class GaugeChart extends LeafRenderObjectWidget {
  const GaugeChart({
    super.key,
    required this.value,
    this.min = 0.0,
    this.max = 100.0,
    this.size = 120.0,
    this.trackColor = const Color(0xFFE0E0E0),
    this.gaugeColor = const Color(0xFF2196F3),
    this.label,
    this.tag,
  });

  final double value;
  final double min;
  final double max;
  final double size;
  final Color trackColor;
  final Color gaugeColor;
  final String? label;
  final String? tag;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderGaugeChart(
      value: value,
      min: min,
      max: max,
      gaugeSize: size,
      trackColor: trackColor,
      gaugeColor: gaugeColor,
      label: label,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderGaugeChart renderObject) {
    renderObject
      ..value = value
      ..min = min
      ..max = max
      ..gaugeSize = size
      ..trackColor = trackColor
      ..gaugeColor = gaugeColor
      ..label = label;
  }
}

class RenderGaugeChart extends RenderBox {
  RenderGaugeChart({
    required double value,
    required double min,
    required double max,
    required double gaugeSize,
    required Color trackColor,
    required Color gaugeColor,
    String? label,
  }) : _value = value,
       _min = min,
       _max = max,
       _gaugeSize = gaugeSize,
       _trackColor = trackColor,
       _gaugeColor = gaugeColor,
       _label = label;

  double _value;
  double get value => _value;
  set value(double v) {
    if (_value == v) return;
    _value = v;
    markNeedsPaint();
  }

  double _min;
  double get min => _min;
  set min(double v) {
    if (_min == v) return;
    _min = v;
    markNeedsPaint();
  }

  double _max;
  double get max => _max;
  set max(double v) {
    if (_max == v) return;
    _max = v;
    markNeedsPaint();
  }

  double _gaugeSize;
  double get gaugeSize => _gaugeSize;
  set gaugeSize(double v) {
    if (_gaugeSize == v) return;
    _gaugeSize = v;
    markNeedsLayout();
  }

  Color _trackColor;
  Color get trackColor => _trackColor;
  set trackColor(Color v) {
    if (_trackColor == v) return;
    _trackColor = v;
    markNeedsPaint();
  }

  Color _gaugeColor;
  Color get gaugeColor => _gaugeColor;
  set gaugeColor(Color v) {
    if (_gaugeColor == v) return;
    _gaugeColor = v;
    markNeedsPaint();
  }

  String? _label;
  String? get label => _label;
  set label(String? v) {
    if (_label == v) return;
    _label = v;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    size = constraints.constrain(Size(_gaugeSize, _gaugeSize * 0.7));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final center = offset + Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 8;

    // Draw track
    final trackPaint = Paint()
      ..color = _trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      trackPaint,
    );

    // Draw progress
    final progress = ((_value - _min) / (_max - _min)).clamp(0.0, 1.0);
    final progressPaint = Paint()
      ..color = _gaugeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi * progress,
      false,
      progressPaint,
    );

    // Draw value text
    final valueText = _value.toStringAsFixed(0);
    final valuePainter = TextPainter(
      text: TextSpan(
        text: valueText,
        style: TextStyle(
          color: const Color(0xFF333333),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    valuePainter.paint(
      canvas,
      center - Offset(valuePainter.width / 2, valuePainter.height + 8),
    );

    // Draw label
    if (_label != null) {
      final labelPainter = TextPainter(
        text: TextSpan(
          text: _label!,
          style: TextStyle(color: const Color(0xFF999999), fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      labelPainter.paint(canvas, center - Offset(labelPainter.width / 2, -4));
    }
  }
}

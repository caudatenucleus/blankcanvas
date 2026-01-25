import 'package:flutter/widgets.dart';
import 'dart:math' as math;

/// A speedometer chart widget.
class SpeedometerChart extends LeafRenderObjectWidget {
  const SpeedometerChart({
    super.key,
    required this.value,
    this.minValue = 0,
    this.maxValue = 100,
    this.unit = '',
    this.label,
    this.zones = const [],
    this.tag,
  });

  final double value;
  final double minValue;
  final double maxValue;
  final String unit;
  final String? label;
  final List<SpeedometerZone> zones;
  final String? tag;

  @override
  RenderSpeedometerChart createRenderObject(BuildContext context) {
    return RenderSpeedometerChart(
      value: value,
      minValue: minValue,
      maxValue: maxValue,
      unit: unit,
      label: label,
      zones: zones,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSpeedometerChart renderObject,
  ) {
    renderObject
      ..value = value
      ..minValue = minValue
      ..maxValue = maxValue
      ..unit = unit
      ..label = label
      ..zones = zones;
  }
}

class SpeedometerZone {
  const SpeedometerZone({
    required this.start,
    required this.end,
    required this.color,
  });
  final double start;
  final double end;
  final Color color;
}

class RenderSpeedometerChart extends RenderBox {
  RenderSpeedometerChart({
    required double value,
    required double minValue,
    required double maxValue,
    required String unit,
    String? label,
    required List<SpeedometerZone> zones,
  }) : _value = value,
       _minValue = minValue,
       _maxValue = maxValue,
       _unit = unit,
       _label = label,
       _zones = zones;

  double _value;
  set value(double val) {
    _value = val;
    markNeedsPaint();
  }

  double _minValue;
  set minValue(double val) {
    _minValue = val;
    markNeedsPaint();
  }

  double _maxValue;
  set maxValue(double val) {
    _maxValue = val;
    markNeedsPaint();
  }

  String _unit;
  set unit(String val) {
    _unit = val;
    markNeedsPaint();
  }

  String? _label;
  set label(String? val) {
    _label = val;
    markNeedsPaint();
  }

  List<SpeedometerZone> _zones;
  set zones(List<SpeedometerZone> val) {
    _zones = val;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    final double dim = math.min(
      constraints.maxWidth,
      constraints.maxHeight.clamp(150, 300),
    );
    size = constraints.constrain(Size(dim, dim * 0.7));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final center = offset + Offset(size.width / 2, size.height - 20);
    final radius = size.width / 2 - 20;
    const startAngle = math.pi;
    const sweepAngle = math.pi;

    // Background arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = const Color(0xFFEEEEEE)
        ..strokeWidth = 20
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Zones
    for (final zone in _zones) {
      final zoneStart =
          startAngle +
          (zone.start - _minValue) / (_maxValue - _minValue) * sweepAngle;
      final zoneSweep =
          (zone.end - zone.start) / (_maxValue - _minValue) * sweepAngle;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        zoneStart,
        zoneSweep,
        false,
        Paint()
          ..color = zone.color
          ..strokeWidth = 20
          ..style = PaintingStyle.stroke,
      );
    }

    // Tick marks
    for (int i = 0; i <= 10; i++) {
      final tickAngle = startAngle + sweepAngle * i / 10;
      final inner =
          center +
          Offset(
            math.cos(tickAngle) * (radius - 25),
            math.sin(tickAngle) * (radius - 25),
          );
      final outer =
          center +
          Offset(
            math.cos(tickAngle) * (radius - 10),
            math.sin(tickAngle) * (radius - 10),
          );
      canvas.drawLine(
        inner,
        outer,
        Paint()
          ..color = const Color(0xFF666666)
          ..strokeWidth = 2,
      );

      // Tick labels
      final tickValue = _minValue + (_maxValue - _minValue) * i / 10;
      textPainter.text = TextSpan(
        text: tickValue.toStringAsFixed(0),
        style: const TextStyle(fontSize: 9, color: Color(0xFF666666)),
      );
      textPainter.layout();
      final labelPos =
          center +
          Offset(
            math.cos(tickAngle) * (radius - 40),
            math.sin(tickAngle) * (radius - 40),
          );
      textPainter.paint(
        canvas,
        labelPos - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    // Needle
    final normalizedValue =
        (_value.clamp(_minValue, _maxValue) - _minValue) /
        (_maxValue - _minValue);
    final needleAngle = startAngle + normalizedValue * sweepAngle;
    final needleLength = radius - 30;

    final needlePath = Path()
      ..moveTo(
        center.dx + math.cos(needleAngle) * needleLength,
        center.dy + math.sin(needleAngle) * needleLength,
      )
      ..lineTo(
        center.dx + math.cos(needleAngle + math.pi / 2) * 4,
        center.dy + math.sin(needleAngle + math.pi / 2) * 4,
      )
      ..lineTo(
        center.dx + math.cos(needleAngle - math.pi / 2) * 4,
        center.dy + math.sin(needleAngle - math.pi / 2) * 4,
      )
      ..close();
    canvas.drawPath(needlePath, Paint()..color = const Color(0xFFE53935));

    // Center cap
    canvas.drawCircle(center, 10, Paint()..color = const Color(0xFF333333));
    canvas.drawCircle(center, 6, Paint()..color = const Color(0xFF666666));

    // Value display
    textPainter.text = TextSpan(
      text: '${_value.toStringAsFixed(1)}$_unit',
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF333333),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - 50),
    );

    // Label
    if (_label != null) {
      textPainter.text = TextSpan(
        text: _label,
        style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(center.dx - textPainter.width / 2, center.dy - 75),
      );
    }
  }
}

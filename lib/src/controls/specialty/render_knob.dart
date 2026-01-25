// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'dart:math' as math;


class RenderKnob extends RenderBox {
  RenderKnob({
    required double value,
    required ValueChanged<double> onChanged,
    required double min,
    required double max,
    required double size,
    required Color color,
    required Color trackColor,
  }) : _value = value,
       _onChanged = onChanged,
       _min = min,
       _max = max,
       _size = size,
       _color = color,
       _trackColor = trackColor;

  double _value;
  double get value => _value;
  set value(double v) {
    if (_value == v) return;
    _value = v;
    markNeedsPaint();
  }

  ValueChanged<double> _onChanged;
  set onChanged(ValueChanged<double> v) => _onChanged = v;

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

  double _size;
  double get knobSize => _size;
  set knobSize(double v) {
    if (_size == v) return;
    _size = v;
    markNeedsLayout();
  }

  Color _color;
  Color get color => _color;
  set color(Color v) {
    if (_color == v) return;
    _color = v;
    markNeedsPaint();
  }

  Color _trackColor;
  Color get trackColor => _trackColor;
  set trackColor(Color v) {
    if (_trackColor == v) return;
    _trackColor = v;
    markNeedsPaint();
  }

  @override
  bool get sizedByParent => false;

  @override
  bool hitTestSelf(Offset position) => true;

  Offset? _dragStart;
  double? _dragStartValue;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _dragStart = event.localPosition;
      _dragStartValue = _value;
    } else if (event is PointerMoveEvent && _dragStart != null) {
      final delta = _dragStart!.dy - event.localPosition.dy;
      final range = _max - _min;
      final newValue = (_dragStartValue! + delta / 100 * range).clamp(
        _min,
        _max,
      );
      _onChanged(newValue);
    } else if (event is PointerUpEvent) {
      _dragStart = null;
      _dragStartValue = null;
    }
  }

  @override
  void performLayout() {
    size = constraints.constrain(Size(_size, _size));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final center = offset + Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 4;

    // Draw track
    final trackPaint = Paint()
      ..color = _trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.75,
      math.pi * 1.5,
      false,
      trackPaint,
    );

    // Draw progress
    final progressPaint = Paint()
      ..color = _color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final progress = (_value - _min) / (_max - _min);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.75,
      math.pi * 1.5 * progress,
      false,
      progressPaint,
    );

    // Draw center circle
    final centerPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 8, centerPaint);

    // Draw indicator
    final angle = math.pi * 0.75 + math.pi * 1.5 * progress;
    final indicatorRadius = radius - 12;
    final indicatorX = center.dx + indicatorRadius * math.cos(angle);
    final indicatorY = center.dy + indicatorRadius * math.sin(angle);

    final indicatorPaint = Paint()
      ..color = _color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(indicatorX, indicatorY), 6, indicatorPaint);

    // Draw value text
    final textPainter = TextPainter(
      text: TextSpan(
        text: _value.toStringAsFixed(0),
        style: TextStyle(
          color: const Color(0xFF333333),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }
}

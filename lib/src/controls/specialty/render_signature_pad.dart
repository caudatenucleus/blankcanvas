// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'dart:ui' as ui;


class RenderSignaturePad extends RenderBox {
  RenderSignaturePad({
    required Color strokeColor,
    required double strokeWidth,
    required Color backgroundColor,
    ValueChanged<List<List<Offset>>>? onSignatureChanged,
  }) : _strokeColor = strokeColor,
       _strokeWidth = strokeWidth,
       _backgroundColor = backgroundColor,
       _onSignatureChanged = onSignatureChanged {
    _pan = PanGestureRecognizer()
      ..onStart = _handlePanStart
      ..onUpdate = _handlePanUpdate
      ..onEnd = _handlePanEnd;
  }

  Color _strokeColor;
  set strokeColor(Color value) {
    if (_strokeColor != value) {
      _strokeColor = value;
      markNeedsPaint();
    }
  }

  double _strokeWidth;
  set strokeWidth(double value) {
    if (_strokeWidth != value) {
      _strokeWidth = value;
      markNeedsPaint();
    }
  }

  Color _backgroundColor;
  set backgroundColor(Color value) {
    if (_backgroundColor != value) {
      _backgroundColor = value;
      markNeedsPaint();
    }
  }

  ValueChanged<List<List<Offset>>>? _onSignatureChanged;
  set onSignatureChanged(ValueChanged<List<List<Offset>>>? value) {
    _onSignatureChanged = value;
  }

  late PanGestureRecognizer _pan;
  final List<List<Offset>> _strokes = [];
  List<Offset>? _currentStroke;

  bool get isEmpty => _strokes.isEmpty;

  void clear() {
    _strokes.clear();
    _currentStroke = null;
    markNeedsPaint();
    _onSignatureChanged?.call(_strokes);
  }

  Future<ui.Image?> toImage({int width = 300, int height = 150}) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      Paint()..color = _backgroundColor,
    );

    final paint = Paint()
      ..color = _strokeColor
      ..strokeWidth = _strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final stroke in _strokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }

    return recorder.endRecording().toImage(width, height);
  }

  @override
  void detach() {
    _pan.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    size = constraints.constrain(
      Size(constraints.maxWidth, constraints.maxHeight),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final rect = offset & size;

    // Background
    canvas.drawRect(rect, Paint()..color = _backgroundColor);

    // Strokes
    final paint = Paint()
      ..color = _strokeColor
      ..strokeWidth = _strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final stroke in _strokes) {
      if (stroke.length < 2) continue;
      final path = Path()
        ..moveTo(offset.dx + stroke.first.dx, offset.dy + stroke.first.dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(offset.dx + stroke[i].dx, offset.dy + stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }

    // Current stroke
    if (_currentStroke != null && _currentStroke!.length >= 2) {
      final path = Path()
        ..moveTo(
          offset.dx + _currentStroke!.first.dx,
          offset.dy + _currentStroke!.first.dy,
        );
      for (int i = 1; i < _currentStroke!.length; i++) {
        path.lineTo(
          offset.dx + _currentStroke![i].dx,
          offset.dy + _currentStroke![i].dy,
        );
      }
      canvas.drawPath(path, paint);
    }
  }

  void _handlePanStart(DragStartDetails details) {
    _currentStroke = [details.localPosition];
    markNeedsPaint();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_currentStroke != null) {
      _currentStroke!.add(details.localPosition);
      markNeedsPaint();
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_currentStroke != null && _currentStroke!.isNotEmpty) {
      _strokes.add(List.from(_currentStroke!));
      _currentStroke = null;
      _onSignatureChanged?.call(_strokes);
      markNeedsPaint();
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _pan.addPointer(event);
    }
  }
}

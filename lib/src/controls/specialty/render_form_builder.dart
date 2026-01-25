// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'form_schema.dart';

class RenderFormBuilder extends RenderBox {
  RenderFormBuilder({
    required FormSchema schema,
    required void Function(Map<String, dynamic> values) onSubmit,
  }) : _schema = schema,
       _onSubmit = onSubmit {
    _initValues();
  }

  FormSchema _schema;
  set schema(FormSchema value) {
    if (_schema == value) return;
    _schema = value;
    _initValues();
    markNeedsLayout();
    markNeedsPaint();
  }

  void Function(Map<String, dynamic> values) _onSubmit;
  set onSubmit(void Function(Map<String, dynamic> values) value) {
    _onSubmit = value;
  }

  final Map<String, dynamic> _values = {};
  final Map<String, String?> _errors = {};

  void _initValues() {
    _values.clear();
    for (final field in _schema.fields) {
      _values[field.name] = field.defaultValue;
    }
  }

  @override
  void performLayout() {
    final fieldHeight = 60.0;
    final buttonHeight = 40.0;
    final totalHeight = _schema.fields.length * fieldHeight + buttonHeight + 24;
    size = constraints.constrain(Size(constraints.maxWidth, totalHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    double y = 0;

    for (final field in _schema.fields) {
      // Label
      textPainter.text = TextSpan(
        text: field.label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Color(0xFF000000),
        ),
      );
      textPainter.layout(maxWidth: size.width);
      textPainter.paint(canvas, offset + Offset(0, y));
      y += 20;

      // Input field placeholder
      final inputRect = Rect.fromLTWH(offset.dx, offset.dy + y, size.width, 36);
      canvas.drawRRect(
        RRect.fromRectAndRadius(inputRect, const Radius.circular(4)),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0xFFE0E0E0),
      );

      // Error painting logic
      final error = _errors[field.name];
      if (error != null) {
        // ...
      }

      y += 60;
    }

    // Submit button
    final buttonRect = Rect.fromLTWH(offset.dx, offset.dy + y, 100, 36);
    canvas.drawRRect(
      RRect.fromRectAndRadius(buttonRect, const Radius.circular(4)),
      Paint()..color = const Color(0xFF2196F3),
    );
    // Button Text
    textPainter.text = TextSpan(
      text: _schema.submitLabel ?? 'Submit',
      style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 14),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        buttonRect.center.dx - textPainter.width / 2,
        buttonRect.center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool hitTestSelf(Offset position) => true;

  // Handling pointer events to detect taps on button
  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerUpEvent) {
      // Check if button tapped (simplified)
      final localPos = event.localPosition;
      final buttonY = _schema.fields.length * 80.0; // Approximation
      if (localPos.dy >= buttonY) {
        _onSubmit(_values);
      }
    }
  }
}

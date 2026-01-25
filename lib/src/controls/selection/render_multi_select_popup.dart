// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;


class RenderMultiSelectPopup<T> extends RenderBox {
  RenderMultiSelectPopup({
    required List<T> options,
    required List<T> selectedValues,
    required String Function(T) labelBuilder,
    required ValueChanged<T> onSelect,
  }) : _options = options,
       _selectedValues = selectedValues,
       _labelBuilder = labelBuilder,
       _onSelect = onSelect {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  List<T> _options;
  set options(List<T> val) {
    if (_options != val) {
      _options = val;
      markNeedsLayout();
    }
  }

  List<T> _selectedValues;
  set selectedValues(List<T> val) {
    if (_selectedValues != val) {
      _selectedValues = val;
      markNeedsPaint();
    }
  }

  String Function(T) _labelBuilder;
  set labelBuilder(String Function(T) val) {
    _labelBuilder = val;
    markNeedsLayout();
  }

  ValueChanged<T> _onSelect;
  set onSelect(ValueChanged<T> val) => _onSelect = val;

  late TapGestureRecognizer _tap;

  @override
  void performLayout() {
    double h = 0;
    for (var _ in _options) {
      h += 36;
    }
    size = Size(constraints.maxWidth, math.max(h, 40));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Paint bg = Paint()..color = const Color(0xFFFFFFFF);
    final Rect rect = offset & size;
    context.canvas.drawRect(rect, bg);
    context.canvas.drawShadow(
      Path()..addRect(rect),
      const Color(0x33000000),
      4,
      true,
    );

    double y = 0;
    for (var item in _options) {
      final bool isSelected = _selectedValues.contains(item);
      final itemRect = Offset(offset.dx, offset.dy + y) & Size(size.width, 36);

      if (isSelected) {
        context.canvas.drawRect(
          itemRect,
          Paint()..color = const Color(0xFFE3F2FD),
        );
      }

      final textPainter = TextPainter(
        text: TextSpan(
          text: _labelBuilder(item),
          style: const TextStyle(fontSize: 14, color: Color(0xFF000000)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      // Checkbox
      final checkboxRect = Rect.fromLTWH(
        offset.dx + 12,
        offset.dy + y + 10,
        16,
        16,
      );
      final Paint boxPaint = Paint()
        ..color = isSelected ? const Color(0xFF2196F3) : const Color(0xFFBDBDBD)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      context.canvas.drawRect(checkboxRect, boxPaint);
      if (isSelected) {
        context.canvas.drawRect(
          checkboxRect,
          Paint()..color = const Color(0xFF2196F3),
        );
        // check mark
        final checkPath = Path();
        checkPath.moveTo(checkboxRect.left + 4, checkboxRect.top + 8);
        checkPath.lineTo(checkboxRect.left + 6, checkboxRect.top + 12);
        checkPath.lineTo(checkboxRect.left + 12, checkboxRect.top + 5);
        context.canvas.drawPath(
          checkPath,
          Paint()
            ..color = const Color(0xFFFFFFFF)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }

      // Paint text shifted
      textPainter.paint(
        context.canvas,
        Offset(offset.dx + 36, offset.dy + y + (36 - textPainter.height) / 2),
      );

      y += 36;
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final dy = details.localPosition.dy;
    final index = (dy / 36).floor();
    if (index >= 0 && index < _options.length) {
      _onSelect(_options[index]);
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
    }
  }

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }
}
